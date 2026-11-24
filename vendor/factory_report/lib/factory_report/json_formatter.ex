defmodule FactoryReport.JSONFormatter do
  @moduledoc """
  A `:logger` formatter: one JSON object per line.

      # config/config.exs (or runtime.exs), Elixir 1.15 and later
      config :logger, :default_handler,
        formatter: {FactoryReport.JSONFormatter, %{}}

  Each line has exactly these keys, `null` where there is nothing to say:

      {"time":"2026-11-19T08:40:02.123Z","level":"warning","msg":"...",
       "app":"blog","module":"Blog.Poller","request_id":"F...","page":"GET /cases"}

  `time` is UTC. `app` is the `:app` given here, else the app the running
  `FactoryReport` was started with. `module` is the module that logged.
  `request_id` is the metadata `Plug.RequestId` sets. `page` is the route or
  LiveView the logging process was working for (the report's `by`, as its
  name), when `FactoryReport` is running and knows.

  ## Options (the map after the module)

    * `:metadata` - a list of further metadata keys to write, each under its
      own name: `%{metadata: [:user_agent, :trace_id]}`. A value that is not
      a string, number, boolean or atom is written as its `inspect/1`.
    * `:app` - the `"app"` value, when it should not come from `FactoryReport`.

  It never raises: an event that cannot be encoded becomes a minimal line
  with `time`, `level` and a `msg` saying so. Every line ends with `"\\n"`.
  It works without `FactoryReport` running (then `page` is `null`).
  """

  alias FactoryReport.{Attribution, Message}

  @reserved ~w(time level msg app module request_id page)

  @doc false
  # Called by :logger when the handler is added or its config changes.
  def check_config(config) when is_map(config), do: :ok
  def check_config(config), do: {:error, {:invalid_formatter_config, __MODULE__, config}}

  @doc "The `:logger` formatter callback."
  def format(event, config) do
    [line(event, config), ?\n]
  catch
    _, _ -> fallback(event)
  end

  defp line(%{level: level, msg: msg, meta: meta}, config) do
    base = [
      {"time", time(meta)},
      {"level", Atom.to_string(level)},
      {"msg", Message.text(msg, meta, :infinity)},
      {"app", app(config)},
      {"module", Message.module(meta)},
      {"request_id", string(Map.get(meta, :request_id))},
      {"page", page()}
    ]

    extra =
      for key <- List.wrap(config[:metadata]),
          is_atom(key),
          name = Atom.to_string(key),
          name not in @reserved,
          Map.has_key?(meta, key) do
        {name, value(Map.get(meta, key))}
      end

    Jason.encode_to_iodata!(Jason.OrderedObject.new(base ++ extra))
  end

  defp time(%{time: us}) when is_integer(us), do: Message.iso(us, :millisecond)
  defp time(_), do: Message.iso(System.system_time(:microsecond), :millisecond)

  defp app(config) do
    case config[:app] || FactoryReport.meta(:app) do
      nil -> nil
      app -> to_string(app)
    end
  end

  defp page do
    case Attribution.current() do
      {_kind, name} when is_binary(name) -> name
      _ -> nil
    end
  end

  defp string(nil), do: nil
  defp string(value), do: value(value) |> to_string()

  defp value(value) when is_number(value) or is_boolean(value) or is_nil(value), do: value
  defp value(value) when is_atom(value), do: Atom.to_string(value)

  defp value(value) when is_binary(value) do
    if String.valid?(value), do: value, else: inspect(value, limit: 50)
  end

  defp value(value), do: inspect(value, limit: 50, printable_limit: 500)

  # Built by hand: nothing here can fail to encode.
  defp fallback(event) do
    level =
      case event do
        %{level: level} when is_atom(level) -> Atom.to_string(level)
        _ -> "error"
      end

    time = Message.iso(System.system_time(:microsecond), :millisecond)
    ~s|{"time":"#{time}","level":"#{level}","msg":"(unformattable log event)"}\n|
  catch
    _, _ -> ~s|{"level":"error","msg":"(unformattable log event)"}\n|
  end
end
