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

_(continued as the work lands)_
