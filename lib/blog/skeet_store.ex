defmodule Blog.SkeetStore do
  @moduledoc """
  Storage for Bluesky skeets (posts) using ETS.
  Maintains a circular buffer of the most recent skeets.
  """
  @table_name :sample_skeets_table
  @max_skeets 100

  @doc """
  Initialize the ETS table for storing skeets.
  """
  def init do
    case :ets.info(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:named_table, :ordered_set, :public, read_concurrency: true])
      _ ->
        :ok
    end
  end

  @doc """
  Store a new skeet with a timestamp as the key.
  Ensures only the most recent @max_skeets skeets are kept.
  """
  def add_skeet(skeet) do
    timestamp = System.system_time(:millisecond)
    :ets.insert(@table_name, {timestamp, %{skeet: skeet, timestamp: timestamp}})

    # Trim if needed
    trim_table()

    :ok
  end

  @doc """
  Get the most recent skeets, sorted by timestamp (newest first).
  """
  def get_recent_skeets(limit \\ @max_skeets) do
    case :ets.info(@table_name) do
      :undefined ->
        []
      _ ->
        :ets.tab2list(@table_name)
        |> Enum.sort_by(fn {ts, _} -> ts end, :desc)
        |> Enum.take(limit)
        |> Enum.map(fn {_, skeet_data} -> skeet_data end)
    end
  end

  @doc """
  Trim the table to keep only the most recent @max_skeets entries.
  """
  defp trim_table do
    table_size = :ets.info(@table_name, :size)

    if table_size > @max_skeets do
      # Get all keys, sorted oldest first
      keys =
        :ets.tab2list(@table_name)
        |> Enum.map(fn {ts, _} -> ts end)
        |> Enum.sort()

      # Calculate how many to remove
      to_remove = table_size - @max_skeets

      # Delete the oldest entries
      keys
      |> Enum.take(to_remove)
      |> Enum.each(fn key -> :ets.delete(@table_name, key) end)
    end
  end
end
