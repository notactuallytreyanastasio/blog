defmodule BlogWeb.SwearSkeetsLive do
  use BlogWeb, :live_view
  require Logger

  @swear_words [
    "damn",
    "hell",
    "shit",
    "fuck",
    "ass",
    "bitch",
    "piss",
    "crap",
    "bastard",
    "motherfucker",
    "asshole",
    "dickhead",
    "bullshit",
    "fucking",
    "goddamn",
    "dammit",
    "bloody",
    "wtf",
    "omfg",
    "jesus christ",
    "christ"
  ]

  @max_skeets 5_000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "bluesky:skeet")
    end

    {:ok,
     assign(socket,
       page_title: "Swear Skeets Filter",
       meta_attrs: [
         %{name: "title", content: "Swear Skeets Filter"},
         %{name: "description", content: "Filter Bluesky posts containing swear words"},
         %{property: "og:title", content: "Swear Skeets Filter"},
         %{property: "og:description", content: "Filter Bluesky posts containing swear words"},
         %{property: "og:type", content: "website"}
       ],
       skeets: [],
       filtered_skeets: [],
       swear_words: @swear_words,
       paused: false,
       new_count: 0
     )}
  end

  def handle_event("toggle_pause", _params, socket) do
    {:noreply, assign(socket, paused: !socket.assigns.paused)}
  end

  def handle_event("clear_count", _params, socket) do
    {:noreply, assign(socket, new_count: 0)}
  end

  def handle_info({:new_skeet, skeet}, socket) do
    if contains_swear_word?(skeet, @swear_words) do
      updated_skeets =
        [skeet | socket.assigns.skeets]
        |> Enum.take(@max_skeets)

      filtered_skeets =
        if socket.assigns.paused do
          socket.assigns.filtered_skeets
        else
          [skeet | socket.assigns.filtered_skeets]
          |> Enum.take(100)
        end

      new_count = 
        if socket.assigns.paused do
          socket.assigns.new_count + 1
        else
          0
        end

      {:noreply, assign(socket, skeets: updated_skeets, filtered_skeets: filtered_skeets, new_count: new_count)}
    else
      {:noreply, socket}
    end
  end

  defp contains_swear_word?(text, swear_words) do
    downcase_text = String.downcase(text)
    
    Enum.any?(swear_words, fn swear ->
      # Check for whole word matches using word boundaries
      regex = ~r/\b#{Regex.escape(swear)}\b/i
      Regex.match?(regex, downcase_text)
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-8">
      <div class="max-w-2xl mx-auto px-4">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-800 mb-2">🤬 Swear Skeets</h1>
          <p class="text-gray-600">The spiciest posts from the BlueSky firehose</p>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center space-x-4">
              <button
                phx-click="toggle_pause"
                class={"px-4 py-2 rounded-lg font-medium transition-all duration-200 #{if @paused, do: "bg-green-500 hover:bg-green-600 text-white", else: "bg-red-500 hover:bg-red-600 text-white"}"}
              >
                <%= if @paused do %>
                  ▶️ Resume
                <% else %>
                  ⏸️ Pause
                <% end %>
              </button>
              
              <%= if @paused and @new_count > 0 do %>
                <div class="flex items-center space-x-2">
                  <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800 animate-pulse">
                    {@new_count} new posts waiting
                  </span>
                  <button
                    phx-click="clear_count"
                    class="text-blue-500 hover:text-blue-700 text-sm underline"
                  >
                    Clear
                  </button>
                </div>
              <% end %>
            </div>
            
            <div class="text-sm text-gray-600">
              <span class="font-medium">{length(@filtered_skeets)}</span> spicy posts shown
            </div>
          </div>

          <div class="text-xs text-gray-600 bg-gray-50 rounded-lg p-3">
            <p class="mb-1">
              <strong>Filtering for:</strong> Words that would make your grandmother blush
            </p>
            <p>
              Posts flow in gradually to avoid overwhelming your timeline
            </p>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-md overflow-hidden">
          <%= if @filtered_skeets == [] do %>
            <div class="p-8 text-center">
              <div class="animate-spin text-4xl mb-4">🌪️</div>
              <p class="text-gray-600 text-lg">
                Scanning the firehose for spicy content...
              </p>
              <p class="text-gray-500 text-sm mt-2">
                Posts with swear words will appear here
              </p>
            </div>
          <% else %>
            <%= for {skeet, index} <- Enum.with_index(@filtered_skeets) do %>
              <div 
                class="border-b border-gray-200 px-4 py-3 transition-all duration-300 hover:bg-gray-50"
                style={"animation: fadeInUp 0.6s ease-out #{index * 0.1}s both;"}
              >
                <div class="flex space-x-3">
                  <!-- Avatar -->
                  <div class="flex-shrink-0">
                    <div class="w-12 h-12 bg-gradient-to-br from-red-500 to-orange-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                      🤬
                    </div>
                  </div>
                  
                  <!-- Tweet Content -->
                  <div class="flex-1 min-w-0">
                    <!-- Header -->
                    <div class="flex items-center space-x-2 mb-1">
                      <span class="font-bold text-gray-900">Anonymous Swearer</span>
                      <span class="text-gray-500">@spicy_poster</span>
                      <span class="text-gray-400">·</span>
                      <span class="text-gray-500 text-sm">{random_time_ago()}</span>
                    </div>
                    
                    <!-- Tweet Text -->
                    <div class="text-gray-900 text-[15px] leading-5 mb-3">
                      <p class="whitespace-pre-wrap break-words">
                        {highlight_swear_words(skeet, @swear_words)}
                      </p>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="flex items-center justify-between max-w-md text-gray-500">
                      <button class="flex items-center space-x-2 hover:text-blue-600 transition-colors group">
                        <div class="w-8 h-8 rounded-full group-hover:bg-blue-50 flex items-center justify-center">
                          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd" />
                          </svg>
                        </div>
                        <span class="text-sm">{:rand.uniform(50)}</span>
                      </button>
                      
                      <button class="flex items-center space-x-2 hover:text-green-600 transition-colors group">
                        <div class="w-8 h-8 rounded-full group-hover:bg-green-50 flex items-center justify-center">
                          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M15 8a3 3 0 10-2.977-2.63l-4.94 2.47a3 3 0 100 4.319l4.94 2.47a3 3 0 10.895-1.789l-4.94-2.47a3.027 3.027 0 000-.74l4.94-2.47C13.456 7.68 14.19 8 15 8z" />
                          </svg>
                        </div>
                        <span class="text-sm">{:rand.uniform(25)}</span>
                      </button>
                      
                      <button class="flex items-center space-x-2 hover:text-red-600 transition-colors group">
                        <div class="w-8 h-8 rounded-full group-hover:bg-red-50 flex items-center justify-center">
                          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd" />
                          </svg>
                        </div>
                        <span class="text-sm">{:rand.uniform(100)}</span>
                      </button>
                      
                      <button class="hover:text-blue-600 transition-colors group">
                        <div class="w-8 h-8 rounded-full group-hover:bg-blue-50 flex items-center justify-center">
                          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M15 8a3 3 0 10-2.977-2.63l-4.94 2.47a3 3 0 100 4.319l4.94 2.47a3 3 0 10.895-1.789l-4.94-2.47a3.027 3.027 0 000-.74l4.94-2.47C13.456 7.68 14.19 8 15 8z" />
                          </svg>
                        </div>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>

    <style>
      @keyframes fadeInUp {
        from {
          opacity: 0;
          transform: translateY(30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      .swear-highlight {
        background: linear-gradient(120deg, #ff6b6b 0%, #ffd93d 100%);
        color: #333;
        padding: 1px 3px;
        border-radius: 3px;
        font-weight: 600;
      }
    </style>
    """
  end

  defp random_time_ago do
    times = ["2m", "5m", "1h", "3h", "12h", "1d", "2d", "now"]
    Enum.random(times)
  end

  defp highlight_swear_words(text, swear_words) do
    highlighted = 
      Enum.reduce(swear_words, text, fn swear, acc ->
        regex = ~r/\b(#{Regex.escape(swear)})\b/i
        String.replace(acc, regex, "<span class=\"swear-highlight\">\\1</span>")
      end)
    
    Phoenix.HTML.raw(highlighted)
  end
end