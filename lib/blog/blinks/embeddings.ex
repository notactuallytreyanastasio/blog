defmodule Blog.Blinks.Embeddings do
  @moduledoc """
  Optional semantic layer. When an OpenAI API key is configured
  (`:blog, :openai_api_key` / OPENAI_API_KEY), blinks get an embedding on
  save and search/similarity use cosine distance, computed in Elixir —
  at personal-archive scale that's milliseconds, no pgvector needed.
  Without a key everything degrades gracefully (FTS + tag/trigram
  similarity).
  """

  require Logger
  import Ecto.Query
  alias Blog.Blinks.Blink
  alias Blog.Repo

  @model "text-embedding-3-small"
  @dims 512

  @spec enabled?() :: boolean()
  def enabled? do
    key = Application.get_env(:blog, :openai_api_key)
    is_binary(key) and key != ""
  end

  @spec embed(String.t()) :: {:ok, [float()]} | :disabled | {:error, term()}
  def embed(text) do
    if enabled?() do
      request(text)
    else
      :disabled
    end
  end

  @spec embed_blink(Blink.t()) :: :ok
  def embed_blink(%Blink{} = blink) do
    case embed(blink_text(blink)) do
      {:ok, vector} ->
        blink |> Blink.changeset(%{embedding: vector}) |> Repo.update()
        :ok

      :disabled ->
        :ok

      {:error, reason} ->
        Logger.info("blinks embedding failed for #{blink.url}: #{inspect(reason)}")
        :ok
    end
  end

  @doc "Embeds every blink without an embedding. Safe to re-run."
  @spec backfill() :: non_neg_integer()
  def backfill do
    if enabled?() do
      Blink
      |> where([b], is_nil(b.embedding))
      |> Repo.all()
      |> Enum.map(&embed_blink/1)
      |> length()
    else
      0
    end
  end

  @doc "Returns [{id, cosine}] for all embedded blinks vs the query vector, best first."
  @spec rank_against([float()]) :: [{integer(), float()}]
  def rank_against(query_vector) do
    Blink
    |> where([b], not is_nil(b.embedding))
    |> select([b], {b.id, b.embedding})
    |> Repo.all()
    |> Enum.map(fn {id, emb} -> {id, cosine(query_vector, emb)} end)
    |> Enum.sort_by(&elem(&1, 1), :desc)
  end

  @spec cosine([float()], [float()]) :: float()
  def cosine(a, b) do
    {dot, na, nb} =
      Enum.zip(a, b)
      |> Enum.reduce({0.0, 0.0, 0.0}, fn {x, y}, {dot, na, nb} ->
        {dot + x * y, na + x * x, nb + y * y}
      end)

    denom = :math.sqrt(na) * :math.sqrt(nb)
    if denom == 0.0, do: 0.0, else: dot / denom
  end

  @spec blink_text(Blink.t()) :: String.t()
  def blink_text(blink) do
    [blink.title, blink.description, Enum.join(blink.tags, " "), blink.site_name, blink.url]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp request(text) do
    case Req.post("https://api.openai.com/v1/embeddings",
           json: %{model: @model, input: String.slice(text, 0, 8000), dimensions: @dims},
           auth: {:bearer, Application.get_env(:blog, :openai_api_key)},
           receive_timeout: 15_000
         ) do
      {:ok, %Req.Response{status: 200, body: %{"data" => [%{"embedding" => vector} | _]}}} ->
        {:ok, vector}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
