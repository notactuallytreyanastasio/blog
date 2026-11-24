defmodule FactoryReport.Observer do
  @moduledoc """
  An on-demand `:observer` for this VM, as JSON: the system, the started
  applications, each application's supervision tree, the busiest processes,
  one process in detail, ETS tables and ports; and a few actions on them
  (kill, exit, garbage collect, restart a supervised child, set the Logger
  level).

  Nothing here runs until it is asked: no process, no table, no telemetry.
  `FactoryReport.Plug` serves it under `/observer/...` (see the README,
  "Observer"); `dispatch/4` is the same thing without HTTP, for an app that
  wants to answer for its own VM in-process.

  Every answer is a map with string keys and always carries `"took_ms"` and
  `"node"`. Every list and string is bounded, and what was cut is said.
  Message contents, process dictionary values and process state never leave
  the VM, except the state of one process when the caller passed
  `inspect_state: true` and the request asked for it.
  """

  require Logger

  # Bounds. They are in the README and in docs/contract.md, "Observer".
  @max_list 100
  @max_stack 30
  @max_string 200
  @tree_children 25
  @tree_depth 8
  @tree_depth_max 12
  @tree_nodes 1_500
  @tree_ms 2_000
  @procs_limit 50
  @procs_limit_max 200
  @procs_walk 100_000
  @interval_max 2_000
  @max_tables 500
  @max_ports 500
  @max_apps 200
  @state_timeout 500
  @state_bytes 4_096
  @call_timeout 1_000

  @summary_keys [:registered_name, :current_function, :initial_call, :status, :message_queue_len, :memory, :reductions, :links]
  @sorts ~w(reductions memory message_queue_len)
  @exit_reasons ~w(shutdown normal kill)
  @levels ~w(all debug info notice warning error critical alert emergency none)

  @type result :: {status :: pos_integer, body :: map}

  @doc """
  Answers one observer request without HTTP.

    * `method` - `"GET"` or `"POST"`.
    * `path` - the segments after `/observer`, e.g. `["proc", "0.123.0"]`.
    * `params` - query parameters (GET) or the decoded JSON body (POST),
      string keys.
    * `opts` - `inspect_state: true` allows `GET proc/:pid?state=true` to
      read the process's state; `by:` (a string) is who asked, for the log
      line every action writes; `log: false` leaves that log line to the
      caller.

  Authorization is the caller's: `dispatch/4` does every action it is asked.
  Returns `{status, body}`; body always has `"took_ms"` and `"node"`.
  """
  @spec dispatch(String.t(), [String.t()], map, keyword) :: result
  def dispatch(method, path, params, opts \\ []) do
    started = System.monotonic_time(:microsecond)

    {status, body} =
      try do
        route(method, path, params || %{}, opts)
      catch
        {:bad, status, message} -> {status, %{"error" => message}}
      end

    took = (System.monotonic_time(:microsecond) - started) / 1000
    {status, Map.merge(body, %{"took_ms" => Float.round(took, 2), "node" => to_string(node())})}
  end

  @doc "Whether `path` (segments after `/observer`) names an action, i.e. needs POST and the actions token."
  def action?(["proc", _, verb]) when verb in ~w(kill gc exit), do: true
  def action?(["tree", _, "restart"]), do: true
  def action?(["logger", "level"]), do: true
  def action?(_), do: false

  # ---- routes ----------------------------------------------------------------

  defp route("GET", [], _params, opts), do: {200, index(opts)}
  defp route("GET", ["system"], _params, _opts), do: {200, system()}
  defp route("GET", ["apps"], _params, _opts), do: {200, apps()}
  defp route("GET", ["tree", app], params, _opts), do: {200, tree(started_app!(app), params)}
  defp route("GET", ["procs"], params, _opts), do: {200, procs(params)}
  defp route("GET", ["proc", pid], params, opts), do: {200, proc(local_pid!(pid), params, opts)}
  defp route("GET", ["ets"], _params, _opts), do: {200, ets()}
  defp route("GET", ["ports"], _params, _opts), do: {200, ports()}

  defp route("POST", ["proc", pid, verb], params, opts) when verb in ~w(kill gc exit),
    do: act(verb, local_pid!(pid), params, opts)

  defp route("POST", ["tree", app, "restart"], params, opts), do: restart(started_app!(app), params, opts)
  defp route("POST", ["logger", "level"], params, opts), do: logger_level(params, opts)

  defp route(method, path, _params, _opts) do
    other = if method == "GET", do: "POST", else: "GET"

    if match?({_, _}, safe_route_exists(other, path)) do
      bad(405, "#{method} is not allowed on /observer/#{Enum.join(path, "/")}; use #{other}")
    else
      bad(404, "no such observer endpoint: #{method} /observer/#{Enum.join(path, "/")}")
    end
  end

  defp safe_route_exists("POST", path), do: if(action?(path), do: {:post, path})
  defp safe_route_exists("GET", [p | _] = path) when p in ~w(system apps tree procs proc ets ports) and length(path) <= 2, do: {:get, path}
  defp safe_route_exists(_, _), do: nil

  defp index(opts) do
    %{
      "observer" => 1,
      "reads" => ~w(system apps tree/:app procs proc/:pid ets ports),
      "actions" => ~w(proc/:pid/kill proc/:pid/gc proc/:pid/exit tree/:app/restart logger/level),
      "inspect_state" => Keyword.get(opts, :inspect_state, false) == true
    }
  end

  # ---- system ----------------------------------------------------------------

  @doc false
  def system do
    {wall_ms, _} = :erlang.statistics(:wall_clock)
    {reductions, _} = :erlang.statistics(:reductions)
    {gcs, words, _} = :erlang.statistics(:garbage_collection)
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    {switches, _} = :erlang.statistics(:context_switches)
    wordsize = :erlang.system_info(:wordsize)

    %{
      "otp_release" => List.to_string(:erlang.system_info(:otp_release)),
      "erts_version" => List.to_string(:erlang.system_info(:version)),
      "elixir" => System.version(),
      "system_version" => :erlang.system_info(:system_version) |> List.to_string() |> String.trim() |> clip(),
      "uptime_s" => div(wall_ms, 1000),
      "system_info" => %{
        "wordsize_bytes" => wordsize,
        "logical_processors" => info_or_nil(:logical_processors),
        "logical_processors_online" => info_or_nil(:logical_processors_online),
        "kernel_poll" => :erlang.system_info(:kernel_poll),
        "build_type" => to_string(:erlang.system_info(:build_type)),
        "emu_flavor" => info_or_nil(:emu_flavor) |> nil_or_string(),
        "os_type" => :os.type() |> Tuple.to_list() |> Enum.map_join("/", &to_string/1),
        "os_version" => os_version(),
        "port_parallelism" => :erlang.system_info(:port_parallelism),
        "dist_buf_busy_limit_bytes" => :erlang.system_info(:dist_buf_busy_limit)
      },
      "schedulers" => %{
        "total" => :erlang.system_info(:schedulers),
        "online" => :erlang.system_info(:schedulers_online),
        "dirty_cpu" => :erlang.system_info(:dirty_cpu_schedulers),
        "dirty_cpu_online" => :erlang.system_info(:dirty_cpu_schedulers_online),
        "dirty_io" => :erlang.system_info(:dirty_io_schedulers)
      },
      "limits" => %{
        "process" => %{"count" => :erlang.system_info(:process_count), "limit" => :erlang.system_info(:process_limit)},
        "port" => %{"count" => :erlang.system_info(:port_count), "limit" => :erlang.system_info(:port_limit)},
        "atom" => %{"count" => :erlang.system_info(:atom_count), "limit" => :erlang.system_info(:atom_limit)},
        "ets" => %{"count" => :erlang.system_info(:ets_count), "limit" => :erlang.system_info(:ets_limit)}
      },
      "memory" => Map.new(:erlang.memory(), fn {k, v} -> {Atom.to_string(k), v} end),
      "statistics" => %{
        "run_queue" => :erlang.statistics(:total_run_queue_lengths),
        "run_queue_all" => :erlang.statistics(:total_run_queue_lengths_all),
        "reductions" => reductions,
        "context_switches" => switches,
        "gc_count" => gcs,
        "gc_words_reclaimed" => words,
        "io_in_bytes" => input,
        "io_out_bytes" => output
      },
      "allocators" => allocators(),
      "distribution" => distribution(),
      "logger" => %{"primary_level" => Atom.to_string(:logger.get_primary_config().level)}
    }
  end

  defp info_or_nil(key) do
    case :erlang.system_info(key) do
      :unknown -> nil
      value -> value
    end
  rescue
    ArgumentError -> nil
  end

  defp nil_or_string(nil), do: nil
  defp nil_or_string(v), do: to_string(v)

  defp os_version do
    case :os.version() do
      {a, b, c} -> "#{a}.#{b}.#{c}"
      other when is_list(other) -> List.to_string(other)
    end
  end

  # Per allocator type: the bytes in blocks (what was asked for) and in
  # carriers (what was taken from the OS), summed over instances and over
  # multi- and single-block carriers. `{:allocator_sizes, a}` is a read of
  # counters the allocators keep; a few dozen instances at most.
  defp allocators do
    case :erlang.system_info(:alloc_util_allocators) do
      list when is_list(list) ->
        list
        |> Enum.map(fn a ->
          {blocks, carriers} = allocator_sizes(:erlang.system_info({:allocator_sizes, a}))
          %{"name" => Atom.to_string(a), "blocks_bytes" => blocks, "carriers_bytes" => carriers}
        end)
        |> Enum.sort_by(&(-&1["carriers_bytes"]))

      _ ->
        []
    end
  catch
    kind, reason -> %{"error" => "allocator sizes unavailable: #{kind} #{clip(inspect(reason, limit: 5))}"}
  end

  defp allocator_sizes(instances) when is_list(instances) do
    Enum.reduce(instances, {0, 0}, fn
      {:instance, _, kinds}, acc when is_list(kinds) ->
        Enum.reduce(kinds, acc, fn
          {kind, parts}, {b, c} when kind in [:mbcs, :sbcs, :mbcs_pool] and is_list(parts) ->
            {b + blocks_size(keyfind(parts, :blocks)), c + current(List.keyfind(parts, :carriers_size, 0))}

          _, acc -> acc
        end)

      _, acc ->
        acc
    end)
  end

  defp allocator_sizes(_), do: {0, 0}

  defp keyfind(list, key) do
    case List.keyfind(list, key, 0) do
      {^key, value} -> value
      _ -> nil
    end
  end

  defp blocks_size(list) when is_list(list) do
    Enum.reduce(list, 0, fn
      {_alloc, items}, sum when is_list(items) -> sum + current(List.keyfind(items, :size, 0))
      _, sum -> sum
    end)
  end

  defp blocks_size(_), do: 0

  defp current({:size, cur, _, _}) when is_integer(cur), do: cur
  defp current({:carriers_size, cur, _, _}) when is_integer(cur), do: cur
  defp current(cur) when is_integer(cur), do: cur
  defp current(_), do: 0

  # This node in its cluster: who it is connected to, and how. The cookie is
  # never read.
  defp distribution do
    %{
      "alive" => Node.alive?(),
      "node" => to_string(node()),
      "net_ticktime_s" => net_ticktime(),
      "connected" =>
        (Enum.map(Node.list(:visible), &%{"node" => to_string(&1), "kind" => "visible"}) ++
           Enum.map(Node.list(:hidden), &%{"node" => to_string(&1), "kind" => "hidden"}))
        |> Enum.sort_by(& &1["node"])
        |> Enum.take(@max_list)
    }
  end

  defp net_ticktime do
    case :net_kernel.get_net_ticktime() do
      t when is_integer(t) -> t
      {:ongoing_change_to, t} -> t
      _ -> nil
    end
  catch
    _, _ -> nil
  end

  # ---- apps ------------------------------------------------------------------

  @doc false
  def apps do
    started = Application.started_applications() |> Enum.take(@max_apps)

    tops =
      started
      |> Task.async_stream(fn {app, _, _} -> top_supervisor(app) end,
        timeout: @call_timeout + 200,
        on_timeout: :kill_task,
        max_concurrency: 16
      )
      |> Enum.map(fn
        {:ok, top} -> top
        {:exit, _} -> {:error, "application master did not answer in #{@call_timeout} ms"}
      end)

    rows =
      started
      |> Enum.zip(tops)
      |> Enum.map(fn {{app, desc, vsn}, top} ->
        base = %{
          "name" => Atom.to_string(app),
          "description" => desc |> to_string() |> clip(),
          "vsn" => vsn |> to_string() |> clip()
        }

        case top do
          {:ok, pid} -> Map.merge(base, %{"top_supervisor" => pid_text(pid), "error" => nil})
          nil -> Map.merge(base, %{"top_supervisor" => nil, "error" => nil})
          {:error, reason} -> Map.merge(base, %{"top_supervisor" => nil, "error" => reason})
        end
      end)
      |> Enum.sort_by(& &1["name"])

    %{"apps" => rows, "count" => length(Application.started_applications())}
  end

  # The pid of the application's top supervisor: `{:ok, pid}`, `nil` for a
  # library application (no master, or a master with no child), or
  # `{:error, reason}`.
  defp top_supervisor(app) do
    case :application_controller.get_master(app) do
      :undefined ->
        nil

      master ->
        task = Task.async(fn -> :application_master.get_child(master) end)

        case Task.yield(task, @call_timeout) || Task.shutdown(task, :brutal_kill) do
          {:ok, {pid, _mod}} when is_pid(pid) -> {:ok, pid}
          {:ok, _} -> nil
          _ -> {:error, "application master did not answer in #{@call_timeout} ms"}
        end
    end
  end

  # An application name from the URL, matched against the started ones by
  # name: no atom is created from input.
  defp started_app!(name) do
    case Enum.find(Application.started_applications(), fn {app, _, _} -> Atom.to_string(app) == name end) do
      {app, _, _} -> app
      nil -> bad(404, "no started application #{inspect(clip(name))}")
    end
  end

  # ---- tree ------------------------------------------------------------------

  @doc false
  def tree(app, params) do
    depth = int_param!(params, "depth", @tree_depth, 1, @tree_depth_max)

    case top_supervisor(app) do
      nil ->
        bad(404, "#{app} has no supervision tree (a library application)")

      {:error, reason} ->
        bad(504, reason)

      {:ok, pid} ->
        ctx = %{
          max_depth: depth,
          nodes: 0,
          deadline: System.monotonic_time(:millisecond) + @tree_ms,
          dict: dict_key?(),
          cut: %{"depth" => 0, "grouped" => 0, "nodes" => 0, "time" => 0, "errors" => 0}
        }

        {root, ctx} = walk(pid, inspect(app_module(app)), "supervisor", 0, ctx)

        %{
          "app" => Atom.to_string(app),
          "supervisor" => pid_text(pid),
          "depth_limit" => depth,
          "children_limit" => @tree_children,
          "node_limit" => @tree_nodes,
          "time_limit_ms" => @tree_ms,
          "nodes" => ctx.nodes,
          "tree" => root,
          "cut" => ctx.cut
        }
    end
  end

  defp app_module(app) do
    case Application.spec(app, :mod) do
      {mod, _} -> mod
      _ -> app
    end
  end

  defp walk(pid, id, type, depth, ctx) do
    ctx = %{ctx | nodes: ctx.nodes + 1}

    case summary(pid, ctx.dict) do
      nil ->
        {%{"id" => id, "type" => type, "pid" => pid_text(pid), "status" => "dead", "children" => nil, "not_walked" => nil}, ctx}

      node ->
        node = Map.merge(node, %{"id" => id, "type" => type})

        if type == "supervisor" do
          {children, not_walked, ctx} = children(pid, node, depth, ctx)
          {node |> Map.delete("supervisor?") |> Map.merge(%{"children" => children, "not_walked" => not_walked}), ctx}
        else
          {Map.delete(node, "supervisor?"), ctx}
        end
    end
  end

  defp children(pid, node, depth, ctx) do
    cond do
      not supervisor_call?(node) ->
        {nil, "not a supervisor: initial call #{node["initial_call"] || "unknown"}", ctx}

      depth >= ctx.max_depth ->
        {nil, "depth limit #{ctx.max_depth}", bump(ctx, "depth")}

      ctx.nodes >= @tree_nodes ->
        {nil, "node limit #{@tree_nodes}", bump(ctx, "nodes")}

      System.monotonic_time(:millisecond) > ctx.deadline ->
        {nil, "time limit #{@tree_ms} ms", bump(ctx, "time")}

      true ->
        case which_children(pid) do
          {:ok, list} -> walk_children(pid, list, depth, ctx)
          {:error, reason} -> {nil, reason, bump(ctx, "errors")}
        end
    end
  end

  defp walk_children(sup, list, depth, ctx) do
    {listed, rest} =
      if length(list) > @tree_children do
        list
        |> Enum.map(fn {_, child, _, _} = c -> {c, memory_of(child)} end)
        |> Enum.sort_by(fn {_, mem} -> -mem end)
        |> Enum.map(&elem(&1, 0))
        |> Enum.split(@tree_children)
      else
        {list, []}
      end

    {nodes, ctx} =
      Enum.map_reduce(listed, ctx, fn
        {id, child, type, _mods}, ctx when is_pid(child) ->
          walk(child, clip(inspect(id)), Atom.to_string(type), depth + 1, ctx)

        {id, child, type, _mods}, ctx ->
          restart = restart_type(sup, id)

          # A child with no process is only a problem if its supervisor meant
          # to keep it running. :transient and :temporary children that ran
          # and stopped (a boot-time Task such as marginalia's :warmup, or
          # kernel's :on_load) are "finished"; they read as down otherwise.
          status =
            cond do
              child == :restarting -> "restarting"
              restart in ["transient", "temporary"] -> "finished"
              true -> "not running"
            end

          {%{"id" => clip(inspect(id)), "type" => Atom.to_string(type), "pid" => nil, "status" => status,
             "restart" => restart, "children" => nil, "not_walked" => nil}, %{ctx | nodes: ctx.nodes + 1}}
      end)

    case rest do
      [] ->
        {nodes, nil, ctx}

      _ ->
        pids = for {_, p, _, _} <- rest, is_pid(p), do: p
        info = for p <- pids, i = :erlang.process_info(p, [:memory, :message_queue_len]), i != :undefined, do: i

        group = %{
          "group" => true,
          "count" => length(rest),
          "memory" => info |> Enum.map(& &1[:memory]) |> Enum.sum(),
          "message_queue_len_max" => info |> Enum.map(& &1[:message_queue_len]) |> Enum.max(fn -> 0 end)
        }

        {nodes ++ [group], nil, %{ctx | cut: Map.update!(ctx.cut, "grouped", &(&1 + length(rest)))}}
    end
  end

  defp bump(ctx, key), do: %{ctx | cut: Map.update!(ctx.cut, key, &(&1 + 1))}

  defp memory_of(pid) when is_pid(pid) do
    case :erlang.process_info(pid, :memory) do
      {:memory, m} -> m
      _ -> 0
    end
  end

  defp memory_of(_), do: 0

  # Only a process that proc_lib says is a supervisor (Supervisor,
  # DynamicSupervisor, Task.Supervisor, PartitionSupervisor and :supervisor
  # all start with `$initial_call` {:supervisor, Mod, 1}) is sent a
  # `which_children` call: anything else might crash on a call it does not
  # expect.
  defp supervisor_call?(%{"supervisor?" => true}), do: true
  defp supervisor_call?(_), do: false

  # "permanent" | "transient" | "temporary", or nil when the supervisor does
  # not say (a DynamicSupervisor, or no answer in time).
  defp restart_type(sup, id) do
    case :supervisor.get_childspec(sup, id) do
      {:ok, %{restart: r}} when r in [:permanent, :transient, :temporary] -> Atom.to_string(r)
      {:ok, {_id, _start, r, _shut, _type, _mods}} when r in [:permanent, :transient, :temporary] -> Atom.to_string(r)
      _ -> nil
    end
  catch
    :exit, _ -> nil
  end

  defp which_children(pid) do
    {:ok, GenServer.call(pid, :which_children, @call_timeout)}
  catch
    :exit, {:timeout, _} -> {:error, "which_children did not answer in #{@call_timeout} ms"}
    :exit, reason -> {:error, "which_children failed: #{clip(inspect(reason, limit: 5))}"}
  end

  # ---- procs -----------------------------------------------------------------

  @doc false
  def procs(params) do
    sort = Map.get(params, "sort", "reductions")
    sort in @sorts || bad(400, "sort must be one of #{Enum.join(@sorts, ", ")}")
    limit = int_param!(params, "limit", @procs_limit, 1, @procs_limit_max)
    interval = int_param!(params, "interval_ms", 0, 0, @interval_max)

    if interval > 0 and sort != "reductions" do
      bad(400, "interval_ms only applies to sort=reductions")
    end

    key = String.to_existing_atom(sort)
    all = :erlang.processes()
    total = length(all)
    pids = Enum.take(all, @procs_walk)
    first = sample(pids, key)

    ranked =
      if interval > 0 do
        Process.sleep(interval)
        second = sample(pids, key) |> Map.new()

        first
        |> Enum.flat_map(fn {pid, before} ->
          case Map.fetch(second, pid) do
            {:ok, now} -> [{pid, now - before}]
            :error -> []
          end
        end)
      else
        first
      end
      |> Enum.sort_by(fn {_, v} -> -v end)
      |> Enum.take(limit)

    dict = dict_key?()

    rows =
      Enum.flat_map(ranked, fn {pid, value} ->
        case summary(pid, dict) do
          nil ->
            []

          s when interval > 0 ->
            [Map.merge(s, %{"reductions_delta" => value, "reductions_per_s" => round(value * 1000 / interval)})]

          s ->
            [s]
        end
      end)
      |> Enum.map(&Map.delete(&1, "supervisor?"))

    %{
      "sort" => sort,
      "limit" => limit,
      "interval_ms" => interval,
      "total" => total,
      "walked" => length(pids),
      "walk_limit" => @procs_walk,
      "procs" => rows
    }
  end

  defp sample(pids, key) do
    Enum.flat_map(pids, fn pid ->
      case :erlang.process_info(pid, key) do
        {^key, v} -> [{pid, v}]
        _ -> []
      end
    end)
  end

  # ---- proc ------------------------------------------------------------------

  @detail_keys [
    :registered_name,
    :current_function,
    :initial_call,
    :status,
    :message_queue_len,
    :links,
    :monitors,
    :monitored_by,
    :trap_exit,
    :group_leader,
    :priority,
    :heap_size,
    :stack_size,
    :total_heap_size,
    :memory,
    :garbage_collection,
    :reductions,
    :current_stacktrace
  ]

  # Listing dictionary keys copies the whole dictionary, values and all,
  # into this process (the VM has no keys-only read). Above this much
  # process memory the keys are not listed, and the answer says why.
  @max_dict_copy 1_048_576

  @doc false
  def proc(pid, params, opts) do
    info =
      case :erlang.process_info(pid, @detail_keys) do
        :undefined -> bad(404, "no process #{pid_text(pid)} (not alive)")
        list -> Map.new(list)
      end

    {dict, keys_part} = dictionary(pid, info[:memory])
    initial = initial_call(:erlang.process_info(pid, :initial_call), dict_get(dict, :"$initial_call"))

    gc = info[:garbage_collection] || []

    %{
      "pid" => pid_text(pid),
      "registered_name" => name_text(info[:registered_name]),
      "initial_call" => initial,
      "current_function" => mfa_text(info[:current_function]),
      "current_stacktrace" => info[:current_stacktrace] |> Enum.take(@max_stack) |> Enum.map(&frame/1),
      "status" => Atom.to_string(info[:status]),
      "message_queue_len" => info[:message_queue_len],
      "links" => info[:links] |> Enum.take(@max_list) |> Enum.map(&ref_obj/1),
      "links_count" => length(info[:links]),
      "monitors" => info[:monitors] |> Enum.take(@max_list) |> Enum.map(&monitor_obj/1),
      "monitors_count" => length(info[:monitors]),
      "monitored_by" => info[:monitored_by] |> Enum.take(@max_list) |> Enum.map(&ref_obj/1),
      "monitored_by_count" => length(info[:monitored_by]),
      "trap_exit" => info[:trap_exit],
      "group_leader" => pid_text(info[:group_leader]),
      "priority" => Atom.to_string(info[:priority]),
      "heap_size_words" => info[:heap_size],
      "stack_size_words" => info[:stack_size],
      "total_heap_size_words" => info[:total_heap_size],
      "memory" => info[:memory],
      "garbage_collection" =>
        for({k, v} <- gc, k in [:min_heap_size, :min_bin_vheap_size, :max_heap_size, :fullsweep_after, :minor_gcs], into: %{}, do: {Atom.to_string(k), gc_value(v)}),
      "reductions" => info[:reductions],
      "application" => application_of(pid),
      "supervisor_path" => supervisor_path(pid, dict),
      "state" => state(pid, dict_get(dict, :"$initial_call"), params, opts)
    }
    |> Map.merge(keys_part)
  end

  # `{dict, fields}`: `dict` holds `$initial_call` and `$ancestors` (read
  # alone where the VM can), `fields` the key names and count, or, for a
  # process above @max_dict_copy, nil for both and `dictionary_not_read`.
  defp dictionary(pid, memory) do
    small? = is_integer(memory) and memory <= @max_dict_copy

    full =
      if small? or not dict_key?() do
        case :erlang.process_info(pid, :dictionary) do
          {:dictionary, d} -> d
          :undefined -> bad(404, "no process #{pid_text(pid)} (not alive)")
        end
      end

    dict =
      if full,
        do: Enum.filter(full, fn {k, _} -> k in [:"$initial_call", :"$ancestors"] end),
        else: for(k <- [:"$initial_call", :"$ancestors"], {_, v} = :erlang.process_info(pid, {:dictionary, k}), v != :undefined, do: {k, v})

    fields =
      if small? do
        %{
          "dictionary_keys" => full |> Enum.map(fn {k, _} -> clip(inspect(k, limit: 5)) end) |> Enum.sort() |> Enum.take(@max_list),
          "dictionary_count" => length(full)
        }
      else
        %{
          "dictionary_keys" => nil,
          "dictionary_count" => nil,
          "dictionary_not_read" =>
            "the process holds #{memory} bytes (over #{@max_dict_copy}); listing its dictionary keys would copy every value, so they are not listed"
        }
      end

    {dict, fields}
  end

  defp gc_value(v) when is_integer(v), do: v
  defp gc_value(%{size: size}), do: size
  defp gc_value(v), do: clip(inspect(v, limit: 5))

  defp frame({m, f, a, loc}) do
    %{
      "mfa" => mfa_text({m, f, a}),
      "file" => case(loc[:file], do: (nil -> nil; file -> file |> to_string() |> clip())),
      "line" => loc[:line]
    }
  end

  defp application_of(pid) do
    case :application.get_application(pid) do
      {:ok, app} -> Atom.to_string(app)
      :undefined -> nil
    end
  end

  # From `$ancestors`, which proc_lib sets when it starts a process: the
  # chain of processes that started this one, nearest last, the top first.
  # For a supervised process that is its supervisors (a process started by a
  # GenServer lists the GenServer). Names are resolved to pids where they
  # are registered here.
  defp supervisor_path(pid, dict) do
    case dict_get(dict, :"$ancestors") do
      list when is_list(list) ->
        list
        |> Enum.take(@max_list)
        |> Enum.reverse()
        |> Enum.map(fn
          p when is_pid(p) -> %{"pid" => pid_text(p), "registered_name" => registered(p)}
          name when is_atom(name) -> %{"pid" => name |> Process.whereis() |> pid_text(), "registered_name" => inspect(name)}
          other -> %{"pid" => nil, "registered_name" => clip(inspect(other, limit: 5))}
        end)

      _ ->
        _ = pid
        []
    end
  end

  defp registered(pid) do
    case :erlang.process_info(pid, :registered_name) do
      {:registered_name, name} when is_atom(name) and name != [] -> inspect(name)
      _ -> nil
    end
  end

  defp state(pid, proc_lib_initial, params, opts) do
    cond do
      Map.get(params, "state") not in ["true", "1", true] ->
        %{"status" => "not requested"}

      Keyword.get(opts, :inspect_state, false) != true ->
        %{"status" => "off", "reason" => "state inspection is off"}

      pid == self() ->
        %{"status" => "error", "reason" => "cannot read the state of the process answering this request"}

      proc_lib_initial == nil ->
        %{"status" => "error", "reason" => "not an OTP process (no $initial_call): it would not answer a system message"}

      true ->
        try do
          text = inspect(:sys.get_state(pid, @state_timeout), limit: 50, printable_limit: @state_bytes, width: 120)
          cut = binary_cut(text, @state_bytes)
          %{"status" => "ok", "inspected" => cut, "bytes" => byte_size(text), "truncated" => byte_size(cut) < byte_size(text)}
        catch
          :exit, {:timeout, _} -> %{"status" => "error", "reason" => "no answer to :sys.get_state in #{@state_timeout} ms"}
          :exit, reason -> %{"status" => "error", "reason" => ":sys.get_state failed: #{clip(inspect(reason, limit: 5))}"}
        end
    end
  end

  # ---- ets, ports ------------------------------------------------------------

  @doc false
  def ets do
    wordsize = :erlang.system_info(:wordsize)
    all = :ets.all()

    rows =
      all
      |> Enum.flat_map(fn t ->
        case :ets.info(t) do
          :undefined -> []
          info -> [info]
        end
      end)
      |> Enum.sort_by(&(-&1[:memory]))
      |> Enum.take(@max_tables)
      |> Enum.map(fn info ->
        named = info[:named_table] == true

        %{
          "name" => clip(inspect(info[:name])),
          "id" => clip(inspect(info[:id])),
          "named" => named,
          "type" => Atom.to_string(info[:type]),
          "size" => info[:size],
          "memory_bytes" => info[:memory] * wordsize,
          "owner" => pid_text(info[:owner]),
          "owner_name" => registered(info[:owner]),
          "protection" => Atom.to_string(info[:protection])
        }
      end)

    %{"tables" => rows, "count" => length(all), "limit" => @max_tables, "cut" => max(length(all) - @max_tables, 0)}
  end

  @doc false
  def ports do
    all = :erlang.ports()

    rows =
      all
      |> Enum.flat_map(fn p ->
        case :erlang.port_info(p) do
          :undefined -> []
          info -> [{p, info}]
        end
      end)
      |> Enum.sort_by(fn {_, i} -> -((i[:input] || 0) + (i[:output] || 0)) end)
      |> Enum.take(@max_ports)
      |> Enum.map(fn {p, info} ->
        %{
          "id" => inspect(p),
          # A spawned port's name is its whole command line, which can carry
          # arguments and secrets: only the program is kept.
          "name" => info[:name] |> to_string() |> String.split(" ", parts: 2) |> hd() |> clip(),
          "connected" => pid_text(info[:connected]),
          "input_bytes" => info[:input],
          "output_bytes" => info[:output],
          "os_pid" => if(is_integer(info[:os_pid]), do: info[:os_pid])
        }
      end)

    %{"ports" => rows, "count" => length(all), "limit" => @max_ports, "cut" => max(length(all) - @max_ports, 0)}
  end

  # ---- actions ---------------------------------------------------------------

  defp act(verb, pid, params, opts) do
    if verb != "gc", do: refuse_vital!(pid)
    what = "#{verb} #{pid_text(pid)}#{label(pid)}"

    case verb do
      "gc" ->
        before = memory_of(pid)
        alive = :erlang.garbage_collect(pid)
        alive || bad(404, "no process #{pid_text(pid)} (not alive)")
        logged(opts, what)
        {200, %{"ok" => true, "action" => "gc", "pid" => pid_text(pid), "memory_before" => before, "memory_after" => memory_of(pid)}}

      "kill" ->
        logged(opts, what)
        {200, Map.merge(%{"ok" => true, "action" => "kill", "pid" => pid_text(pid)}, exit_and_wait(pid, :kill))}

      "exit" ->
        reason = Map.get(params, "reason")
        reason in @exit_reasons || bad(400, "reason must be one of #{Enum.join(@exit_reasons, ", ")}")
        logged(opts, "#{what} (#{reason})")

        {200,
         Map.merge(%{"ok" => true, "action" => "exit", "reason" => reason, "pid" => pid_text(pid)}, exit_and_wait(pid, String.to_existing_atom(reason)))}
    end
  end

  # Sends the exit signal and waits up to 1 s for the process to go.
  # A process that traps exits survives `shutdown` and `normal`: then
  # `alive_after` is true, which is the answer, not an error.
  defp exit_and_wait(pid, reason) do
    Process.alive?(pid) || bad(404, "no process #{pid_text(pid)} (not alive)")
    ref = Process.monitor(pid)
    Process.exit(pid, reason)

    receive do
      {:DOWN, ^ref, :process, ^pid, why} -> %{"alive_after" => false, "exit_reason" => clip(inspect(why, limit: 5))}
    after
      1_000 ->
        Process.demonitor(ref, [:flush])
        %{"alive_after" => Process.alive?(pid), "exit_reason" => nil}
    end
  end

  # Killing one of these stops or wedges the VM: refused, with the reason.
  # By application (kernel, stdlib), by identity (the VM's own processes,
  # which belong to no application: everything whose group leader is init,
  # i.e. started by erts or init before any application, among them
  # erts_code_purger, socket_registry, erl_prim_loader and logger), by
  # registered name, and any application master (killing it stops its
  # application, and the VM with it when the application is permanent).
  @vital_names ~w(init application_controller erl_prim_loader erts_code_purger socket_registry logger
                  user standard_error code_server file_server_2 kernel_sup user_drv)a
  defp refuse_vital!(pid) do
    init = Process.whereis(:init)
    name = registered(pid)

    cond do
      pid == self() -> bad(409, "refused: #{pid_text(pid)} is the process answering this request")
      pid == init -> bad(409, "refused: #{pid_text(pid)} is init; killing it stops the VM")
      name in Enum.map(@vital_names, &inspect/1) ->
        bad(409, "refused: #{pid_text(pid)}#{label(pid)} is one of the VM's own processes; killing it stops the VM")
      group_leader(pid) == init ->
        bad(409, "refused: #{pid_text(pid)}#{label(pid)} was started by the VM before any application (its group leader is init); killing it can stop the VM")
      application_of(pid) in ["kernel", "stdlib"] ->
        bad(409, "refused: #{pid_text(pid)}#{label(pid)} belongs to #{application_of(pid)}; killing it can stop the VM")
      application_master?(pid) ->
        bad(409, "refused: #{pid_text(pid)} is the application master of #{application_of(pid)}; killing it stops the application, and the VM if it is permanent")
      true -> :ok
    end
  end

  defp group_leader(pid) do
    case :erlang.process_info(pid, :group_leader) do
      {:group_leader, gl} -> gl
      :undefined -> nil
    end
  end

  defp application_master?(pid) do
    match?({:initial_call, {:application_master, _, _}}, :erlang.process_info(pid, :initial_call)) or
      match?({:application_master, _, _}, proc_lib_initial(pid))
  end

  defp proc_lib_initial(pid) do
    if dict_key?() do
      case :erlang.process_info(pid, {:dictionary, :"$initial_call"}) do
        {_, v} -> v
        :undefined -> nil
      end
    else
      case :erlang.process_info(pid, :dictionary) do
        {:dictionary, d} -> dict_get(d, :"$initial_call")
        :undefined -> nil
      end
    end
  end

  defp restart(app, params, opts) do
    sup = params |> Map.get("supervisor") |> local_pid!()
    child_id = Map.get(params, "child_id")
    is_binary(child_id) || bad(400, "child_id must be a string: the child's id as the tree shows it")

    app in [:kernel, :stdlib] &&
      bad(409, "refused: #{app}'s children are the VM's own processes (code server, file server, user); restarting them can stop the VM")

    application_of(sup) == Atom.to_string(app) ||
      bad(400, "#{pid_text(sup)} is not in #{app}'s tree (it belongs to #{application_of(sup) || "no application"})")

    refuse_vital!(sup)

    summary = summary(sup, dict_key?()) || bad(404, "no process #{pid_text(sup)} (not alive)")
    summary["supervisor?"] || bad(400, "#{pid_text(sup)} is not a supervisor (initial call #{summary["initial_call"] || "unknown"})")

    children =
      case which_children(sup) do
        {:ok, list} -> list
        {:error, reason} -> bad(504, reason)
      end

    case Enum.find(children, fn {id, _, _, _} -> inspect(id) == child_id end) do
      nil ->
        bad(404, "#{pid_text(sup)} has no child with id #{clip(child_id)}")

      {:undefined, _, _, _} ->
        bad(409, "#{pid_text(sup)} is a DynamicSupervisor: its children have no ids and are not restarted by id; kill the process instead")

      {id, old, _, _} ->
        if is_pid(old), do: refuse_vital!(old)

        # terminate_child deletes a temporary child's spec, so restart_child
        # would find nothing and the child would be gone for good
        case sup_call(sup, {:get_childspec, id}, "get_childspec") do
          {:ok, spec} ->
            if restart_type(spec) == :temporary,
              do: bad(409, "refused: #{clip(child_id)} is a temporary child; terminating it removes it from #{pid_text(sup)} and it cannot be restarted")

          {:error, status, reason} ->
            bad(status, reason)
        end

        logged(opts, "restart #{child_id} under #{pid_text(sup)}#{label(sup)} in #{app}")

        with :ok <- sup_call(sup, {:terminate_child, id}, "terminate_child"),
             {:ok, new} <- restarted(sup_call(sup, {:restart_child, id}, "restart_child")) do
          {200,
           %{
             "ok" => true,
             "action" => "restart",
             "supervisor" => pid_text(sup),
             "child_id" => child_id,
             "old_pid" => if(is_pid(old), do: pid_text(old)),
             "new_pid" => if(is_pid(new), do: pid_text(new))
           }}
        else
          {:error, status, reason} -> {status, %{"error" => reason}}
        end
    end
  end

  defp restart_type(%{} = spec), do: Map.get(spec, :restart, :permanent)
  defp restart_type({_id, _start, restart, _shutdown, _type, _mods}), do: restart
  defp restart_type(_), do: :unknown

  defp restarted({:ok, pid}), do: {:ok, pid}
  defp restarted({:ok, pid, _info}), do: {:ok, pid}
  defp restarted({:error, _, _} = e), do: e

  # terminate_child waits for the child's shutdown (5 s for a worker by
  # default); 4.5 s here so the answer arrives inside the observer's 5 s.
  defp sup_call(sup, msg, what) do
    case GenServer.call(sup, msg, 4_500) do
      :ok -> :ok
      {:ok, _} = ok -> ok
      {:ok, _, _} = ok -> ok
      {:error, reason} -> {:error, 500, "#{what} failed: #{clip(inspect(reason, limit: 5))}"}
    end
  catch
    :exit, {:timeout, _} -> {:error, 504, "#{what} did not answer in 4500 ms"}
    :exit, reason -> {:error, 500, "#{what} failed: #{clip(inspect(reason, limit: 5))}"}
  end

  defp logger_level(params, opts) do
    level = Map.get(params, "level")
    level in @levels || bad(400, "level must be one of #{Enum.join(@levels, ", ")}")
    before = :logger.get_primary_config().level
    logged(opts, "logger level #{before} -> #{level}")
    :ok = :logger.set_primary_config(:level, String.to_existing_atom(level))
    {200, %{"ok" => true, "action" => "logger_level", "before" => Atom.to_string(before), "level" => level}}
  end

  defp logged(opts, what) do
    if Keyword.get(opts, :log, true) do
      by = Keyword.get(opts, :by) || "nobody said (no x-factory-by)"
      Logger.warning("factory_report observer action: #{what} by #{by}", factory_report: :observer_action)
    end

    :ok
  end

  defp label(pid) do
    case registered(pid) do
      nil -> ""
      name -> " (#{name})"
    end
  end

  # ---- process summary -------------------------------------------------------

  # `$initial_call` read alone where the VM can (OTP 26.2+), so a process
  # dictionary full of large values is never copied here.
  defp dict_key? do
    _ = :erlang.process_info(self(), {:dictionary, :"$initial_call"})
    true
  rescue
    ArgumentError -> false
  end

  @doc false
  def summary(pid, dict?) do
    keys = if dict?, do: [{:dictionary, :"$initial_call"} | @summary_keys], else: [:dictionary | @summary_keys]

    case :erlang.process_info(pid, keys) do
      :undefined ->
        nil

      [{_, dict_part} | rest] ->
        info = Map.new(rest)

        proc_lib =
          if dict?,
            do: if(dict_part == :undefined, do: nil, else: dict_part),
            else: dict_get(dict_part, :"$initial_call")

        %{
          "pid" => pid_text(pid),
          "registered_name" => name_text(info[:registered_name]),
          "initial_call" => initial_call({:initial_call, info[:initial_call]}, proc_lib),
          "current_function" => mfa_text(info[:current_function]),
          "status" => Atom.to_string(info[:status]),
          "message_queue_len" => info[:message_queue_len],
          "memory" => info[:memory],
          "reductions" => info[:reductions],
          "links" => length(info[:links]),
          "supervisor?" => match?({:supervisor, _, _}, proc_lib)
        }
    end
  end

  defp dict_get(dict, key) when is_list(dict) do
    case List.keyfind(dict, key, 0) do
      {_, v} -> v
      nil -> nil
    end
  end

  defp dict_get(_, _), do: nil

  # proc_lib's `$initial_call` names the module a GenServer or supervisor
  # was started with; the VM's own initial call is proc_lib:init_p/5 for
  # every one of them, so it is used only when proc_lib did not set one.
  defp initial_call(_, {m, f, a}) when is_atom(m) and is_atom(f) and is_integer(a), do: mfa_text({m, f, a})
  defp initial_call({:initial_call, {m, f, a}}, _), do: mfa_text({m, f, a})
  defp initial_call(_, _), do: nil

  # proc_lib records a supervisor as {:supervisor, CallbackModule, 1}: the
  # "function" is then a module, written as Elixir writes it.
  defp mfa_text({m, f, a}) when is_atom(m) and is_atom(f) and is_integer(a),
    do: clip("#{inspect(m)}.#{fun_text(f)}/#{a}")

  defp mfa_text({m, f, a}) when is_atom(m) and is_atom(f) and is_list(a),
    do: clip("#{inspect(m)}.#{fun_text(f)}/#{length(a)}")

  defp mfa_text(_), do: nil

  defp fun_text(f) do
    text = Atom.to_string(f)
    if String.starts_with?(text, "Elixir."), do: inspect(f), else: text
  end

  defp name_text(name) when is_atom(name) and name not in [nil, []], do: clip(inspect(name))
  defp name_text(_), do: nil

  defp ref_obj(p) when is_pid(p), do: pid_obj(p)
  defp ref_obj(p) when is_port(p), do: %{"port" => inspect(p)}
  defp ref_obj(other), do: %{"other" => clip(inspect(other, limit: 3))}

  defp pid_obj(p) do
    if node(p) == node(),
      do: %{"pid" => pid_text(p)},
      else: %{"pid" => pid_text(p), "node" => to_string(node(p))}
  end

  defp monitor_obj({:process, p}) when is_pid(p), do: Map.put(pid_obj(p), "type", "process")
  defp monitor_obj({:process, {name, n}}), do: %{"type" => "process", "registered_name" => clip(inspect(name)), "node" => to_string(n)}
  defp monitor_obj({:port, p}) when is_port(p), do: %{"type" => "port", "port" => inspect(p)}
  defp monitor_obj({:port, {name, n}}), do: %{"type" => "port", "registered_name" => clip(inspect(name)), "node" => to_string(n)}
  defp monitor_obj(other), do: %{"type" => "other", "other" => clip(inspect(other, limit: 3))}

  # ---- input and output ------------------------------------------------------

  @doc """
  `"0.123.0"` for a pid (its text without the brackets), `nil` for
  anything else.
  """
  def pid_text(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> List.to_string() |> String.trim_leading("<") |> String.trim_trailing(">")
  end

  def pid_text(_), do: nil

  @doc false
  # "0.123.0" -> a pid of this node. Anything else, a pid of another node
  # included, is a 400.
  def local_pid!(text) when is_binary(text) do
    case Regex.run(~r/\A(\d{1,6})\.(\d{1,10})\.(\d{1,10})\z/, text) do
      [_, "0", _, _] ->
        try do
          :erlang.list_to_pid(~c"<" ++ String.to_charlist(text) ++ ~c">")
        rescue
          ArgumentError -> bad(400, "not a valid pid: #{inspect(clip(text))}")
        end

      [_, _, _, _] ->
        bad(400, "pid #{text} is not on this node (#{node()}): ask that node's own observer")

      nil ->
        bad(400, "not a pid: #{inspect(clip(text))} (expected the form 0.123.0)")
    end
  end

  def local_pid!(other), do: bad(400, "not a pid: #{clip(inspect(other, limit: 3))} (expected a string like \"0.123.0\")")

  defp int_param!(params, key, default, min, max) do
    case Map.get(params, key) do
      nil ->
        default

      n when is_integer(n) and n >= min and n <= max ->
        n

      text when is_binary(text) ->
        case Integer.parse(text) do
          {n, ""} when n >= min and n <= max -> n
          _ -> bad(400, "#{key} must be an integer from #{min} to #{max}")
        end

      _ ->
        bad(400, "#{key} must be an integer from #{min} to #{max}")
    end
  end

  defp clip(s) when is_binary(s), do: binary_cut(s, @max_string)

  # At most `max` bytes, cut on a character boundary, always valid UTF-8.
  defp binary_cut(s, max) do
    s = if String.valid?(s), do: s, else: s |> String.chunk(:valid) |> Enum.filter(&String.valid?/1) |> Enum.join()
    if byte_size(s) <= max, do: s, else: s |> binary_part(0, max) |> trim_partial()
  end

  defp trim_partial(s) do
    if String.valid?(s), do: s, else: trim_partial(binary_part(s, 0, byte_size(s) - 1))
  end

  defp bad(status, message), do: throw({:bad, status, message})
end
