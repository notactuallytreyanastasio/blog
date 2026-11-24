# factory_report

A Phoenix app's own account of its inside, for the obs_factor observer: the
BEAM's numbers, every connected LiveView and joined channel, counters for
what happens (requests, LiveView events, queries, outbound calls, log lines,
and whatever the app reports itself) broken down by the page that caused
it, and the app's most recent warnings and errors. It serves one JSON
document, the format in `docs/contract.md`, "Reports: what is inside a
building" and "Reports, second round".

On the same port, on demand: an `:observer` for the VM, as JSON, with
actions (kill, exit, gc, restart a child, the Logger level) that are off
until you give them a token. See "Observer".

**The report contains log messages.** The last 50 log events at `warning`
and above are in it, in the app's own words. See "What is not reported, and
what is" before you expose it; `log_events: false` leaves them out.

Works with Phoenix 1.7 and 1.8, LiveView 1.0 to 1.2, and with neither: an
app without LiveView, Ecto or Finch reports its runtime and its routes.

## Install: two steps

1. The dependency, in `mix.exs`:

   ```elixir
   {:factory_report, path: "../obs_factor/packages/factory_report"}
   ```

2. One child in the supervision tree (`lib/my_app/application.ex`), anywhere
   in the list:

   ```elixir
   children = [
     # ...
     {FactoryReport, app: :my_app, port: 9568}
   ]
   ```

That is all. `GET http://<container>:9568/report` now answers the report.
Point the observer's topology at it: `report: "http://my_app:9568/report"`.

### An app that is built on a server from its own source tree

A path outside the app does not exist there, and neither does a git remote.
Vendor the library into the app instead:

```sh
packages/factory_report/install.sh ../my_app
```

It copies `mix.exs`, `lib/` and this README to
`../my_app/vendor/factory_report` (with `rsync --delete`: run it again to
update the copy), changes nothing else, and prints what to add by hand:

```elixir
# mix.exs
{:factory_report, path: "vendor/factory_report"}
```

```dockerfile
COPY mix.exs mix.lock ./
COPY vendor vendor                    # before deps.get: Mix reads vendor/factory_report/mix.exs
RUN mix deps.get --only $MIX_ENV
```

and the child from step 2. Run `mix deps.get` once locally so `mix.lock`
has the library's own dependencies (telemetry, plug, bandit, jason).

With the options most apps want:

```elixir
{FactoryReport,
 app: :my_app,
 port: 9568,
 repos: [MyApp.Repo],
 token: System.get_env("FACTORY_REPORT_TOKEN")}
```

## Options

| Option | Default | Meaning |
|---|---|---|
| `:app` | required | The host application, an atom. The report's `"app"`, and the application whose version is reported. |
| `:port` | `9568` | The listener's port. `false`: no listener (mount `FactoryReport.Plug` yourself). `0`: any free port (`FactoryReport.port/0` says which). |
| `:ip` | `{0, 0, 0, 0}` | The address the listener binds. All IPv4 interfaces, because the observer comes over the container network. |
| `:token` | `nil` | A non-empty string makes `authorization: Bearer <token>` mandatory (401 otherwise). `nil` and `""` mean no token, so `System.get_env/1` of an unset or empty variable is safe to pass. |
| `:repos` | `[]` | Ecto repos whose queries are counted (`db.query`). |
| `:max_stream_names` | `400` | Rows one stream kind may hold (totals and breakdowns together). Later names count under `"(other)"`. |
| `:log_events` | `true` | `false` keeps log messages out of the report (`"events": []`). Log events are still counted per level. |
| `:log_level` | `:warning` | The lowest level whose messages go into `"events"`. |
| `:observer` | on, reads need `:token` | `false` turns `/observer/...` off (404). Left out, it is on but its reads answer 403 `observer reads need a token ...` while there is no `:token`: the port binds every interface, and a `procs` read walks every process twice. `true` serves reads without a token; say it only where nothing but the observer reaches the port. See "Observer". |
| `:inspect_state` | `false` | `true` lets `GET /observer/proc/:pid?state=true` read a process's state (`:sys.get_state/2`, 500 ms). |
| `:actions_token` | `FACTORY_REPORT_ACTIONS_TOKEN` | A non-empty string turns the observer's actions on, behind `authorization: Bearer <actions_token>`. Unset or empty: actions answer 403. |

One reporter per VM (its tables are named).

## API

- `{FactoryReport, opts}` / `FactoryReport.start_link(opts)`: the child above.
- `FactoryReport.report()`: the report as a map with string keys. Raises
  `ArgumentError` when the reporter is not running.
- `FactoryReport.event(name, opts \\ [])`: one occurrence in a `custom`
  stream. See below.
- `FactoryReport.port()`: the listener's bound port, or `nil`.
- `FactoryReport.Plug`: the report as a plug, for your own router.
- `FactoryReport.JSONFormatter`: a `:logger` formatter, one JSON object per
  line on stdout. Separate from the report; see "Structured stdout".

### In your own router instead of a port

```elixir
# application.ex
{FactoryReport, app: :my_app, port: false, token: System.get_env("FACTORY_REPORT_TOKEN")}

# router.ex, outside every pipeline
forward "/internal/factory-report", FactoryReport.Plug
```

The plug answers `GET` on the mount point itself and on `<mount>/report`,
and 404 for anything else. It takes `token:` to override the reporter's.
Served this way the report is on the app's public port: set a token, or make
sure the proxy does not route that path.

## Custom events

```elixir
FactoryReport.event("gif.rendered")

started = System.monotonic_time()
result = render_gif(frames)
FactoryReport.event("gif.rendered",
  duration: System.monotonic_time() - started,
  error: match?({:error, _}, result)
)

FactoryReport.event("mail.sent", duration_us: 15_300)
```

- `duration:` is in native time units (the difference of two
  `System.monotonic_time/0`); `duration_us:` is microseconds. Without
  either the occurrence adds 0 to the stream's `duration_us`.
- `error: true` counts it in `errors` as well as in `count`.
- It returns `:ok` and never raises, also when the reporter is not running.
- A name is a row: use a small fixed set. Never put an id, a user or a URL
  in a name.

## What is reported

**`runtime`** (`kind: "beam"`)

- `versions`: `otp`, `elixir`, and `phoenix`, `phoenix_live_view`, `app`
  when those applications are loaded.
- `uptime_s`: the VM's, in seconds.
- `gauges`: `memory.total`, `memory.processes`, `memory.binary`,
  `memory.ets`, `memory.atom`, `memory.code` (bytes); `process.count`,
  `process.limit`, `port.count`, `port.limit`, `atom.count`, `atom.limit`,
  `ets.count`, `run_queue` (all run queues together), `schedulers.online`;
  and `scheduler.utilization`, 0..1: the share of time the normal schedulers
  were busy between the previous report and this one. It is absent from the
  first report (one sample is not an interval). Whoever reads the report sets
  the interval: a second reader (you, with curl) shortens the observer's.
- `counters`: `reductions`, `gc.count`, `gc.words_reclaimed`,
  `io.in_bytes`, `io.out_bytes`, `context_switches`, and
  `report.handler_errors` (how often one of this library's telemetry
  handlers had to swallow an error; anything but 0 is a bug here).

**`units`**

- `kind: "liveview"`: every *connected* LiveView process alive now (the
  disconnected first render is a request, not a unit), grouped by view
  module. `route` is the router's pattern (`/post/:slug`). Each member has
  `label` (its path, no query string, kept current across patches), `since`,
  `gauges.memory` and `gauges.message_queue`, and `counters.events` (the
  `handle_event` calls it has handled, its components' included). A nested
  LiveView is a unit of its own view, labelled with its root's path.
- `kind: "channel"`: every joined `Phoenix.Channel` process, grouped by
  topic prefix: `room:42` and `room:43` are both in the unit `room:*`. The
  member's label is the prefix too, never the full topic (the rest of a
  topic is very often a user or a room id). `route` is `null`.

**`liveviews`: sessions alive now, per view**

```json
{"total": 5, "views": [{"view": "MyAppWeb.PostLive", "alive": 3}, {"view": "MyAppWeb.NavLive", "alive": 2}],
 "views_cut": 0, "processes": 812, "walked": 812, "walk_limit": 20000, "took_ms": 1.25}
```

Counted by walking the VM's processes on each report, not from telemetry,
so a LiveView that mounted before the reporter started is counted too (it
is not a unit). A LiveView process is one whose `$initial_call` is
`{View, :mount, 3}` where `View` exports `__live__/0`; that is how
LiveView 1.0 to 1.2 mark it (checked by running 1.0.19 and 1.2.13). A
nested LiveView counts under its own module. The walk reads that one
dictionary key per process and stops after 20,000 processes: past that,
`walked` is less than `processes` and `total` is a lower bound. `views` is
the 100 most populous. Before OTP 26.2 a single key cannot be read without
copying the whole dictionary, so there the section has `"total": null`,
`"walked": 0` and `"unavailable"` saying why.

**`tables`: repo time per table** (cumulative, the most time first)

```json
{"repo": "MyApp.Repo", "table": "posts", "count": 99120, "errors": 0, "duration_us": 55443322}
```

The same queries as the `db.query` stream, split by Ecto's `source`: the
FROM table (a join counts under its first table). `"table": null` is SQL
with no source: `Repo.query/3`, and the `begin` and `commit` of every
transaction. So a repo's tables add up to its `db.query` total. Not
attributed to a page. The observer turns these into rate, average and
total time over its window and shows the 15 with the most time.

**`streams`** (`count`, `errors`, `duration_us`, cumulative)

| kind | name | from | an error is |
|---|---|---|---|
| `http.route` | `GET /post/:slug` | `[:phoenix, :router_dispatch, :stop \| :exception]` | a raise, or a status of 500 and up |
| `liveview.mount` | `MyAppWeb.PostLive` | `[:phoenix, :live_view, :mount, :stop \| :exception]` | a raise |
| `liveview.params` | `MyAppWeb.PostLive` | `[:phoenix, :live_view, :handle_params, :stop \| :exception]` | a raise |
| `liveview.event` | `MyAppWeb.PostLive#like` | `[:phoenix, :live_view \| :live_component, :handle_event, :stop \| :exception]` | a raise |
| `channel.join` | `MyAppWeb.RoomChannel` | `[:phoenix, :channel_joined]` | a join that was refused |
| `channel.event` | `MyAppWeb.RoomChannel#new_msg` | `[:phoenix, :channel_handled_in]` | never: Phoenix emits nothing when `handle_in` raises |
| `db.query` | `MyApp.Repo` | the repo's `telemetry_prefix ++ [:query]` (`total_time`) | a query that returned `{:error, _}` |
| `outbound.http` | `api.example.com` | `[:finch, :request, :stop \| :exception]` (so Req too) | a raise, `{:error, _}`, or a status of 500 and up |
| `custom` | what you chose | `FactoryReport.event/2` | `error: true` |
| `log` | the level: `error`, `warning`, `info`, ... | a `:logger` handler | never (`errors` and `duration_us` are 0) |

`log` counts every log event that passes the app's own Logger level
(`config :logger, level:`); what the app filters out is never seen.

`liveview.mount` counts both mounts of a page view: the disconnected render
and the connected one. `[:phoenix, :live_view, :render, :stop]` is attached
too, only to notice a connected LiveView that defines neither `mount/3` nor
`handle_params/3` (LiveView then emits neither event); it feeds no stream.

**`by`: who did it**

A `db.query`, `outbound.http`, `custom` or `log` row can come twice: once
plain (the total, exactly as before), and once more per page that caused
part of it, with `"by": {"kind": "liveview", "name": "MyAppWeb.PostLive"}`
or `"by": {"kind": "http.route", "name": "GET /cases"}`. Rows with `by` are
a breakdown of the row without; summing only rows without `by` counts
nothing twice. A total row has no `by` key.

What decides the page is the process the event happens in:

- a process serving a routed request, from `[:phoenix, :router_dispatch,
  :start]` to `:stop` (after a raise the mark stays, so what the web server
  logs about the crash is the route's);
- a connected LiveView process, for its whole life (the disconnected first
  render happens in the request's process, so it is the route's);
- a `Task` started by either, up to two processes away (`$callers`, which
  `Task` sets; this is also how Ecto's parallel preloads are attributed).

Everything else (a GenServer, a scheduled job, a process started with
`spawn`, a task three or more away, a channel) is in the total only.

**`events`: what was logged**

The 50 most recent log events at `:log_level` (default `warning`) and
above, newest first:

```json
{"at": "2026-11-19T08:40:02Z", "level": "error", "name": "Blog.GitHub.WorkLogPoller",
 "message": "poll failed: timeout", "by": null}
```

`name` is the module that logged (`"(unknown)"` when the event does not say),
`message` is the formatted message cut at 300 characters, `by` is as above
or `null`. Crash reports from OTP (a GenServer that died) arrive already
translated by Elixir's Logger and are listed like any other error.

**Bounds** (`truncated` says what was cut)

- 100 units, the most populous first; `truncated.units` is how many more.
- 20 members per unit, the largest by memory first; `count` and the unit's
  gauges still cover all of them; `truncated.members` is how many members
  of the listed units are not listed.
- 300 streams: totals first (the busiest by `count`), then breakdown rows
  (the busiest by `count`), so a cut takes breakdowns before any total;
  `truncated.streams` is how many rows were left out.
- 100 tables, the most `duration_us` first; `truncated.tables` is how many
  more. The library keeps at most 200 repo/table pairs; a pair after that
  is counted under `"table": "(other)"` (the schemas are a fixed set, so
  this is only a guard).
- 100 LiveView modules in `liveviews.views` (`views_cut` is the rest); a
  walk of at most 20,000 processes.
- 50 events, each message cut at 300 characters.
- Names and labels are cut at 120 characters and are always valid UTF-8.
- A kind holds at most `:max_stream_names` names. What arrives after that
  is counted in that kind's `"(other)"` row (so nothing is lost from the
  totals, only the name). LiveView and channel event names are the client's
  to choose, so one that has only ever *failed* never gets a row: it goes to
  `"(other)"` too. Made-up event names cannot fill the table. Breakdown
  rows share the kind's room but never take its last quarter; one that
  finds no room is not kept (its occurrence is in the total regardless).

## What is not reported, and what is

The library itself adds no request parameters, no assigns, no session data,
no socket ids, no user identifiers, no query strings, no SQL, no request
paths (only route patterns), no outbound URLs (only hosts), no full channel
topics (only prefixes), and no log metadata.

Two places carry the app's own concrete values:

- **Log messages.** `"events"` holds the text of the app's last 50 log
  events at `warning` and above, as the app wrote them. Whatever the app
  puts in a warning or an error is in the report: an email address in
  `"could not deliver to ..."`, a changeset, a URL with a token, the message
  of an exception. The library does not scrub them and cannot know what is
  private. If that is not acceptable for an app, start it with
  `log_events: false` (the per-level counts stay; no message leaves the
  app), or raise the floor with `log_level: :error`.
- **LiveView paths.** A member's `label` is its URL path, which contains
  path parameters (`/post/the-factory-must-grow`). A token in a path would
  be shown.

So treat the report as you treat the app's logs: for the observer only,
behind the factory's password, never on a public route.

Also not reported: processes that are neither LiveViews nor channels
(GenServers, tasks), LiveComponents as units (their events are counted),
`handle_info`/`handle_async` work, and the path of a LiveView that has
neither `mount/3` nor `handle_params/3` (its label is the view's name and
its `route` is `null`).

## Cost: what runs in whose process

**In your processes (requests, LiveViews, channels): the telemetry
handlers.** Each is a pattern match plus one `:ets.update_counter/3` (two
for LiveView and channel events: the stream and the member's counter).
Measured on an M-series laptop, including `:telemetry.execute` itself
(about 0.28 µs with no handler at all):

| handler | per call |
|---|---|
| `http.route` | 0.41 µs |
| `liveview.event` | 0.70 µs |
| LiveView render (already tracked) | 0.12 µs |
| LiveView mount / handle_params (parses the URI, asks the router for the pattern) | about 4 µs |
| `FactoryReport.event/2` | 0.15 µs, attributed 0.22 µs |
| `outbound.http` | 0.21 µs; 0.29 µs when attributed (the total and the `by` row) |
| `db.query` | the same, plus about 0.08 µs for its table's row (0.18 µs without it, 0.26 µs with it, measured side by side) |
| router dispatch `:start` (sets the page mark) | 0.32 µs |
| the same handlers in a `Task` whose caller is not a page | 0.80 µs (the caller is looked up each time; a found page is remembered) |
| the log handler, a line below the floor (counted) | 0.21 µs |
| the log handler, a line at or above the floor (counted, formatted, kept) | 0.78 µs |

They never raise (everything is caught, and counted in
`report.handler_errors`), never block, and send exactly one message in the
life of a LiveView or channel process: "watch me", to the tracker, when it
is first seen. The name tables are bounded as described above. Knowing the
page is one read of the process dictionary: a request process is marked at
router dispatch, a LiveView process at mount.

The log handler is a `:logger` handler, so it too runs in the process that
logs, under the same rules, and it never logs itself. It adds about 0.07 µs
to a `Logger.info` and 0.35 µs to a `Logger.warning` that already cost
about 1 µs with no other handler. A message is formatted with a bound: at
most 300 characters are ever produced, however large the logged term.

**In the library's own processes.** A supervisor (it owns five ETS
tables), a tracker (one monitor per tracked process; it deletes the row on
`DOWN`; it also holds the telemetry attachments, the log handler and the
`scheduler_wall_time` flag, which costs the VM a timestamp per scheduler
state change), and the listener: Bandit with 2 acceptors, at most 64
connections.

**In the caller of `report/0`** (the listener's request process): about
0.2 ms with nothing tracked, mostly `:erlang.memory/0`; 2.7 ms median
(p95 3.3 ms, 157k reductions) with 1,000 tracked processes and 300
streams, 2.9 ms with the JSON encoding (96 kB). It grows linearly with
tracked processes: `Process.info/2` is asked for exactly those pids.
Those numbers are from before `liveviews`, which does walk the process
table: one `process_info(pid, {:dictionary, :"$initial_call"})` per
process, 1.4 to 1.9 µs each (27 to 37 ms for 20,000 processes, measured on
an M-series laptop, OTP 28), capped at 20,000 processes, on every read; its
`took_ms` says what it cost. Memory is one ETS row per tracked process, one
per stream name and one per repo/table pair.

## Observer

`:observer`, as JSON, on the same port and the same plug: costs nothing
until it is asked (no process, table or handler of its own). The full
request and response shapes are in obs_factor's `docs/contract.md`,
"Observer"; in short (`:pid` is written `0.123.0`, every response has
`took_ms` and `node`):

| Request | Answer |
|---|---|
| `GET /observer` | which reads and actions exist, `inspect_state` |
| `GET /observer/system` | versions, system_info, schedulers, limits (process/port/atom/ets), `:erlang.memory`, statistics, allocator sizes, distribution (connected nodes), the primary Logger level |
| `GET /observer/apps` | started applications, each with its top supervisor's pid |
| `GET /observer/tree/:app?depth=8` | the supervision tree, each node a process summary |
| `GET /observer/procs?sort=reductions\|memory\|message_queue_len&limit=50&interval_ms=0` | the top N processes; `interval_ms` > 0 takes two samples and ranks by reductions in between |
| `GET /observer/proc/:pid?state=true` | one process: links, monitors, stack, heap, GC, dictionary keys, supervisor path, state if allowed |
| `GET /observer/ets` | tables by memory |
| `GET /observer/ports` | ports by traffic |
| `POST /observer/proc/:pid/kill` | `exit(pid, :kill)` |
| `POST /observer/proc/:pid/exit` `{"reason": "shutdown"\|"normal"\|"kill"}` | `exit(pid, reason)` |
| `POST /observer/proc/:pid/gc` | `:erlang.garbage_collect(pid)` |
| `POST /observer/tree/:app/restart` `{"supervisor": "0.1.0", "child_id": "MyApp.Worker"}` | `terminate_child` + `restart_child`, the child matched by `inspect(id)` |
| `POST /observer/logger/level` `{"level": "debug"}` | the primary Logger level |

Actions are off (403) unless `actions_token:` or
`FACTORY_REPORT_ACTIONS_TOKEN` is set; then they need
`authorization: Bearer <token>` (compared in constant time). Each action is
logged by the app at `warning` with what was done and the `x-factory-by`
request header (who asked). Killing or exiting `init` or a `kernel` process
is refused (409): it would stop the VM.

Bounds: 25 children per supervisor (the heaviest by memory; the rest as one
`{"group": true, "count", "memory", "message_queue_len_max"}`), depth 8 (at
most 12), 1,500 nodes and 2 s per tree, with a `cut` object counting what
each limit left out; at most 200 processes from a walk of at most 100,000;
`interval_ms` at most 2,000; 100 links/monitors/dictionary keys, 30 stack
frames, 500 tables, 500 ports, 200 characters per string. `which_children`
is sent only to processes that proc_lib started as supervisors, with a 1 s
timeout. A pid of another node is refused (400): ask that node's observer.

`FactoryReport.Observer.dispatch(method, path, params, opts)` is the same
thing without HTTP, for an app that serves its own VM in-process.

## Structured stdout

Separate from the report, and optional: one JSON object per log line, for
`docker logs` and whatever reads it later. In `config/config.exs` (Elixir
1.15 and later; checked against Logger's source, and run on 1.18 and 1.19):

```elixir
config :logger, :default_handler,
  formatter: {FactoryReport.JSONFormatter, %{}}
```

That replaces the default handler's formatter, so `config :logger,
:default_formatter` (and the old `config :logger, :console, format: ...`)
no longer shapes the output. At run time the same is
`:logger.update_handler_config(:default, :formatter, {FactoryReport.JSONFormatter, %{}})`.

```json
{"time":"2026-11-19T08:24:39.522Z","level":"warning","msg":"room 42: 5 knocks and nobody answers","app":"liveapp","module":"LiveappWeb.RoomLive","request_id":null,"page":"LiveappWeb.RoomLive"}
```

Exactly these seven keys, `null` where there is nothing to say: `time` (UTC),
`level`, `msg` (the whole message, not cut), `app` (the app `FactoryReport`
was started with), `module` (the one that logged), `request_id`
(`Plug.RequestId`'s metadata), `page` (the `by` name: a route or a
LiveView). Options, in the map: `metadata: [:trace_id, ...]` writes those
metadata keys too, each under its own name; `app: :name` sets `app`. It
never raises (an event it cannot encode becomes a minimal line saying so)
and every line ends with a newline. Unlike the report, these lines carry
every level the app logs and the full message.

## Security

- The report is for the observer, on the internal network. Give the
  container the port (`9568`), do not publish it on the host, and **do not
  route it through the public proxy**.
- `token:` adds a shared secret on top (`FACTORY_REPORT_TOKEN` in the app,
  `REPORT_TOKEN` in the observer). It is compared in constant time. It is
  not a substitute for the above: the listener speaks plain HTTP, so the
  token crosses the network in the clear.
- The listener answers `GET /report` and the observer's `/observer/...`
  (below); everything else is 404. Observer reads take the same token as
  the report. Observer actions (POST) take only the actions token, are off
  without one, and read at most 8 kB of body.
- The observer shows process, table, port and application names, initial
  calls and stack traces: names the app chose, which can say a lot about
  it. It never shows message contents, process dictionary values or (unless
  `inspect_state: true`) process state. With `inspect_state: true` a state
  is shown as `inspect/2` prints it, cut at 4096 bytes: whatever a
  GenServer holds (a token, a user) is then visible to whoever can read
  the observer.

## Tests

```sh
mix test                                              # Phoenix 1.8, LiveView 1.2
FACTORY_REPORT_COMPAT=1 mix do deps.get + test        # Phoenix 1.7, LiveView 1.0
```

The second run has its own lockfile (`mix.compat.lock`) and its own
`deps_compat/` and `_build_compat/`, so the two never overwrite each other.
The Ecto and Finch streams are tested with events of the shape those
libraries emit, not against the libraries themselves. Where those events
are executed was read in their sources: Ecto's query event in the process
that runs the query (`ecto_sql` `lib/ecto/adapters/sql.ex`, the `log/5`
that DBConnection calls back in the caller), Finch's request span in the
process that calls `Finch.request/3` or `Finch.stream/5`
(`lib/finch.ex`, `request_span`). `Finch.async_request/3` emits no request
event, so those calls are not counted.
