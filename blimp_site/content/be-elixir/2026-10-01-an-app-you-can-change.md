# 2026-10-01: an app you can change

A Temper build that fails still writes its Elixir. Give textkit's `stats` a
string where an `Int` belongs and `temper build -b elixir` exits 1, prints
the diagnostic, and leaves this in `temper.out`:

```
exit=1
[-work/textkit/src/stats.temper.md:31+46-52]@G: Expected subtype of Int32, but got String
Build failed
185:      Temper.Textkit.Stats.new(words, sentences, characters, "slow")
```

That file compiles, and runs:

```
$ mix compile && mix run --no-compile -e 'IO.inspect Temper.Textkit.stats("one two three")'
Generated temper_textkit app
%Temper.Textkit.Stats{
  words: 3,
  sentences: 0,
  characters: 13,
  readingSeconds: "slow"
}
```

So the obvious way to keep a Phoenix app in step with its Temper, building
into the directory the app depends on and letting Phoenix reload it, puts
code Temper rejected into a running page, which would then say "slow s to
read". The example repo built in this chapter does it the other way round.

## The repo

[temper-elixir-example](https://github.com/notactuallytreyanastasio/temper-elixir-example)
is a small Phoenix LiveView app. You type two drafts and it shows the word
diff between them, with counts for each. The diff and the counts are
`textkit`, two literate Temper files in `temper/textkit/`, generated into
`Temper.Textkit`. Marginalia (entry 26) showed be-elixir inside an app that
existed first. This one is meant to be cloned and edited. Everything runs in
Docker, and the host needs Docker and `make`.

It is two commits:
[65a2e66](https://github.com/notactuallytreyanastasio/temper-elixir-example/commit/65a2e66fefa08d5a05d737db463d11166668edb7),
the app, and
[928262c](https://github.com/notactuallytreyanastasio/temper-elixir-example/commit/928262c53ec1c6b8ac0c29ca9b7bd5b9960a6590),
a fix that only a fresh clone exposed.

## From a `.temper.md` to the page

An edit passes through four steps, and each one needs its own piece of
configuration.

`bin/temper-watch`, the `temper` service, hashes the mtime and size of every
`*.temper.md`, `*.temper` and `_connected.ex` under `temper/` once a second.
It polls because file events from a macOS host do not reliably reach a
container.

`bin/temper-gen` copies each library into a `mktemp -d` directory and builds
it there. `temper/out` is replaced only when the build succeeds:

```sh
if ! (cd "$work" && temper build -b elixir -w . > build.log 2>&1) || grep -q ']@[A-Z]:' "$work/build.log"; then
  grep -v '^[[:space:]]*at ' "$work/build.log" | grep -v '^##' >&2
  echo "temper-gen: the build failed; temper/out keeps the last good build" >&2
  exit 1
fi
...
rm -rf temper/out
mv temper/out.new temper/out
```

The scratch copy is there because of the output shown at the top. The
`grep` for a diagnostic is a second guard, in case a build prints one and
exits 0. I could not make it fire: a type error, an assignment of the wrong
type, a missing member and a call to an undefined function each exited 1
under the pinned CLI.

The app depends on the result as a path dependency,
`{:temper_textkit, path: "../temper/out/textkit"}`. Phoenix's code reloader
recompiles only the project's own app unless told otherwise, so
`config/dev.exs` names the dependency:

```elixir
reloadable_apps: [:draft, :temper_textkit],
```

and `config/runtime.exs` points live reload, which also polls, at the
generated files:

```elixir
dirs: ["", "../temper/out"],
patterns: [
  ~r"temper/out/textkit/lib/.*\.ex$",
```

The first makes the new code load on the next request, and the second
makes the browser send one. I did not try removing either. The commit
records the whole chain working once:

> Changing the reading speed in stats.temper.md: rebuilt in about 6 s,
> and the page's reading time went from 3 s to 13 s.

I did not run `make up` again for this entry. The two edits the README
suggests do what it says, though. Here they are against the generated
library, with the default draft and the hyphen example:

```
# words * 60 / 238, as committed
%Temper.Textkit.Stats{words: 13, sentences: 2, characters: 63, readingSeconds: 3}
[%Temper.Textkit.Piece{kind: "removed", text: "state-of-the-art"},
 %Temper.Textkit.Piece{kind: "added", text: "state-of-the-science"}]

# words * 60 / 60, and isSpace also accepting 45
readingSeconds: 13
[%Temper.Textkit.Piece{kind: "same", text: "state-of-the-"},
 %Temper.Textkit.Piece{kind: "removed", text: "art"},
 %Temper.Textkit.Piece{kind: "added", text: "science"}]
```

The README calls 3 to 13 "four times longer". The division is integer
division in Temper, and so in Elixir (`div(TemperCore.int32(words * 60),
238)`), which is why a 3.97 ratio shows up as 4.3.

The LiveView uses the generated code like any other library. A Temper
`List` is `Enumerable`, and an `@imu` class is a struct, so the template
reads `piece.kind` and `@stats.readingSeconds` directly. The field keeps its
Temper name, camelCase included.

## What broke

**A fresh clone has no `temper/out`.** Unlike Marginalia, this repo does
not commit the generated code. `.gitignore` lists `/temper/out/`, because
the point is to watch it change. `make up` handles that: the `web` service
waits for the directory before it starts.

```yaml
command: >
  sh -c "until [ -d ../temper/out/textkit ]; do echo 'web: waiting for temper/out'; sleep 2; done;
         mix deps.get && mix phx.server"
```

`make test` replaced that command with its own. `depends_on` started the
watcher, but nothing waited for its first build, so `mix test` ran against
a path dependency that did not exist. 928262c generates first, and stops
`make test` starting the watcher at all:

```diff
 	$(COMPOSE) run --rm --no-deps temper sh -c 'cd temper && temper test -b elixir -w .'
-	$(COMPOSE) run --rm web sh -c 'mix deps.get >/dev/null && mix test'
+	$(COMPOSE) run --rm --no-deps temper bin/temper-gen
+	$(COMPOSE) run --rm --no-deps web sh -c 'mix deps.get >/dev/null && mix test'
```

The commit says it was checked from a fresh clone, with 5 Temper tests and
5 ExUnit tests passing.

**Colima mounts only your home directory, and it fails silently.** The same
commit adds a line to the README: clone under `~`. Here is the failure, with
a directory in this session's scratchpad under `/private/tmp`, which holds
files:

```
$ docker run --rm -v $W:/work alpine ls -la /work
total 8
drwxr-xr-x    2 root     root          4096 Oct  2 03:57 .
drwxr-xr-x    1 root     root          4096 Oct  2 03:57 ..
```

There is no error, only an empty directory, so the first sign of trouble is
that `bin/temper-watch` cannot be found.

**Temper's Gradle build wants Python and Node to build only the CLI.** The
Dockerfile installs `python3 python3-venv nodejs npm` into the JDK stage
because Gradle configures the other backends even for `:cli:installDist`.
The README asks for 6 to 8 GB for Docker, since Gradle wants a 4 GB heap.
The README puts the first `make up`, which builds the toolchain, at about
ten minutes.

## What is pinned

```dockerfile
ARG TEMPER_REPO=https://github.com/notactuallytreyanastasio/temper.git
# the fork's main: be-elixir, typespecs checked by Dialyzer, the review's fixes
ARG TEMPER_REF=94efe3e041321a6858bc33d51367de8fa2fd99c4
```

The CLI is built from a commit, not a branch, so a clone made next month
generates the same Elixir as one made today. When the example was pushed
(02:36 UTC), `94efe3e0` was the fork's main:
[#5](https://github.com/notactuallytreyanastasio/temper/pull/5) and
[#7](https://github.com/notactuallytreyanastasio/temper/pull/7). At 03:56
UTC [#8](https://github.com/notactuallytreyanastasio/temper/pull/8),
[#9](https://github.com/notactuallytreyanastasio/temper/pull/9),
[#10](https://github.com/notactuallytreyanastasio/temper/pull/10) and
[#11](https://github.com/notactuallytreyanastasio/temper/pull/11) were
merged, and main is now `ee05521d`. So the Dockerfile's comment is out of
date, and the pin is four PRs behind. Building textkit with both and
diffing shows what moving the pin would change:

```diff
-  def isSpace(c) do
+  defp isSpace(c) do
...
+  @doc """
+  Counts for one draft.
+  """
...
-          if not Temper.Textkit.isSpace(TemperCore.String.get(t1, TemperCore.String.begin())) do
+          if not isSpace(TemperCore.String.get(t1, TemperCore.String.begin())) do
...
-  def merged(pieces) do
+  defp merged(pieces) do
```

Under the pin, the app could call `Temper.Textkit.isSpace(32)` and get
`true`, even though textkit never exported it. At main, `function_exported?`
says `false`. The app only calls `diff/2` and `stats/1`, and textkit's
tests pass at main (`5 tests, 0 failures`), so moving the pin is a
one-line change. It has not been made.

The rest of the toolchain is pinned by image tag: `eclipse-temurin:21-jdk`
to build the CLI and `elixir:1.18` to run it, which gives Elixir 1.18.4 on
OTP 28. The guide says be-elixir was developed on 1.19.5 and is untested
below 1.19. This app and textkit's tests are a 1.18 run. The Phoenix
versions are whatever `mix.lock` holds.

## Tests, and what a test of constants reaches

`textkit_test.temper.md` puts each check inside a helper that takes the
`test`. The README explains why: "a test made only of constants is evaluated
by the Temper compiler, not by the generated code". The guide says the same
in section 12. In textkit's case it turns out not to matter, and the reason
is worth knowing. `journal/examples/folding/` checks four calls:

```
    TemperCore.Test.assert(test, true, fn_1)                     # isSpace(32)
    TemperCore.Test.assert(test, true, fn_2)                     # sumTo(4) == 6
    actual1 = Temper.Folding.P.get_n(Temper.Folding.mk(3))       # mk(3).n == 3
    actual2 = TemperCore.List.length(Temper.Folding.cut("abc"))  # cut("abc").length == 1
```

The frontend evaluates a call with constant arguments, exported or not and
loops included, until the call makes an object. A class instance or a
`List` stops it. `stats` returns a `Stats` and `diff` a `List<Piece>`, so a
bare `assert(stats("One two. Three? Four!").words == 4)` does reach
Elixir. I added one to textkit and the generated test calls
`Temper.Textkit.stats/1`. A check of `isSpace` would not reach Elixir. From
the test's side you cannot see where that line falls, so the helper is still
the right habit.

textkit passes its tests on all three backends, with the CLI at the fork's
main:

```
== elixir
Tests passed: 5 of 5
== js
Tests passed: 5 of 5
== py
Tests passed: 5 of 5
```

## What it does not do

- It does not deploy. `config/prod.exs` and `runtime.exs` are Phoenix's
  defaults, and no release is built. For that, Marginalia's
  commit-the-output shape (guide section 16) is the one to copy.
- The watcher rebuilds every library under `temper/` on any change. With
  one small library that takes about 6 s, by the commit's measure.
- `make up` was not re-run for this entry. The reload chain is quoted from
  the commit, and the generated behaviour above was reproduced outside
  Docker. The failed-build output was reproduced with the pinned CLI, inside
  the image.

`journal/probes/13_failed_build_writes.sh` reproduces the top of this
entry against any `temper`:

```
exit=1
[-work/probe/src/main.temper.md:6+23-29]@G: Expected subtype of Int32, but got String
31:      Temper.Probe.Stats.new(words, "slow")
```
