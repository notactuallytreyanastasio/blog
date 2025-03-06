defmodule BlogWeb.WordleGodLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Wordle.Game

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to the global wordle games topic
    Phoenix.PubSub.subscribe(Blog.PubSub, Game.topic())

    # Debug message
    IO.puts("WordleGodLive subscribed to #{Game.topic()}")

    # Initialize with empty games map
    {:ok, assign(socket, games: %{}, page_title: "Wordle God Mode")}
  end

  @impl true
  def handle_info({:game_updated, game}, socket) do
    # Debug info
    IO.puts("Received game update in WordleGodLive: #{game.session_id}")

    # Update the games map with the latest game state
    # Always include active games - removed the filtering for troubleshooting
    games = Map.put(socket.assigns.games, game.session_id, game)

    {:noreply, assign(socket, games: games)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Wordle God Mode</h1>
        <div><%= map_size(@games) %> active games</div>
      </div>

      <div class="mb-4 p-4 bg-gray-100 rounded-lg">
        <h2 class="text-lg font-bold mb-2">Debug Info</h2>
        <div class="text-sm">
          <p>Subscribed to topic: <%= Blog.Wordle.Game.topic() %></p>
          <p>Games in state: <%= Kernel.inspect(Map.keys(@games)) %></p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <%= for {_session_id, game} <- @games do %>
          <div class="bg-white p-4 rounded-lg shadow-md">
            <div class="flex justify-between items-center mb-2">
              <div class="font-bold">
                Player: <%= game.player_id %>
              </div>
              <div class="text-xs text-gray-500">
                <%= if game.last_activity, do: format_time_ago(game.last_activity), else: "Unknown" %>
              </div>
            </div>

            <div class="text-sm mb-2">
              <span class="font-semibold">Target:</span> <%= game.target_word %>
              <span class={["ml-2", if(game.hard_mode, do: "text-yellow-600 font-bold", else: "text-gray-500")]}>
                <%= if game.hard_mode, do: "HARD MODE", else: "Normal" %>
              </span>
            </div>

            <div class="text-sm mb-3">
              <span class="font-semibold">Status:</span>
              <%= cond do %>
                <% game.game_over && Enum.any?(game.guesses, fn %{word: word} -> word == game.target_word end) -> %>
                  <span class="text-green-600 font-bold">Won</span>
                <% game.game_over -> %>
                  <span class="text-red-600 font-bold">Lost</span>
                <% true -> %>
                  <span class="text-blue-600">In Progress (<%= length(game.guesses) %>/<%= game.max_attempts %> guesses)</span>
              <% end %>
            </div>

            <div class="grid grid-rows-6 gap-[3px] mb-2">
              <%= for %{word: guess, result: result} <- game.guesses do %>
                <div class="grid grid-cols-5 gap-[3px]">
                  <%= for {letter, status} <- Enum.zip(String.graphemes(guess), result) do %>
                    <div class={["w-full aspect-square flex items-center justify-center text-sm font-bold text-white rounded-none uppercase", color_class(status)]}>
                      <%= letter %>
                    </div>
                  <% end %>
                </div>
              <% end %>

              <%= if length(game.guesses) < game.max_attempts && !game.game_over do %>
                <div class="grid grid-cols-5 gap-[3px]">
                  <%= for i <- 0..4 do %>
                    <div class={["w-full aspect-square flex items-center justify-center text-sm font-bold rounded-none uppercase border", if(i < String.length(game.current_guess), do: "border-gray-600", else: "border-gray-300")]}>
                      <%= String.at(game.current_guess, i) %>
                    </div>
                  <% end %>
                </div>

                <%= for _i <- (length(game.guesses) + 1)..(game.max_attempts - 1) do %>
                  <div class="grid grid-cols-5 gap-[3px]">
                    <%= for _j <- 1..5 do %>
                      <div class="w-full aspect-square flex items-center justify-center text-sm font-bold rounded-none border border-gray-200">
                      </div>
                    <% end %>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp color_class(:correct), do: "bg-green-600 border-green-600"
  defp color_class(:present), do: "bg-yellow-500 border-yellow-500"
  defp color_class(:absent), do: "bg-gray-600 border-gray-600"
  defp color_class(_), do: "border-2 border-gray-300"

  defp format_time_ago(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _} ->
        seconds_diff = DateTime.diff(DateTime.utc_now(), datetime)
        cond do
          seconds_diff < 60 -> "just now"
          seconds_diff < 3600 -> "#{div(seconds_diff, 60)} min ago"
          seconds_diff < 86400 -> "#{div(seconds_diff, 3600)} hours ago"
          true -> "#{div(seconds_diff, 86400)} days ago"
        end
      _ ->
        "Unknown"
    end
  end

  defp format_time_ago(_), do: "Unknown"
end
