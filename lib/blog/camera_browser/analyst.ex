defmodule Blog.CameraBrowser.Analyst do
  @moduledoc """
  Asks a mid-tier OpenAI model for a collector's read on each listing: a
  one-line take, a rarity score, whether the price is a steal, commentary,
  fun features and a couple of unique facts. Runs over every listing that has
  its post body and no analysis yet, so the backfill and the "incoming" case
  are the same code path, called at the end of each sweep.

  Structured outputs (`json_schema`, strict) so the shape is guaranteed; the
  result is stored on the listing as a plain map.
  """

  require Logger
  import Ecto.Query

  alias Blog.CameraBrowser.Listing
  alias Blog.Repo

  @endpoint "https://api.openai.com/v1/chat/completions"
  @default_model "gpt-5.4-mini"
  @concurrency 4
  @max_body 3000

  @schema %{
    "type" => "object",
    "additionalProperties" => false,
    "properties" => %{
      "quick_take" => %{"type" => "string", "description" => "One sentence: what this is and whether it's worth a look."},
      "rarity" => %{"type" => "integer", "description" => "1 = common, 5 = genuinely rare or collectible."},
      "price_take" => %{"type" => "string", "enum" => ["steal", "fair", "high", "unclear"]},
      "price_note" => %{"type" => "string", "description" => "Typical going rate and why this asking price lands where it does, briefly."},
      "commentary" => %{"type" => "string", "description" => "2-4 sentences: condition signals, red flags, what to ask the seller."},
      "fun_features" => %{"type" => "array", "items" => %{"type" => "string"}},
      "facts" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Unique or surprising facts about this model."}
    },
    "required" => ["quick_take", "rarity", "price_take", "price_note", "commentary", "fun_features", "facts"]
  }

  @system """
  You are a seasoned film camera dealer and collector writing quick, honest notes for a friend
  browsing Craigslist. Be specific to the exact model when you can identify it. Judge price against
  the current used market for working examples. Flag digital cameras, lenses-only or accessory-only
  posts plainly. Keep every field short and concrete. Never invent condition details the seller
  didn't state.
  """

  @spec configured?() :: boolean()
  def configured?, do: Application.get_env(:blog, :camera_analyst) != nil

  @spec model() :: String.t()
  def model, do: cfg(:model) || @default_model

  defp cfg(key), do: Application.get_env(:blog, :camera_analyst, []) |> Keyword.get(key)

  # ---------------------------------------------------------------------------
  # Running it
  # ---------------------------------------------------------------------------

  @doc "Analyze every open listing with a fetched body and no analysis, up to `cap`. Returns the count done."
  @spec analyze_missing(pos_integer()) :: non_neg_integer()
  def analyze_missing(cap \\ 200) do
    if configured?() do
      Listing
      |> where([l], is_nil(l.analyzed_at) and not is_nil(l.detail_fetched_at) and is_nil(l.closed_at))
      # never-tried first, then retries of earlier failures
      |> order_by([l], asc: fragment("? IS NOT NULL", l.analysis_error), desc: l.score, desc: l.id)
      |> limit(^cap)
      |> Repo.all()
      |> Task.async_stream(&analyze/1, max_concurrency: @concurrency, timeout: 120_000, on_timeout: :kill_task)
      |> Enum.count(&match?({:ok, {:ok, _}}, &1))
    else
      0
    end
  end

  @doc "Analyze one listing and store the result (or the error)."
  @spec analyze(Listing.t()) :: {:ok, Listing.t()} | {:error, term()}
  def analyze(%Listing{} = listing) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case request(prompt(listing)) do
      {:ok, analysis} ->
        {:ok, listing |> Listing.changeset(%{analysis: analysis, analyzed_at: now, analysis_error: nil}) |> Repo.update!()}

      {:error, reason} ->
        msg = reason |> inspect() |> String.slice(0, 250)
        Logger.warning("camera analyst: #{listing.posting_id} failed: #{msg}")
        listing |> Listing.changeset(%{analysis_error: msg}) |> Repo.update!()
        {:error, reason}
    end
  end

  @doc false
  def prompt(l) do
    price = if l.price_cents, do: "$#{div(l.price_cents, 100)}", else: "not listed"
    attrs = l.attrs |> Enum.map(fn {k, v} -> "#{k}: #{v}" end) |> Enum.join("; ")
    body = (l.body || "") |> String.slice(0, @max_body)

    """
    Craigslist post (#{Listing.city(l)}#{if l.neighborhood, do: ", " <> l.neighborhood}):

    Title: #{l.title}
    Asking: #{price}
    Seller attributes: #{if attrs == "", do: "none", else: attrs}
    Photos: #{length(l.image_ids || [])}
    Posted: #{l.posted_at && Calendar.strftime(l.posted_at, "%b %-d, %Y")}

    Body:
    #{body}
    """
  end

  @doc false
  def request(user_prompt) do
    body = %{
      "model" => model(),
      "messages" => [
        %{"role" => "system", "content" => String.trim(@system)},
        %{"role" => "user", "content" => user_prompt}
      ],
      "response_format" => %{
        "type" => "json_schema",
        "json_schema" => %{"name" => "camera_analysis", "strict" => true, "schema" => @schema}
      },
      "max_completion_tokens" => 1200
    }

    req_opts =
      [
        json: body,
        headers: [{"authorization", "Bearer #{cfg(:api_key)}"}],
        receive_timeout: 90_000,
        retry: :transient,
        max_retries: 2
      ] ++ (cfg(:req_options) || [])

    case Req.post(@endpoint, req_opts) do
      {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}} | _]} = resp}} ->
        with {:ok, parsed} <- Jason.decode(content) do
          {:ok, normalize(parsed, resp["model"] || model())}
        end

      {:ok, %{status: status, body: b}} ->
        {:error, {:http, status, b |> inspect() |> String.slice(0, 200)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp normalize(parsed, model) do
    %{
      "quick_take" => str(parsed["quick_take"]),
      "rarity" => parsed["rarity"] |> to_int() |> clamp(1, 5),
      "price_take" => (parsed["price_take"] in ["steal", "fair", "high", "unclear"] && parsed["price_take"]) || "unclear",
      "price_note" => str(parsed["price_note"]),
      "commentary" => str(parsed["commentary"]),
      "fun_features" => list(parsed["fun_features"]),
      "facts" => list(parsed["facts"]),
      "model" => model
    }
  end

  defp str(s) when is_binary(s), do: String.trim(s)
  defp str(_), do: ""
  defp list(l) when is_list(l), do: l |> Enum.filter(&is_binary/1) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) |> Enum.take(6)
  defp list(_), do: []
  defp to_int(i) when is_integer(i), do: i
  defp to_int(f) when is_float(f), do: round(f)
  defp to_int(s) when is_binary(s), do: (Integer.parse(s) |> elem(0)) |> then(fn i -> if is_integer(i), do: i, else: 3 end)
  defp to_int(_), do: 3
  defp clamp(n, lo, hi), do: n |> max(lo) |> min(hi)

  @doc "Rarity as stars for the UI."
  @spec stars(map() | nil) :: String.t() | nil
  def stars(%{"rarity" => r}) when is_integer(r), do: String.duplicate("★", r) <> String.duplicate("☆", 5 - r)
  def stars(_), do: nil
end
