defmodule FactoryReport.Attribution do
  @moduledoc false
  # Which page the calling process is working for: `{"liveview", view}` or
  # `{"http.route", "GET /pattern"}`, or nil.
  #
  # A mark in the process dictionary, put there by the telemetry handlers
  # that run in the process itself: a request process is marked from
  # router_dispatch :start to :stop, a connected LiveView for its whole life.
  # Reading it is one `Process.get/1`.
  #
  # A process without a mark may be a Task working for one: `$callers`
  # (which Task sets) is followed two hops. Only a found answer is cached in
  # the task, so a task started before its caller was marked is asked again.

  @key :"$factory_report_by"
  @tab :factory_report_units

  def mark(by), do: Process.put(@key, by)
  def clear, do: Process.delete(@key)

  def current do
    case Process.get(@key) do
      {_, _} = by -> by
      _ -> from_callers(Process.get(:"$callers"))
    end
  end

  defp from_callers([first | rest]) do
    by =
      of(first) ||
        case rest do
          [second | _] -> of(second)
          _ -> nil
        end

    if by, do: Process.put(@key, by)
    by
  end

  defp from_callers(_), do: nil

  defp of(pid) when is_pid(pid) and node(pid) == node() do
    case :ets.lookup(@tab, pid) do
      [{_, "liveview", name, _, _, _, _}] ->
        {"liveview", name}

      _ ->
        # One key of another process's dictionary (OTP 26.2 and later; on
        # an older OTP this raises and the answer is nil).
        case Process.info(pid, {:dictionary, @key}) do
          {{:dictionary, @key}, {_, _} = by} -> by
          _ -> nil
        end
    end
  catch
    _, _ -> nil
  end

  defp of(_), do: nil
end
