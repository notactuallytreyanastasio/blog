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
                reader_count: get_reader_count(slug)
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

  def render(assigns) do
    ~H"""
    <div class="px-8 py-12 font-mono text-gray-700">
      <div class="max-w-7xl mx-auto">
        <div class="mb-4 text-sm text-gray-500">
          <%= if @reader_count > 1 do %>
            {@reader_count - 1} other {if @reader_count == 2, do: "person", else: "people"} reading this post
          <% end %>
        </div>

        <article class="p-8 bg-white rounded-lg border-2 border-gray-200">
          <div
            id="post-content"
            phx-hook="Highlight"
            class="prose prose-lg prose-headings:font-mono prose-headings:font-bold prose-h1:text-4xl prose-h2:text-3xl prose-h3:text-2xl max-w-none"
          >
            {raw(@html)}
          </div>
        </article>
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
