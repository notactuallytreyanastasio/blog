defmodule BlogWeb.RedditLinksLive do
  use BlogWeb, :live_view
  require Logger

  @max_skeets 50

  def mount(_params, _session, socket) do
    initial_skeets = BlueskyHose.get_reddit_links(@max_skeets)

    # Create a map of position => video_url for stable grid positioning
    # Videos stay in their grid cell - no shifting when new ones arrive
    videos =
      initial_skeets
      |> Enum.with_index()
      |> Map.new(fn {url, idx} -> {idx, %{url: url, key: make_key()}} end)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "reddit_links")
    end

    {:ok,
     assign(socket,
       page_title: "YouTube Links from Bluesky",
       videos: videos,
       next_pos: map_size(videos),
       max_skeets: @max_skeets,
       newest_pos: nil,
       meta_attrs: [
         %{name: "description", content: "Bluesky posts containing Youtube links"},
         %{property: "og:title", content: "Youtube Links from Bluesky"},
         %{property: "og:description", content: "Bluesky posts containing Youtube links"},
         %{property: "og:type", content: "website"}
       ]
     )}
  end

  def handle_info({:reddit_link, skeet}, socket) do
    max = socket.assigns.max_skeets
    videos = socket.assigns.videos
    next_pos = socket.assigns.next_pos

    # Calculate position: fills grid sequentially, then wraps around to replace oldest
    write_pos = rem(next_pos, max)

    # Use a new key to trigger animation on replacement
    updated_videos = Map.put(videos, write_pos, %{url: skeet, key: make_key()})

    {:noreply,
     assign(socket,
       videos: updated_videos,
       next_pos: next_pos + 1,
       newest_pos: write_pos
     )}
  end

  defp make_key, do: System.unique_integer([:positive])

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

            <%= if map_size(@videos) == 0 do %>
              <div class="p-8 text-center bg-white rounded-lg shadow-md">
                <p class="text-gray-500">Waiting for posts with YouTube links to appear...</p>
                <p class="text-sm text-gray-400 mt-2">
                  This could take some time depending on Bluesky activity.
                </p>
              </div>
            <% else %>
              <style>
                @keyframes video-slide-in {
                  0% { opacity: 0; transform: scale(0.8); }
                  100% { opacity: 1; transform: scale(1); }
                }
                .video-card-new {
                  animation: video-slide-in 0.4s ease-out;
                }
              </style>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                <%= for pos <- Enum.sort(Map.keys(@videos)) do %>
                  <% video = @videos[pos] %>
                  <%= if youtube_id = extract_youtube_id(video.url) do %>
                    <div
                      id={"video-slot-#{pos}-#{video.key}"}
                      class={[
                        "bg-white rounded-lg shadow-md overflow-hidden transition-shadow hover:shadow-xl",
                        @newest_pos == pos && "video-card-new"
                      ]}
                    >
                      <div class="relative pb-[56.25%]">
                        <iframe
                          src={"https://www.youtube.com/embed/#{youtube_id}"}
                          frameborder="0"
                          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                          allowfullscreen
                          class="absolute inset-0 w-full h-full"
                        >
                        </iframe>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
        <div class="os-statusbar">
          <span>Videos: {map_size(@videos)}</span>
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
