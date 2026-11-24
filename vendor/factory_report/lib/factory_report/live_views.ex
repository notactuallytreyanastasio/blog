defmodule FactoryReport.LiveViews do
  @moduledoc false
  # How many LiveView processes are alive right now, per view module, found
  # by walking the process table: the count does not depend on any telemetry
  # event having been seen (the tracker's `units` do).
  #
  # What marks a LiveView process, checked by running a LiveView in
  # LiveViewTest on LiveView 1.0.19 and 1.2.13, OTP 28 (not read from
  # memory): `Phoenix.LiveView.Channel` puts `{View, :mount, 3}` in the
  # process's `$initial_call` before it mounts, in both. `$process_label`
  # (`{Phoenix.LiveView, View, topic}`) exists from 1.1 on only, and the
  # VM's own `initial_call` is `{:proc_lib, :init_p, 5}` for every
  # GenServer, so neither can be used. A `{Module, :mount, 3}` counts only
  # when `Module` exports `__live__/0`, which `use Phoenix.LiveView`
  # defines. A nested LiveView (`live_render/3`) is its own process with its
  # own `$initial_call`, so it counts under its own module; a dead render
  # (the first HTTP GET) has no process and is not counted.
  #
  # Cost: one `process_info(pid, {:dictionary, :"$initial_call"})` per
  # process, which reads that one key and does not copy the dictionary (OTP
  # 26.2 and later; on an older VM the section says it is unavailable rather
  # than copy every dictionary). Measured on an M-series laptop, OTP 28:
  # 27 to 37 ms for 20,000 processes, 1.4 to 1.9 us each. It runs on every
  # report read (every 5 s), so the walk stops at @walk_limit processes,
  # the way the observer engine's procs walk stops at its own limit, and
  # says how many it walked of how many: past the limit `total` is a lower
  # bound.

  alias FactoryReport.Streams

  @walk_limit 20_000
  @max_views 100

  def section do
    started = System.monotonic_time()

    if dict_key?() do
      all = :erlang.processes()
      pids = Enum.take(all, @walk_limit)
      counts = count(pids)
      sorted = counts |> Enum.sort_by(fn {view, n} -> {-n, view} end)
      {shown, cut} = Enum.split(sorted, @max_views)

      %{
        "total" => counts |> Map.values() |> Enum.sum(),
        "views" =>
          Enum.map(shown, fn {view, n} -> %{"view" => Streams.text(inspect(view)), "alive" => n} end),
        "views_cut" => length(cut),
        "processes" => length(all),
        "walked" => length(pids),
        "walk_limit" => @walk_limit,
        "took_ms" => took_ms(started)
      }
    else
      %{
        "total" => nil,
        "views" => [],
        "views_cut" => 0,
        "processes" => :erlang.system_info(:process_count),
        "walked" => 0,
        "walk_limit" => @walk_limit,
        "took_ms" => took_ms(started),
        "unavailable" =>
          "needs OTP 26.2 or later to read one process dictionary key; this VM is OTP #{System.otp_release()}"
      }
    end
  end

  @doc false
  def count(pids) do
    {counts, _live?} =
      Enum.reduce(pids, {%{}, %{}}, fn pid, {counts, live?} ->
        case :erlang.process_info(pid, {:dictionary, :"$initial_call"}) do
          {_, {view, :mount, 3}} when is_atom(view) ->
            {yes, live?} = live_view?(view, live?)
            {if(yes, do: Map.update(counts, view, 1, &(&1 + 1)), else: counts), live?}

          # Any other initial call, none, or the process exited (:undefined).
          _ ->
            {counts, live?}
        end
      end)

    counts
  end

  # Asked once per module per walk.
  defp live_view?(module, seen) do
    case seen do
      %{^module => yes} ->
        {yes, seen}

      _ ->
        yes = function_exported?(module, :__live__, 0)
        {yes, Map.put(seen, module, yes)}
    end
  end

  defp dict_key? do
    _ = :erlang.process_info(self(), {:dictionary, :"$initial_call"})
    true
  rescue
    ArgumentError -> false
  end

  defp took_ms(started) do
    us = System.convert_time_unit(System.monotonic_time() - started, :native, :microsecond)
    Float.round(us / 1000, 2)
  end
end
