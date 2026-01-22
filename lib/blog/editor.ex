defmodule Blog.Editor do
  @moduledoc """
  Context for the markdown editor and draft management.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.Editor.Draft

  @doc """
  Lists all drafts, ordered by most recently updated.
  """
  def list_drafts do
    Draft
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Lists drafts by status.
  """
  def list_drafts_by_status(status) do
    Draft
    |> where(status: ^status)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single draft by ID.
  """
  def get_draft(id), do: Repo.get(Draft, id)

  @doc """
  Gets a single draft by slug.
  """
  def get_draft_by_slug(slug), do: Repo.get_by(Draft, slug: slug)

  @doc """
  Creates a new draft.
  """
  def create_draft(attrs \\ %{}) do
    %Draft{}
    |> Draft.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a draft.
  """
  def update_draft(%Draft{} = draft, attrs) do
    draft
    |> Draft.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a draft.
  """
  def delete_draft(%Draft{} = draft) do
    Repo.delete(draft)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draft changes.
  """
  def change_draft(%Draft{} = draft, attrs \\ %{}) do
    Draft.changeset(draft, attrs)
  end

  @doc """
  Publishes a draft by changing its status to "published".
  Requires author name and email.
  """
  def publish_draft(%Draft{} = draft, attrs \\ %{}) do
    draft
    |> Draft.publish_changeset(Map.merge(attrs, %{status: "published"}))
    |> Repo.update()
  end

  @doc """
  Lists all published drafts (guest posts).
  """
  def list_published do
    Draft
    |> where(status: "published")
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Renders markdown content to HTML with custom extensions.
  Supports:
  - Standard markdown via Earmark
  - Bluesky post embeds via ::bsky[url] syntax
  - YouTube video embeds via ::youtube[url] syntax
  """
  def render_markdown(nil), do: ""
  def render_markdown(""), do: ""

  def render_markdown(content) do
    # Process markdown first, then replace embed syntax in the resulting HTML
    # This prevents Earmark from interfering with our embed HTML
    content
    |> render_earmark()
    |> process_bluesky_embeds()
    |> process_youtube_embeds()
  end

  defp render_earmark(content) do
    opts = %Earmark.Options{
      code_class_prefix: "language-",
      escape: false,
      breaks: true
    }

    case Earmark.as_html(content, opts) do
      {:ok, html, _} -> html
      {:error, html, _} -> html
    end
  end

  @bluesky_embed_regex ~r/::bsky\[([^\]]+)\]/

  defp process_bluesky_embeds(content) do
    Regex.replace(@bluesky_embed_regex, content, fn _, url ->
      render_bluesky_embed(url)
    end)
  end

  defp render_bluesky_embed(url) do
    # Extract post info from URL like https://bsky.app/profile/user.bsky.social/post/abc123
    case parse_bluesky_url(url) do
      {:ok, handle, rkey} ->
        # Single line to avoid breaks: true converting newlines to <br>
        ~s(<div class="bsky-embed" data-handle="#{handle}" data-rkey="#{rkey}"><div class="bsky-embed-inner"><div class="bsky-embed-header"><span class="bsky-icon">🦋</span><a href="#{url}" target="_blank" rel="noopener">@#{handle}</a></div><div class="bsky-embed-loading">Loading post...</div></div></div>)

      :error ->
        # Return as a simple link if parsing fails
        "[Bluesky Post](#{url})"
    end
  end

  defp parse_bluesky_url(url) do
    # Pattern: https://bsky.app/profile/HANDLE/post/RKEY
    case Regex.run(~r|bsky\.app/profile/([^/]+)/post/([^/\s]+)|, url) do
      [_, handle, rkey] -> {:ok, handle, rkey}
      _ -> :error
    end
  end

  @youtube_embed_regex ~r/::youtube\[([^\]]+)\]/

  defp process_youtube_embeds(content) do
    Regex.replace(@youtube_embed_regex, content, fn _, url ->
      render_youtube_embed(url)
    end)
  end

  defp render_youtube_embed(url) do
    case parse_youtube_url(url) do
      {:ok, video_id} ->
        # Single line to avoid breaks: true converting newlines to <br>
        ~s(<div class="youtube-embed"><iframe src="https://www.youtube.com/embed/#{video_id}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>)

      :error ->
        # Return as a simple link if parsing fails
        "[YouTube Video](#{url})"
    end
  end

  defp parse_youtube_url(url) do
    cond do
      # youtube.com/watch?v=VIDEO_ID
      match = Regex.run(~r|youtube\.com/watch\?v=([a-zA-Z0-9_-]+)|, url) ->
        {:ok, Enum.at(match, 1)}

      # youtu.be/VIDEO_ID
      match = Regex.run(~r|youtu\.be/([a-zA-Z0-9_-]+)|, url) ->
        {:ok, Enum.at(match, 1)}

      # youtube.com/embed/VIDEO_ID
      match = Regex.run(~r|youtube\.com/embed/([a-zA-Z0-9_-]+)|, url) ->
        {:ok, Enum.at(match, 1)}

      true ->
        :error
    end
  end
end
