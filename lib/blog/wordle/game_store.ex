defmodule Blog.Wordle.GameStore do
  @moduledoc """
  Manages ETS table for storing Wordle game sessions.
  """
  use GenServer
  require Logger

  @games_table :wordle_game_sessions
  # Cleanup intervals in milliseconds
  # 10 minutes (changed from 1 hour)
  @cleanup_interval 600_000
  # Seconds of inactivity for new games with no guesses
  @idle_threshold 60

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Create ETS table
    :ets.new(@games_table, [:named_table, :set, :public])

    # Clean up potentially problematic records on startup
    Process.send_after(self(), :cleanup_on_startup, 1000)

    # Schedule periodic cleanups
    schedule_cleanup()

    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup_on_startup, state) do
    cleanup_problematic_games()
    cleanup_duplicate_player_sessions()
    cleanup_idle_empty_games()
    {:noreply, state}
  end

  @impl true
  def handle_info(:periodic_cleanup, state) do
    Logger.info("GameStore: Running periodic cleanup")

    # Run all cleanup operations
    cleanup_stale_games(24)
    cleanup_problematic_games()
    cleanup_duplicate_player_sessions()
    cleanup_idle_empty_games()

    # Schedule the next cleanup
    schedule_cleanup()

    {:noreply, state}
  end

  # Schedule the next cleanup
  defp schedule_cleanup do
    Process.send_after(self(), :periodic_cleanup, @cleanup_interval)
  end

  @doc """
  Cleans up idle games that have no guesses and have been inactive for more than the threshold
  """
  def cleanup_idle_empty_games do
    now = DateTime.utc_now()
    threshold_seconds = @idle_threshold

    deleted_count =
      :ets.tab2list(@games_table)
      |> Enum.count(fn {session_id, game} ->
        is_idle_with_no_guesses?(game, now, threshold_seconds) &&
          delete_game(session_id)
      end)

    Logger.info("GameStore: Cleaned up #{deleted_count} idle games with no guesses")
  end

  defp is_idle_with_no_guesses?(game, now, threshold_seconds) do
    # Check that the game has no guesses
    empty_guesses? = valid_game?(game) && length(game.guesses) == 0

    # Check the game is idle (hasn't been active recently)
    idle? =
      case DateTime.from_iso8601(game.last_activity) do
        {:ok, last_active, _} ->
          diff = DateTime.diff(now, last_active, :second)
          diff > threshold_seconds

        _ ->
          # If we can't parse the timestamp, consider it idle
          true
      end

    empty_guesses? && idle?
  end

  defp delete_game(session_id) do
    :ets.delete(@games_table, session_id)
    true
  end

  @doc """
  Saves a game state to ETS
  """
  def save_game(game) do
    # Don't store games with missing data
    if valid_game?(game) do
      :ets.insert(@games_table, {game.session_id, game})
      game
    else
      # If we detect an invalid game, log it but return the original game
      Logger.warning("GameStore: Rejected invalid game: #{inspect(game.session_id)}")
      game
    end
  end

  @doc """
  Gets a game by session ID
  """
  def get_game(session_id) do
    case :ets.lookup(@games_table, session_id) do
      [{^session_id, game}] -> game
      _ -> nil
    end
  end

  @doc """
  Gets all active games
  """
  def all_games do
    :ets.tab2list(@games_table)
    |> Enum.map(fn {_session_id, game} -> game end)
    |> Enum.filter(&valid_game?/1)
  end

  @doc """
  Gets all active game sessions as a map
  """
  def all_games_map do
    :ets.tab2list(@games_table)
    |> Enum.filter(fn {_session_id, game} -> valid_game?(game) end)
    |> Enum.into(%{}, fn {session_id, game} -> {session_id, game} end)
  end

  @doc """
  Removes stale games older than the given time period
  """
  def cleanup_stale_games(hours \\ 24) do
    cutoff = DateTime.add(DateTime.utc_now(), -hours * 60 * 60, :second) |> DateTime.to_iso8601()

    deleted_count =
      :ets.tab2list(@games_table)
      |> Enum.count(fn {session_id, game} ->
        if older_than?(game.last_activity, cutoff) do
          :ets.delete(@games_table, session_id)
          true
        else
          false
        end
      end)

    Logger.info("GameStore: Cleaned up #{deleted_count} stale games older than #{hours} hours")
  end

  @doc """
  Cleans up problematic game entries (e.g., games with missing fields)
  """
  def cleanup_problematic_games do
    deleted_count =
      :ets.tab2list(@games_table)
      |> Enum.count(fn {session_id, game} ->
        if !valid_game?(game) do
          :ets.delete(@games_table, session_id)
          true
        else
          false
        end
      end)

    Logger.info("GameStore: Cleaned up #{deleted_count} problematic game entries")
  end

  @doc """
  Cleans up duplicate sessions for the same player, keeping only the most recent one
  """
  def cleanup_duplicate_player_sessions do
    # Group games by player_id
    games_by_player =
      all_games()
      |> Enum.group_by(fn game -> game.player_id end)

    # For each player, keep only the most recent active game and one completed game
    deleted_count =
      games_by_player
      |> Enum.map(fn {_player_id, games} ->
        # Sort games by activity timestamp (newest first)
        sorted_games = Enum.sort_by(games, fn game -> game.last_activity end, {:desc, DateTime})

        # Split into active and completed games
        {active_games, completed_games} =
          Enum.split_with(sorted_games, fn game -> !game.game_over end)

        # Keep at most one active game and one completed game
        games_to_keep =
          if(Enum.empty?(active_games), do: [], else: [List.first(active_games)]) ++
            if Enum.empty?(completed_games), do: [], else: [List.first(completed_games)]

        # Find which games to delete
        games_to_delete = games -- games_to_keep

        # Delete the extra games
        Enum.each(games_to_delete, fn game ->
          :ets.delete(@games_table, game.session_id)
        end)

        # Return the count of deleted games
        length(games_to_delete)
      end)
      |> Enum.sum()

    Logger.info("GameStore: Cleaned up #{deleted_count} duplicate player sessions")
  end

  @doc """
  Validates that a game has all required fields
  """
  def valid_game?(game) do
    # Check that all the important fields exist and have valid values
    is_map(game) &&
      is_binary(game.session_id) && String.length(game.session_id) > 0 &&
      is_binary(game.player_id) && String.length(game.player_id) > 0 &&
      is_binary(game.target_word) && String.length(game.target_word) == 5 &&
      is_list(game.guesses) &&
      is_map(game.used_letters)
  end

  defp older_than?(timestamp, cutoff) when is_binary(timestamp) and is_binary(cutoff) do
    case {DateTime.from_iso8601(timestamp), DateTime.from_iso8601(cutoff)} do
      {{:ok, time, _}, {:ok, cutoff_time, _}} ->
        DateTime.compare(time, cutoff_time) == :lt

      _ ->
        false
    end
  end

  defp older_than?(_, _), do: false
end
