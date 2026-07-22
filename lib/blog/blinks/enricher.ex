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
    blink = maybe_unroll_thread(blink)

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
      Blog.Blinks.broadcast(updated, :blink_updated)
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

  # ── bluesky thread unrolling ──────────────────────────────────────────
  # Saving a bsky.app post pulls the whole self-thread (root + the author's
  # own reply chain) from the public AppView, no auth needed.

  @bsky_post ~r{bsky\.app/profile/([^/]+)/post/([^/?#]+)}
  @appview "https://public.api.bsky.app/xrpc"

  defp maybe_unroll_thread(%Blink{} = blink) do
    with [_, handle, rkey] <- Regex.run(@bsky_post, blink.url),
         {:ok, did} <- resolve_did(handle),
         {:ok, posts} when posts != [] <- fetch_thread_posts(did, rkey) do
      {:ok, updated} = blink |> Blink.changeset(%{thread: %{"posts" => posts}}) |> Repo.update()
      Blog.Blinks.broadcast(updated, :blink_updated)
      updated
    else
      nil ->
        blink

      other ->
        Logger.info("blinks thread unroll failed for #{blink.url}: #{inspect(other)}")
        blink
    end
  end

  defp resolve_did("did:" <> _ = did), do: {:ok, did}

  defp resolve_did(handle) do
    case Req.get("#{@appview}/com.atproto.identity.resolveHandle",
           params: [handle: handle],
           receive_timeout: 10_000
         ) do
      {:ok, %Req.Response{status: 200, body: %{"did" => did}}} -> {:ok, did}
      other -> {:error, other}
    end
  end

  defp fetch_thread_posts(did, rkey) do
    case Req.get("#{@appview}/app.bsky.feed.getPostThread",
           params: [uri: "at://#{did}/app.bsky.feed.post/#{rkey}", depth: 50, parentHeight: 50],
           receive_timeout: 15_000
         ) do
      {:ok, %Req.Response{status: 200, body: %{"thread" => thread}}} ->
        {:ok, unroll_posts(thread)}

      other ->
        {:error, other}
    end
  end

  @doc """
  Posts to display for a saved bsky URL, oldest first. If the saved post's
  author owns the thread root, unroll their whole self-thread; otherwise
  (a reply saved out of someone else's thread, or a standalone post) just
  the saved post itself. Public for tests.
  """
  @spec unroll_posts(map()) :: [map()]
  def unroll_posts(thread) do
    focused_author = get_in(thread, ["post", "author", "did"])
    root = climb_to_root(thread)

    nodes =
      if get_in(root, ["post", "author", "did"]) == focused_author do
        chain(root, focused_author)
      else
        [thread]
      end

    nodes
    |> Enum.map(fn node ->
      post = node["post"] || %{}

      %{
        "name" => get_in(post, ["author", "displayName"]),
        "handle" => get_in(post, ["author", "handle"]),
        "text" => get_in(post, ["record", "text"]),
        "at" => get_in(post, ["record", "createdAt"]),
        "quote" => quoted_embed(post)
      }
    end)
    |> Enum.reject(&is_nil(&1["text"]))
  end

  # Quote posts embed the quoted record — pull its author + text so the
  # saved post doesn't read like half a conversation.
  defp quoted_embed(post) do
    record =
      case post["embed"] do
        %{"$type" => "app.bsky.embed.record#view", "record" => r} -> r
        %{"$type" => "app.bsky.embed.recordWithMedia#view", "record" => %{"record" => r}} -> r
        _ -> nil
      end

    with %{"$type" => "app.bsky.embed.record#viewRecord"} = r <- record,
         text when is_binary(text) <- get_in(r, ["value", "text"]) do
      %{
        "name" => get_in(r, ["author", "displayName"]),
        "handle" => get_in(r, ["author", "handle"]),
        "text" => text
      }
    else
      _ -> nil
    end
  end

  defp climb_to_root(%{"parent" => %{"post" => _} = parent}), do: climb_to_root(parent)
  defp climb_to_root(node), do: node

  defp chain(node, author_did) do
    next =
      (node["replies"] || [])
      |> Enum.filter(&(get_in(&1, ["post", "author", "did"]) == author_did))
      |> Enum.sort_by(&get_in(&1, ["post", "record", "createdAt"]))
      |> List.first()

    case next do
      nil -> [node]
      n -> [node | chain(n, author_did)]
    end
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
