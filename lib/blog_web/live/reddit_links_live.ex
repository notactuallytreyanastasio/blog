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
         %{name: "description", content: "Bluesky posts containing Youtube links"},
         %{property: "og:title", content: "Youtube Links from Bluesky"},
         %{property: "og:description", content: "Bluesky posts containing Youtube links"},
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
    <div class="os-desktop-osx">
      <div class="os-window os-window-osx" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <div class="os-titlebar-buttons">
            <a href="/" class="os-btn-close"></a>
            <span class="os-btn-min"></span>
            <span class="os-btn-max"></span>
          </div>
          <span class="os-titlebar-title">YouTube Links from Bluesky</span>
          <div class="os-titlebar-spacer"></div>
        </div>
        <div class="os-content" style="height: calc(100% - 60px); overflow-y: auto; background: linear-gradient(180deg, #f5f5f5 0%, #e5e5e5 100%);">
          <div class="p-6">
            <div class="mb-6 p-4 bg-blue-100 rounded-lg border border-blue-300 shadow-sm">
              <p class="text-blue-900">
                This page shows Bluesky posts that contain YouTube links. New posts will appear automatically.
              </p>
            </div>

            <div class="space-y-4">
              <%= if Enum.empty?(@skeets) do %>
                <div class="p-8 text-center bg-white rounded-lg shadow-md">
                  <p class="text-gray-500">Waiting for posts with YouTube links to appear...</p>
                  <p class="text-sm text-gray-400 mt-2">
                    This could take some time depending on Bluesky activity.
                  </p>
                </div>
              <% end %>

              <%= for skeet <- @skeets do %>
                <div class="p-4 bg-white rounded-lg shadow-md transition-all hover:shadow-lg">
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
        </div>
        <div class="os-statusbar">
          <span>Videos: {length(@skeets)}</span>
          <span>Max: {@max_skeets}</span>
        </div>
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
