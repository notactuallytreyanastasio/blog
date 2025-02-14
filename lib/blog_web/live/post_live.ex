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
      {:ok, _} = Presence.track(self(), @presence_topic, reader_id, %{
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

        # require IEx; IEx.pry
        Logger.debug("Found post: #{inspect(post, pretty: true)}")
        case Earmark.as_html(post.body, code_class_prefix: "language-") do
          {:ok, html, _} ->
            headers = extract_headers(post.body)
            socket = assign(socket,
              html: html,
              headers: headers,
              reader_count: get_reader_count(slug)
            )
            {:ok, socket}

          {:error, html, errors} ->
            # Still show the content even if there are markdown errors
            Logger.error("Markdown parsing warnings: #{inspect(errors)}")
            headers = extract_headers(post.body)
            socket = assign(socket,
              html: html,
              headers: headers,
              post: post
            )
            {:ok, socket}
        end
    end
  end

  defp truncated_post(body) do
    String.slice(body, 0, 250) <> "..."
  end

  def handle_info(%{event: "presence_diff"} = _diff, socket) do
    socket = assign(socket,
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
            <%= @reader_count - 1 %> other <%= if @reader_count == 2, do: "person", else: "people" %> reading this post
          <% end %>
        </div>
        <div class="mb-12 p-6 bg-gray-50 rounded-lg border-2 border-gray-200">
          <h2 class="text-xl font-bold mb-4 pb-2 border-b-2 border-gray-200">Table of Contents</h2>
          <ul class="space-y-2">
            <%= for {text, level} <- @headers do %>
              <li class={[
                "hover:text-blue-600 transition-colors",
                level_to_padding(level)
              ]}>
                <a href={"##{generate_id(text)}"}><%= text %></a>
              </li>
            <% end %>
          </ul>
        </div>

        <article class="p-8 bg-white rounded-lg border-2 border-gray-200">
          <div id="post-content" phx-hook="Highlight" class="prose prose-lg prose-headings:font-mono prose-headings:font-bold prose-h1:text-4xl prose-h2:text-3xl prose-h3:text-2xl max-w-none">
            <%= raw(@html) %>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp extract_headers(markdown) do
    markdown
    |> String.split("\n")
    |> Enum.filter(&header?/1)
    |> Enum.map(fn line ->
      {text, level} = parse_header(line)
      {text, level}
    end)
  end

  defp header?(line) do
    String.match?(line, ~r/^#+\s+.+$/)
  end

  defp parse_header(line) do
    [hashes | words] = String.split(line, " ")
    level = String.length(hashes)
    text = Enum.join(words, " ")
    {text, level}
  end

  defp generate_id(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
    |> String.trim("-")
  end

  defp level_to_padding(1), do: "pl-0"
  defp level_to_padding(2), do: "pl-4"
  defp level_to_padding(3), do: "pl-8"
  defp level_to_padding(4), do: "pl-12"
  defp level_to_padding(_), do: "pl-16"

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
      %{property: "article:published_time",
        content: DateTime.from_naive!(post.written_on, "Etc/UTC") |> DateTime.to_iso8601()},
      %{name: "twitter:card", content: "summary_large_image"},
      %{name: "twitter:title", content: post.title},
      %{name: "twitter:description", content: description}
    ]

    # Add image tags only if we have an image
    meta_tags = if image_url do
      meta_tags ++ [
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
    |> String.split("\n")
    |> Enum.reject(&String.starts_with?(&1, "tags:"))
    |> Enum.join(" ")
    |> String.replace(~r/[#*`]/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, max_length)
    |> Kernel.<>("...")
  end
end
