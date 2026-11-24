defmodule FactoryReport.Handlers do
  @moduledoc false
  # The telemetry handlers. They run inside the host app's own request,
  # LiveView and channel processes, so every one of them:
  #
  #   * is O(1): pattern matches, one or two ETS counter updates;
  #   * never raises: `handle/4` catches everything (`:telemetry` detaches a
  #     handler that raises) and counts what it swallowed;
  #   * sends at most one message, once in a tracked process's life.
  #
  # Events are attached by name, so nothing here needs Phoenix, LiveView,
  # Finch or Ecto to exist: an event that is never emitted costs nothing.

  alias FactoryReport.{Attribution, Streams, Tables, Tracker}

  @http [
    [:phoenix, :router_dispatch, :start],
    [:phoenix, :router_dispatch, :stop],
    [:phoenix, :router_dispatch, :exception]
  ]

  @liveview [
    [:phoenix, :live_view, :mount, :start],
    [:phoenix, :live_view, :mount, :stop],
    [:phoenix, :live_view, :mount, :exception],
    [:phoenix, :live_view, :handle_params, :stop],
    [:phoenix, :live_view, :handle_params, :exception],
    [:phoenix, :live_view, :handle_event, :stop],
    [:phoenix, :live_view, :handle_event, :exception],
    [:phoenix, :live_component, :handle_event, :stop],
    [:phoenix, :live_component, :handle_event, :exception],
    [:phoenix, :live_view, :render, :stop]
  ]

  @channel [
    [:phoenix, :channel_joined],
    [:phoenix, :channel_handled_in]
  ]

  @finch [
    [:finch, :request, :stop],
    [:finch, :request, :exception]
  ]

  @doc "Every event attached to, by group. Repos add `prefix ++ [:query]`."
  def events, do: %{http: @http, liveview: @liveview, channel: @channel, finch: @finch}

  def attach(repos) do
    groups =
      [http: @http, liveview: @liveview, channel: @channel, finch: @finch]
      |> Enum.map(fn {group, events} -> {{FactoryReport, group}, events, nil} end)

    repos =
      for repo <- repos, is_atom(repo) do
        {{FactoryReport, {:repo, repo}}, [repo_event(repo)], {:repo, inspect(repo)}}
      end

    for {id, events, config} <- groups ++ repos do
      # A previous owner that was killed could not detach.
      :telemetry.detach(id)
      :telemetry.attach_many(id, events, &__MODULE__.handle/4, config)
    end

    FactoryReport.put_meta(:handler_ids, Enum.map(groups ++ repos, &elem(&1, 0)))
    :ok
  end

  def detach do
    for id <- FactoryReport.meta(:handler_ids) || [], do: :telemetry.detach(id)
    :ok
  end

  @doc "The telemetry event an Ecto repo reports its queries on."
  def repo_event(repo) do
    configured =
      try do
        repo.config()[:telemetry_prefix]
      catch
        _, _ -> nil
      end

    prefix =
      if is_list(configured) and configured != [] do
        configured
      else
        # Ecto's own default.
        repo |> Module.split() |> Enum.map(&(&1 |> Macro.underscore() |> String.to_atom()))
      end

    prefix ++ [:query]
  end

  @doc false
  def handle(event, measurements, metadata, config) do
    dispatch(event, measurements, metadata, config)
    :ok
  catch
    _, _ -> FactoryReport.handler_error()
  end

  # ---- http ----

  # From here to :stop, what this process does is done for this route.
  defp dispatch([:phoenix, :router_dispatch, :start], _, %{conn: %{method: method}, route: route}, _) do
    Attribution.mark({"http.route", http_name(method, route)})
  end

  defp dispatch([:phoenix, :router_dispatch, :stop], %{duration: d}, %{conn: conn, route: route}, _) do
    # A kept-alive connection serves its next request in this same process.
    Attribution.clear()
    %{method: method, status: status} = conn
    Streams.hit("http.route", http_name(method, route), d, is_integer(status) and status >= 500)
  end

  # The mark stays after a raise: what the web server logs about the crash,
  # in this process, belongs to the route.
  defp dispatch([:phoenix, :router_dispatch, :exception], %{duration: d}, %{conn: conn, route: route}, _) do
    Streams.hit("http.route", http_name(conn.method, route), d, true)
  end

  # ---- liveview ----

  # Marked before mount/3 runs, so a task it starts already finds its caller.
  defp dispatch([:phoenix, :live_view, :mount, :start], _, %{socket: socket}, _) do
    if connected?(socket), do: Attribution.mark({"liveview", view_name(socket)})
  end

  defp dispatch([:phoenix, :live_view, :mount, :stop], %{duration: d}, %{socket: socket} = meta, _) do
    name = view_name(socket)
    Streams.hit("liveview.mount", name, d, false)
    if connected?(socket), do: Tracker.put("liveview", name, place(socket, meta[:uri]))
  end

  defp dispatch([:phoenix, :live_view, :mount, :exception], %{duration: d}, %{socket: socket}, _) do
    Streams.hit("liveview.mount", view_name(socket), d, true)
  end

  defp dispatch([:phoenix, :live_view, :handle_params, :stop], %{duration: d}, %{socket: socket} = meta, _) do
    name = view_name(socket)
    Streams.hit("liveview.params", name, d, false)
    if connected?(socket), do: Tracker.put("liveview", name, place(socket, meta[:uri]))
  end

  defp dispatch([:phoenix, :live_view, :handle_params, :exception], %{duration: d}, %{socket: socket}, _) do
    Streams.hit("liveview.params", view_name(socket), d, true)
  end

  defp dispatch(
         [:phoenix, :live_view, :handle_event, :stop],
         %{duration: d},
         %{socket: socket, event: event},
         _
       ) do
    Streams.hit("liveview.event", event_name(view_name(socket), event), d, false)
    Tracker.bump()
  end

  defp dispatch(
         [:phoenix, :live_view, :handle_event, :exception],
         %{duration: d},
         %{socket: socket, event: event},
         _
       ) do
    Streams.hit("liveview.event", event_name(view_name(socket), event), d, true, false)
    Tracker.bump()
  end

  defp dispatch(
         [:phoenix, :live_component, :handle_event, :stop],
         %{duration: d},
         %{component: component, event: event},
         _
       ) do
    Streams.hit("liveview.event", event_name(module_name(component), event), d, false)
    Tracker.bump()
  end

  defp dispatch(
         [:phoenix, :live_component, :handle_event, :exception],
         %{duration: d},
         %{component: component, event: event},
         _
       ) do
    Streams.hit("liveview.event", event_name(module_name(component), event), d, true, false)
    Tracker.bump()
  end

  # Every connected LiveView renders, also one with no mount/3 and no
  # handle_params/3 (which then emits neither event). Renders are frequent,
  # so the usual path here is a single ETS membership test.
  defp dispatch([:phoenix, :live_view, :render, :stop], _, %{socket: socket}, _) do
    if connected?(socket) and not Tracker.tracked?(self()) do
      Tracker.put("liveview", view_name(socket), place(socket, nil))
    end
  end

  # ---- channels ----

  defp dispatch([:phoenix, :channel_joined], %{duration: d}, %{socket: socket, result: result}, _) do
    %{channel: channel, topic: topic} = socket
    Streams.hit("channel.join", module_name(channel), d, result != :ok)

    if result == :ok do
      # The prefix only: the rest of a topic is very often a user or a room id.
      prefix = topic_prefix(topic)
      Tracker.put("channel", prefix, {nil, prefix})
    end
  end

  defp dispatch([:phoenix, :channel_handled_in], %{duration: d}, %{socket: socket, event: event}, _) do
    Streams.hit("channel.event", event_name(module_name(socket.channel), event), d, false)
    Tracker.bump()
  end

  # ---- outbound http ----

  defp dispatch([:finch, :request, :stop], %{duration: d}, %{request: request} = meta, _) do
    error? =
      case meta[:result] do
        {:error, _} -> true
        {:ok, %{status: status}} when is_integer(status) and status >= 500 -> true
        _ -> false
      end

    Streams.hit_by("outbound.http", host_name(request), d, error?)
  end

  defp dispatch([:finch, :request, :exception], %{duration: d}, %{request: request}, _) do
    Streams.hit_by("outbound.http", host_name(request), d, true)
  end

  # ---- ecto ----

  defp dispatch(_event, measurements, metadata, {:repo, name}) do
    error? = match?(%{result: {:error, _}}, metadata)
    total = Map.get(measurements, :total_time, 0)
    Streams.hit_by("db.query", name, total, error?)
    # The same query again, by table (Ecto's `source`; nil for Repo.query/3
    # and begin/commit). Not attributed to a page: the page breakdown is on
    # db.query, and repo x table x page would multiply the rows.
    Tables.hit(name, metadata[:source], total, error?)
  end

  # ---- names ----

  defp connected?(%{transport_pid: pid}), do: is_pid(pid)

  defp view_name(%{view: view}), do: module_name(view)

  defp module_name(module) when is_atom(module), do: inspect(module)

  # The event name is the client's to choose: cut it before joining.
  defp event_name(owner, event), do: owner <> "#" <> Streams.cut(event)

  defp http_name(method, route) when is_binary(method) and is_binary(route) do
    method = if byte_size(method) > 16, do: binary_part(method, 0, 16), else: method
    method <> " " <> route
  end

  defp host_name(%{host: host}) when is_binary(host), do: host
  defp host_name(_), do: "(unix socket)"

  defp topic_prefix(topic) when is_binary(topic) do
    case :binary.match(topic, ":") do
      {at, 1} -> binary_part(topic, 0, at + 1) <> "*"
      :nomatch -> topic
    end
  end

  # Where a LiveView is: `{route pattern | nil, path}`, or nil when it cannot
  # be told (the caller then keeps what the row says). The path is the URI's
  # path alone: no query string, no fragment.
  defp place(socket, uri) when is_binary(uri) do
    %URI{path: path, host: host} = URI.parse(uri)
    path = Streams.cut(path || "/")
    {route(socket, path, host), path}
  catch
    _, _ -> place(socket, nil)
  end

  # A nested LiveView has no URI of its own: it is wherever its root is.
  defp place(%{root_pid: root}, _) when is_pid(root) and root != self(), do: Tracker.place(root)
  defp place(_, _), do: nil

  defp route(%{router: router}, path, host) when is_atom(router) and not is_nil(router) do
    # apply/3: Phoenix is not a compile-time dependency of this library.
    case apply(Phoenix.Router, :route_info, [router, "GET", path, host || ""]) do
      %{route: route} when is_binary(route) -> route
      _ -> nil
    end
  catch
    _, _ -> nil
  end

  defp route(_, _, _), do: nil
end
