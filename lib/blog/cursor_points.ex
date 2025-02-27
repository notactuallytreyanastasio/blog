defmodule Blog.CursorPoints do
  use GenServer
  require Logger

  @table_name :cursor_favorite_points
  # Limit the number of points to prevent unbounded growth
  @max_points 1000
  # 60 minutes in milliseconds
  @clear_interval 60 * 60 * 1000

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_point(point) do
    GenServer.cast(__MODULE__, {:add_point, point})
  end

  def get_points do
    case :ets.info(@table_name) do
      :undefined -> []
      _ -> :ets.tab2list(@table_name) |> Enum.map(fn {_key, point} -> point end)
    end
  end

  def clear_points do
    GenServer.cast(__MODULE__, :clear_points)
  end

  # Server callbacks

  @impl true
  def init(_) do
    # Create ETS table
    table = :ets.new(@table_name, [:named_table, :set, :public])

    # Schedule periodic clearing
    schedule_clear()

    {:ok, %{table: table}}
  end

  @impl true
  def handle_cast({:add_point, point}, state) do
    # Generate a unique key for the point
    key = "#{point.user_id}-#{:os.system_time(:millisecond)}"

    # Add the point to the ETS table
    :ets.insert(@table_name, {key, point})

    # Trim the table if it gets too large
    trim_table()

    {:noreply, state}
  end

  @impl true
  def handle_cast(:clear_points, state) do
    # Clear all points from the ETS table
    :ets.delete_all_objects(@table_name)

    # Broadcast that points were cleared
    broadcast_clear()

    {:noreply, state}
  end

  @impl true
  def handle_info(:scheduled_clear, state) do
    # Clear all points from the ETS table
    :ets.delete_all_objects(@table_name)

    # Broadcast that points were cleared
    broadcast_clear("SYSTEM")

    # Reschedule the next clearing
    schedule_clear()

    {:noreply, state}
  end

  # Private functions

  defp trim_table do
    # Get the current count of points
    count = :ets.info(@table_name, :size)

    if count > @max_points do
      # Get all points
      all_points = :ets.tab2list(@table_name)

      # Sort by timestamp (newest first)
      sorted_points =
        Enum.sort_by(
          all_points,
          fn {_, point} ->
            DateTime.to_unix(point.timestamp)
          end,
          :desc
        )

      # Keep only the newest @max_points
      {to_keep, to_delete} = Enum.split(sorted_points, @max_points)

      # Delete the oldest points
      Enum.each(to_delete, fn {key, _} -> :ets.delete(@table_name, key) end)

      Logger.info("Trimmed cursor points table from #{count} to #{length(to_keep)} points")
    end
  end

  defp schedule_clear do
    Process.send_after(self(), :scheduled_clear, @clear_interval)
  end

  defp broadcast_clear(user_id \\ nil) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "cursor_tracker",
      {:clear_points, user_id || "SYSTEM"}
    )

    Logger.info("Points cleared by #{user_id || "scheduled task"}")
  end
end
