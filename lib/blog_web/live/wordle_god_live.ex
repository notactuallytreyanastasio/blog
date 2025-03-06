defmodule BlogWeb.WordleGodLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Wordle.{Game, GameStore}

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to the global wordle games topic
    Phoenix.PubSub.subscribe(Blog.PubSub, Game.topic())

    # Debug message
    Logger.info("WordleGodLive subscribed to #{Game.topic()}")

    # Get all existing games from ETS
    existing_games = GameStore.all_games_map()
    Logger.info("Loaded #{map_size(existing_games)} existing games from ETS")

    # Start a timer process for cleaning up stale games
    if connected?(socket) do
      :timer.send_interval(60_000, self(), :cleanup_stale_games)  # Every minute
    end

    # Initialize with games map from ETS
    {:ok, assign(socket,
      games: existing_games,
      page_title: "Wordle God Mode",
      stats: calculate_stats(existing_games)
    )}
  end

  @impl true
  def handle_info({:game_updated, game}, socket) do
    games = Map.put(socket.assigns.games, game.session_id, game)
    stats = calculate_stats(games)

    {:noreply, assign(socket, games: games, stats: stats)}
  end

  @impl true
  def handle_info(:cleanup_stale_games, socket) do
    # Clean up games that haven't had activity in the last hour
    GameStore.cleanup_stale_games(1)

    # Get fresh data from ETS
    games = GameStore.all_games_map()
    stats = calculate_stats(games)

    {:noreply, assign(socket, games: games, stats: stats)}
  end

  @impl true
  def handle_event("cleanup_stale", %{"hours" => hours}, socket) do
    hours = String.to_integer(hours)
    GameStore.cleanup_stale_games(hours)

    # Get fresh data from ETS
    games = GameStore.all_games_map()

    {:noreply, assign(socket, games: games, cleanup_message: "Cleaned up games older than #{hours} hour(s)")}
  end

  @impl true
  def handle_event("cleanup_all", _params, socket) do
    # Get all games before cleanup for counting
    before_count = map_size(socket.assigns.games)

    # Clean up problematic games
    GameStore.cleanup_problematic_games()

    # Get fresh data
    games = GameStore.all_games_map()
    after_count = map_size(games)

    {:noreply, assign(socket, games: games, cleanup_message: "Removed #{before_count - after_count} invalid/problematic games")}
  end

  @impl true
  def handle_event("cleanup_duplicates", _params, socket) do
    # Get all games before cleanup for counting
    before_count = map_size(socket.assigns.games)

    # Clean up duplicate player sessions
    GameStore.cleanup_duplicate_player_sessions()

    # Get fresh data
    games = GameStore.all_games_map()
    after_count = map_size(games)

    {:noreply, assign(socket, games: games, cleanup_message: "Removed #{before_count - after_count} duplicate player sessions")}
  end

  @impl true
  def handle_event("cleanup_idle_empty", _params, socket) do
    # Get all games before cleanup for counting
    before_count = map_size(socket.assigns.games)

    # Clean up idle empty games
    GameStore.cleanup_idle_empty_games()

    # Get fresh data
    games = GameStore.all_games_map()
    after_count = map_size(games)
    stats = calculate_stats(games)

    {:noreply, assign(socket,
      games: games,
      stats: stats,
      cleanup_message: "Removed #{before_count - after_count} idle games with no activity"
    )}
  end

  @impl true
  def render(assigns) do
    assigns = assign_new(assigns, :cleanup_message, fn -> nil end)

    ~H"""
    <div class="p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Wordle God Mode</h1>
        <div><%= map_size(@games) %> active games</div>
      </div>

      <div class="mb-4 grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div class="p-4 bg-gray-100 rounded-lg">
          <h2 class="text-lg font-bold mb-2">Debug Info</h2>
          <div class="text-sm">
            <p>Subscribed to topic: <%= Blog.Wordle.Game.topic() %></p>
            <p>Games in state: <%= Kernel.inspect(Map.keys(@games)) %></p>
          </div>

          <div class="mt-4 flex flex-wrap gap-2 items-center">
            <button
              phx-click="cleanup_stale"
              phx-value-hours="1"
              class="px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm"
            >
              Clean 1h Inactive
            </button>

            <button
              phx-click="cleanup_stale"
              phx-value-hours="24"
              class="px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm"
            >
              Clean 24h Inactive
            </button>

            <button
              phx-click="cleanup_all"
              class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600 text-sm"
            >
              Clean Invalid Sessions
            </button>

            <button
              phx-click="cleanup_duplicates"
              class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 text-sm"
            >
              Clean Duplicate Sessions
            </button>

            <button
              phx-click="cleanup_idle_empty"
              class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600 text-sm"
            >
              Clean Idle Empty Games
            </button>

            <%= if @cleanup_message do %>
              <span class="ml-2 text-green-600 font-medium"><%= @cleanup_message %></span>
            <% end %>
          </div>
        </div>

        <div class="p-4 bg-gray-100 rounded-lg">
          <h2 class="text-lg font-bold mb-2">Game Statistics</h2>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <h3 class="font-semibold mb-2">Game Status</h3>
              <ul class="text-sm">
                <li>Active Games: <span class="font-medium"><%= @stats.active_count %></span></li>
                <li>Completed Games: <span class="font-medium"><%= @stats.completed_count %></span></li>
                <li>Won Games: <span class="font-medium text-green-600"><%= @stats.won_count %></span></li>
                <li>Lost Games: <span class="font-medium text-red-600"><%= @stats.lost_count %></span></li>
                <li>Empty Games: <span class="font-medium text-gray-500"><%= @stats.empty_count %></span>
                  <span class="text-xs text-gray-500">(Idle: <span class="text-gray-600 font-medium"><%= @stats.idle_empty_count %></span>)</span>
                </li>
                <li>Win Rate: <span class="font-medium"><%= @stats.win_rate %>%</span></li>
              </ul>
            </div>

            <div>
              <h3 class="font-semibold mb-2">Activity</h3>
              <ul class="text-sm">
                <li>Recent (5m): <span class="font-medium text-green-600"><%= @stats.recent_count %></span></li>
                <li>Last Hour: <span class="font-medium text-yellow-600"><%= @stats.hour_count %></span></li>
                <li>Last Day: <span class="font-medium text-orange-600"><%= @stats.day_count %></span></li>
                <li>Older: <span class="font-medium text-gray-600"><%= @stats.older_count %></span></li>
                <li>Unique Players: <span class="font-medium"><%= @stats.unique_players %></span></li>
              </ul>
            </div>
          </div>

          <%= if length(@stats.common_words) > 0 do %>
            <div class="mt-4">
              <h3 class="font-semibold mb-2">Most Common Target Words</h3>
              <div class="flex flex-wrap gap-2">
                <%= for {word, count} <- @stats.common_words do %>
                  <div class="px-2 py-1 bg-white rounded border border-gray-300 text-sm">
                    <span class="font-medium"><%= word %></span>
                    <span class="text-xs text-gray-500 ml-1">(<%= count %>)</span>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <%= for {session_id, game} <- @games do %>
          <div class={["bg-white p-4 rounded-lg shadow-md",
            activity_class(game.last_activity),
            if(is_idle_empty?(game), do: "border-t-4 border-t-gray-400", else: "")
          ]}>
            <div class="flex justify-between items-center mb-2">
              <div class="font-bold">
                Player: <%= game.player_id %>
                <%= if is_idle_empty?(game) do %>
                  <span class="ml-1 text-xs text-white bg-gray-400 px-1 rounded">Idle</span>
                <% end %>
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

            <div class="text-sm mb-2">
              <span class="font-semibold">Session:</span>
              <span class="text-xs font-mono text-gray-500"><%= session_id %></span>
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

  defp activity_class(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _} ->
        seconds_diff = DateTime.diff(DateTime.utc_now(), datetime)
        cond do
          seconds_diff < 300 -> "border-l-4 border-green-500" # Active in last 5 minutes
          seconds_diff < 3600 -> "border-l-4 border-yellow-500" # Active in last hour
          seconds_diff < 86400 -> "border-l-4 border-orange-300" # Active in last day
          true -> "border-l-4 border-gray-300" # Inactive for more than a day
        end
      _ ->
        "border-l-4 border-red-300" # Invalid timestamp
    end
  end

  defp activity_class(_), do: "border-l-4 border-red-300" # Missing timestamp

  defp is_idle_empty?(game, threshold_seconds \\ 60) do
    length(game.guesses) == 0 &&
      case DateTime.from_iso8601(game.last_activity) do
        {:ok, timestamp, _} ->
          diff = DateTime.diff(DateTime.utc_now(), timestamp, :second)
          diff > threshold_seconds
        _ ->
          true
      end
  end

  # Calculate statistics about the games
  defp calculate_stats(games) do
    now = DateTime.utc_now()

    # Initialize counters
    stats = %{
      active_count: 0,
      completed_count: 0,
      won_count: 0,
      lost_count: 0,
      empty_count: 0,
      recent_count: 0,
      hour_count: 0,
      day_count: 0,
      older_count: 0,
      unique_players: 0,
      win_rate: 0,
      common_words: [],
      idle_threshold: 60, # seconds
      idle_empty_count: 0
    }

    # Get all games as a list
    games_list = Map.values(games)

    # Count unique players
    unique_players = games_list |> Enum.map(& &1.player_id) |> Enum.uniq() |> length()

    # Find common target words
    word_counts =
      games_list
      |> Enum.map(& &1.target_word)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_word, count} -> count end, :desc)
      |> Enum.take(5)

    # Calculate various statistics
    stats =
      Enum.reduce(games_list, stats, fn game, acc ->
        # Game status
        {active, completed, won, lost, empty} =
          cond do
            !game.game_over && length(game.guesses) == 0 ->
              {acc.active_count + 1, acc.completed_count, acc.won_count, acc.lost_count, acc.empty_count + 1}
            !game.game_over ->
              {acc.active_count + 1, acc.completed_count, acc.won_count, acc.lost_count, acc.empty_count}
            Enum.any?(game.guesses, fn %{word: word} -> word == game.target_word end) ->
              {acc.active_count, acc.completed_count + 1, acc.won_count + 1, acc.lost_count, acc.empty_count}
            true ->
              {acc.active_count, acc.completed_count + 1, acc.won_count, acc.lost_count + 1, acc.empty_count}
          end

        # Check for idle empty games
        idle_empty =
          if length(game.guesses) == 0 do
            case DateTime.from_iso8601(game.last_activity) do
              {:ok, timestamp, _} ->
                diff_seconds = DateTime.diff(now, timestamp, :second)
                if diff_seconds > acc.idle_threshold, do: acc.idle_empty_count + 1, else: acc.idle_empty_count
              _ ->
                acc.idle_empty_count
            end
          else
            acc.idle_empty_count
          end

        # Activity timeframe
        {recent, hour, day, older} =
          case DateTime.from_iso8601(game.last_activity) do
            {:ok, timestamp, _} ->
              diff_seconds = DateTime.diff(now, timestamp, :second)
              cond do
                diff_seconds < 300 -> # 5 minutes
                  {acc.recent_count + 1, acc.hour_count, acc.day_count, acc.older_count}
                diff_seconds < 3600 -> # 1 hour
                  {acc.recent_count, acc.hour_count + 1, acc.day_count, acc.older_count}
                diff_seconds < 86400 -> # 1 day
                  {acc.recent_count, acc.hour_count, acc.day_count + 1, acc.older_count}
                true ->
                  {acc.recent_count, acc.hour_count, acc.day_count, acc.older_count + 1}
              end
            _ ->
              {acc.recent_count, acc.hour_count, acc.day_count, acc.older_count + 1}
          end

        %{acc |
          active_count: active,
          completed_count: completed,
          won_count: won,
          lost_count: lost,
          empty_count: empty,
          idle_empty_count: idle_empty,
          recent_count: recent,
          hour_count: hour,
          day_count: day,
          older_count: older
        }
      end)

    # Calculate win rate
    win_rate =
      if stats.completed_count > 0 do
        round(stats.won_count / stats.completed_count * 100)
      else
        0
      end

    # Return the completed stats
    %{stats |
      unique_players: unique_players,
      win_rate: win_rate,
      common_words: word_counts
    }
  end
end
