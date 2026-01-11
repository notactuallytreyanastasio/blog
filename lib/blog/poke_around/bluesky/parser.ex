defmodule Blog.PokeAround.Bluesky.Parser do
  @moduledoc """
  Parses Turbostream events into typed structs.

  Turbostream provides hydrated events with author profiles inline.
  """

  alias Blog.PokeAround.Bluesky.Types.{Author, ExternalEmbed, FacetLink, Post}

  @doc """
  Parse a Turbostream event into a Post struct.

  Turbostream format:
  - at_uri: "at://did/app.bsky.feed.post/rkey"
  - did: "did:plc:..."
  - message: {commit: {record: {...}, ...}}
  - hydrated_metadata: {author: {...}, ...}

  Returns `{:ok, post}` or `{:error, reason}`.
  """
  @spec parse_post(map()) :: {:ok, Post.t()} | {:error, term()}
  def parse_post(%{"at_uri" => at_uri, "message" => message, "hydrated_metadata" => metadata} = _event) do
    commit = message["commit"] || %{}
    record = commit["record"] || %{}

    post = %Post{
      uri: at_uri,
      cid: commit["cid"],
      text: record["text"] || "",
      created_at: parse_datetime(record["createdAt"]),
      author: parse_turbostream_author(metadata),
      external_embed: parse_external_embed(record["embed"]),
      facet_links: parse_facet_links(record["facets"]),
      langs: record["langs"],
      reply_to: get_reply_parent(record["reply"]),
      is_reply: record["reply"] != nil
    }

    {:ok, post}
  rescue
    e -> {:error, {:parse_error, e}}
  end

  # Fallback for raw Jetstream format
  def parse_post(%{"commit" => commit, "did" => did} = event) do
    record = commit["record"] || %{}
    rkey = commit["rkey"]

    uri = "at://#{did}/app.bsky.feed.post/#{rkey}"

    post = %Post{
      uri: uri,
      cid: commit["cid"],
      text: record["text"] || "",
      created_at: parse_datetime(record["createdAt"]),
      author: parse_author(event),
      external_embed: parse_external_embed(record["embed"]),
      facet_links: parse_facet_links(record["facets"]),
      langs: record["langs"],
      reply_to: get_reply_parent(record["reply"]),
      is_reply: record["reply"] != nil
    }

    {:ok, post}
  rescue
    e -> {:error, {:parse_error, e}}
  end

  def parse_post(_), do: {:error, :invalid_event}

  @doc """
  Extract all links from a post (both embed and facets).
  """
  @spec extract_links(Post.t()) :: [String.t()]
  def extract_links(%Post{} = post) do
    embed_link =
      case post.external_embed do
        %ExternalEmbed{uri: uri} when is_binary(uri) -> [uri]
        _ -> []
      end

    facet_links =
      (post.facet_links || [])
      |> Enum.map(& &1.uri)

    (embed_link ++ facet_links)
    |> Enum.uniq()
    |> Enum.filter(&valid_link?/1)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  # Turbostream hydrated author from metadata - uses snake_case keys
  defp parse_turbostream_author(%{"user" => user}) when is_map(user) do
    %Author{
      did: user["did"],
      handle: user["handle"],
      display_name: user["display_name"],
      avatar: user["avatar"],
      description: user["description"],
      followers_count: user["followers_count"],
      follows_count: user["follows_count"],
      posts_count: user["posts_count"],
      indexed_at: parse_datetime(user["indexed_at"])
    }
  end

  defp parse_turbostream_author(_), do: nil

  # Fallback author parsing for raw Jetstream
  defp parse_author(%{"author" => author}) when is_map(author) do
    %Author{
      did: author["did"],
      handle: author["handle"],
      display_name: author["displayName"],
      avatar: author["avatar"],
      description: author["description"],
      followers_count: author["followersCount"],
      follows_count: author["followsCount"],
      posts_count: author["postsCount"],
      indexed_at: parse_datetime(author["indexedAt"])
    }
  end

  defp parse_author(%{"did" => did}) do
    # Fallback if author not hydrated
    %Author{did: did, handle: nil}
  end

  defp parse_author(_), do: nil

  defp parse_external_embed(%{"$type" => "app.bsky.embed.external", "external" => ext}) do
    %ExternalEmbed{
      uri: ext["uri"],
      title: ext["title"],
      description: ext["description"],
      thumb: ext["thumb"]
    }
  end

  defp parse_external_embed(%{"$type" => "app.bsky.embed.recordWithMedia", "media" => media}) do
    # Handle recordWithMedia - check if media contains external
    parse_external_embed(media)
  end

  defp parse_external_embed(_), do: nil

  defp parse_facet_links(nil), do: []

  defp parse_facet_links(facets) when is_list(facets) do
    facets
    |> Enum.flat_map(fn facet ->
      index = facet["index"] || %{}
      features = facet["features"] || []

      features
      |> Enum.filter(fn f -> f["$type"] == "app.bsky.richtext.facet#link" end)
      |> Enum.map(fn f ->
        %FacetLink{
          uri: f["uri"],
          byte_start: index["byteStart"],
          byte_end: index["byteEnd"]
        }
      end)
    end)
  end

  defp get_reply_parent(%{"parent" => %{"uri" => uri}}), do: uri
  defp get_reply_parent(_), do: nil

  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp valid_link?("https://bsky.app" <> _), do: false
  defp valid_link?("http://bsky.app" <> _), do: false
  defp valid_link?("https://bsky.social" <> _), do: false
  defp valid_link?("http://bsky.social" <> _), do: false
  defp valid_link?("at://" <> _), do: false
  defp valid_link?("https://" <> _), do: true
  defp valid_link?("http://" <> _), do: true
  defp valid_link?(_), do: false
end
