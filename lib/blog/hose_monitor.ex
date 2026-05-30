defmodule Blog.HoseMonitor do
  @moduledoc """
  Tracks the connection status of all the firehose websocket clients.
  Pages can check `status/0` to see which hoses are down.
  """
  use GenServer

  @table :hose_monitor_status

  @typedoc "Name of a firehose client, e.g. :jetstream."
  @type hose_name :: atom()

  @typedoc "Connection state of a hose."
  @type hose_status :: :up | :down

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    end

    # Assume all down until they report in
    :ets.insert(@table, {:bluesky_hose, :down})
    :ets.insert(@table, {:jetstream, :down})
    :ets.insert(@table, {:turbostream, :down})

    {:ok, %{}}
  end

  @doc "Report a hose as connected."
  @spec report_up(hose_name()) :: true
  def report_up(hose_name) do
    :ets.insert(@table, {hose_name, :up})
  end

  @doc "Report a hose as disconnected."
  @spec report_down(hose_name()) :: true
  def report_down(hose_name) do
    :ets.insert(@table, {hose_name, :down})
  end

  @doc "Returns a map of hose statuses, e.g. %{jetstream: :up, turbostream: :down, ...}"
  @spec status() :: %{optional(hose_name()) => hose_status()}
  def status do
    case :ets.whereis(@table) do
      :undefined -> %{bluesky_hose: :down, jetstream: :down, turbostream: :down}
      _ -> :ets.tab2list(@table) |> Map.new()
    end
  end

  @doc "Returns true if any hose is down."
  @spec any_down?() :: boolean()
  def any_down? do
    status() |> Map.values() |> Enum.any?(&(&1 == :down))
  end

  @doc "Returns list of down hose names."
  @spec down_hoses() :: [hose_name()]
  def down_hoses do
    status()
    |> Enum.filter(fn {_k, v} -> v == :down end)
    |> Enum.map(fn {k, _v} -> k end)
  end
end
