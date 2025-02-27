defmodule BlogWeb.RedditLinksLive do
  use BlogWeb, :live_view
  require Logger

  @max_skeets 50

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
      <h1 class="text-3xl font-bold mb-6">Reddit Links from Bluesky</h1>
      <div class="mb-8 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <p class="text-blue-800">
          This page shows Bluesky posts that contain Reddit links. New posts will appear automatically.
        </p>
      </div>

      <div class="space-y-6">
        <%= if Enum.empty?(@skeets) do %>
          <div class="p-8 text-center bg-gray-50 rounded-lg border border-gray-200">
            <p class="text-gray-500">Waiting for posts with Reddit links to appear...</p>
            <p class="text-sm text-gray-400 mt-2">This could take some time depending on Bluesky activity.</p>
          </div>
        <% end %>

        <%= for skeet <- @skeets do %>
          <%= skeet.text %>
        <% end %>
      </div>
    </div>
    """
  end
end
