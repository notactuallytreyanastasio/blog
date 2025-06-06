defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  require Logger

  @presence_topic "blog_presence"

  def mount(%{"slug" => slug}, _session, socket) do
    if connected?(socket) do
      # Subscribe first to get presence updates
      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)

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
            
            socket =
              assign(socket,
                html: processed_html,
                reader_count: get_reader_count(slug),
                word_count: word_count(content_without_tags),
                estimated_read_time: estimated_read_time(content_without_tags),
                # Default to showing line numbers
                show_line_numbers: true
              )

            {:ok, socket}

          {:error, html, errors} ->
            # Still show the content even if there are markdown errors
            Logger.error("Markdown parsing warnings: #{inspect(errors)}")
            
            # Still try to process details blocks even if there were errors
            processed_html = process_details_in_html(html)

            socket =
              assign(socket,
                html: processed_html,
                post: post,
                reader_count: get_reader_count(slug),
                word_count: word_count(content_without_tags),
                estimated_read_time: estimated_read_time(content_without_tags),
                show_line_numbers: true
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

  def render(assigns) do
    ~H"""
    <article class="min-h-screen bg-gray-50">
      <!-- Header with navigation and metadata -->
      <header class="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div class="max-w-4xl mx-auto px-6 py-4">
          <div class="flex items-center justify-between">
            <.link navigate={~p"/"} class="flex items-center text-gray-600 hover:text-gray-900 transition-colors">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
              </svg>
              Back to posts
            </.link>
            
            <div class="flex items-center space-x-4 text-sm text-gray-500">
              <%= if @reader_count > 1 do %>
                <div class="flex items-center">
                  <div class="w-2 h-2 bg-green-400 rounded-full mr-2"></div>
                  {@reader_count - 1} {if @reader_count == 2, do: "other reader", else: "others reading"}
                </div>
              <% end %>
              <div>{@word_count} words</div>
              <div>{@estimated_read_time}</div>
            </div>
          </div>
        </div>
      </header>

      <!-- Main content -->
      <div class="max-w-4xl mx-auto px-6 py-12">
        <!-- Article header -->
        <header class="mb-12">
          <h1 class="text-4xl md:text-5xl font-bold text-gray-900 leading-tight mb-6">
            {@post.title}
          </h1>
          
          <div class="flex items-center justify-between mb-8">
            <time class="text-gray-600 font-medium">
              {Calendar.strftime(@post.written_on, "%B %d, %Y")}
            </time>
            
            <div class="flex flex-wrap gap-2">
              <%= for tag <- @post.tags do %>
                <span class="px-3 py-1 bg-blue-100 text-blue-800 text-sm font-medium rounded-full">
                  {tag.name}
                </span>
              <% end %>
            </div>
          </div>
          
          <!-- Reading progress indicator -->
          <div class="w-full h-1 bg-gray-200 rounded-full overflow-hidden">
            <div class="h-full bg-blue-500 rounded-full transition-all duration-300" style="width: 0%" id="reading-progress"></div>
          </div>
        </header>

        <!-- Article body -->
        <div class="prose prose-lg prose-gray max-w-none">
          <div
            id="post-content"
            phx-hook="Highlight"
            class="article-content"
          >
            {raw(@html)}
          </div>
        </div>
      </div>
    </article>
    
    <script>
      // Reading progress indicator
      window.addEventListener('scroll', function() {
        const article = document.querySelector('.article-content');
        const progress = document.getElementById('reading-progress');
        if (article && progress) {
          const articleHeight = article.offsetHeight;
          const windowHeight = window.innerHeight;
          const scrollTop = window.pageYOffset;
          const scrollPercent = (scrollTop / (articleHeight + windowHeight - window.innerHeight)) * 100;
          progress.style.width = Math.min(100, Math.max(0, scrollPercent)) + '%';
        }
      });
    </script>
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
