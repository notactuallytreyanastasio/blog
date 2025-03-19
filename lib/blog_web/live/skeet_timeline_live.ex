defmodule BlogWeb.SkeetTimelineLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.SkeetStore
  import Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    # Initialize the ETS table if needed - with error handling
    try do
      SkeetStore.init()
    rescue
      e ->
        Logger.error("Error initializing SkeetStore: #{inspect(e)}")
    end

    # Subscribe to the PubSub topic for skeet updates
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "sample_skeets")
    end

    # Get the initial skeets to display - with error handling
    skeets =
      try do
        SkeetStore.get_recent_skeets()
      rescue
        e ->
          Logger.error("Error fetching recent skeets: #{inspect(e)}")
          []
      end

    socket =
      socket
      |> assign(:skeets, skeets)
      |> assign(:new_skeet_count, 0)
      |> assign(:new_skeets, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("load_new_skeets", _params, socket) do
    # Append the new skeets to the beginning of our list
    updated_skeets = socket.assigns.new_skeets ++ socket.assigns.skeets

    socket =
      socket
      |> assign(:skeets, updated_skeets)
      |> assign(:new_skeet_count, 0)
      |> assign(:new_skeets, [])
      |> push_event("scroll-to-top", %{})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:sample_skeet, skeet}, socket) do
    # Store the skeet in ETS - with error handling
    try do
      SkeetStore.add_skeet(skeet)
    rescue
      e ->
        Logger.error("Error storing skeet: #{inspect(e)}")
    end

    # Add the skeet to our new skeets list and increment the counter
    new_skeet = %{skeet: skeet, timestamp: System.system_time(:millisecond)}
    new_skeets = [new_skeet | socket.assigns.new_skeets]
    new_count = socket.assigns.new_skeet_count + 1

    socket =
      socket
      |> assign(:new_skeet_count, new_count)
      |> assign(:new_skeets, new_skeets)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="skeet-timeline font-mono" phx-hook="ScrollToTop" id="skeet-timeline">
      <div class="mb-4 pt-4">
        <h1 class="text-2xl font-bold mb-2">Bluesky Skeet Timeline</h1>
        <p class="text-sm mb-4">A retro minimalist view of the Bluesky firehose</p>
      </div>

      <%= if @new_skeet_count > 0 do %>
        <div
          class="sticky top-2 left-0 right-0 mx-auto w-64 bg-blue-500 text-white font-mono text-center py-2 px-4 rounded-full cursor-pointer shadow-lg z-10 mb-4"
          phx-click="load_new_skeets"
        >
          {@new_skeet_count} new {if @new_skeet_count == 1, do: "skeet", else: "skeets"}
        </div>
      <% end %>

      <div id="skeet-anchor" class="h-0"></div>
      <div class="skeet-container space-y-4">
        <%= for skeet_data <- @skeets do %>
          <div class="skeet-item p-4 border border-gray-300 rounded-md hover:bg-gray-50">
            <div class="skeet-content whitespace-pre-wrap font-mono text-sm">
              {skeet_data.skeet}
            </div>
            <div class="text-xs text-gray-500 mt-2 font-mono">
              {format_timestamp(skeet_data.timestamp)}
            </div>
          </div>
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
