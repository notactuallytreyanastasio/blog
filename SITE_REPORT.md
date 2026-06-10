# Site Report — Full Codebase Sweep & MTA Bus Map Fix

**Date:** 2026-06-10
**Scope:** Entire repository (226 Elixir files, 40 LiveViews, JS hooks, CSS, config, Docker/deploy infra)
**Method:** 74-agent workflow — 1 diagnosis agent, 15 read-only area reviewers, 1 adversarial verifier per finding, per-file applier agents on disjoint file groups. Medium/high-risk findings were excluded by design; only findings that survived adversarial verification were applied.
**Status:** All changes are uncommitted in the working tree. Nothing has been deployed.

## Verification

| Check | Result |
|---|---|
| `mix test` | 826 tests, 0 failures, 1 skipped (matches pre-sweep baseline) |
| `mix compile` | Clean |
| `mix assets.build` (tailwind + esbuild) | Succeeds (pre-existing 2.1 MB bundle-size warning only) |
| `node --check` on edited JS | Passes |

## Pipeline numbers

- 80 raw findings from 15 reviewers
- 30 low-risk candidates after dedup and metering (45 dropped by the cap; medium/high-risk excluded outright)
- 29 survived adversarial verification (1 rejected)
- 29 applied by workflow agents + 2 follow-ups applied manually (a skipped cross-file companion fix and the test-environment poller fix below)

---

## 1. MTA Bus Map — root cause and fix

### Diagnosis (confidence 0.9, confirmed against code)

The map was not primarily a mobile-CSS failure. The LiveView template loaded Leaflet via inline `<link>`/`<script>` tags inside `render/1`. **Script tags injected during LiveView live navigation never execute** (DOM-patched scripts are inert per the HTML spec). The home page's Finder opens "MTA Map" via `push_navigate` (`terminal_live.ex`), so anyone arriving that way got no `window.L`; the hook's `L.map()` call threw `L is not defined`, the error was swallowed by a bare `try/catch`, and `updateMarkers` looped forever. Direct URL visits triggered a full page load where the inline script did run — which is why the page appeared to work in some entry paths and not others.

Contributing issues, also confirmed:

- **Blocking `alert()` on geolocation failure** — the hook called `map.locate()` on every mount and `alert()`ed when permission was denied (the default state on mobile). Reads as "broken" even when the map loads.
- **iOS Safari `100vh` quirk** — `.mta-bus-window`/`.mta-bus-map-container` used `100vh`, which on iOS equals the *largest* viewport, pushing the bottom of the window under the browser toolbar. Cosmetic, not the load failure.

Ruled out by the diagnosis agent: unpkg outage and SRI hash mismatch (fetched live, digest matches exactly); CSS class pruning (the `e1037af` refactor's classes ship in the built CSS); dual hook registration (`assets/js/hooks.js` is dead code — only `app.js`'s LiveSocket runs).

### Fix applied

| File | Change |
|---|---|
| `assets/js/hooks/mta_bus_map.js` | Hook now owns Leaflet loading via a `loadLeaflet()` promise (same CDN, same SRI hashes, resolves instantly if already loaded) — works on both full page loads and live navigation, mirroring the proven `nyc_map.js` pattern. Bus updates arriving before the map is ready are buffered and replayed. On load failure the map container shows "Map failed to load. Check your connection and refresh." instead of failing silently. The geolocation `alert()` is now a non-blocking overlay hint that auto-dismisses after 4 s. The recursive `updateMarkers` retry loop was removed. |
| `lib/blog_web/live/mta_bus_map_live.ex` | Removed the inline Leaflet `<link>`/`<script>` tags from the template (13 deletions, nothing else touched). |
| `assets/css/app.css` | Added `@supports (height: 100dvh)` overrides so the window and map container use the dynamic viewport height on iOS Safari. Desktop and older browsers keep the `vh` values. |

**Manual check after deploy:** on a phone, open the site and go Finder → MTA Map (the previously broken `push_navigate` path); confirm the map initializes, and that denying location shows the small hint banner instead of an alert.

---

## 2. Applied improvements (29 verified findings + 2 follow-ups)

### Security

| File | Problem | Fix |
|---|---|---|
| `lib/blog_web/live/museum_admin_live.ex` | All mutating admin events (add/edit/delete/reorder projects) were executable without authenticating | Catch-all `handle_event` guard silently ignores every event except `check_password` while `authenticated: false` |
| `lib/blog_web/live/role_call_live.ex` | Same class of issue: non-critical events accepted while unauthenticated | Auth guard clause added |
| `lib/blog_web/live/bookmarks_live.ex` | `delete_bookmark` had no ownership check, and bookmark IDs are sequential integers — anyone could delete anyone's bookmarks | Delete now fetches the bookmark and only deletes when its `user_id` matches the session's |
| `config/runtime.exs` | Empty-string env vars counted as "set": docker-compose's `${VAR:-}` defaulting sets absent vars to `""`, so the finder/museum admin password could effectively be empty in prod | `read_env` helper treats `""` as unset for `RECEIPT_PRINTER_API_TOKEN`, `LIVE_DRAFT_TOKEN`, `FINDER_ADMIN_PASSWORD`, `CAIRN_API_TOKEN`, `S3_ACCESS_KEY` |
| `lib/blog_web/live/twenty48_live.ex` | `set_size`/`set_blitz_time` accepted arbitrary client integers — a crafted `phx-value-size` could allocate a giant board (memory DoS) or crash | Inputs validated against the allowed `@sizes`/`@blitz_options` lists; invalid input is a no-op |

### Crash fixes

| File | Problem | Fix |
|---|---|---|
| `lib/blog_web/live/blackjack_live.ex` | Joining a game crashed the LiveView because `@game` is `nil` while waiting for the host | Nil-safe rendering/handling |
| `lib/blog_web/live/allowed_chats_live.ex` | Submitting an empty chat message or empty word raised `FunctionClauseError`, crashing the LiveView | Catch-all clauses for `send_message` and `add_word` no-op on empty/invalid params |
| `lib/blog_web/live/keylogger_live.ex` | Backspace crashed the typewriter when the buffer was empty, and byte-slicing corrupted multi-byte characters | Replaced with `String.slice(pressed_keys, 0..-2//1)` |
| `lib/blog_web/live/hacker_news_live.ex` | Mount returned HTTP 500 whenever the HN API call failed | API calls wrapped in proper error handling; `Task.async_stream` with 10 s timeout + `on_timeout: :kill_task`; rescue returns an empty list |
| `lib/blog_web/live/nyc_census_and_pluto_live.ex` | A malformed polygon payload crashed the whole LiveView — the linked `Task.async` defeated the `:DOWN` error handler | Estimation wrapped in try/rescue/catch, returning `{:error, message}` |
| `lib/blog/smart_steps/session_server.ex` | An out-of-range choice index crashed the shared session GenServer for **all** participants | Choice is looked up safely first; invalid index is a no-op |
| `lib/blog/wordle/game_store.ex` | Periodic cleanup crashed the GameStore (wiping all games) when a player had 2+ sessions: `last_activity` is an ISO8601 *string*, but the sort used the `{:desc, DateTime}` comparator, which calls `DateTime.compare/2` on strings | Plain `:desc` sort — lexicographic order on ISO8601 UTC strings is chronologically correct |
| `lib/blog_web/live/phish_live.ex` | `Enum.random(years)` returned an *integer* year, but the query filter only matches binaries — the year filter silently no-oped and the UI lied about the displayed year; empty DB crashed `Enum.random([])` | Year converted with `to_string/1`; empty list falls back to `"all"` |
| `lib/blog_web/live/phish_component.ex` | Same defect as `phish_live.ex` (companion fix, applied manually after the workflow flagged it as outside its file ownership) | Same guard mirrored |

### Silently broken features

| File | Problem | Fix |
|---|---|---|
| `lib/blog_web/components/layouts.ex` | Google Analytics was configured with the literal string `'{@measurement_id}'` — GA tracking has been silently broken | Proper interpolation of the measurement ID |
| `lib/blog_web/live/role_call_live.ex` | Live search read the stale `phx-value-query` attribute, so typing in the search box never returned results in a real browser | Handler reads the live input value (`%{"key" => _, "value" => query}`) |
| `lib/blog_web/live/hacker_news_live.ex` | The 3-minute story refresh was dead: `send(self(), ...)` inside `Task.start` sent to the Task process, not the LiveView | `parent = self()` captured before the task; messages go to the LiveView |
| `assets/js/app.js` | The `TourSpotlight` hook used by `/role-call`'s guided tour was never registered — the tour was broken | Hook implemented and registered in the LiveSocket |
| `lib/blog_web/live/chess_live.ex` | NEW GAME didn't push fresh legal targets, leaving the JS hook with a stale move cache; bot-move task had the same `send(self())`-inside-task bug | `push_legal_targets` on new game; `parent = self()` pattern for the bot task |

### Reliability (background processes)

| File | Problem | Fix |
|---|---|---|
| `lib/bluesky_hose.ex` | `Jason.decode!` crashed the firehose process on any malformed frame; remote disconnects **stopped** the process instead of reconnecting | Safe `Jason.decode` with graceful skip; `handle_disconnect` logs and returns `{:reconnect, state}` |
| `lib/blog/gif_maker/processor.ex` | Retried jobs discarded the updated GenServer state, breaking the max-concurrent-jobs cap | Retry path returns the state from the re-dispatched handler |
| `lib/blog/collage_maker/processor.ex` | Identical retry-state bug | Identical fix |
| `lib/blog/live_draft.ex` | Posts directory resolved at compile time (`@posts_dir`) — draft persistence broke in releases where build and runtime paths differ | Runtime `posts_dir()` function |

### Data correctness

| File | Problem | Fix |
|---|---|---|
| `lib/blog/chat.ex` | `list_messages` returned the 50 **oldest** messages instead of the most recent 50 | Query orders `desc` with limit, then reverses for chronological display |
| `lib/blog/chat/message_store.ex` | Prune deleted the **newest** messages instead of the oldest once the 100-message cap was hit | Sort direction corrected so the oldest keys are evicted |
| `lib/blog_web/live/reddit_links_live.ex` | `extract_youtube_id` crashed with `MatchError` when a regex matched more than once — crash-looping the page on firehose input | Rewritten as a single `Enum.find_value` over the pattern list |

### Performance

| File | Problem | Fix |
|---|---|---|
| `lib/blog_web/live/emoji_skeets_live.ex` | Full re-filter of up to 100,000 skeets on **every** firehose message | Incremental prepend of matching skeets; full re-filter only on cap eviction |
| `lib/bluesky_jetstream.ex` | Subscribed to the entire Bluesky firehose and filtered client-side | `?wantedCollections=app.bsky.feed.post` filters server-side |
| `assets/js/hooks/bubble_game.js` | The WebGL `requestAnimationFrame` loop was never cancelled — it kept rendering forever after navigating away | Frame ID tracked and `cancelAnimationFrame` called in `destroyed()`; renderer nulled after dispose |

### Mobile

| File | Problem | Fix |
|---|---|---|
| `lib/blog_web/live/wordle_live.ex` | On-screen keyboard clipped and unreachable in mobile Safari (`100vh` quirk) | `100dvh` fallback added to the window style |
| `assets/css/app.css` | Same quirk on the MTA bus map (see section 1) | `@supports (height: 100dvh)` overrides |

---

## 3. Found during post-sweep verification

**`Blog.GitHub.WorkLogPoller` made the test suite a time bomb.** The poller fetches the live GitHub events API and inserts into the database, starting immediately at boot — including in the test environment. Whenever GitHub's unauthenticated rate limit happened to let a response through, the insert raised `DBConnection.OwnershipError` under the test sandbox, the GenServer crash-looped past supervisor restart intensity, and the entire application shut down mid-suite (observed as 192 cascading failures). Previous green runs only passed because GitHub was returning errors at the time.

**Fix:** `lib/blog/application.ex` now gates the poller behind `Application.get_env(:blog, :start_work_log_poller, true)`, and `config/test.exs` sets it to `false`. Config-based, so it is release-safe; production behavior is unchanged.

---

## 4. Not applied — known remaining issues and recommendations

These were observed during the sweep but intentionally left alone (out of "metered, don't break anything" scope). Worth future attention, roughly in priority order:

1. **Hardcoded fallback secrets in `config/runtime.exs`** — `FINDER_ADMIN_PASSWORD` falls back to `"letmein"` and `RECEIPT_PRINTER_API_TOKEN` to a hardcoded hex token when the env var is absent. The empty-string fix tightened the docker-compose hole, but the fallbacks themselves should be removed (fail loudly instead) and any exposed values rotated.
2. **unpkg.com is a single point of failure** for Leaflet on both the bus map and `nyc_map.js`. Vendoring leaflet 1.9.4 into `assets/vendor/leaflet/` and serving it from the app would eliminate the dependency; the diagnosis agent left wiring notes (beware `--external:leaflet` in the esbuild config — don't use a bare `import "leaflet"`).
3. **`nyc_map.js` has no `onerror` handling** in its own leaflet loader — same failure-UI treatment as the bus map fix would apply.
4. **`assets/js/hooks.js` is dead code** — nothing imports it; `app.js` registers hooks directly. It silently drifts from the real registrations and should be deleted to avoid confusion.
5. **`app.js` bundles to 2.1 MB** (esbuild warning). Code-splitting or lazy-loading the heavy hooks (deck.gl, three.js-class games) would help mobile load times — likely relevant to overall mobile feel.
6. **45 low-risk findings were dropped by the metering cap and all medium/high-risk findings were excluded by design.** Their details were not retained in the workflow output — a second sweep with a higher cap (or one focused on the medium-risk tier with manual review) would surface them again.
7. **1 finding failed adversarial verification** and was discarded.

---

## Files changed (summary)

32 tracked files modified (plus this report). Two of the larger diffs — `wordle_live.ex` (~400 lines) and `blackjack_live.ex` — are mostly `mix format` attribute reformatting around small substantive fixes; the per-file review above lists every behavioral change. `post.md` and `.deciduous/` changes predate this work and were not touched.

Decision-graph trail: goal 547 → options 548/549 → decision 550 → action 551 → outcomes 552/553 and observation 554.
