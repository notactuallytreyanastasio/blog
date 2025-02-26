defmodule BlogWeb.SwearStreamLive do
  use BlogWeb, :live_view
  require Logger

  @common_swears [
    "FUCK", "SHIT", "DAMN", "BITCH", "CUNT", "ASSHOLE", "BASTARD",
    "PISS", "COCK", "DICK", "ASS", "BULLSHIT", "MOTHERFUCKER",
    "HELL", "CRAP", "WHORE", "SLUT", "DOUCHE", "JERK", "IDIOT"
  ]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to the general skeet feed
      Phoenix.PubSub.subscribe(Blog.PubSub, "skeet_feed")
    end

    {:ok,
     assign(socket,
       page_title: "Swear Stream",
       selected_swear: nil,
       search_term: "",
       filtered_swears: [],
       common_swears: @common_swears,
       skeets: [],
       max_skeets: 50,
       show_suggestions: false
     )}
  end

  def handle_event("search", %{"search" => search_term}, socket) do
    filtered_swears =
      if String.length(search_term) > 0 do
        @common_swears
        |> Enum.filter(fn swear ->
          String.contains?(String.downcase(swear), String.downcase(search_term))
        end)
        |> Enum.sort()
      else
        []
      end

    {:noreply,
     assign(socket,
       search_term: search_term,
       filtered_swears: filtered_swears,
       show_suggestions: String.length(search_term) > 0
     )}
  end

  def handle_event("select_swear", %{"swear" => swear}, socket) do
    # Check if the selected swear is in our options or a custom entry
    if swear in @common_swears or String.length(swear) > 0 do
      {:noreply,
       assign(socket,
         selected_swear: swear,
         search_term: swear,
         filtered_swears: [],
         show_suggestions: false,
         skeets: [] # Reset skeets when changing filter
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("use_custom", _, socket) do
    if String.length(socket.assigns.search_term) > 0 do
      {:noreply,
       assign(socket,
         selected_swear: String.upcase(socket.assigns.search_term),
         filtered_swears: [],
         show_suggestions: false,
         skeets: [] # Reset skeets when changing filter
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:new_post, skeet}, socket) do
    selected_swear = socket.assigns.selected_swear

    # If no swear is selected or the skeet doesn't contain the selected swear, do nothing
    if is_nil(selected_swear) or not contains_swear?(skeet, selected_swear) do
      {:noreply, socket}
    else
      # Add the new skeet to our collection
      updated_skeets = [%{text: skeet, timestamp: DateTime.utc_now()} | socket.assigns.skeets]
      |> Enum.take(socket.assigns.max_skeets) # Keep only the most recent skeets

      {:noreply, assign(socket, skeets: updated_skeets)}
    end
  end

  defp contains_swear?(text, swear) do
    String.contains?(String.downcase(text), String.downcase(swear))
  end

  # Helper function to highlight the swear word in the text
  defp highlight_swear(text, swear) do
    regex = ~r/#{Regex.escape(swear)}/i
    String.replace(text, regex, fn match ->
      "<span class=\"text-red-500 font-bold\">#{match}</span>"
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-white p-4 font-mono">
      <div class="max-w-4xl mx-auto">
        <div class="mb-8 border-b border-gray-800 pb-4">
          <h1 class="text-4xl font-bold mb-2 glitch" data-text="SWEAR STREAM">SWEAR STREAM</h1>
          <p class="text-gray-400">Search for a swear word to see matching skeets in real-time</p>
        </div>

        <div class="mb-8">
          <form phx-change="search" class="relative">
            <div class="flex items-center gap-2">
              <div class="relative flex-1">
                <input
                  type="text"
                  name="search"
                  value={@search_term}
                  placeholder="Type a swear word..."
                  class="w-full bg-gray-900 border border-gray-700 rounded px-4 py-2 text-white text-xl focus:outline-none focus:border-blue-500"
                  autocomplete="off"
                />
                <%= if @show_suggestions and not Enum.empty?(@filtered_swears) do %>
                  <div class="absolute z-10 w-full mt-1 bg-gray-900 border border-gray-700 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                    <%= for swear <- @filtered_swears do %>
                      <button
                        type="button"
                        phx-click="select_swear"
                        phx-value-swear={swear}
                        class="w-full text-left px-4 py-2 hover:bg-gray-800 focus:bg-gray-800 focus:outline-none"
                      >
                        <%= swear %>
                      </button>
                    <% end %>
                  </div>
                <% end %>
              </div>
              <%= if String.length(@search_term) > 0 and is_nil(@selected_swear) do %>
                <button
                  type="button"
                  phx-click="use_custom"
                  class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
                >
                  Search
                </button>
              <% end %>
            </div>
          </form>

          <%= if @selected_swear do %>
            <div class="mt-4 flex items-center">
              <div class="bg-red-900/50 text-red-300 px-3 py-1 rounded-lg flex items-center">
                <span>Filtering by: <span class="font-bold"><%= @selected_swear %></span></span>
                <button
                  phx-click="select_swear"
                  phx-value-swear=""
                  class="ml-2 text-red-300 hover:text-white"
                >
                  <.icon name="hero-x-mark" class="h-4 w-4" />
                </button>
              </div>
            </div>
          <% end %>
        </div>

        <%= if is_nil(@selected_swear) do %>
          <div class="flex items-center justify-center h-64 border-2 border-dashed border-gray-700 rounded-lg">
            <p class="text-2xl text-gray-500">Search for a swear word to start seeing skeets</p>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= if Enum.empty?(@skeets) do %>
              <div class="flex items-center justify-center h-64 border-2 border-dashed border-gray-700 rounded-lg">
                <p class="text-xl text-gray-500">Waiting for skeets containing "<%= @selected_swear %>"...</p>
              </div>
            <% else %>
              <%= for {skeet, index} <- Enum.with_index(@skeets) do %>
                <div
                  id={"skeet-#{index}"}
                  class="border border-gray-800 p-4 rounded-lg hover:border-gray-600 transition-all"
                  phx-mounted={JS.transition("fade-in-slide", time: 500)}
                >
                  <div class="flex justify-between items-start mb-2">
                    <div class="text-gray-400 text-sm">
                      <%= Calendar.strftime(skeet.timestamp, "%Y-%m-%d %H:%M:%S") %>
                    </div>
                  </div>
                  <p class="whitespace-pre-wrap"><%= raw(highlight_swear(skeet.text, @selected_swear)) %></p>
                </div>
              <% end %>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>

    <style>
    .glitch {
      position: relative;
      text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                   0.025em 0.04em 0 #fffc00;
      animation: glitch 725ms infinite;
    }

    @keyframes glitch {
      0% {
        text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                     0.025em 0.04em 0 #fffc00;
      }
      15% {
        text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                     0.025em 0.04em 0 #fffc00;
      }
      16% {
        text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.035em 0 #fc00ff,
                     -0.05em -0.05em 0 #fffc00;
      }
      49% {
        text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.035em 0 #fc00ff,
                     -0.05em -0.05em 0 #fffc00;
      }
      50% {
        text-shadow: 0.05em 0.035em 0 #00fffc, 0.03em 0 0 #fc00ff,
                     0 -0.04em 0 #fffc00;
      }
      99% {
        text-shadow: 0.05em 0.035em 0 #00fffc, 0.03em 0 0 #fc00ff,
                     0 -0.04em 0 #fffc00;
      }
      100% {
        text-shadow: -0.05em 0 0 #00fffc, -0.025em -0.04em 0 #fc00ff,
                     -0.04em -0.025em 0 #fffc00;
      }
    }

    .fade-in-slide {
      animation: fadeInSlide 0.5s ease-out;
    }

    @keyframes fadeInSlide {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
    </style>
    """
  end
end
