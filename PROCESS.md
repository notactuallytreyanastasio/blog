# Putting a sprawling blog under the microscope

This blog is one Phoenix app wearing about forty hats. Blog posts, a 2048 clone,
a Bluesky firehose viewer, a thermal-printer controller, a community map of half
a million Bluesky accounts, a GIF maker, a census importer — it all lives in one
repo and ships to one box. That kind of thing accretes. The plan here is to walk
the whole thing, top to bottom, and tighten it: kill warnings, modernize the
toolchain, turn on real type analysis, write tests around what's there, and then
go page by page making the code better. Each step lands as its own pull request.

This file is the running log of that work — what I found, what I changed, and the
places where the codebase turned out to be in better (or weirder) shape than
expected.

## Phase 1: compiler warnings

The first surprise: there basically weren't any. A clean `mix compile` in dev
came back silent. The test build threw 284 warnings, which looked alarming until
I traced where they came from — all but one were inside dependencies. Floki,
MDEx, Ecto, Phoenix, Postgrex. Elixir 1.19 reports those with the dependency's
own relative path (`lib/floki/html/tokenizer.ex`), which makes them look like
local files at a glance. They aren't ours, and they aren't ours to fix.

The single real one was an unused alias in `test/support/test_helpers.ex` — a
`Post` pulled into scope and never used. Deleted it. Our code now compiles
without a single warning. Phase 1 was a one-line fix wearing a trenchcoat.

## Phase 2: the toolchain was already current

Second surprise: the upgrade was already done. The box is on Erlang 28.3.1 and
Elixir 1.19.5-otp-28, which is the latest. Nothing to bump at the runtime level.
The only stale artifact is `mix.exs` still declaring `elixir: "~> 1.14"`, a floor
that no longer reflects reality.

What *is* behind is the hex dependencies — Phoenix 1.7 to 1.8, Bandit 1.6 to
1.11, ecto_sql 3.12 to 3.14, mdex 0.7 to 0.12, and a dozen more. That's the real
modernization work hiding under "Phase 2," and it's riskier than a version bump
(Phoenix 1.7 to 1.8 in particular), so it gets its own treatment later.

## Phase 3: turning on Dialyzer

For type analysis I'm using [Assay](https://github.com/Ch4s3/assay), a wrapper
around incremental Dialyzer that reads its config straight out of `mix.exs` and
only surfaces warnings for the apps you care about.

The Igniter-based installer didn't work — `mix igniter.install assay` blew up
with `Assay.Install.supports_umbrella?/0 is undefined`, a version mismatch
against Igniter 0.8.0. So I set it up by hand instead, which Assay documents as a
supported path: add the dep, add an `assay:` block to the project config, drop a
blank `dialyzer_ignore.exs`, and gitignore the PLT cache. Igniter got pulled back
out of the dependency tree afterward, since the manual route doesn't need it.

The first run found 50 problems. About thirty of them were noise: Dialyzer
couldn't find `crypto:strong_rand_bytes/1`, `crypto:hash/2`, or anything under
`Mix` and `Mix.Task`, because those Erlang/Elixir apps weren't in the analysis
set. Assay's `apps` option takes a list that mixes its symbolic selectors with
literal app names, so adding `:crypto` and `:mix` alongside `:project_plus_deps`
made all of those resolve. That dropped the count from 50 to 18.

The remaining 18 are the real ones, across 11 files:

- **Five "pattern match will never succeed."** A clause that can't ever run is
  either dead code or a bug where the author expected a shape the function never
  receives. Each one needs reading before touching. Files: the remote-IP plug,
  the Hacker News live view, the thermal-printer image processor, a PokeAround
  link module, and a Bluesky extractor.
- **Six opaque-term violations** in the SmartSteps designer logic, all from
  reaching into a `MapSet`'s internals instead of going through its API.
- **Three `MapSet.member?` type mismatches** in the population estimator.
- **Five "unknown type"** — specs that reference `Blog.Pluto.Lot.t/0` and
  `Blog.Sky.Profile.t/0`, types that were never defined. These are Ecto schemas
  that need an explicit `@type t`.
- **Two "function has no local return"** in the GIF maker, usually a sign of a
  function that always raises.

The fixes go out next, fanned across agents — one per file — with an independent
review pass on each change, because the "never succeeds" cases are exactly the
kind of thing where deleting the wrong clause quietly changes behavior.

### Fanning the fixes out

I ran the eleven files through a workflow: one agent per file to make the fix and
add `@spec`s, then a second, independent agent to review that exact diff and rule
on whether behavior was preserved. Twenty-two agents, about two minutes. The
agents were told to edit only their own file and to run no build commands —
eleven `mix compile`s fighting over the same `_build` directory would have
corrupted it — so verification happened centrally afterward.

The interesting part is what they refused to do. Three files came back as
"needs human" instead of a guessed fix:

- **The population estimator.** My work-list said it had a `MapSet.member?`
  type mismatch. The agent went looking and found the file has no MapSet in it
  at all — the lines I'd pointed at were `@spec` declarations, and they were
  already correct. The finding was an artifact of how I'd paired up file
  locations with messages while reading the raw Dialyzer output; the real MapSet
  warnings were all in a different module. The agent declined to invent a fix
  for a problem that wasn't there. Exactly right.

- **The YouTube downloader.** Dialyzer said `download_segment/3` "has no local
  return," which usually means a function that always raises. The agent traced
  it to a real bug: the code calls `System.cmd("yt-dlp", args, timeout: 120_000)`,
  and `System.cmd/3` has no `:timeout` option. Every call raises `ArgumentError`.
  This feature was simply broken. The agent refused to slap a `no_return()` spec
  on it (which would have enshrined the bug as intended) and flagged it for a
  human. I fixed it by dropping the unsupported option, which is what the author
  wanted minus a timeout that never worked. That also cleared the GIF processor
  finding, which only inherited the breakage by delegating to it.

- **The Hacker News list.** A template branch — `if domain = format_domain(url)`
  — could never take its false path, because `format_domain` returned `""` (which
  is truthy) instead of `nil` for URL-less stories. So every Ask HN post rendered
  an empty domain badge. The fix that matched the obvious intent was to return
  `nil`, which makes the conditional do what it looks like it does.

The rest fixed cleanly: a dead RGB branch in the thermal-printer grayscale path
(pixels are always integers), a redundant `|| ""` on a URI host that was already
known to be non-nil, an unreachable catch-all in the Bluesky post filter, the
missing `@type t` on the Pluto and Sky schemas, and `@spec`s threaded through the
SmartSteps graph logic.

### The MapSet that wouldn't typecheck

The SmartSteps designer logic was stubborn. It runs BFS and DFS over a scenario
tree, threading a `visited` MapSet through private recursion. Dialyzer kept
complaining about opaque terms — `MapSet.member?` "contains an opaque subterm,"
the helper specs have "an opaque subtype." The code is correct; it only ever uses
MapSet's public API. The trouble is that MapSet's type is `@opaque`, defined in
another module, and once you both annotate a parameter as `MapSet.t()` and call
`MapSet.member?` on it inside the same function, Dialyzer's opaqueness checker
trips over its own feet. Parameterizing it as `MapSet.t(scenario_id())` made it
worse, not better.

This is a known limitation, not a defect, so it goes in the ignore file — but
narrowly. The rule matches only MapSet-related warnings in that one file, so a
genuine opaque bug somewhere else in it would still surface. Every entry in
`dialyzer_ignore.exs` has to earn its place with a comment explaining why it's a
false positive.

### Where Phase 3 landed

Eighteen real findings down to zero. Five were dead code, two were a genuine
runtime bug, five were missing type definitions, and the rest were honest types
the analyzer just needed spelled out. The project now has incremental Dialyzer
wired in, runs clean, and has its first layer of `@spec` coverage on the modules
that got touched. The broader gradual-typing pass — specs across all 206 modules
— is its own effort for later.

Verification: `mix compile --warnings-as-errors` is clean, `mix assay` reports
zero errors, and the SmartSteps suite (which exercises the BFS/MapSet code that
got the heaviest edits) passes all 87 tests. Trying to run the *full* suite
surfaced the first lead for Phase 4: `test/blog_web/live/post_live/index_test.exs`
won't compile — it `use`s a `BlogWeb.LiveCase` that doesn't exist and calls into
`:meck`, which isn't even a dependency. One broken test file aborts compilation
for the whole suite, so the test story is in worse shape than the app code. That
is the thread to pull on next.

## The gradual-typing pass

With Dialyzer green and the foundation merged, the next job was breadth: put
honest `@type`/`@spec` coverage across the whole domain layer. This is where the
codebase's size actually mattered — around a hundred modules — so it ran as a
fan-out. One agent per module to write specs from reading the implementation, a
second, independent agent to review that exact diff for accuracy, then a single
central `mix compile --warnings-as-errors` and `mix assay` to verify the whole
batch before anything got committed. Each subsystem landed as its own pull
request.

The discipline that made this safe was making the agents edit-only. A hundred
`mix compile`s fighting over one `_build` directory would have been chaos, so the
writers only touched source; verification happened once, centrally. When a batch
came back, the central run was the judge — not the agents' own confidence.

That judge earned its keep. A few patterns kept recurring:

- **Ecto timestamps.** Agents reflexively typed `inserted_at`/`updated_at` as
  `DateTime.t()`, but a bare `timestamps()` in Ecto defaults to `:naive_datetime`.
  Six schemas had it wrong; the fix was mechanical once spotted (`NaiveDateTime.t()`),
  and the schemas using `timestamps(type: :utc_datetime_usec)` were correctly
  left as `DateTime.t()`.

- **Specs that were too narrow.** `Wordle.Game.handle_key_press/2` got typed
  `{:ok, t()}` — but it also returns `{:error, t()}`. Dialyzer didn't complain
  about the spec directly; it flagged the LiveView that consumes it, where the
  `{:error, _}` branch suddenly looked unreachable. The fix was to widen the spec
  to match reality. Accurate types turning a vague function into a tripwire is the
  whole point.

- **A latent 500.** Typing the receipt-message context surfaced a real bug in its
  API controller: it called `get_receipt_message!/1` — the bang version that
  *raises* on a missing row — and then pattern-matched a `nil ->` branch to return
  a 404. That branch was dead. A request for a missing id crashed with a 500
  instead of returning the 404 the author clearly intended. The fix was to add a
  non-raising `get_receipt_message/1` and point the controller at it.

The MapSet opaque-type problem also resurfaced when the writers tried
`MapSet.t(scenario_id())` and `MapSet.t()` in specs; the resolution stayed the
same as before — narrow ignore rules, because the code is correct and Dialyzer's
opaqueness checker simply can't see through it.

By the end, every domain subsystem and every standalone top-level context module
carried types, all verified against a green Assay run. The two bugs the pass
turned up — a feature that crashed on every call, and an endpoint that 500'd
instead of 404'ing — are the kind of thing that hides for years in code that
"works." Making the types honest is what dragged them into the light.

What's left for the typing story is the web layer (`lib/blog_web`), where most
functions are framework callbacks with fixed shapes and `@spec` buys little. The
more valuable next move is Phase 4: fix the broken test harness so the suite runs
again, then build coverage before reshaping any of the pages.

## Phase 4: getting the test suite to run at all

The suite didn't run. Not "some tests failed" — it wouldn't *compile*, so zero
tests executed. One file aborted the whole thing: `index_test.exs` used a
`BlogWeb.LiveCase` that didn't exist and `:meck`, which wasn't a dependency. Fix
that and the next file aborts, and the next. The tests had rotted while the code
moved on, and because compilation is all-or-nothing, a single stale file hid the
state of everything behind it.

First the harness: a `BlogWeb.LiveCase` (the usual ConnCase plus
`Phoenix.LiveViewTest`) and `{:meck, "~> 1.0", only: :test}`. Then `index_test.exs`
itself turned out to be testing a UI that no longer exists — it expected a simple
post list at `/` with tag-filtering and post-click events, but `/` is the terminal
now and the post index lives at `/blog` as a much richer page. So it got rewritten
against the real `/blog`: mock `Post.all/0`, assert the posts render, sorted,
tagged, linked. (`:meck` mocks globally, so that test has to be `async: false`,
and the mock needs `:no_link` or it dies with the test process before `on_exit`
can unload it.)

A scan of all 38 test files turned up eight broken ones, so the repairs fanned
out — one agent per file, edit-only, fixing each test against the current code,
with a reviewer per file. The rot was the expected kind: a removed `:win` field
on the Wordle game (a win is now `game_over` plus a message), renamed helpers
(`color_class`, `keyboard_color_class`), a changed `GameStore` arity, a Presence
table the test never started. The agents were told to adapt the tests to the code,
never the reverse — if a test exposed a real bug, flag it, don't "fix" the app to
match a stale expectation.

Central verification did the judging. One agent declined to touch the Blackjack
test because it couldn't reproduce the failure it was handed — correctly, as it
turned out, since that file's one real failure is a behavior assertion that belongs
to the broader cleanup, not the compile unblock. Another over-asserted: it pinned
a message-limit test to `hd(limited).content == "Message 1"`, but twenty-five
inserts in a tight loop share `inserted_at` timestamps, so the `order_by` tie is
non-deterministic. The contract under test is the *cap*, not the slice, so the
assertion became `length == 10`.

The result: from zero tests running to **571 executing**, with the harness and the
eight rotted files green. That's the unblock. It also exposed how much had drifted
— there's a tail of pre-existing *runtime* failures (a LiveView whose `handle_info`
no longer matches, a background firehose GenServer that connects to real Bluesky
during tests and crashes) that compilation had been hiding. Those are the next
thread: now that the suite runs, the failures are finally visible enough to fix.

_(continued as the work lands)_
