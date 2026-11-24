defmodule FactoryReport do
  @moduledoc """
  A sub-app's own account of its inside, in the obs_factor report format
  (`docs/contract.md`, "Reports: what is inside a building").

  Add one child to the supervision tree:

      children = [
        # ...
        {FactoryReport, app: :my_app, port: 9568}
      ]

  That starts the collectors (telemetry handlers, a tracker for live LiveView
  and channel processes) and a small HTTP listener answering `GET /report`.

  ## Options

    * `:app` (required) - the host application's name, an atom. It is the
      report's `"app"` and the application whose `vsn` is reported.
    * `:port` - the listener's port (default `9568`). `false` starts no
      listener: mount `FactoryReport.Plug` in your own router instead.
    * `:ip` - the address to bind (default `{0, 0, 0, 0}`, every IPv4
      interface, because the observer reaches it over the container network).
    * `:token` - when a non-empty string, `GET /report` needs
      `authorization: Bearer <token>`. `nil` and `""` mean no token.
    * `:repos` - Ecto repos whose queries are counted, e.g. `[MyApp.Repo]`.
    * `:max_stream_names` - how many distinct names one stream kind may hold
      (default `400`). Later names are counted under `"(other)"`.
    * `:log_events` - `false` keeps log messages out of the report's
      `"events"` (log events are still counted per level). Default `true`.
    * `:log_level` - the lowest level whose messages go into `"events"`
      (default `:warning`).
    * `:observer` - `false` turns `/observer/...` off (404). By default
      it is on, but its reads answer 403 while there is no `:token`
      (the listener binds every interface, and the reads list every
      process, tree, table and port, and a procs read walks every process
      twice). `true` serves them without a token too: say so only where
      the port is reachable by the observer alone. See
      `FactoryReport.Observer`.
    * `:inspect_state` - `true` lets `GET /observer/proc/:pid?state=true`
      read a process's state with `:sys.get_state/2`. Default `false`.
    * `:actions_token` - a non-empty string turns the observer's actions
      (kill, exit, gc, restart, logger level) on, behind
      `authorization: Bearer <actions_token>`. Default: the
      `FACTORY_REPORT_ACTIONS_TOKEN` environment variable; unset or empty
      means actions are off (403).

  One instance per VM: the tables are named.
  """

  use Supervisor

  alias FactoryReport.{Cluster, LiveViews, LogHandler, Runtime, Streams, Tables, Tracker}

  @version 1
  @meta :factory_report_meta
  @default_port 9568

  @max_units 100
  @max_members 20
  @max_streams 300
  @max_tables 100

  @type option ::
          {:app, atom}
          | {:port, :inet.port_number() | false}
          | {:ip, :inet.ip_address()}
          | {:token, String.t() | nil}
          | {:repos, [module]}
          | {:max_stream_names, pos_integer}
          | {:log_events, boolean}
          | {:log_level, Logger.level()}
          | {:observer, boolean}
          | {:inspect_state, boolean}
          | {:actions_token, String.t() | nil}

  @doc false
  def child_spec(opts) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}, type: :supervisor}
  end

  @doc "Starts the reporter. See the module documentation for the options."
  @spec start_link([option]) :: Supervisor.on_start()
  def start_link(opts) when is_list(opts) do
    app = Keyword.get(opts, :app)

    if not (is_atom(app) and not is_nil(app)) do
      raise ArgumentError, "FactoryReport needs app: :your_app, got: #{inspect(app)}"
    end

    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    # The tables belong to the supervisor, so a collector that restarts finds
    # its counters and its tracked processes as it left them.
    :ets.new(@meta, [:named_table, :public, :set, read_concurrency: true])
    Streams.create()
    Tables.create()
    Tracker.create()
    LogHandler.create()

    token =
      case Keyword.get(opts, :token) do
        token when is_binary(token) and token != "" -> token
        _ -> nil
      end

    :ets.insert(@meta, [
      {:app, Keyword.fetch!(opts, :app)},
      {:token, token},
      {:max_stream_names, Keyword.get(opts, :max_stream_names, 400)},
      {:handler_errors, 0},
      {:observer, observer_config(opts)}
    ])

    port = Keyword.get(opts, :port, @default_port)

    listener =
      if port do
        [
          Supervisor.child_spec(
            {Bandit,
             plug: {FactoryReport.Plug, []},
             scheme: :http,
             port: port,
             ip: Keyword.get(opts, :ip, {0, 0, 0, 0}),
             startup_log: false,
             thousand_island_options: [num_acceptors: 2, num_connections: 64]},
            id: :listener
          )
        ]
      else
        []
      end

    children = [{Tracker, Keyword.take(opts, [:repos, :log_events, :log_level])} | listener]
    Supervisor.init(children, strategy: :one_for_one)
  end

  # The observer's settings, kept in the meta table for the plug. The
  # actions token falls back to FACTORY_REPORT_ACTIONS_TOKEN, read once here.
  defp observer_config(opts) do
    token =
      case Keyword.get_lazy(opts, :actions_token, fn -> System.get_env("FACTORY_REPORT_ACTIONS_TOKEN") end) do
        token when is_binary(token) and token != "" -> token
        _ -> nil
      end

    %{
      enabled: Keyword.get(opts, :observer, :default) != false,
      open: Keyword.get(opts, :observer, :default) == true,
      inspect_state: Keyword.get(opts, :inspect_state, false) == true,
      actions_token: token
    }
  end

  @doc """
  The report, as a map with string keys ready for a JSON encoder.

  Raises `ArgumentError` when the reporter is not running.
  """
  @spec report() :: map
  def report do
    app =
      case meta(:app) do
        nil -> raise ArgumentError, "FactoryReport is not running"
        app -> app
      end

    {units, cut_units, cut_members} = Tracker.units(@max_units, @max_members)
    {streams, cut_streams} = Streams.rows(@max_streams)
    {tables, cut_tables} = Tables.rows(@max_tables)

    %{
      "factory_report" => @version,
      "app" => to_string(app),
      "at" => DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      "runtime" => Runtime.section(app),
      "cluster" => Cluster.section(),
      "units" => units,
      "liveviews" => LiveViews.section(),
      "streams" => streams,
      "tables" => tables,
      "events" => LogHandler.events(),
      "truncated" => %{
        "units" => cut_units,
        "members" => cut_members,
        "streams" => cut_streams,
        "tables" => cut_tables
      }
    }
  end

  @doc """
  Counts one occurrence in the `custom` stream called `name`.

      FactoryReport.event("gif.rendered")
      FactoryReport.event("gif.rendered", duration: System.monotonic_time() - started)
      FactoryReport.event("gif.rendered", duration_us: 15_300, error: true)

  Options: `:duration` in native time units (what a difference of two
  `System.monotonic_time/0` calls is), or `:duration_us` in microseconds;
  `error: true` also counts it as an error. Always returns `:ok`, also when
  the reporter is not running, and never raises.

  Use a small, fixed set of names: a name is a row in the report. Never put
  an id, a user or a URL in it.
  """
  @spec event(String.t() | atom, keyword) :: :ok
  def event(name, opts \\ []) do
    native =
      case opts do
        [] ->
          0

        _ ->
          case Keyword.get(opts, :duration_us) do
            us when is_integer(us) -> System.convert_time_unit(us, :microsecond, :native)
            _ -> Keyword.get(opts, :duration, 0)
          end
      end

    name = if is_binary(name), do: name, else: to_string(name)
    Streams.hit_by("custom", name, native, opts != [] and Keyword.get(opts, :error, false) == true)
  catch
    _, _ -> :ok
  end

  @doc """
  The port the listener is bound to, or `nil` when there is none. With
  `port: 0` this is the port the system chose.
  """
  @spec port() :: :inet.port_number() | nil
  def port do
    with children when is_list(children) <- safe_children(),
         {_, pid, _, _} when is_pid(pid) <- List.keyfind(children, :listener, 0),
         {:ok, {_ip, port}} <- ThousandIsland.listener_info(pid) do
      port
    else
      _ -> nil
    end
  end

  defp safe_children do
    Supervisor.which_children(__MODULE__)
  catch
    :exit, _ -> nil
  end

  @doc false
  def meta(key) do
    case :ets.lookup(@meta, key) do
      [{_, value}] -> value
      [] -> nil
    end
  rescue
    ArgumentError -> nil
  end

  @doc false
  def put_meta(key, value), do: :ets.insert(@meta, {key, value})

  @doc false
  # Telemetry handlers that had to swallow an error count it here, so a
  # broken handler is visible in the report instead of silent.
  def handler_error do
    :ets.update_counter(@meta, :handler_errors, 1, {:handler_errors, 0})
    :ok
  catch
    _, _ -> :ok
  end
end
