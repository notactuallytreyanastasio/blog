defmodule Blog.Blinks.Enricher do
  @moduledoc """
  Fetches a saved link's page and pulls out og:image, favicon, site name,
  and a fallback description. Runs fire-and-forget after save; failures
  leave the blink untouched.
  """

  require Logger
  alias Blog.Blinks.Blink
  alias Blog.Repo

  @spec enrich_async(Blink.t()) :: :ok
  def enrich_async(%Blink{} = blink) do
    if Application.get_env(:blog, :blinks_enrich, true) do
      Task.start(fn -> enrich(blink) end)
    end

    :ok
  end

  @spec enrich(Blink.t()) :: {:ok, Blink.t()} | :skipped | {:error, term()}
  def enrich(%Blink{} = blink) do
    with true <- String.starts_with?(blink.url, "http") or :skipped,
         {:ok, %Req.Response{status: 200, body: html}} when is_binary(html) <-
           Req.get(blink.url,
             redirect: true,
             max_redirects: 4,
             receive_timeout: 10_000,
             headers: [{"user-agent", "blinks/1.0 (+https://bobbby.online/blinks)"}]
           ),
         {:ok, doc} <- Floki.parse_document(html) do
      attrs =
        %{
          image_url: absolutize(meta(doc, "og:image") || meta_name(doc, "twitter:image"), blink.url),
          site_name: meta(doc, "og:site_name"),
          favicon_url: favicon(doc, blink.url),
          description:
            blink.description || meta(doc, "og:description") || meta_name(doc, "description"),
          enriched_at: NaiveDateTime.utc_now(:second)
        }
        |> Enum.reject(fn {_k, v} -> is_nil(v) end)
        |> Map.new()

      {:ok, updated} = blink |> Blink.changeset(attrs) |> Repo.update()
      {:ok, updated}
    else
      :skipped ->
        :skipped

      other ->
        Logger.info("blinks enrich failed for #{blink.url}: #{inspect(other)}")
        {:error, other}
    end
  end

  @doc "Enriches (and embeds) every blink never enriched. Safe to re-run."
  @spec backfill() :: non_neg_integer()
  def backfill do
    import Ecto.Query

    Blink
    |> where([b], is_nil(b.enriched_at))
    |> Repo.all()
    |> Enum.map(&enrich/1)
    |> Enum.count(&match?({:ok, _}, &1))
  end

  defp meta(doc, property) do
    doc
    |> Floki.attribute(~s{meta[property="#{property}"]}, "content")
    |> List.first()
    |> presence()
  end

  defp meta_name(doc, name) do
    doc
    |> Floki.attribute(~s{meta[name="#{name}"]}, "content")
    |> List.first()
    |> presence()
  end

  defp favicon(doc, page_url) do
    href =
      doc
      |> Floki.attribute(~s{link[rel~="icon"]}, "href")
      |> List.first()

    case absolutize(presence(href), page_url) do
      nil ->
        uri = URI.parse(page_url)
        if uri.host, do: "#{uri.scheme}://#{uri.host}/favicon.ico"

      url ->
        url
    end
  end

  defp absolutize(nil, _base), do: nil

  defp absolutize(url, base) do
    base |> URI.merge(url) |> URI.to_string()
  rescue
    _ -> nil
  end

  defp presence(nil), do: nil
  defp presence(""), do: nil
  defp presence(s), do: String.slice(s, 0, 2048)
end
