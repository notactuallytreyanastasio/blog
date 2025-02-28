defmodule BlogWeb.RedditLinksLive do
  use BlogWeb, :live_view
  require Logger

  @max_skeets 50
  # Extract YouTube video ID from various YouTube URL formats

  def mount(_params, _session, socket) do
    # Load existing skeets from ETS
    initial_skeets =
      BlueskyHose.get_reddit_links(@max_skeets)

    if connected?(socket) do
      # Subscribe to the reddit links feed
      Phoenix.PubSub.subscribe(Blog.PubSub, "reddit_links")
    end

    {:ok,
     assign(socket,
       page_title: "Reddit Links from Bluesky",
       skeets: initial_skeets,
       filtered_skeets: initial_skeets,
       max_skeets: @max_skeets,
       meta_attrs: [
         %{name: "description", content: "Bluesky posts containing Reddit links"},
         %{property: "og:title", content: "Reddit Links from Bluesky"},
         %{property: "og:description", content: "Bluesky posts containing Reddit links"},
         %{property: "og:type", content: "website"}
       ]
     )}
  end

  def handle_info({:reddit_link, skeet}, socket) do
    # Add the new skeet to the list and trim to max size
    updated_skeets =
      [skeet | socket.assigns.skeets]
      |> Enum.take(socket.assigns.max_skeets)

    {:noreply, assign(socket, skeets: updated_skeets)}
  end


  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8">
      <h1 class="text-3xl font-bold mb-6">Youtube Links from Bluesky</h1>

      <div class="mb-8 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <p class="text-blue-800">
          This page shows Bluesky posts that contain youtube links. New posts will appear automatically.
        </p>
      </div>

      <div class="space-y-6">
        <%= if Enum.empty?(@skeets) do %>
          <div class="p-8 text-center bg-gray-50 rounded-lg border border-gray-200">
            <p class="text-gray-500">Waiting for posts with Reddit links to appear...</p>
            <p class="text-sm text-gray-400 mt-2">
              This could take some time depending on Bluesky activity.
            </p>
          </div>
        <% end %>

        <%= for skeet <- @skeets do %>
          <div class="p-4 bg-white rounded-lg shadow-md border border-gray-200 transition-all hover:shadow-lg">
            <div class="prose prose-sm max-w-none">
                <%= if youtube_id = extract_youtube_id(skeet) do %>
                  <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    <div class="aspect-w-16 aspect-h-9 w-full">
                      <iframe
                        src={"https://www.youtube.com/embed/#{youtube_id}"}
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen
                        class="w-full h-full rounded-lg"
                      >
                      </iframe>
                    </div>
                  </div>
                <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp extract_youtube_id(url) do
    cond do
      # youtu.be format
      String.match?(url, ~r/youtu\.be\/([a-zA-Z0-9_-]+)/) ->
        [[_, id]] = Regex.scan(~r/youtu\.be\/([a-zA-Z0-9_-]+)/, url)
        id

      # youtube.com/watch?v= format
      String.match?(url, ~r/youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/) ->
        [[_, id]] = Regex.scan(~r/v=([a-zA-Z0-9_-]+)/, url)
        id

      # youtube.com/v/ format
      String.match?(url, ~r/youtube\.com\/v\/([a-zA-Z0-9_-]+)/) ->
        [[_, id]] = Regex.scan(~r/youtube\.com\/v\/([a-zA-Z0-9_-]+)/, url)
        id

      # youtube.com/embed/ format
      String.match?(url, ~r/youtube\.com\/embed\/([a-zA-Z0-9_-]+)/) ->
        [[_, id]] = Regex.scan(~r/youtube\.com\/embed\/([a-zA-Z0-9_-]+)/, url)
        id

      true ->
        nil
    end
  end

end
