defmodule Blog.RateLimiter do
  @moduledoc """
  Tiny fixed-window rate limiter on ETS. `allow?("comment:1.2.3.4", 4, 60)`
  permits 4 hits per rolling-ish 60s window per key. State is per-node and
  lost on restart, which is fine for abuse throttling.
  """
  use GenServer

  @table __MODULE__

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @spec allow?(String.t(), pos_integer(), pos_integer()) :: boolean()
  def allow?(key, limit, window_seconds) do
    now = System.system_time(:second)
    window = div(now, window_seconds)
    full_key = {key, window_seconds, window}

    count = :ets.update_counter(@table, full_key, {2, 1}, {full_key, 0})
    if count == 1, do: :ets.insert(@table, {full_key, count, now})
    count <= limit
  end

  @impl true
  def init(nil) do
    :ets.new(@table, [:named_table, :public, :set, write_concurrency: true])
    # sweep dead windows hourly so the table doesn't grow forever
    :timer.send_interval(:timer.hours(1), :sweep)
    {:ok, nil}
  end

  @impl true
  def handle_info(:sweep, state) do
    cutoff = System.system_time(:second) - 24 * 3600
    :ets.select_delete(@table, [
      {{{:_, :_, :_}, :_, :"$1"}, [{:<, :"$1", cutoff}], [true]},
      {{{:_, :_, :_}, :_}, [], [true]}
    ])
    {:noreply, state}
  end
end
