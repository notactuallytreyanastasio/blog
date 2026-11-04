defmodule Blog.Memory.Distiller do
  @moduledoc """
  Turns one chat exchange into the topic nodes that make the memory graph
  worth querying.

  The deterministic half of `Blog.Memory` records exactly what was said. This
  is the lossy half: a cheap model reads the exchange and names the two to four
  subjects it was actually about, so recall can answer "what have we concluded
  about repair?" rather than only matching literal words.

  Runs detached from the chat turn — the visitor never waits on it, and a
  failure here costs a topic, not an answer.
  """

  require Logger

  @prompt """
  You label what a conversation exchange was ABOUT, for a memory index.

  Reply with ONLY a JSON object: {"topics": ["...", "..."]}

  Rules:
  - 2 to 4 topics, each 1-4 words, lowercase unless a proper noun.
  - Name the SUBJECT, not the act of asking. "choice boards", "prompt fading",
    "repair after rupture" — never "user question" or "explanation".
  - Prefer terms someone would search for months later.
  - Reuse obvious canonical wording so the same subject collapses to one topic
    across conversations: "co-regulation", not "co regulating your child".
  - If the exchange is chit-chat or an error, reply {"topics": []}.
  """

  @doc """
  Distil an exchange and attach the topics, in a detached task.

  Always returns `:ok` immediately.
  """
  def distill_async(graph, visitor_id, node_ids, question, answer) do
    Task.Supervisor.start_child(Blog.TaskSupervisor, fn ->
      distill(graph, visitor_id, node_ids, question, answer)
    end)

    :ok
  rescue
    # no supervisor (tests, or a boot-order surprise) must not break the chat
    _ -> :ok
  end

  @doc "Synchronous version — used by tests and by distill_async/5."
  def distill(graph, visitor_id, node_ids, question, answer) do
    case topics_for(question, answer) do
      {:ok, []} ->
        :ok

      {:ok, topics} ->
        Blog.Memory.attach_topics(graph, visitor_id, node_ids, topics)

      {:error, reason} ->
        Logger.debug("memory distillation skipped: #{inspect(reason)}")
        :ok
    end
  end

  @doc "Ask the model what an exchange was about. {:ok, [topic]} | {:error, reason}"
  def topics_for(question, answer) do
    with {:ok, api_key} <- fetch_api_key() do
      model =
        Application.get_env(:blog, :openai_memory_model) ||
          Application.get_env(:blog, :openai_autocomplete_model, "gpt-5.4-nano")

      body = %{
        "model" => model,
        "messages" => [
          %{"role" => "system", "content" => @prompt},
          %{
            "role" => "user",
            "content" => "Q: #{truncate(question, 1500)}\n\nA: #{truncate(answer, 3000)}"
          }
        ],
        "response_format" => %{"type" => "json_object"},
        "max_completion_tokens" => 120
      }

      case Req.post("https://api.openai.com/v1/chat/completions",
             headers: [{"authorization", "Bearer #{api_key}"}],
             json: body,
             receive_timeout: 15_000
           ) do
        {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}} | _]}}} ->
          parse(content)

        {:ok, %{status: status}} ->
          {:error, "status #{status}"}

        {:error, reason} ->
          {:error, inspect(reason)}
      end
    end
  end

  defp parse(content) do
    case Jason.decode(content || "") do
      {:ok, %{"topics" => topics}} when is_list(topics) ->
        {:ok, topics |> Enum.filter(&is_binary/1) |> Enum.take(4)}

      {:ok, _other} ->
        {:ok, []}

      {:error, _} ->
        {:error, "unparseable topics"}
    end
  end

  defp fetch_api_key do
    case Application.get_env(:blog, :openai_api_key) do
      key when is_binary(key) and key != "" -> {:ok, key}
      _ -> {:error, "OPENAI_API_KEY is not configured"}
    end
  end

  defp truncate(nil, _n), do: ""
  defp truncate(text, n) when byte_size(text) <= n, do: text
  defp truncate(text, n), do: String.slice(text, 0, n)
end
