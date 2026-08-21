# What's running on bobbby.online

An inventory of every domain, app, and route served off the Hetzner box, written 2026-08-19 from the Caddyfile, docker-compose.yml, deploy.sh, and the Phoenix router.

## The machine

One VPS at 5.161.181.91. Everything lives in `/opt/blog` as a single `docker compose` project. Caddy owns 80/443, terminates TLS, and trusts Cloudflare's IP ranges for the real client IP. Nothing else is exposed to the host.

One Postgres 17 container backs three Phoenix apps with separate databases: `blog_prod`, `blinks_backend_prod`, and `nathan_for_us_prod`.

Deploys go through `./deploy.sh`, which rsyncs the working tree (not a git ref) to `/opt/blog` and `/opt/nathan`, publishes two static sites, rebuilds images, and runs migrations. Static sites bind-mounted read-only into Caddy go live the moment their files change, with no container restart.

| Container | What it is | Deploy style |
|---|---|---|
| `app` | The blog Phoenix app, port 4000 | Image build |
| `blinks` | blinks_backend Phoenix app, port 4000 | Image build from `/opt/blinks_backend` |
| `nathan` | Framecut (nathan_for_us), port 4001 | Image build from `/opt/nathan` |
| `soldat` | Arena watcher (8901) + 1v1 game server (8902) | Bind mount, rsync + restart |
| `slides-relay` | Phone-remote WebSocket router, 8787 | Bind mount, rsync + restart |
| `lumines` | LUMINES rooms server, 8903 | Bind mount, rsync + restart |
| `caddy` | Reverse proxy and static file server | Config file |
| `db` | Postgres 17 | Image |

## Domains

| Domain | Served by | What it is |
|---|---|---|
| bobbby.online | `app` (Phoenix) | The main site. Blog, toys, games, data explorers. |
| bobbby.online/arena/* | `soldat` container | The Claude Arena. `/arena/play/*` is a static replay client from `/opt/arena`; everything else proxies to the live watcher daemon. `/arena/ws` is the online 1v1 game server. |
| gifmaker.bobbby.online | `nathan` (Phoenix) | Framecut. Slices video into 1fps frames, cuts GIFs from timeline ranges, caption search, voting feed. |
| downloader.bobbby.online | Static, `/srv/downloader` | Framecut Grabber download and setup page. Ships inside nathan_for_us as `site/`. |
| slides.bobbby.online | Static SPA + `slides-relay` | Slides.net, a reveal.js deck editor. Markdown per slide, 2D deck structure, phone remote over `wss://slides.bobbby.online/relay`. |
| lumines.bobbby.online | Static SPA + `lumines` | LUMINES HD. Falling-block puzzle where two players share one board over `/ws`, with music synthesized from play. |
| soldat.bobbby.online | Static, `/srv/soldat-landing` | The write-up page for the Soldat rewrite project. |
| deciduous.dev | Static, `/srv/deciduous` | Deciduous, the decision-graph tool. Docs, tutorial, demo graph. |
| phishjamexplorer.com | Static SPA, `/srv/phstats` | D3 visualizations of Phish 3.0 jam data. Eight jamchart tabs plus PhanGraphs sabermetrics. |
| blimp.bobbby.online | Static, `/srv/blimp` | Blimp language docs and tutorial. Pulled fresh from GitHub on every deploy. |
| links.bobbby.online | `blinks` (Phoenix) | Configured in Caddy, but DNS does not resolve. See "Loose ends". |
| bobbbys.link | `blinks` (Phoenix) | Host-routed landing page in blinks_backend. DNS points at 192.64.119.240, not this box. |
| donny.bobbby.online | Static, `/srv/donny` | Configured in Caddy with a mount from `/opt/donny`, but DNS does not resolve and no local repo references it. |

## The blog app, by route

### Writing

`/` is the home page, a Mac-desktop-style Finder whose sections and icons come from the database (edit at `/admin/finder`) with a persistent chatroom and presence tracking. `/blog` lists posts, `/post/:slug` renders one. Posts stream live from the author's editor through `Blog.LiveDraft`, an ETS cache that broadcasts rendered HTML over PubSub.

Longform one-offs: `/trees` (327 years of tree law), `/knicks` (2026 Finals feature with vendored D3), `/nathan` (Nathan Fielder writing experiments).

### Blinks, the link stack

| Route | What it does |
|---|---|
| `/blinks` | The front page. Two hand-set columns, newspaper layout, live occupancy dots per link room. |
| `/blinks-reader` | Contact sheet layout. More links per screen, thumbnails open into a full-viewport lightbox you can walk with arrow keys. |
| `/blinks/surf` | One random unseen link at a time with a button that rerolls. Channels narrow to a tag, back retraces hops. |
| `/blinks/walk` | Wiki-walk. Every card offers three nearest neighbors by shared tags and title similarity, plus a wildcard. The trail stays on screen. |
| `/blinks/tv` | Lean-back mode. Retunes every few seconds with static, top tags are channels, arrows change channel, space pauses. |
| `/blinks/review` | Private triage queue, gated by `?key=` against the blinks API token. Upvote promotes a bookmark to a blink. |
| `/blinks.rss`, `/blinks/stumble`, `/blinks/privacy` | Feed, random redirect, and the privacy policy for the iOS app listing. |
| `/api/blinks*` | Reads are open, writes are token-gated. Create, search, tags, lookup, export, candidate import, tag add/remove, delete. |
| `/api/push/devices` | Open APNs device registration for the Blinks iOS app. |

A `Blog.Blinks.LinkCheck` process sweeps for dead links daily, and `Blog.Push.Notifier` fires an APNs push on every new blink.

### Phish

`/phish` is PhanGraphs, jam analytics with batting averages, jamchart rates, and duration timelines for every song since 2009. `/phish_lab` runs anomaly detection with per-leaderboard chart presets (jammiest shows, bustouts, most variable songs). `/moon_phish` maps every show against the lunar calendar. `/map` is Tag A Wook, a shared map where visitors drop pins for songs.

### Bluesky and atproto

`/emoji-skeets` searches the firehose. `/reddit-links` surfaces YouTube links posted to Bluesky. `/jetstream_comparison` runs Jetstream and the raw relay side by side. `/sky` is Fill The Sky, a community map over 546K seeded Bluesky profiles. `/allowed-chats` is a shared chat with a community-voted word allowlist. Three supervised consumers keep this fed: `Blog.HoseMonitor`, `BlueskyHose`, and `BlueskyJetstream`.

### NYC data

`/mta-bus-map` tracks live bus positions on Leaflet across three boroughs, refreshing every 30 seconds off the MTA Bus Time API. `/mta-train` does the same for trains. `/nyc_census_and_pluto` estimates population for any drawn polygon from PLUTO tax lots plus Census data.

### Games

Wordle (`/wordle`, plus `/wordle_god` for the solver's view), Pong against an AI paddle at 30fps (`/pong`, `/pong/god`), multiplayer Blackjack over PubSub (`/blackjack`), 2048 with a blitz timer (`/2048`), and chess in two flavors, one controller-rendered (`/chess`) and one LiveView (`/chess-lv`).

### Toys and art

| Route | What it does |
|---|---|
| `/art` | Seeded generative art. Bauhaus by default, generators registered from the client. |
| `/cursor-tracker` | Shared canvas. Everyone sees everyone's cursor, clicks leave colored dots, ETS-backed, cleared hourly. |
| `/typewriter` | Keypresses render as a typewriter animation. |
| `/mirror` | The page fetches and displays its own source from GitHub with spinning character animations. |
| `/chaos-typing` | Typing experiment. |
| `/lumon-celebration` | Severance bit. |
| `/stumble` | A Mac-windowed browser over a bag of links, with tag browsing and per-language filtering. |
| `/gif-maker` | Concert GIF maker with captcha and rate limiting, backed by a processor and cleanup GenServer. |
| `/collage-maker`, `/collage/:token` | Up to 36 images, 20MB each, share links by token. |
| `/very_direct_message` | Writes a message that a thermal printer on the author's desk pulls down and prints. |

### Utilities and the rest

`/bookmarks` (per-visitor, ownership-checked), `/markdown-editor`, `/hacker-news` (top stories with timeouts and a fallback), `/role-call` (TV writer discovery driven by liked shows), `/python-demo` (Pythonx sandbox), `/work-log` (live GitHub activity feed polled into the DB), `/privacy`, `/terms`.

`/smart-steps` is the largest self-contained feature: a scenario system for social-skills practice with ten themes, plus play, results, dashboard, connect, designer, and demo views. Shared sessions run as GenServers under a dynamic supervisor with a registry.

Admin lives at `/admin/finder` (home page icons) and `/admin/museum` (project list), both password-gated against `FINDER_ADMIN_PASSWORD`.

The receipt printer API (`/api/receipt_messages/*`) is the polling side of `/very_direct_message`: the printer asks for pending jobs, fetches the rendered image, and reports printed or failed.

## Sidecar apps

blinks_backend is a second Phoenix app that duplicates the blinks feature set against its own database. It has `/` (LinksLive), `/review`, RSS, stumble, and the same `/api/blinks*` surface. `bobbbys.link` and `www.bobbbys.link` are host-scoped to a landing controller.

Framecut (nathan_for_us) is the GIF maker at gifmaker.bobbby.online. Videos are sliced client-side in a canvas and uploaded as 1fps JPEG frames stored in Postgres, with SRT captions linked to frames by timestamp. GIFs are deduplicated by a sha256 of video id plus frame ids. It has an ingest API keyed per user.

The Arena (soldat) runs four daemons under `deploy/arena-supervisor.mjs`: an HTTP watcher, a commissioner, a league grinder, and the online game server. The shipped fight feed is capped at 40 matches because the full `data.json` crossed 300MB and the floor polls it every five seconds.

## Loose ends

`/cairn` and `/python` are in the router but the modules they point at do not exist anywhere in `lib/`. Both return 500 in production right now. Either write `BlogWeb.CairnLive` and `BlogWeb.PythonLive.Index` or delete the two lines.

`links.bobbby.online` and `donny.bobbby.online` have Caddy blocks, a container or mount behind them, and no DNS record. `bobbbys.link` resolves to 192.64.119.240 (a registrar parking IP), so its Caddy block never sees traffic. The `blinks` container is running and unreachable from outside.

Blinks exists twice, once in this app and once in blinks_backend, against two separate databases. The iOS extension writes to whichever host it is configured for. Worth deciding which one is canonical before they drift further apart.

`/blinks/surf`, `/blinks/walk`, and `/blinks/tv` are live in production and still uncommitted locally, because `deploy.sh` rsyncs the working tree rather than a git ref.
