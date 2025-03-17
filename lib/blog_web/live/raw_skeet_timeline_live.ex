defmodule BlogWeb.RawSkeetTimelineLive do
  use BlogWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "sample_skeets")
    end

    # Initialize with empty list
    socket = assign(socket, skeets: [])

    {:ok, socket}
  end

  @impl true
  def handle_info({:sample_skeet, skeet}, socket) do
    # Add the new skeet to the beginning of the list
    # Include timestamp for display purposes
    new_skeet = %{
      content: skeet,
      timestamp: System.system_time(:millisecond)
    }

    # Prepend the new skeet to our list
    updated_skeets = [new_skeet | socket.assigns.skeets]

    # Limit to most recent 100 to prevent the list from growing too large
    limited_skeets = Enum.take(updated_skeets, 100)

    socket = assign(socket, skeets: limited_skeets)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="raw-skeet-timeline container mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold mb-2">Raw Skeet Timeline</h1>
        <p class="text-gray-600">Displaying raw skeet data from the PubSub channel in real-time.</p>
      </div>

      <div class="skeet-container space-y-6">
        <%= if Enum.empty?(@skeets) do %>
          <div class="p-6 bg-gray-100 rounded-lg text-center">
            <p class="text-gray-500">Waiting for skeets...</p>
          </div>
        <% else %>
          <%= for skeet <- @skeets do %>
            <div class="skeet-item bg-white p-6 rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition">
              <div class="skeet-content text-sm font-mono whitespace-pre-wrap overflow-auto max-h-96">
                <%= skeet.content %>
              </div>
              <div class="text-xs text-gray-500 mt-4 flex justify-between items-center">
                <span><%= format_timestamp(skeet.timestamp) %></span>
                <span class="bg-gray-100 px-2 py-1 rounded-full text-xs">
                  <%= byte_size(inspect(skeet.content)) %> bytes
                </span>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper function to format timestamps
  defp format_timestamp(timestamp) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
  end
end
