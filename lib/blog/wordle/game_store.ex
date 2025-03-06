defmodule Blog.Wordle.GameStore do
  @moduledoc """
  Manages ETS table for storing Wordle game sessions.
  """
  use GenServer

  @games_table :wordle_game_sessions

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Create ETS table
    :ets.new(@games_table, [:named_table, :set, :public])
    {:ok, %{}}
  end

  @doc """
  Saves a game state to ETS
  """
  def save_game(game) do
    :ets.insert(@games_table, {game.session_id, game})
    game
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
  end

  @doc """
  Gets all active game sessions as a map
  """
  def all_games_map do
    :ets.tab2list(@games_table)
    |> Enum.into(%{}, fn {session_id, game} -> {session_id, game} end)
  end

  @doc """
  Removes stale games older than the given time period
  """
  def cleanup_stale_games(hours \\ 24) do
    cutoff = DateTime.add(DateTime.utc_now(), -hours * 60 * 60, :second) |> DateTime.to_iso8601()

    :ets.tab2list(@games_table)
    |> Enum.each(fn {session_id, game} ->
      if older_than?(game.last_activity, cutoff) do
        :ets.delete(@games_table, session_id)
      end
    end)
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
