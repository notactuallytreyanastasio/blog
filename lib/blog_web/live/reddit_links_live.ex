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
       filtered_skeets: filter_nsfw_skeets(initial_skeets, true),
       max_skeets: @max_skeets,
       filter_nsfw: true,
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

    # Apply NSFW filter if enabled
    filtered_skeets = filter_nsfw_skeets(updated_skeets, socket.assigns.filter_nsfw)

    {:noreply, assign(socket, skeets: updated_skeets, filtered_skeets: filtered_skeets)}
  end

  def handle_event("toggle_nsfw_filter", _params, socket) do
    # Toggle the filter state
    filter_nsfw = !socket.assigns.filter_nsfw

    # Apply the filter to the current skeets
    filtered_skeets = filter_nsfw_skeets(socket.assigns.skeets, filter_nsfw)

    {:noreply, assign(socket, filter_nsfw: filter_nsfw, filtered_skeets: filtered_skeets)}
  end

  # Filter out NSFW skeets if the filter is enabled
  defp filter_nsfw_skeets(skeets, true) do
    Enum.reject(skeets, fn skeet ->
      is_nsfw?(skeet.original_text)
    end)
  end

  # Return all skeets if the filter is disabled
  defp filter_nsfw_skeets(skeets, false), do: skeets

  # Check if a skeet contains NSFW indicators
  defp is_nsfw?(text) when is_binary(text) do
    nsfw_patterns = [
      ~r/\bNSFW\b/i,
      ~r/\bNSFL\b/i,
      ~r/\b18\+\b/,
      ~r/\bXXX\b/i
    ]

    Enum.any?(nsfw_patterns, fn pattern ->
      Regex.match?(pattern, text)
    end)
  end

  defp is_nsfw?(_), do: false

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8">
      <h1 class="text-3xl font-bold mb-6">Reddit Links from Bluesky</h1>

      <div class="mb-4 flex items-center">
        <div class="form-control">
          <label class="cursor-pointer flex items-center">
            <input
              type="checkbox"
              checked={@filter_nsfw}
              class="checkbox checkbox-primary mr-2"
              phx-click="toggle_nsfw_filter"
            />
            <span class="label-text text-gray-700">Filter NSFW content</span>
          </label>
        </div>
      </div>

      <div class="mb-8 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <p class="text-blue-800">
          This page shows Bluesky posts that contain Reddit links. New posts will appear automatically.
        </p>
      </div>

      <div class="space-y-6">
        <%= if Enum.empty?(@filtered_skeets) do %>
          <div class="p-8 text-center bg-gray-50 rounded-lg border border-gray-200">
            <p class="text-gray-500">Waiting for posts with Reddit links to appear...</p>
            <p class="text-sm text-gray-400 mt-2">This could take some time depending on Bluesky activity.</p>
          </div>
        <% end %>

        <%= for skeet <- @filtered_skeets do %>
          <div class="p-4 bg-white rounded-lg shadow-md border border-gray-200 transition-all hover:shadow-lg">
            <div class="prose prose-sm max-w-none">
              <div class="text-sm text-gray-600 mb-2 italic">Original post: <%= String.slice(skeet.original_text, 0, 300) %><%= if String.length(skeet.original_text) > 300, do: "...", else: "" %></div>
              <ul class="list-disc pl-5">
                <%= for link <- skeet.links do %>
                  <li class="mb-1">
                    <a href={link} class="text-blue-600 hover:underline break-all" target="_blank"><%= link %></a>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
