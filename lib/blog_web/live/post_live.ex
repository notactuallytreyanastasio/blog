defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Comments
  require Logger

  @presence_topic "blog_presence"

  def mount(%{"slug" => slug}, _session, socket) do
    if connected?(socket) do
      # Subscribe first to get presence updates
      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)

      # Subscribe to live draft updates for this post
      Phoenix.PubSub.subscribe(Blog.PubSub, "live_draft:#{slug}")

      # Schedule staleness checks for live drafts
      Process.send_after(self(), :check_draft_staleness, 30_000)

      # Generate a random ID for this reader
      reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

      # Track presence with the slug
      {:ok, _} =
        Presence.track(self(), @presence_topic, reader_id, %{
          name: "Reader-#{:rand.uniform(999)}",
          anonymous: true,
          joined_at: DateTime.utc_now(),
          slug: slug
        })
    end

    require Logger
    Logger.debug("Mounting PostLive with slug: #{slug}")

    case Blog.Content.Post.get_by_slug(slug) do
      nil ->
        Logger.debug("No post found for slug: #{slug}")
        {:ok, push_navigate(socket, to: "/")}

      post ->
        # Set meta tags for the page
        meta_attrs = [
          %{name: "title", content: post.title},
          %{name: "description", content: truncated_post(post.body)},
          %{property: "og:title", content: post.title},
          %{property: "og:description", content: truncated_post(post.body)},
          %{property: "og:type", content: "website"}
        ]

        socket =
          socket
          |> assign_meta_tags(post)
          |> assign(:post, post)
          |> assign(meta_attrs: meta_attrs)
          |> assign(page_title: post.title)

        Logger.debug("Found post: #{inspect(post, pretty: true)}")

        # Filter out tags line and process markdown
        content_without_tags = remove_tags_line(post.body)

        case Earmark.as_html(content_without_tags, code_class_prefix: "language-", escape: false) do
          {:ok, html, _} ->
            # Post-process the HTML to handle details blocks
            processed_html = process_details_in_html(html)

            # Check for active live draft
            {display_html, live_draft_active} =
              case Blog.LiveDraft.get(slug) do
                {:ok, draft_html, _updated_at} -> {draft_html, true}
                _ -> {processed_html, false}
              end

            socket =
              socket
              |> assign(
                html: display_html,
                static_html: processed_html,
                live_draft_active: live_draft_active,
                reader_count: get_reader_count(slug),
                word_count: word_count(content_without_tags),
                estimated_read_time: estimated_read_time(content_without_tags),
                show_line_numbers: true,
                comments: Comments.list_comments(slug),
                comment_form: %{"author_name" => "", "content" => ""}
              )

            {:ok, socket}

          {:error, html, errors} ->
            # Still show the content even if there are markdown errors
            Logger.error("Markdown parsing warnings: #{inspect(errors)}")

            # Still try to process details blocks even if there were errors
            processed_html = process_details_in_html(html)

            {display_html, live_draft_active} =
              case Blog.LiveDraft.get(slug) do
                {:ok, draft_html, _updated_at} -> {draft_html, true}
                _ -> {processed_html, false}
              end

            socket =
              socket
              |> assign(
                html: display_html,
                static_html: processed_html,
                live_draft_active: live_draft_active,
                post: post,
                reader_count: get_reader_count(slug),
                word_count: word_count(content_without_tags),
                estimated_read_time: estimated_read_time(content_without_tags),
                show_line_numbers: true,
                comments: Comments.list_comments(slug),
                comment_form: %{"author_name" => "", "content" => ""}
              )

            {:ok, socket}
        end
    end
  end

  # Remove the tags line from the content
  defp remove_tags_line(content) when is_binary(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&is_tags_line?/1)
    |> Enum.join("\n")
  end

  # Check if a line is a tags line
  defp is_tags_line?(line) do
    String.starts_with?(String.trim(line), "tags:")
  end

  # Process details blocks in already-rendered HTML
  defp process_details_in_html(html) do
    # Pattern to match details blocks that contain raw markdown text
    pattern = ~r/<details([^>]*)>\s*<summary([^>]*)>(.*?)<\/summary>\s*(.*?)<\/details>/s
    
    matches = Regex.scan(pattern, html)
    
    # Process each match one by one
    Enum.reduce(matches, html, fn [full_match, details_attrs, summary_attrs, summary_content, details_content], acc ->
      processed_block = process_single_html_details_block(details_attrs, summary_attrs, summary_content, details_content)
      String.replace(acc, full_match, processed_block, global: false)
    end)
  end

  # Process a single details block from HTML
  defp process_single_html_details_block(details_attrs, summary_attrs, summary_content, details_content) do
    # Check if the content looks like raw markdown (has ## headings, --- rules, etc.)
    trimmed_content = String.trim(details_content)
    
    
    if looks_like_markdown?(trimmed_content) do
      case Earmark.as_html(trimmed_content, code_class_prefix: "language-", escape: false) do
        {:ok, processed_content, _} ->
          "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary><div class=\"details-content\">#{processed_content}</div></details>"
        
        {:error, _, _} ->
          "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary><div class=\"details-content\">#{trimmed_content}</div></details>"
      end
    else
      # Content is already HTML, just wrap it
      "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary><div class=\"details-content\">#{trimmed_content}</div></details>"
    end
  end

  # Check if content looks like markdown rather than HTML
  defp looks_like_markdown?(content) do
    # More comprehensive heuristics to detect markdown
    has_markdown_headings = String.contains?(content, "##") or String.contains?(content, "# ")
    has_markdown_rules = String.contains?(content, "---")
    has_markdown_lists = Regex.match?(~r/^\s*[-*+]\s+/m, content) or Regex.match?(~r/^\s*\d+\.\s+/m, content)
    has_markdown_emphasis = (String.contains?(content, "*") and not String.contains?(content, "<strong>")) or
                           (String.contains?(content, "_") and not String.contains?(content, "<em>"))
    has_markdown_code = String.contains?(content, "```") or Regex.match?(~r/`[^`]+`/, content)
    has_blockquotes = Regex.match?(~r/^\s*>\s+/m, content)
    
    # If it has HTML tags, it's probably already processed
    has_html_tags = String.contains?(content, "<h") or String.contains?(content, "<p>") or String.contains?(content, "<ul>")
    
    # Return true if it has markdown features and doesn't look like HTML
    (has_markdown_headings or has_markdown_rules or has_markdown_lists or 
     has_markdown_emphasis or has_markdown_code or has_blockquotes) and not has_html_tags
  end

  defp truncated_post(body) do
    body
    |> remove_tags_line()
    |> String.slice(0, 250)
    |> Kernel.<>("...")
  end

  def handle_info(%{event: "presence_diff"} = _diff, socket) do
    socket =
      assign(socket,
        reader_count: get_reader_count(socket.assigns.post.slug)
      )

    {:noreply, socket}
  end

  def handle_info({:live_draft_update, _slug, rendered_html, _updated_at}, socket) do
    {:noreply, assign(socket, html: rendered_html, live_draft_active: true)}
  end

  def handle_info({:live_draft_cleared, _slug}, socket) do
    {:noreply, assign(socket, html: socket.assigns.static_html, live_draft_active: false)}
  end

  def handle_info(:check_draft_staleness, socket) do
    slug = socket.assigns.post.slug

    socket =
      if socket.assigns.live_draft_active do
        case Blog.LiveDraft.get(slug) do
          :stale -> assign(socket, html: socket.assigns.static_html, live_draft_active: false)
          :none -> assign(socket, html: socket.assigns.static_html, live_draft_active: false)
          _ -> socket
        end
      else
        socket
      end

    Process.send_after(self(), :check_draft_staleness, 30_000)
    {:noreply, socket}
  end

  defp get_reader_count(slug) do
    Presence.list(@presence_topic)
    |> Enum.count(fn {_key, %{metas: [meta | _]}} ->
      # Only count readers that have a slug and are reading this post
      Map.get(meta, :slug) == slug
    end)
  end

  # Calculate word count
  defp word_count(content) when is_binary(content) do
    content
    |> String.split(~r/\s+/, trim: true)
    |> length()
  end

  # Estimate reading time based on average reading speed of 250 words per minute
  defp estimated_read_time(content) when is_binary(content) do
    words = word_count(content)
    minutes = Float.ceil(words / 250, 1)

    if minutes < 1.0 do
      "< 1 min read"
    else
      "#{trunc(minutes)} min read"
    end
  end

  # Handle line number toggle
  def handle_event("toggle_line_numbers", _, socket) do
    {:noreply, assign(socket, show_line_numbers: !socket.assigns.show_line_numbers)}
  end

  # Handle mouse movement events (from cursor tracking functionality)
  def handle_event("mousemove", _params, socket) do
    # For now, we'll just ignore these events in the post view
    # This prevents the FunctionClauseError from crashing the page
    {:noreply, socket}
  end

  # Handle comment submission
  def handle_event("submit_comment", %{"author_name" => name, "content" => content}, socket) do
    comment_params = %{
      "post_slug" => socket.assigns.post.slug,
      "author_name" => name,
      "content" => content
    }

    case Comments.create_comment(comment_params) do
      {:ok, _comment} ->
        socket =
          socket
          |> assign(
            comments: Comments.list_comments(socket.assigns.post.slug),
            comment_form: %{"author_name" => "", "content" => ""}
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

  def render(assigns) do
    ~H"""
    <div class="mac-post">
      <!-- Menu Bar -->
      <div class="mac-menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">View</span>
          <a href="/" class="menu-item" style="text-decoration: none; color: inherit;">Home</a>
          <a href="/blog" class="menu-item" style="text-decoration: none; color: inherit;">Blog</a>
        </div>
        <div class="menu-right">
          <span>
            <%= if @reader_count > 1 do %>
              <%= @reader_count %> reading
            <% else %>
              1 reader
            <% end %>
          </span>
        </div>
      </div>

      <!-- Desktop -->
      <div class="mac-desktop">
        <!-- Post Window -->
        <div class="mac-window">
          <div class="mac-title-bar">
            <a href="/blog" class="mac-close-box"></a>
            <div class="mac-title">
              <%= @post.title %>
              <%= if @live_draft_active do %>
                <span class="live-badge">LIVE</span>
              <% end %>
            </div>
            <div class="mac-resize-box"></div>
          </div>
          <div class="mac-window-content">
            <!-- Post metadata bar -->
            <div class="post-meta-bar">
              <span class="post-date"><%= Calendar.strftime(@post.written_on, "%B %d, %Y") %></span>
              <%= if @post.is_guest_post && @post.author_name do %>
                <span class="post-author">by <%= @post.author_name %></span>
              <% end %>
              <span class="post-stats"><%= @word_count %> words · <%= @estimated_read_time %></span>
              <div class="post-tags-inline">
                <%= for tag <- @post.tags do %>
                  <span class="mac-tag"><%= tag.name %></span>
                <% end %>
              </div>
            </div>

            <!-- Article body -->
            <div
              id="post-content"
              phx-hook="Highlight"
              class="article-content"
            >
              {raw(@html)}
            </div>

            <!-- Comments Section -->
            <div class="comments-section">
              <h3 class="comments-header">Comments (<%= length(@comments) %>)</h3>

              <!-- Comment Form -->
              <.form for={%{}} phx-submit="submit_comment" phx-change="validate_comment" class="comment-form">
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
                  ><%= @comment_form["content"] %></textarea>
                </div>
                <button type="submit" class="submit-btn">Post Comment</button>
              </.form>

              <!-- Comments List -->
              <div class="comments-list">
                <%= for comment <- @comments do %>
                  <div class="comment">
                    <div class="comment-header">
                      <span class="comment-author"><%= comment.author_name %></span>
                      <span class="comment-date"><%= Calendar.strftime(comment.inserted_at, "%b %d, %Y at %I:%M %p") %></span>
                    </div>
                    <div class="comment-body"><%= comment.content %></div>
                  </div>
                <% end %>
                <%= if Enum.empty?(@comments) do %>
                  <p class="no-comments">No comments yet. Be the first to comment!</p>
                <% end %>
              </div>
            </div>

            <!-- Back link at bottom -->
            <div class="post-footer">
              <a href="/blog" class="back-link">← Back to all posts</a>
            </div>
          </div>
          <div class="mac-status-bar">
            <span><%= @word_count %> words</span>
            <span><%= @estimated_read_time %></span>
          </div>
        </div>
      </div>
    </div>

    <style>
      .mac-post {
        min-height: 100vh;
        background: #a8a8a8;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        cursor: default;
        -webkit-font-smoothing: none;
      }

      .mac-post .mac-menu-bar {
        height: 20px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        position: sticky;
        top: 0;
        z-index: 100;
      }

      .mac-post .menu-left {
        display: flex;
        gap: 16px;
      }

      .mac-post .apple-menu {
        font-family: system-ui;
        font-size: 14px;
      }

      .mac-post .menu-item {
        cursor: default;
      }

      .mac-post .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .mac-post .menu-right {
        font-size: 11px;
      }

      .mac-post .mac-desktop {
        min-height: calc(100vh - 20px);
        padding: 20px;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
        display: flex;
        justify-content: center;
        align-items: flex-start;
      }

      .mac-post .mac-window {
        width: 800px;
        max-width: 95vw;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 2px 2px 0 #000;
        margin-top: 10px;
        margin-bottom: 40px;
      }

      .mac-post .mac-title-bar {
        height: 20px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 4px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px,
          #fff 1px,
          #000 1px,
          #000 2px,
          #fff 2px,
          #fff 3px
        );
      }

      .mac-post .mac-close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
        cursor: pointer;
        display: block;
      }

      .mac-post .mac-close-box:hover {
        background: #000;
      }

      .mac-post .mac-title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .mac-post .live-badge {
        display: inline-block;
        background: #ff0000;
        color: #fff;
        font-size: 9px;
        padding: 1px 6px;
        border-radius: 3px;
        margin-left: 8px;
        animation: live-pulse 1.5s ease-in-out infinite;
        vertical-align: middle;
      }

      @keyframes live-pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
      }

      .mac-post .mac-resize-box {
        width: 12px;
        height: 12px;
      }

      .mac-post .mac-window-content {
        padding: 20px;
        background: #fff;
      }

      .mac-post .post-meta-bar {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        align-items: center;
        padding-bottom: 12px;
        margin-bottom: 16px;
        border-bottom: 1px solid #ccc;
        font-size: 11px;
      }

      .mac-post .post-date {
        font-weight: bold;
      }

      .mac-post .post-author {
        color: #0066cc;
        font-style: italic;
      }

      .mac-post .post-stats {
        color: #666;
      }

      .mac-post .post-tags-inline {
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
      }

      .mac-post .mac-tag {
        background: #e0e0e0;
        padding: 2px 8px;
        border-radius: 3px;
        font-size: 10px;
      }

      .mac-post .post-footer {
        margin-top: 32px;
        padding-top: 16px;
        border-top: 1px solid #ccc;
      }

      .mac-post .back-link {
        color: #000;
        text-decoration: underline;
        font-size: 12px;
      }

      .mac-post .back-link:hover {
        background: #000;
        color: #fff;
        text-decoration: none;
      }

      .mac-post .mac-status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
      }

      /* Article content styling within Mac window */
      .mac-post .article-content {
        font-family: 'Charter', 'Georgia', serif;
        font-size: 16px;
        line-height: 1.7;
        color: #1f2937;
      }

      .mac-post .article-content h1 {
        display: none;
      }

      .mac-post .article-content h2 {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 2rem 0 1rem 0;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
      }

      .mac-post .article-content h3 {
        font-size: 1.25rem;
        font-weight: 600;
        margin: 1.5rem 0 0.75rem 0;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
      }

      .mac-post .article-content p {
        margin: 1rem 0;
      }

      .mac-post .article-content a {
        color: #000;
        text-decoration: underline;
      }

      .mac-post .article-content a:hover {
        background: #000;
        color: #fff;
      }

      .mac-post .article-content pre {
        background: #1f2937;
        padding: 1rem;
        border-radius: 4px;
        overflow-x: auto;
        margin: 1rem 0;
        border: 1px solid #000;
      }

      .mac-post .article-content code {
        font-family: 'Monaco', 'Courier New', monospace;
        font-size: 0.9em;
      }

      .mac-post .article-content :not(pre) > code {
        background: #e0e0e0;
        padding: 2px 4px;
        border-radius: 2px;
      }

      .mac-post .article-content blockquote {
        border-left: 3px solid #000;
        padding-left: 1rem;
        margin: 1rem 0;
        font-style: italic;
        color: #444;
      }

      .mac-post .article-content ul, .mac-post .article-content ol {
        margin: 1rem 0;
        padding-left: 2rem;
      }

      .mac-post .article-content li {
        margin: 0.5rem 0;
      }

      .mac-post .article-content img {
        max-width: 100%;
        height: auto;
        border: 1px solid #000;
      }

      .mac-post .article-content hr {
        border: none;
        border-top: 1px solid #000;
        margin: 2rem 0;
      }

      .mac-post .article-content br {
        display: block;
        content: "";
        margin: 0.75em 0;
      }

      /* Comments Section */
      .mac-post .comments-section {
        margin-top: 32px;
        padding-top: 24px;
        border-top: 2px solid #000;
      }

      .mac-post .comments-header {
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 14px;
        font-weight: bold;
        margin-bottom: 16px;
      }

      .mac-post .comment-form {
        background: #f5f5f5;
        padding: 16px;
        border: 1px solid #000;
        margin-bottom: 24px;
      }

      .mac-post .comment-form .form-group {
        margin-bottom: 12px;
      }

      .mac-post .comment-form label {
        display: block;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 11px;
        font-weight: bold;
        margin-bottom: 4px;
      }

      .mac-post .comment-form input[type="text"],
      .mac-post .comment-form textarea {
        width: 100%;
        padding: 8px;
        border: 1px solid #000;
        font-family: 'Charter', 'Georgia', serif;
        font-size: 14px;
        box-sizing: border-box;
      }

      .mac-post .comment-form textarea {
        resize: vertical;
        min-height: 80px;
      }

      .mac-post .comment-form .submit-btn {
        background: #fff;
        border: 1px solid #000;
        padding: 6px 16px;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        cursor: pointer;
        box-shadow: 1px 1px 0 #000;
      }

      .mac-post .comment-form .submit-btn:hover {
        background: #000;
        color: #fff;
      }

      .mac-post .comment-form .submit-btn:active {
        box-shadow: none;
        transform: translate(1px, 1px);
      }

      .mac-post .comments-list {
        display: flex;
        flex-direction: column;
        gap: 16px;
      }

      .mac-post .comment {
        background: #fff;
        border: 1px solid #000;
        padding: 12px;
      }

      .mac-post .comment-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        padding-bottom: 8px;
        border-bottom: 1px solid #ccc;
      }

      .mac-post .comment-author {
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        font-weight: bold;
      }

      .mac-post .comment-date {
        font-size: 10px;
        color: #666;
      }

      .mac-post .comment-body {
        font-family: 'Charter', 'Georgia', serif;
        font-size: 14px;
        line-height: 1.5;
        white-space: pre-wrap;
      }

      .mac-post .no-comments {
        color: #666;
        font-style: italic;
        text-align: center;
        padding: 20px;
      }

      @media (max-width: 768px) {
        .mac-post .mac-desktop {
          padding: 10px;
        }

        .mac-post .mac-window {
          width: 100%;
          margin-top: 10px;
        }

        .mac-post .menu-item {
          display: none;
        }

        .mac-post .menu-item:nth-last-child(-n+2) {
          display: inline;
        }

        .mac-post .mac-window-content {
          padding: 12px;
        }

        .mac-post .article-content {
          font-size: 15px;
        }

        .mac-post .post-meta-bar {
          flex-direction: column;
          align-items: flex-start;
          gap: 6px;
        }
      }
    </style>
    """
  end

  defp assign_meta_tags(socket, post) do
    description = get_preview(post.body)

    # Get image path, fallback to nil if generation fails
    image_path = Blog.Content.ImageGenerator.ensure_post_image(post.slug)
    image_url = if image_path, do: BlogWeb.Endpoint.url() <> image_path

    meta_tags = [
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

    # Add image tags only if we have an image
    meta_tags =
      if image_url do
        meta_tags ++
          [
            %{property: "og:image", content: image_url},
            %{property: "og:image:width", content: "1200"},
            %{property: "og:image:height", content: "630"},
            %{name: "twitter:image", content: image_url}
          ]
      else
        meta_tags
      end

    assign(socket,
      page_title: post.title,
      meta_tags: meta_tags ++ tag_meta_tags(post.tags)
    )
  end

  defp tag_meta_tags(tags) do
    Enum.map(tags, fn tag ->
      %{property: "article:tag", content: tag.name}
    end)
  end

  defp get_preview(content, max_length \\ 200) do
    content
    |> remove_tags_line()
    |> String.split("\n")
    |> Enum.join(" ")
    |> String.replace(~r/[#*`]/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, max_length)
    |> Kernel.<>("...")
  end
end
