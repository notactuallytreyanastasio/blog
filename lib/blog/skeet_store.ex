defmodule Blog.SkeetStore do
  @moduledoc """
  Storage for Bluesky skeets (posts) using ETS.
  Maintains a circular buffer of the most recent skeets.
  """
  @table_name :sample_skeets_table
  @max_skeets 100

  @doc """
  Initialize the ETS table for storing skeets.
  Will safely handle cases where the table already exists.
  """
  def init do
    case :ets.info(@table_name) do
      :undefined ->
        try do
          # Try to create the table
          :ets.new(@table_name, [:named_table, :ordered_set, :public, read_concurrency: true])
          :ok
        rescue
          ArgumentError ->
            # Table already exists, that's fine
            :ok
        end
      _ ->
        # Table already exists
        :ok
    end
  end

  @doc """
  Store a new skeet with a timestamp as the key.
  Ensures only the most recent @max_skeets skeets are kept.
  Safely handles cases where the table doesn't exist yet.
  """
  def add_skeet(skeet) do
    # Ensure the table exists
    init()

    timestamp = System.system_time(:millisecond)

    # Safely insert the data
    try do
      :ets.insert(@table_name, {timestamp, %{skeet: skeet, timestamp: timestamp}})
      # Trim if needed
      trim_table()
      :ok
    rescue
      _ -> :error
    end
  end

  @doc """
  Get the most recent skeets, sorted by timestamp (newest first).
  Safely handles cases where the table doesn't exist yet.
  """
  def get_recent_skeets(limit \\ @max_skeets) do
    # Ensure the table exists
    init()

    try do
      case :ets.info(@table_name) do
        :undefined ->
          []
        _ ->
          :ets.tab2list(@table_name)
          |> Enum.sort_by(fn {ts, _} -> ts end, :desc)
          |> Enum.take(limit)
          |> Enum.map(fn {_, skeet_data} -> skeet_data end)
      end
    rescue
      _ -> []
    end
  end

  @doc """
  Trim the table to keep only the most recent @max_skeets entries.
  """
  defp trim_table do
    try do
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
    rescue
      _ -> :ok  # Ignore errors during trimming
    end
  end
end
