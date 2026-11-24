defmodule FactoryReport.Tracker do
  @moduledoc false
  # Which long-lived processes exist right now: connected LiveViews and
  # joined channels. A telemetry handler, running in the process itself,
  # writes the process's row and sends this server one message (`watch`);
  # this server monitors the process and deletes the row when it exits.
  #
  # Row: {pid, kind, name, route, label, since_s, events}
  #
  # It also owns the things that need a long-lived owner: the telemetry
  # attachments and the :logger handler (both removed when it stops) and the
  # scheduler_wall_time flag
  # (the VM switches it off when the process that asked for it exits).

  use GenServer

  alias FactoryReport.{Attribution, Handlers, LogHandler, Streams}

  @tab :factory_report_units
  @events_pos 7

  def create do
    :ets.new(@tab, [:named_table, :public, :set, write_concurrency: true])
  end

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  # ---- written from the tracked process itself (telemetry handlers) ----

  @doc """
  Adds or moves the calling process. `place` is `{route, label}` or `nil`
  when the caller does not know where it is (then an existing row is left
  alone). O(1).
  """
  def put(kind, name, place) do
    pid = self()

    moved? =
      case place do
        {route, label} -> :ets.update_element(@tab, pid, [{4, route}, {5, label}])
        nil -> :ets.member(@tab, pid)
      end

    if not moved? do
      {route, label} = place || {nil, nil}
      # What this process's queries, calls and log lines are attributed to.
      if kind == "liveview", do: Attribution.mark({kind, name})
      :ets.insert(@tab, {pid, kind, name, route, label, System.system_time(:second), 0})
      GenServer.cast(__MODULE__, {:watch, pid})
    end

    :ok
  end

  def tracked?(pid), do: :ets.member(@tab, pid)

  @doc "Where another tracked process is: `{route, label}` or `nil`."
  def place(pid) do
    case :ets.lookup(@tab, pid) do
      [{_, _, _, route, label, _, _}] when is_binary(label) -> {route, label}
      _ -> nil
    end
  end

  @doc "One more event handled by the calling process, if it is tracked."
  def bump do
    :ets.update_counter(@tab, self(), {@events_pos, 1})
    :ok
  catch
    :error, :badarg -> :ok
  end

  @doc "Returns once every message sent to the tracker before this call was handled."
  def sync, do: GenServer.call(__MODULE__, :sync)

  # ---- the report ----

  @doc """
  `{units, cut_units, cut_members}`: at most `max_units` units (the most
  populous first), each with at most `max_members` members (the largest by
  memory first). Only tracked pids are asked for `Process.info/2`.
  """
  def units(max_units, max_members) do
    groups =
      :ets.tab2list(@tab)
      |> Enum.reduce(%{}, fn {pid, kind, name, route, label, since, events}, acc ->
        case Process.info(pid, [:memory, :message_queue_len]) do
          [memory: memory, message_queue_len: queue] ->
            member = {memory, queue, pid, route, label, since, events}
            Map.update(acc, {kind, name}, [member], &[member | &1])

          # Exited, and its DOWN has not reached the tracker yet.
          _ ->
            acc
        end
      end)

    sorted =
      groups
      |> Enum.map(fn {key, members} -> {length(members), key, members} end)
      |> Enum.sort(fn {c1, k1, _}, {c2, k2, _} -> c1 > c2 or (c1 == c2 and k1 <= k2) end)

    {kept, cut} = Enum.split(sorted, max_units)

    {units, cut_members} =
      Enum.map_reduce(kept, 0, fn {count, {kind, name}, members}, cut_members ->
        shown = members |> Enum.sort(:desc) |> Enum.take(max_members)

        unit = %{
          "kind" => kind,
          "name" => Streams.text(name),
          "route" => route_of(members),
          "count" => count,
          "gauges" => %{
            "memory" => members |> Enum.map(&elem(&1, 0)) |> Enum.sum(),
            "message_queue" => members |> Enum.map(&elem(&1, 1)) |> Enum.sum()
          },
          "members" => Enum.map(shown, &member(&1, name))
        }

        {unit, cut_members + count - length(shown)}
      end)

    {units, length(cut), cut_members}
  end

  defp member({memory, queue, pid, _route, label, since, events}, name) do
    %{
      "id" => id(pid, since),
      "label" => Streams.text(label || name),
      "since" => since |> DateTime.from_unix!() |> DateTime.to_iso8601(),
      "gauges" => %{"memory" => memory, "message_queue" => queue},
      "counters" => %{"events" => events}
    }
  end

  # Opaque, and the same for as long as the process lives.
  defp id(pid, since) do
    :erlang.phash2({pid, since}, 4_294_967_296)
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(8, "0")
  end

  # One view can be mounted at several routes: the unit carries the one most
  # of its members are on, or nil when none is known.
  defp route_of(members) do
    members
    |> Enum.map(&elem(&1, 3))
    |> Enum.reject(&is_nil/1)
    |> Enum.frequencies()
    |> Enum.max_by(fn {route, n} -> {n, route} end, fn -> {nil, 0} end)
    |> elem(0)
    |> case do
      nil -> nil
      route -> Streams.text(route)
    end
  end

  # ---- server ----

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)
    :erlang.system_flag(:scheduler_wall_time, true)

    # After a restart the rows are still there (the supervisor owns the
    # table) but the monitors are gone.
    for {pid, _, _, _, _, _, _} <- :ets.tab2list(@tab), do: Process.monitor(pid)

    Handlers.attach(Keyword.get(opts, :repos, []))
    LogHandler.install(opts)
    {:ok, nil}
  end

  @impl true
  def handle_cast({:watch, pid}, state) when is_pid(pid) do
    Process.monitor(pid)
    {:noreply, state}
  end

  def handle_cast(_, state), do: {:noreply, state}

  @impl true
  def handle_call(:sync, _from, state), do: {:reply, :ok, state}

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    :ets.delete(@tab, pid)
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, _state) do
    LogHandler.remove()
    Handlers.detach()
    :ok
  end
end
