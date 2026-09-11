defmodule BlogWeb.DirectoryLive do
  @moduledoc """
  A directory of everything running on the box: domains, containers, routes,
  and the museum catalog. Rendered as a stack of System 7 windows on the
  desktop, matching the Finder on the home page.

  Infrastructure facts (containers, domains, routes) live in module attributes
  here. The museum list is read from the database so it never drifts from
  /admin/museum.
  """
  use BlogWeb, :live_view

  alias Blog.Museum.Icons
  alias Blog.Museum.Projects

  @checked_on "31 August 2026"

  # Unique paths in the router, excluding dev-only mounts. 69 pages + 24 API endpoints.
  @router_paths 93
  @api_paths 24

  @containers [
    {"app", "The blog — the main Phoenix application", "4000", "Image build"},
    {"blinks", "blinks_backend, the standalone link-stack app", "4000", "Image build"},
    {"nathan", "Framecut — video slicing and GIF cutting", "4001", "Image build"},
    {"soldat", "Arena watcher daemon + online 1v1 game server", "8901, 8902", "Bind mount"},
    {"slides-relay", "Phone-remote WebSocket router for the deck editor", "8787", "Bind mount"},
    {"lumines", "LUMINES rooms server — matchmaking + board relay", "8903", "Bind mount"},
    {"caddy", "Reverse proxy and static file server", "80, 443", "Config file"},
    {"db", "Postgres 17, three databases", "internal", "Image"}
  ]

  # {host, status, served_by, blurb}
  @domains [
    {"bobbby.online", :live, "Phoenix app",
     "The main site. Blog, toys, games, maps, data explorers — everything in the next window."},
    {"bobbby.online/arena/", :live, "soldat",
     "The Claude Arena. /arena/play/* is a static replay client; the rest proxies to the live watcher, and /arena/ws is the 1v1 game server."},
    {"gifmaker.bobbby.online", :live, "Phoenix nathan",
     "Framecut. Slices video into 1fps frames, cuts GIFs from timeline ranges, caption search, voting feed."},
    {"lumines.bobbby.online", :live, "Static + lumines",
     "LUMINES HD. Two players share one board over /ws, with music synthesized from play. Also /league and /deck/."},
    {"slides.bobbby.online", :live, "Static + slides-relay",
     "Slides.net, a reveal.js deck editor. Markdown per slide, 2D decks, phone remote over a WebSocket relay."},
    {"deciduous.dev", :live, "Static",
     "Deciduous, the decision-graph tool. Docs, tutorial, demo graph."},
    {"phishjamexplorer.com", :live, "Static SPA",
     "D3 visualizations of Phish 3.0 jam data. Eight jamchart tabs plus PhanGraphs sabermetrics."},
    {"soldat.bobbby.online", :live, "Static", "The write-up page for the Soldat rewrite project."},
    {"downloader.bobbby.online", :live, "Static",
     "Framecut Grabber download and setup page. Ships inside nathan_for_us as site/."},
    {"blimp.bobbby.online", :live, "Static",
     "Blimp language docs and tutorial. Pulled fresh from GitHub on every deploy."},
    {"links.bobbby.online", :dark, "Phoenix blinks",
     "Caddy block and a running container behind it, but the name does not resolve."},
    {"bobbbys.link", :dark, "Phoenix blinks",
     "Host-routed landing page in blinks_backend. DNS points at a registrar parking IP, not this box."},
    {"donny.bobbby.online", :dark, "Static",
     "Caddy block with a mount from /opt/donny. No DNS, and no repo references it."}
  ]

  # {group, [{route, blurb}]}
  @routes [
    {"Writing",
     [
       {"/", "The Finder desktop. Icons come from the DB, with a live chatroom and presence."},
       {"/blog, /post/:slug",
        "Post index and reader. Drafts stream from the editor through an ETS cache over PubSub."},
       {"/trees", "327 years of tree law — a post that became its own application."},
       {"/knicks", "2026 Finals feature with vendored D3."},
       {"/nathan", "Nathan Fielder writing experiments."}
     ]},
    {"Blinks — the link stack",
     [
       {"/blinks", "Two hand-set columns, newspaper layout, live occupancy dots per room."},
       {"/blinks-reader", "Contact sheet. Thumbnails open a full-viewport lightbox you walk with arrows."},
       {"/blinks/surf", "One random unseen link at a time. Channels narrow to a tag; back retraces hops."},
       {"/blinks/walk",
        "Wiki-walk. Three nearest neighbors by shared tags and title similarity, plus a wildcard."},
       {"/blinks/tv", "Retunes every few seconds with static. Top tags are channels, space pauses."},
       {"/blinks/review", "Private triage queue. Upvoting promotes a bookmark to a blink."},
       {"/blinks.rss, /blinks/stumble", "Feed and random redirect."},
       {"/api/blinks*", "Reads open, writes token-gated. Create, search, tags, export, import, delete."},
       {"/api/push/devices", "APNs device registration for the Blinks iOS app."}
     ]},
    {"Camera browser",
     [
       {"/cameras",
        "Film cameras live on Craigslist across NYC, swept every 15 minutes. Kept until the post closes; scored, tagged, starred and hidden by hand."}
     ]},
    {"Phish",
     [
       {"/phish", "PhanGraphs. Batting averages, jamchart rates, duration timelines since 2009."},
       {"/phish_lab", "Anomaly detection — jammiest shows, bustouts, most variable songs."},
       {"/moon_phish", "Every show mapped against the lunar calendar."},
       {"/map", "Tag A Wook. A shared map where visitors drop pins for songs."}
     ]},
    {"Bluesky and atproto",
     [
       {"/sky", "Fill The Sky. 418+ communities across 546K seeded profiles."},
       {"/emoji-skeets", "Live emoji search across the firehose."},
       {"/reddit-links", "YouTube links posted to Bluesky, as they arrive."},
       {"/jetstream_comparison", "Jetstream and the raw relay running side by side."},
       {"/allowed-chats", "A shared chat where the permitted vocabulary is voted on."}
     ]},
    {"NYC data",
     [
       {"/mta-bus-map", "Live bus positions across three boroughs, refreshed every 30 seconds."},
       {"/mta-train", "The same, for trains."},
       {"/nyc_census_and_pluto",
        "Draw any polygon and get a population estimate from PLUTO lots plus Census data."}
     ]},
    {"Games",
     [
       {"/wordle, /wordle_god", "Wordle, plus the view from the solver's side."},
       {"/pong, /pong/god", "Pong against an AI paddle at 30fps, plus the omniscient view."},
       {"/blackjack", "Multiplayer blackjack over PubSub."},
       {"/2048", "2048 with a blitz timer."},
       {"/chess, /chess-lv", "Chess twice: one controller-rendered, one LiveView."}
     ]},
    {"Toys and art",
     [
       {"/art", "Temper Art. Deterministic generative art from a splitmix32 seed, with PNG export."},
       {"/cursor-tracker", "Shared canvas. Everyone sees everyone's cursor; clicks leave dots."},
       {"/mirror", "The page fetches and displays its own source from GitHub."},
       {"/stumble", "A Mac-windowed browser over a bag of links, with tag and language filters."},
       {"/gif-maker", "Concert GIF maker. Two-pass FFmpeg, overlay text, captcha, rate limiting."},
       {"/collage-maker", "Up to 36 images at 20MB each, arranged into a grid. Share by token."},
       {"/very_direct_message", "A thermal printer on my desk pulls the message down and prints it."},
       {"/typewriter, /chaos-typing", "Keypress-as-typewriter animation, and a typing experiment."},
       {"/lumon-celebration", "A Severance bit."}
     ]},
    {"Utilities and admin",
     [
       {"/smart-steps",
        "The largest feature here: social-skills scenarios across ten themes, with play, results, dashboard, connect, designer, and demo views. Sessions run as supervised GenServers."},
       {"/role-call", "TV writer discovery driven by shows you liked."},
       {"/work-log", "Live GitHub activity, polled into the database."},
       {"/bookmarks", "Per-visitor bookmarks with ownership checks on delete."},
       {"/hacker-news", "Top stories with timeouts and a fallback."},
       {"/markdown-editor", "A plain markdown editing surface."},
       {"/python-demo", "A Pythonx sandbox running inside the BEAM."},
       {"/directory", "This page. The inventory of everything above."},
       {"/admin/finder, /admin/museum", "Home-page icons and this project list. Password-gated."},
       {"/api/receipt_messages/*", "The printer asks for pending jobs and reports printed or failed."}
     ]}
  ]

  @loose_ends [
    {"Two routes return 500",
     "/cairn and /python are declared in the router, but CairnLive and PythonLive.Index do not exist in lib/. Both throw on every request. Write them or delete the two lines."},
    {"Three domains are dark",
     "links.bobbby.online and donny.bobbby.online have Caddy blocks and no DNS. bobbbys.link resolves to a registrar parking IP. The blinks container is running, healthy, and unreachable."},
    {"Blinks exists twice",
     "The link stack is implemented once in this app and again in blinks_backend, against two separate databases. The iOS extension writes to whichever host it is pointed at. Worth picking a canonical one."},
    {"Production runs ahead of git",
     "deploy.sh rsyncs the working tree rather than a git ref, so code can be live without ever having been committed. That is how /blinks/surf, /blinks/walk, and /blinks/tv shipped."}
  ]

  def mount(_params, _session, socket) do
    projects = Projects.all()

    # The /arena/* row is a path on bobbby.online, not a host of its own, so it
    # is listed but not counted as a domain.
    hosts = Enum.reject(@domains, fn {host, _, _, _} -> String.contains?(host, "/") end)
    live_count = Enum.count(hosts, fn {_, status, _, _} -> status == :live end)
    listed_routes = @routes |> Enum.flat_map(fn {_, rows} -> rows end) |> length()

    {:ok,
     socket
     |> assign(:page_title, "The bobbby.online Directory")
     |> assign(
       :page_description,
       "One VPS, 12 domains, 8 containers, 93 routes, and 32 projects — every domain, app, route, and project running on bobbby.online, with what is live and what quietly stopped working."
     )
     |> assign(:page_image, "https://www.bobbby.online/images/og-directory.png")
     |> assign(:projects, projects)
     |> assign(:containers, @containers)
     |> assign(:domains, @domains)
     |> assign(:routes, @routes)
     |> assign(:loose_ends, @loose_ends)
     |> assign(:checked_on, @checked_on)
     |> assign(:host_count, length(hosts))
     |> assign(:live_count, live_count)
     |> assign(:listed_routes, listed_routes)
     |> assign(:router_paths, @router_paths)
     |> assign(:api_paths, @api_paths)}
  end

  defp where(%{internal_path: path}) when is_binary(path), do: path
  defp where(%{external_url: url}) when is_binary(url), do: url

  defp where(%{github_repos: repos}) when is_list(repos) and repos != [] do
    case length(repos) do
      1 -> "GitHub"
      n -> "GitHub ×#{n}"
    end
  end

  defp where(_), do: "—"

  defp category_label("ml"), do: "ML"
  defp category_label(cat), do: String.capitalize(cat)

  defp status_label(:live), do: "Live"
  defp status_label(:dark), do: "No DNS"

  def render(assigns) do
    ~H"""
    <div class="dir">
      <div class="dir-menubar">
        <div class="dir-menu-left">
          <.link navigate={~p"/"} class="dir-apple">&#63743;</.link>
          <.link navigate={~p"/"} class="dir-menu-item">Finder</.link>
          <.link navigate={~p"/blog"} class="dir-menu-item">Blog</.link>
          <span class="dir-menu-item dir-menu-on">Directory</span>
        </div>
        <div class="dir-menu-right">Checked {@checked_on}</div>
      </div>

      <div class="dir-desktop">
        <div class="dir-stack">
          <%!-- Masthead --%>
          <div class="dir-win">
            <div class="dir-titlebar">
              <.link navigate={~p"/"} class="dir-close"></.link>
              <div class="dir-title">Directory</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-body">
              <h1 class="dir-h1">Everything running on one box</h1>
              <p class="dir-lede">
                One VPS, one <code>docker compose</code>
                project, and somewhere north of a hundred and forty things to click. This is what is
                actually running, what it does, and what has quietly stopped working. Status was checked
                against every configured host on {@checked_on}.
              </p>
              <div class="dir-stats">
                <div class="dir-stat"><b>1</b><span>VPS</span></div>
                <div class="dir-stat"><b>{@host_count}</b><span>Domains</span></div>
                <div class="dir-stat"><b>{@live_count}</b><span>Resolving</span></div>
                <div class="dir-stat"><b>{length(@containers)}</b><span>Containers</span></div>
                <div class="dir-stat"><b>3</b><span>Phoenix apps</span></div>
                <div class="dir-stat"><b>{@router_paths}</b><span>Routes</span></div>
                <div class="dir-stat"><b>{length(@projects)}</b><span>Projects</span></div>
              </div>
            </div>
            <div class="dir-statusbar">
              <span>6 windows</span>
              <span>bobbby.online</span>
            </div>
          </div>

          <%!-- The machine --%>
          <div class="dir-win" id="machine">
            <div class="dir-titlebar">
              <div class="dir-close"></div>
              <div class="dir-title">The Machine</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-body">
              <p class="dir-note">
                Caddy owns 80 and 443, terminates TLS, and trusts Cloudflare's ranges so Phoenix sees
                real client IPs. Nothing else is published to the host. One Postgres 17 container backs
                three separate databases. Deploys rsync <em>the working tree</em>
                rather than a git ref; static sites are bind-mounted read-only into Caddy, so their
                files go live the instant they land.
              </p>
            </div>
            <div class="dir-scroll">
              <table class="dir-table">
                <thead>
                  <tr>
                    <th>Container</th>
                    <th>What it is</th>
                    <th>Port</th>
                    <th>Deploy</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={{name, what, port, deploy} <- @containers}>
                    <td class="dir-key"><code>{name}</code></td>
                    <td>{what}</td>
                    <td class="dir-nowrap"><code>{port}</code></td>
                    <td class="dir-nowrap">{deploy}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="dir-statusbar">
              <span>{length(@containers)} containers</span>
              <span>5.161.181.91</span>
            </div>
          </div>

          <%!-- Domains --%>
          <div class="dir-win" id="domains">
            <div class="dir-titlebar">
              <div class="dir-close"></div>
              <div class="dir-title">Domains</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-scroll">
              <table class="dir-table">
                <thead>
                  <tr>
                    <th>Domain</th>
                    <th>Status</th>
                    <th>Served by</th>
                    <th>What it is</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={{host, status, served, blurb} <- @domains}>
                    <td class="dir-key"><code>{host}</code></td>
                    <td class="dir-nowrap">
                      <span class={"dir-tag #{if status == :live, do: "dir-tag-on", else: "dir-tag-off"}"}>
                        {status_label(status)}
                      </span>
                    </td>
                    <td class="dir-nowrap">{served}</td>
                    <td>{blurb}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="dir-statusbar">
              <span>{@host_count} domains + 1 path</span>
              <span>{@live_count} resolving, {@host_count - @live_count} dark</span>
            </div>
          </div>

          <%!-- Routes --%>
          <div class="dir-win" id="routes">
            <div class="dir-titlebar">
              <div class="dir-close"></div>
              <div class="dir-title">This Site, By Route</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-scroll">
              <table class="dir-table">
                <tbody>
                  <%= for {group, rows} <- @routes do %>
                    <tr class="dir-group">
                      <td colspan="2">{group}</td>
                    </tr>
                    <tr :for={{route, blurb} <- rows}>
                      <td class="dir-key dir-nowrap"><code>{route}</code></td>
                      <td>{blurb}</td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
            <div class="dir-statusbar">
              <span>{@listed_routes} entries in {length(@routes)} sections</span>
              <span>{@router_paths} paths in the router, {@api_paths} of them API</span>
            </div>
          </div>

          <%!-- Museum --%>
          <div class="dir-win" id="museum">
            <div class="dir-titlebar">
              <div class="dir-close"></div>
              <div class="dir-title">Technical Museum</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-body">
              <p class="dir-note">
                The curated project list, read live from the same table that backs the Projects window on
                the home page. Most of these are not hosted here — they are repositories, apps, or
                hardware.
              </p>
            </div>
            <div class="dir-scroll">
              <div class="dir-list">
                <div :for={project <- @projects} class="dir-row">
                  <div class="dir-row-icon">{raw(Icons.get(project.slug))}</div>
                  <div class="dir-row-main">
                    <div class="dir-row-name">{project.title}</div>
                    <div class="dir-row-tagline">{project.tagline}</div>
                  </div>
                  <div class="dir-row-meta">
                    <span class="dir-tag">{category_label(project.category)}</span>
                    <span class="dir-row-where"><code>{where(project)}</code></span>
                  </div>
                </div>
              </div>
            </div>
            <div class="dir-statusbar">
              <span>{length(@projects)} items</span>
              <span>Edit at /admin/museum</span>
            </div>
          </div>

          <%!-- Loose ends --%>
          <div class="dir-win" id="loose-ends">
            <div class="dir-titlebar">
              <div class="dir-close"></div>
              <div class="dir-title">Loose Ends</div>
              <div class="dir-resize"></div>
            </div>
            <div class="dir-body">
              <div class="dir-alerts">
                <div :for={{title, body} <- @loose_ends} class="dir-alert">
                  <div class="dir-alert-icon">!</div>
                  <div>
                    <div class="dir-alert-title">{title}</div>
                    <p class="dir-alert-body">{body}</p>
                  </div>
                </div>
              </div>
            </div>
            <div class="dir-statusbar">
              <span>{length(@loose_ends)} items</span>
              <span>Confirmed against production</span>
            </div>
          </div>

          <div class="dir-colophon">
            Compiled from the Caddyfile, docker-compose.yml, deploy.sh, the Phoenix router, and the
            museum table, with live HTTP checks against every configured host.
          </div>
        </div>
      </div>
    </div>

    <style>
      .dir {
        min-height: 100vh;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 14px;
        color: #000;
        -webkit-font-smoothing: none;
      }

      .dir *, .dir *::before, .dir *::after { box-sizing: border-box; }

      /* ---- Menu bar ---- */
      .dir-menubar {
        position: sticky;
        top: 0;
        z-index: 10;
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
      }

      .dir-menu-left { display: flex; gap: 16px; align-items: center; }

      .dir-apple {
        font-family: system-ui;
        font-size: 16px;
        line-height: 1;
        text-decoration: none;
        color: #000;
      }

      .dir-menu-item {
        font-size: 14px;
        text-decoration: none;
        color: #000;
        padding: 0 2px;
      }

      .dir-menu-item:hover, .dir-apple:hover { background: #000; color: #fff; }

      .dir-menu-on { background: #000; color: #fff; }

      .dir-menu-right { font-size: 13px; }

      /* ---- Desktop ---- */
      .dir-desktop { padding: 20px 20px 60px; }

      .dir-stack {
        max-width: 940px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        gap: 20px;
      }

      /* ---- Window chrome ---- */
      .dir-win {
        scroll-margin-top: 34px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
      }

      .dir-titlebar {
        height: 24px;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 4px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px,
          #fff 1px,
          #000 1px,
          #000 2px,
          #fff 2px,
          #fff 3px
        );
      }

      .dir-close {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
        flex-shrink: 0;
      }

      a.dir-close:hover { background: #000; }

      .dir-title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .dir-resize { width: 12px; height: 12px; flex-shrink: 0; }

      .dir-statusbar {
        height: 22px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 12px;
        color: #333;
      }

      .dir-body { padding: 14px 16px; }

      .dir-scroll { overflow-x: auto; }

      /* ---- Masthead ---- */
      .dir-h1 {
        font-size: 22px;
        font-weight: bold;
        margin: 0 0 8px;
        line-height: 1.25;
      }

      .dir-lede {
        font-family: "Geneva", "Helvetica", sans-serif;
        font-size: 14px;
        line-height: 1.55;
        margin: 0 0 14px;
        max-width: 62ch;
      }

      .dir-note {
        font-family: "Geneva", "Helvetica", sans-serif;
        font-size: 13px;
        line-height: 1.55;
        margin: 0;
        max-width: 68ch;
        color: #333;
      }

      .dir-stats {
        display: flex;
        flex-wrap: wrap;
        border: 1px solid #000;
        background: #000;
        gap: 1px;
      }

      .dir-stat {
        background: #fff;
        flex: 1 1 96px;
        padding: 7px 10px 8px;
      }

      .dir-stat b {
        display: block;
        font-size: 22px;
        line-height: 1;
        font-variant-numeric: tabular-nums;
      }

      .dir-stat span {
        display: block;
        font-size: 10px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #666;
        margin-top: 4px;
      }

      /* ---- Tables ---- */
      .dir-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
      }

      .dir-table th {
        background: #e0e0e0;
        border-bottom: 1px solid #000;
        text-align: left;
        padding: 4px 12px;
        font-size: 10px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #333;
        white-space: nowrap;
      }

      .dir-table td {
        padding: 7px 12px;
        border-bottom: 1px solid #ccc;
        vertical-align: top;
        font-family: "Geneva", "Helvetica", sans-serif;
        line-height: 1.45;
      }

      .dir-table tbody tr:last-child td { border-bottom: 0; }

      .dir-table tbody tr:hover td { background: #000; color: #fff; }
      .dir-table tbody tr:hover .dir-tag { background: #333; color: #fff; border-color: #fff; }
      .dir-table tbody tr:hover .dir-tag-on { background: #fff; color: #000; }

      .dir-table tr.dir-group td,
      .dir-table tr.dir-group:hover td {
        background: #e0e0e0;
        color: #000;
        border-bottom: 1px solid #000;
        border-top: 1px solid #000;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 10px;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 4px 12px;
      }

      .dir-key { font-weight: bold; }
      .dir-nowrap { white-space: nowrap; }

      .dir code {
        font-family: "SF Mono", "Monaco", "Menlo", monospace;
        font-size: 0.9em;
      }

      /* ---- Tags ---- */
      .dir-tag {
        display: inline-block;
        border: 1px solid #000;
        background: #fff;
        color: #000;
        padding: 0 5px;
        font-size: 10px;
        line-height: 15px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        white-space: nowrap;
      }

      .dir-tag-on { background: #000; color: #fff; }
      .dir-tag-off { border-style: dashed; color: #333; }

      /* ---- Museum list ---- */
      .dir-list { display: flex; flex-direction: column; }

      .dir-row {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 7px 12px;
        border-bottom: 1px solid #ccc;
      }

      .dir-row:last-child { border-bottom: 0; }
      .dir-row:hover { background: #000; color: #fff; }
      .dir-row:hover .dir-row-tagline { color: #ccc; }
      .dir-row:hover .dir-tag { background: #333; color: #fff; border-color: #fff; }
      .dir-row:hover .dir-row-icon svg { filter: invert(1); }

      .dir-row-icon {
        width: 26px;
        height: 26px;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .dir-row-icon svg {
        width: 26px;
        height: 26px;
        image-rendering: pixelated;
      }

      .dir-row-main { flex: 1; min-width: 0; }

      .dir-row-name { font-weight: bold; font-size: 13px; }

      .dir-row-tagline {
        font-family: "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        color: #666;
        line-height: 1.4;
      }

      .dir-row-meta {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
        text-align: right;
      }

      .dir-row-where { font-size: 11px; }

      /* ---- Loose ends ---- */
      .dir-alerts { display: flex; flex-direction: column; gap: 14px; }

      .dir-alert { display: flex; gap: 12px; align-items: flex-start; }

      .dir-alert-icon {
        width: 22px;
        height: 22px;
        border: 1px solid #000;
        border-radius: 50%;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        font-size: 14px;
      }

      .dir-alert-title { font-weight: bold; font-size: 13px; margin-bottom: 2px; }

      .dir-alert-body {
        font-family: "Geneva", "Helvetica", sans-serif;
        font-size: 13px;
        line-height: 1.5;
        margin: 0;
        max-width: 68ch;
        color: #333;
      }

      .dir-colophon {
        font-family: "Geneva", "Helvetica", sans-serif;
        font-size: 11px;
        color: #444;
        text-align: center;
        max-width: 60ch;
        margin: 0 auto;
        line-height: 1.5;
      }

      /* ---- Mobile ---- */
      @media (max-width: 700px) {
        .dir-desktop { padding: 10px 10px 40px; }
        .dir-stack { gap: 12px; }
        .dir-table { font-size: 12px; }
        .dir-table td, .dir-table th { padding: 6px 8px; }
        .dir-row-meta { display: none; }
        .dir-h1 { font-size: 18px; }
      }
    </style>
    """
  end
end
