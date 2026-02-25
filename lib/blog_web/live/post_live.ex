defmodule BlogWeb.PostLive do
  @moduledoc """
  LiveView for displaying a single blog post by slug.

  Supports live draft previews, presence-based reader counts,
  and inline comments. Pure functions are extracted to
  `BlogWeb.PostLive.Helpers` for testability.
  """

  use BlogWeb, :live_view

  alias Blog.Comments
  alias Blog.Content.ImageGenerator
  alias Blog.Content.Post
  alias Blog.LiveDraft
  alias BlogWeb.PostLive.Helpers
  alias BlogWeb.Presence

  require Logger

  @presence_topic "blog_presence"
  @draft_check_interval_ms 30_000

  # ------------------------------------------------------------
  # Callbacks
  # ------------------------------------------------------------

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    if connected?(socket), do: subscribe_and_track(slug)

    Logger.debug("Mounting PostLive with slug: #{slug}")

    case Post.get_by_slug(slug) do
      nil ->
        Logger.debug("No post found for slug: #{slug}")
        {:ok, push_navigate(socket, to: "/")}

      post ->
        {:ok, mount_post(socket, post, slug)}
    end
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, reader_count: get_reader_count(socket.assigns.post.slug))}
  end

  def handle_info({:live_draft_update, _slug, rendered_html, _updated_at}, socket) do
    {:noreply, assign(socket, html: rendered_html, live_draft_active: true)}
  end

  def handle_info({:live_draft_cleared, _slug}, socket) do
    fresh_html = reload_post_html(socket.assigns.post.slug)
    {:noreply, assign(socket, html: fresh_html, live_draft_active: false, static_html: fresh_html)}
  end

  def handle_info(:check_draft_staleness, socket) do
    slug = socket.assigns.post.slug

    socket =
      if socket.assigns.live_draft_active do
        case LiveDraft.get(slug) do
          {:ok, _draft_html, _updated_at} ->
            socket

          _stale_or_none ->
            fresh_html = reload_post_html(slug)
            assign(socket, html: fresh_html, live_draft_active: false, static_html: fresh_html)
        end
      else
        socket
      end

    Process.send_after(self(), :check_draft_staleness, @draft_check_interval_ms)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_line_numbers", _params, socket) do
    {:noreply, assign(socket, show_line_numbers: !socket.assigns.show_line_numbers)}
  end

  def handle_event("mousemove", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit_comment", %{"author_name" => name, "content" => content}, socket) do
    slug = socket.assigns.post.slug

    comment_params = %{
      "post_slug" => slug,
      "author_name" => name,
      "content" => content
    }

    case Comments.create_comment(comment_params) do
      {:ok, _comment} ->
        socket =
          assign(socket,
            comments: Comments.list_comments(slug),
            comment_form: empty_comment_form()
          )

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("validate_comment", params, socket) do
    comment_form = %{
      "author_name" => params["author_name"] || "",
      "content" => params["content"] || ""
    }

    {:noreply, assign(socket, comment_form: comment_form)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mac-post">
      <div class="mac-menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">View</span>
          <a href="/" class="menu-item menu-link">Home</a>
          <a href="/blog" class="menu-item menu-link">Blog</a>
        </div>
        <div class="menu-right">
          <span>
            {reader_count_text(@reader_count)}
          </span>
        </div>
      </div>

      <div class="mac-desktop">
        <div class="mac-window">
          <div class="mac-title-bar">
            <a href="/blog" class="mac-close-box"></a>
            <div class="mac-title">
              {@post.title}
              <span :if={@live_draft_active} class="live-badge">LIVE</span>
            </div>
            <div class="mac-resize-box"></div>
          </div>
          <div class="mac-window-content">
            <div class="post-meta-bar">
              <span class="post-date">{Calendar.strftime(@post.written_on, "%B %d, %Y")}</span>
              <span :if={@post.is_guest_post && @post.author_name} class="post-author">
                by {@post.author_name}
              </span>
              <span class="post-stats">{@word_count} words · {@estimated_read_time}</span>
              <div class="post-tags-inline">
                <span :for={tag <- @post.tags} class="mac-tag">{tag.name}</span>
              </div>
            </div>

            <div id="post-content" phx-hook="Highlight" class="article-content">
              {raw(@html)}
            </div>

            <div class="comments-section">
              <h3 class="comments-header">Comments ({length(@comments)})</h3>

              <.form
                for={%{}}
                id="comment-form"
                phx-submit="submit_comment"
                phx-change="validate_comment"
                class="comment-form"
              >
                <div class="form-group">
                  <label for="author_name">Name</label>
                  <input
                    type="text"
                    id="author_name"
                    name="author_name"
                    value={@comment_form["author_name"]}
                    placeholder="Your name"
                    required
                  />
                </div>
                <div class="form-group">
                  <label for="content">Comment</label>
                  <textarea
                    id="content"
                    name="content"
                    placeholder="Write a comment..."
                    rows="3"
                    required
                  >{@comment_form["content"]}</textarea>
                </div>
                <button type="submit" class="submit-btn">Post Comment</button>
              </.form>

              <div class="comments-list">
                <div :for={comment <- @comments} class="comment">
                  <div class="comment-header">
                    <span class="comment-author">{comment.author_name}</span>
                    <span class="comment-date">
                      {Calendar.strftime(comment.inserted_at, "%b %d, %Y at %I:%M %p")}
                    </span>
                  </div>
                  <div class="comment-body">{comment.content}</div>
                </div>
                <p :if={Enum.empty?(@comments)} class="no-comments">
                  No comments yet. Be the first to comment!
                </p>
              </div>
            </div>

            <div class="post-footer">
              <a href="/blog" class="back-link">&larr; Back to all posts</a>
            </div>
          </div>
          <div class="mac-status-bar">
            <span>{@word_count} words</span>
            <span>{@estimated_read_time}</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ------------------------------------------------------------
  # Private — mount helpers
  # ------------------------------------------------------------

  defp subscribe_and_track(slug) do
    Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
    Phoenix.PubSub.subscribe(Blog.PubSub, "live_draft:#{slug}")
    Process.send_after(self(), :check_draft_staleness, @draft_check_interval_ms)

    reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

    {:ok, _} =
      Presence.track(self(), @presence_topic, reader_id, %{
        name: "Reader-#{:rand.uniform(999)}",
        anonymous: true,
        joined_at: DateTime.utc_now(),
        slug: slug
      })
  end

  defp mount_post(socket, post, slug) do
    content_without_tags = Helpers.remove_tags_line(post.body)
    processed_html = Helpers.render_markdown(post.body)

    {display_html, live_draft_active} = resolve_live_draft(slug, processed_html)

    socket
    |> assign_meta_tags(post)
    |> assign(
      post: post,
      page_title: post.title,
      html: display_html,
      static_html: processed_html,
      live_draft_active: live_draft_active,
      reader_count: get_reader_count(slug),
      word_count: Helpers.word_count(content_without_tags),
      estimated_read_time: Helpers.estimated_read_time(content_without_tags),
      show_line_numbers: true,
      comments: Comments.list_comments(slug),
      comment_form: empty_comment_form()
    )
  end

  defp resolve_live_draft(slug, fallback_html) do
    case LiveDraft.get(slug) do
      {:ok, draft_html, _updated_at} -> {draft_html, true}
      _ -> {fallback_html, false}
    end
  end

  defp empty_comment_form, do: %{"author_name" => "", "content" => ""}

  # ------------------------------------------------------------
  # Private — runtime helpers
  # ------------------------------------------------------------

  defp reload_post_html(slug) do
    case Post.get_by_slug(slug) do
      nil -> ""
      post -> Helpers.render_markdown(post.body)
    end
  end

  defp get_reader_count(slug) do
    Presence.list(@presence_topic)
    |> Enum.count(fn {_key, %{metas: [meta | _]}} ->
      Map.get(meta, :slug) == slug
    end)
  end

  defp reader_count_text(count) when count > 1, do: "#{count} reading"
  defp reader_count_text(_count), do: "1 reader"

  # ------------------------------------------------------------
  # Private — meta tags
  # ------------------------------------------------------------

  defp assign_meta_tags(socket, post) do
    description = Helpers.get_preview(post.body)
    image_path = ImageGenerator.ensure_post_image(post.slug)
    image_url = if image_path, do: BlogWeb.Endpoint.url() <> image_path

    meta_tags =
      base_meta_tags(post, description) ++
        image_meta_tags(image_url) ++
        tag_meta_tags(post.tags)

    assign(socket,
      page_title: post.title,
      meta_tags: meta_tags
    )
  end

  defp base_meta_tags(post, description) do
    [
      %{name: "description", content: description},
      %{property: "og:title", content: post.title},
      %{property: "og:description", content: description},
      %{property: "og:type", content: "article"},
      %{property: "og:site_name", content: "Thoughts and Tidbits"},
      %{
        property: "article:published_time",
        content: DateTime.from_naive!(post.written_on, "Etc/UTC") |> DateTime.to_iso8601()
      },
      %{name: "twitter:card", content: "summary_large_image"},
      %{name: "twitter:title", content: post.title},
      %{name: "twitter:description", content: description}
    ]
  end

  defp image_meta_tags(nil), do: []

  defp image_meta_tags(image_url) do
    [
      %{property: "og:image", content: image_url},
      %{property: "og:image:width", content: "1200"},
      %{property: "og:image:height", content: "630"},
      %{name: "twitter:image", content: image_url}
    ]
  end

  defp tag_meta_tags(tags) do
    Enum.map(tags, fn tag ->
      %{property: "article:tag", content: tag.name}
    end)
  end
end
