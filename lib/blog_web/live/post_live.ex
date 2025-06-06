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

        case Earmark.as_html(content_without_tags, code_class_prefix: "language-") do
          {:ok, html, _} ->
            socket =
              assign(socket,
                html: html,
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

            socket =
              assign(socket,
                html: html,
                post: post
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

  def render(assigns) do
    ~H"""
    <div class="px-2 py-3 font-mono text-gray-700" id="post-container">
      <div class="max-w-3xl mx-auto">
        <div class="flex flex-wrap justify-between items-center text-xs text-gray-500 mb-2">
          <div class="flex items-center space-x-3">
            <div>
              <%= if @reader_count > 1 do %>
                {@reader_count - 1} other {if @reader_count == 2, do: "person", else: "people"} reading
              <% end %>
            </div>

            <div class="border-l pl-2 border-gray-200">
              {@word_count} words · {@estimated_read_time}
            </div>
          </div>

          <div class="flex items-center space-x-3">
            <div class="flex space-x-1 border border-gray-200 rounded-md overflow-hidden shadow-sm">
              <button
                phx-click="toggle_line_numbers"
                class={"hover:bg-gray-100 px-2 py-1 flex items-center text-xs bg-white #{if @show_line_numbers, do: "border-b-2 border-blue-400"}"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class={"h-3.5 w-3.5 mr-1 #{if @show_line_numbers, do: "text-blue-500"}"}
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
                  />
                </svg>
                Line #
              </button>
            </div>

            <.link navigate={~p"/"} class="hover:underline">← Back to index</.link>
          </div>
        </div>

        <div>
          <!-- Main Content -->
          <article class="p-3 md:p-4 bg-white rounded border border-gray-200">
            <h1 class="text-2xl font-bold mb-2">{@post.title}</h1>
            
    <!-- Post metadata -->
            <div class="flex flex-wrap gap-1 text-xs mb-3">
              <%= for tag <- @post.tags do %>
                <span class="px-1.5 py-0.5 bg-gray-100 rounded text-gray-600">
                  {tag.name}
                </span>
              <% end %>
              <span class="px-1.5 py-0.5 text-gray-500">
                {Calendar.strftime(@post.written_on, "%b %d, %Y")}
              </span>
            </div>

            <div
              id="post-content"
              phx-hook="Highlight"
              class={"prose prose-sm max-w-none prose-headings:font-mono prose-headings:font-bold prose-h1:text-xl prose-h2:text-lg prose-h3:text-base prose-a:text-blue-600 prose-a:no-underline hover:prose-a:underline prose-p:my-2 prose-ul:my-2 prose-ol:my-2 prose-li:my-0.5 prose-pre:p-2 prose-pre:text-xs prose-code:text-xs prose-pre:overflow-x-auto prose-pre:whitespace-pre prose-pre:max-w-full prose-pre:border prose-pre:border-gray-200 prose-pre:shadow-sm prose-pre:relative prose-pre:group #{if @show_line_numbers, do: "line-numbers", else: ""}"}
            >
              {raw(@html)}
            </div>
          </article>
        </div>
      </div>
    </div>
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
