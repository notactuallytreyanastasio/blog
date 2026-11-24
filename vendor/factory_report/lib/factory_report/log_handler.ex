defmodule FactoryReport.LogHandler do
  @moduledoc false
  # A `:logger` handler. `log/2` runs in the process that logged, so it is
  # held to the telemetry handlers' rules: O(1) (one or two counter updates;
  # for an event at or above the floor, formatting at most 300 characters
  # and one ETS insert), never raises (`:logger` removes a handler that
  # does), never blocks, and never logs.
  #
  # The ring: {slot, seq, time_us, level, module, message, by} with
  # slot = seq rem size, so the newest `size` events are always there.

  alias FactoryReport.{Attribution, Message, Streams}

  @id :factory_report
  @tab :factory_report_events
  @size 50
  @message 300

  def create, do: :ets.new(@tab, [:named_table, :public, :set, write_concurrency: true])

  def install(opts) do
    floor = Keyword.get(opts, :log_level, :warning)
    floor = if :logger.compare_levels(floor, :debug) in [:lt, :eq, :gt], do: floor
    config = %{events: Keyword.get(opts, :log_events, true) != false, floor: floor}
    # A previous owner that was killed could not remove it.
    _ = :logger.remove_handler(@id)
    :logger.add_handler(@id, __MODULE__, %{level: :all, config: config})
  catch
    _, _ -> {:error, :invalid_log_level}
  end

  def remove do
    _ = :logger.remove_handler(@id)
    :ok
  end

  @doc false
  # The :logger handler callback.
  def log(%{level: level, msg: msg, meta: meta}, %{config: %{events: events?, floor: floor}}) do
    by = Attribution.current()
    Streams.hit_by("log", Atom.to_string(level), 0, false, by)

    if events? and :logger.compare_levels(level, floor) != :lt do
      seq = :ets.update_counter(:factory_report_meta, :event_seq, 1, {:event_seq, 0})

      time =
        case meta do
          %{time: time} when is_integer(time) -> time
          _ -> System.system_time(:microsecond)
        end

      message = Message.text(msg, meta, @message)
      :ets.insert(@tab, {rem(seq, @size), seq, time, level, Message.module(meta), message, by})
    end

    :ok
  catch
    _, _ -> FactoryReport.handler_error()
  end

  def log(_, _), do: :ok

  @doc "The recent events, newest first, as the report lists them."
  def events do
    :ets.tab2list(@tab)
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(fn {_slot, _seq, time, level, module, message, by} ->
      %{
        "at" => Message.iso(time, :second),
        "level" => Atom.to_string(level),
        "name" => module || "(unknown)",
        "message" => message,
        "by" => Streams.by_map(by)
      }
    end)
  end
end
