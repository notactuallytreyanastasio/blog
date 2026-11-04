defmodule Blog.LLM do
  @moduledoc """
  One model client, so that a page talking to a model does not have to
  hand-roll `Req.post`, its own error tuples and its own idea of failure.

  This is `Marginalia.LLM` brought back to the repo it was extracted from.
  Its moduledoc names the mistake it exists to avoid: this blog had three
  modules (`Blog.Lolly.OpenAI`, `Blog.Rooted.OpenAI`, `Blog.Ziggy.OpenAI`)
  each posting to the same endpoint with their own retry and error handling.
  Those three are untouched here; the Doctor Who chat is the first caller of
  this module and the others can move when someone has a reason to.

  Two things it is opinionated about:

  * `finish_reason: "length"` is a **failure**, not a success. A truncated
    answer parses as a plausible-but-short reply, and treating it as success
    is how silently-wrong output gets stored.
  * `{:error, :invalid_json}` is distinct from `{:error, :rate_limited}`, so a
    malformed reply is not retried as if it were congestion.
  """

  require Logger

  @max_attempts 3

  # Reasoning over a long tool transcript is slow; a timeout here throws away
  # work that was going to succeed.
  @default_timeout 300_000

  # DeepSeek speaks the OpenAI chat-completions dialect, but not identically:
  # different host, different model names, and it wants `max_tokens` where
  # OpenAI now wants `max_completion_tokens`. Provider is therefore config,
  # not a hardcoded URL, so switching is one env var (`LLM_PROVIDER`).
  #
  # `deepseek-chat` is NOT merely an alias for `deepseek-flash`: it selects the
  # same model with thinking OFF, while the bare id turns reasoning ON.
  #
  # `max_tokens` covers reasoning *and* content, and DeepSeek spends the
  # reasoning first, so `reasoning_headroom` is added to whatever the caller
  # asks for: callers keep saying how much *answer* they want, and thinking
  # never eats it. Measured in marginalia: a real section cost ~10k reasoning
  # tokens against a caller asking for 1,400, and every call came back
  # `finish_reason: "length"` until the headroom existed.
  @providers %{
    deepseek: %{
      label: "DeepSeek Flash",
      endpoint: "https://api.deepseek.com/chat/completions",
      key: :deepseek_api_key,
      model: "deepseek-flash",
      fast_model: "deepseek-chat",
      max_tokens_field: "max_tokens",
      default_body: %{"reasoning_effort" => "low"},
      reasoning_headroom: 24_000
    },
    openai: %{
      label: "OpenAI",
      endpoint: "https://api.openai.com/v1/chat/completions",
      key: :openai_api_key,
      model: "gpt-5.1",
      fast_model: "gpt-5.4-nano",
      max_tokens_field: "max_completion_tokens",
      default_body: %{},
      reasoning_headroom: 24_000
    }
  }

  @type result :: {:ok, map()} | {:error, term()}

  @doc """
  A single chat completion. Returns the assistant `message` map on success.

  Options: `:provider`, `:model`, `:messages`, `:tools`, `:tool_choice`,
  `:temperature`, `:effort`, `:json` (force a JSON object reply),
  `:max_tokens`, `:timeout`.
  """
  @spec chat(keyword()) :: result()
  def chat(opts) do
    prov = resolve(opts[:provider])

    with {:ok, key} <- api_key(prov) do
      body =
        prov.default_body
        |> Map.merge(%{
          "model" => opts[:model] || model_for(prov),
          "messages" => Keyword.fetch!(opts, :messages)
        })
        |> put_effort(opts[:effort])
        |> maybe_put("tools", opts[:tools])
        |> maybe_put("tool_choice", opts[:tool_choice] || if(opts[:tools], do: "auto"))
        |> maybe_put("temperature", opts[:temperature])
        |> maybe_put(prov.max_tokens_field, budget(prov, opts[:max_tokens]))
        |> maybe_put("response_format", if(opts[:json], do: %{"type" => "json_object"}))

      request(body, prov, key, opts[:timeout] || @default_timeout, 1)
    end
  end

  @doc """
  A chat completion whose reply must be a JSON object, decoded for you.

  Returns `{:error, :invalid_json}` rather than a half-parsed map, so callers
  can decide between retrying and discarding.
  """
  @spec json(keyword()) :: result()
  def json(opts) do
    with {:ok, %{"content" => content}} <- chat(Keyword.put(opts, :json, true)) do
      case Jason.decode(content || "") do
        {:ok, decoded} when is_map(decoded) -> {:ok, decoded}
        _ -> {:error, :invalid_json}
      end
    end
  end

  # DeepSeek prices a cached prefix token at a fraction of a fresh one, so
  # knowing the hit rate is the difference between guessing at the bill and
  # reading it.
  defp report_usage(%{"usage" => usage}, prov) when is_map(usage) do
    hit = usage["prompt_cache_hit_tokens"] || 0
    miss = usage["prompt_cache_miss_tokens"] || 0
    prompt = usage["prompt_tokens"] || hit + miss
    completion = usage["completion_tokens"] || 0
    reasoning = get_in(usage, ["completion_tokens_details", "reasoning_tokens"]) || 0

    if prompt > 0 do
      Logger.info(
        "blog llm: prompt=#{prompt} cached=#{hit} (#{round(hit / prompt * 100)}%) " <>
          "completion=#{completion} reasoning=#{reasoning}"
      )
    end

    :telemetry.execute(
      [:blog, :llm, :usage],
      %{prompt: prompt, cached: hit, completion: completion, reasoning: reasoning},
      %{provider: prov.label}
    )

    :ok
  end

  defp report_usage(_body, _prov), do: :ok

  defp request(body, prov, key, timeout, attempt) do
    options =
      [
        headers: [{"authorization", "Bearer #{key}"}],
        json: body,
        receive_timeout: timeout
      ] ++ Application.get_env(:blog, :llm_req_options, [])

    case Req.post(endpoint(prov), options) do
      {:ok, %{status: 200, body: %{"choices" => [choice | _]} = resp}} ->
        report_usage(resp, prov)
        interpret(choice)

      {:ok, %{status: status}} when status in [429, 500, 502, 503, 504] ->
        retry_or_fail({:error, :rate_limited}, body, prov, key, timeout, attempt)

      {:ok, %{status: status, body: resp}} ->
        {:error, {:http, status, inspect(resp) |> String.slice(0, 300)}}

      {:error, reason} ->
        retry_or_fail({:error, {:transport, inspect(reason)}}, body, prov, key, timeout, attempt)
    end
  end

  # A truncated completion is a failure. Retrying it unchanged would truncate
  # again, so this one does not retry: the caller has to ask for less.
  defp interpret(%{"finish_reason" => "length"}), do: {:error, :truncated}
  defp interpret(%{"message" => message}), do: {:ok, message}
  defp interpret(other), do: {:error, {:unexpected, inspect(other) |> String.slice(0, 200)}}

  defp retry_or_fail(error, _body, _prov, _key, _timeout, attempt)
       when attempt >= @max_attempts,
       do: error

  defp retry_or_fail(_error, body, prov, key, timeout, attempt) do
    # Jittered backoff: 0.5s, 1.5s, with noise so concurrent calls do not all
    # come back at the same instant. Zero in test, where the endpoint is a
    # closed port: every call would otherwise spend seconds backing off from
    # a refusal that is never going to stop refusing.
    sleep = trunc(:math.pow(2, attempt) * Application.get_env(:blog, :llm_backoff_ms, 250))
    if sleep > 0, do: Process.sleep(sleep + :rand.uniform(400))
    request(body, prov, key, timeout, attempt + 1)
  end

  # Reasoning tokens are billed as output and are never cached, so effort is
  # the dial that changes the bill most. Set per call, not per deploy.
  defp put_effort(body, nil), do: body

  defp put_effort(body, effort) when effort in [:low, :high, :none, "low", "high", "none"],
    do: Map.put(body, "reasoning_effort", to_string(effort))

  defp put_effort(body, _other), do: body

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)

  # The caller's number is how much answer it wants; the headroom is what the
  # model needs to think first. Keeping them separate is what lets
  # `:truncated` still mean "the answer was cut off" rather than "it thought
  # too hard".
  defp budget(_prov, nil), do: nil
  defp budget(prov, asked), do: asked + Map.get(prov, :reasoning_headroom, 0)

  @doc "Which provider is active: :deepseek or :openai."
  def provider_name do
    case Application.get_env(:blog, :llm_provider, "deepseek") do
      "openai" -> :openai
      :openai -> :openai
      _ -> :deepseek
    end
  end

  defp provider, do: Map.fetch!(@providers, provider_name())

  @doc "Provider names this deploy knows how to talk to."
  def available, do: Map.keys(@providers)

  @doc "The human name for a provider, for anything a person reads."
  def label(provider \\ nil), do: resolve(provider).label

  @doc "The model used for the big reasoning calls (chat with tools)."
  def default_model(provider \\ nil),
    do: Application.get_env(:blog, :llm_model) || resolve(provider).model

  @doc "The cheap model for the many small calls."
  def fast_model(provider \\ nil),
    do: Application.get_env(:blog, :llm_fast_model) || resolve(provider).fast_model

  defp model_for(prov), do: Application.get_env(:blog, :llm_model) || prov.model

  @doc "Whether a key is configured for the given (or default) provider."
  def configured?(provider \\ nil), do: match?({:ok, _}, api_key(resolve(provider)))

  @doc """
  Where a provider's calls go.

  Overridable so the test environment can point at an address that goes
  nowhere. A suite that reaches a third-party API is slow, flaky and, if the
  machine happens to have a real key, billable.
  """
  def endpoint(prov) do
    Application.get_env(:blog, :llm_endpoints, %{})
    |> Map.get(prov.key, prov.endpoint)
  end

  # An unknown or nil override falls back to the deploy default rather than
  # erroring.
  defp resolve(nil), do: provider()
  defp resolve(name) when is_binary(name), do: resolve(safe_atom(name))
  defp resolve(name) when is_atom(name), do: Map.get(@providers, name, provider())

  defp safe_atom("openai"), do: :openai
  defp safe_atom("deepseek"), do: :deepseek
  defp safe_atom(_), do: nil

  defp api_key(prov) do
    case Application.get_env(:blog, prov.key) do
      key when is_binary(key) and key != "" -> {:ok, key}
      _ -> {:error, :no_api_key}
    end
  end
end
