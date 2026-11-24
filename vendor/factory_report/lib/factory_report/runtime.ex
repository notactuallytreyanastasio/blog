defmodule FactoryReport.Runtime do
  @moduledoc false
  # The machine room: the BEAM's own numbers. Every call here is a constant
  # time read of a VM counter; none walks the process table.

  def section(app) do
    %{
      "kind" => "beam",
      "versions" => versions(app),
      "uptime_s" => div(elem(:erlang.statistics(:wall_clock), 0), 1000),
      "gauges" => gauges(),
      "counters" => counters()
    }
  end

  defp versions(app) do
    base = %{
      "otp" => List.to_string(:erlang.system_info(:otp_release)),
      "elixir" => System.version()
    }

    [{"phoenix", :phoenix}, {"phoenix_live_view", :phoenix_live_view}, {"app", app}]
    |> Enum.reduce(base, fn {key, name}, acc ->
      case Application.spec(name, :vsn) do
        nil -> acc
        vsn -> Map.put(acc, key, to_string(vsn))
      end
    end)
  end

  defp gauges do
    memory = :erlang.memory()

    gauges = %{
      "memory.total" => memory[:total],
      "memory.processes" => memory[:processes],
      "memory.binary" => memory[:binary],
      "memory.ets" => memory[:ets],
      "memory.atom" => memory[:atom],
      "memory.code" => memory[:code],
      "process.count" => :erlang.system_info(:process_count),
      "process.limit" => :erlang.system_info(:process_limit),
      "port.count" => :erlang.system_info(:port_count),
      "port.limit" => :erlang.system_info(:port_limit),
      "atom.count" => :erlang.system_info(:atom_count),
      "atom.limit" => :erlang.system_info(:atom_limit),
      "ets.count" => :erlang.system_info(:ets_count),
      "run_queue" => :erlang.statistics(:total_run_queue_lengths),
      "schedulers.online" => :erlang.system_info(:schedulers_online)
    }

    case scheduler_utilization() do
      nil -> gauges
      value -> Map.put(gauges, "scheduler.utilization", value)
    end
  end

  defp counters do
    {reductions, _} = :erlang.statistics(:reductions)
    {gcs, words, _} = :erlang.statistics(:garbage_collection)
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    {switches, _} = :erlang.statistics(:context_switches)

    %{
      "reductions" => reductions,
      "gc.count" => gcs,
      "gc.words_reclaimed" => words,
      "io.in_bytes" => input,
      "io.out_bytes" => output,
      "context_switches" => switches,
      # Not the VM's: how often one of this library's telemetry handlers had
      # to swallow an error. Anything but 0 is a bug in the library.
      "report.handler_errors" => FactoryReport.meta(:handler_errors) || 0
    }
  end

  # The share of time the normal schedulers were busy between the previous
  # report and this one: 0..1. `nil` until two samples exist. The flag is
  # switched on by the tracker process (it lasts as long as that process).
  defp scheduler_utilization do
    case sample() do
      nil ->
        nil

      now ->
        before = FactoryReport.meta(:scheduler_sample)
        FactoryReport.put_meta(:scheduler_sample, now)
        utilization(before, now)
    end
  end

  defp sample do
    case :erlang.statistics(:scheduler_wall_time) do
      :undefined ->
        nil

      list ->
        # Normal schedulers only (ids 1..schedulers); dirty CPU schedulers
        # follow and would dilute the figure when idle.
        normal = :erlang.system_info(:schedulers)

        Enum.reduce(list, {0, 0}, fn
          {id, active, total}, {a, t} when id <= normal -> {a + active, t + total}
          _, acc -> acc
        end)
    end
  end

  @doc false
  def utilization({a0, t0}, {a1, t1}) when t1 > t0 do
    value = (a1 - a0) / (t1 - t0)
    Float.round(min(max(value, 0.0), 1.0), 4)
  end

  def utilization(_, _), do: nil
end
