# 2026-10-01: the backend moves into Temper

The first time upstream's CI built be-elixir, 64 of its 95 tests failed,
every one with the same trace:

```
ElixirFunctionalTest[jvm] > classesSetters()[jvm] FAILED
    java.lang.NullPointerException
        at lang.temper.be.cli.CliEnv.get(CliEnv.kt:70)
        at lang.temper.be.elixir.ElixirSpecificsKt.runMain(ElixirSpecifics.kt:88)
...
95 tests completed, 64 failed
```

GitHub's runner had no Elixir. The description of the PR it was building
had said, about the modules that failed on this machine, "Upstream CI has
the toolchains this machine lacks, so its run is the real check." It had
dotnet, lua and mypy. It did not have `mix`, the one toolchain this
backend needs, and nobody had checked.

Until this chapter be-elixir lived in temper-blimp, under a vendored copy of
Temper at `temper/`. It now lives in a fork of Temper,
[notactuallytreyanastasio/temper](https://github.com/notactuallytreyanastasio/temper),
merged to the fork's `main` by [#5](https://github.com/notactuallytreyanastasio/temper/pull/5)
and proposed upstream as [temperlang/temper#507](https://github.com/temperlang/temper/pull/507).
This entry is what the move took.

## The replay

temper-blimp vendored Temper at upstream `0a0f24a8` (2026-09-16). Each
chapter was applied to a checkout of `0a0f24a8` with `git am`, which
keeps message, author and date: the first chapter is still dated
2026-09-30. The
check is a `diff -r` of the result against temper-blimp's `temper/` at
E41. Reproduced now, against the replay branch:

```
$ git archive origin/elixir-41-kept-on-purpose temper | tar -x -C blimp
$ git archive be-elixir-exact | tar -x -C exact
$ diff -rq blimp/temper exact
Only in exact/cli/src/test/resources: build
Only in exact/docs/for-users/temper-docs/docs: blog
```

The first is a directory of test inputs temper-blimp's `.gitignore`
drops, the second a submodule the vendored copy never had. Nothing else
differs, across 40 commits.

It took two tries. The first replay, at 15:29 local time, had 38 commits: it was
missing E33 and E34 (code nothing reaches, names that stay put), and its
later chapters were numbered two lower. The second, at 17:24, has all
40. One trace of the first try survives: the next commit's message was
written against it, and says "the 38 commits before this one", calls the
rejected-constructor chapter E33 and the kept-on-purpose chapter E39.
They are E35 and E41. #5's description has the right numbers; the commit
message does not, and now that it is signed and pushed it stays that way.

## Two weeks of upstream

Rebased from `0a0f24a8` onto upstream `main` at `e9ff0d25`, the chapters
had one conflict. Upstream had restructured std's regex specials from
classes declared inside `doPure` blocks into top-level classes
(`class DigitSpecial extends SpecialSet {}`), and E24 had put `@imu` on
the old ones. The rebase puts it on the same declarations in their new
places.

Then the backend stopped compiling. [689602b3](https://github.com/notactuallytreyanastasio/temper/commit/689602b3716c24ab639c8d30a0baab5f3658ee61)
is what it took to follow two upstream changes.

**Restless function signatures** ([#498](https://github.com/temperlang/temper/pull/498))
took rest parameters out of TmpL and `Signature2`. be-elixir read
`restInputsType` in five places, and three of them had nothing to do
with rest parameters. `invalidSig`, the signature the frontend gives a
call it could not type-check, used to claim a rest parameter of the
invalid type, and E35 recognized a failed call that way. It now declares
no inputs, so the test became `sig == invalidSig`. The obvious port,
deleting every read of `restInputsType`, would also have deleted the only
way E35 had of telling a failed call from a good one.

**Relational operators as operators** ([#494](https://github.com/temperlang/temper/pull/494))
removed the generic comparisons and most of the per-type ones. Only
`Int` still has `<`, `<=`, `>` and `>=`. For every other type the
frontend writes `a < b` as `(a <=> b) < 0` and `a != b` as `!(a == b)`.
be-elixir's table lost `NeIntInt`, the Float64 and String `Lt/Le/Gt/Ge/Ne`
families and every `*Generic`, and gained `EqLongLong`, `EqBoolBool`,
`CmpLongLong` and `CmpBoolBool`. String searching broke on one new name:

```
method StringIndexOption.eq has no Elixir support code
```

`StringIndexOption.eq` is now a method marked `@operator("==")`.

The lowered form is correct and nobody would write it.
`simplifyPossibleComparison`, the hook #494 added for backends that
want their infix operators back, turns `TemperCore.cmp(a, b) < 0` into
`a < b` where the BEAM's term order is Temper's: Int64, Boolean, String
(UTF-8 binaries compare by code point) and a string index. Float64 keeps
`TemperCore.Float.cmp`, because the BEAM calls `-0.0 == 0.0` and has no
NaN to order. `journal/examples/comparisons` exercises each case, with
every operand read from a `var` so the frontend cannot fold it. Today's
build generates:

```elixir
negZ = TemperCore.Float.neg(TemperCore.Global.get(:"Temper.Cmp.z"))
Atom.to_string(TemperCore.Global.get(:"Temper.Cmp.s") < "abd") <> " " <>
Atom.to_string(TemperCore.Global.get(:"Temper.Cmp.n") <= 4) <> " " <>
Atom.to_string(TemperCore.Global.get(:"Temper.Cmp.t") > false) <> " " <>
Atom.to_string(TemperCore.Float.cmp(negZ, TemperCore.Global.get(:"Temper.Cmp.z")) >= 0) <> ...
```

(one line in the output, broken here). js, py and elixir all print

```
true false true false true false true false
```

The fourth value is `-0.0 >= 0.0`, false in Temper's order. A bare `>=`
on the BEAM would say true.

**#494 also took away a decision's program.** Entry 38 kept `==` on two
`@imu` values comparing their fields, on purpose, where js and py compare
identity. On today's Temper the comparison does not compile on any
backend:

```
Actual arguments do not match signature: (Int32, Int32) -> Boolean
expected [Int32, Int32], but got [V__0, V__0]
```

So there is nothing left to differ on. The function that tried still
builds, as broken code, and its body is the panic:

```elixir
def same(_k) do
  Temper.Cmp.__temper_init__()
  TemperCore.Heap.entry(fn ->
    raise(TemperCore.Panic, "broken code: Operator member infix nym`==` should have been converted to dot-name form")
  end)
end
```

That message is the frontend's internal one, not the type error the user
saw; js throws the same text at run time. The test that pinned field
equality, `imuValuesCompareByTheirFields`, now pins what is still true:
an `@imu` class is a struct, and the rejected `==` is a located panic.
Elixir code that compares two such structs with its own `==` still gets
field equality.

Upstream CI runs `gradlew build`, which includes detekt, and be-elixir
had never been through it: 14 `MagicNumber` and 5 `SpreadOperator`
findings, now named constants and a `List` overload of `elixirModule`.

After 689602b3, by its message: ElixirBackendTest 17/17,
ElixirFunctionalTest 64/64 (65 before; upstream deleted
`functions/rest-formal`), grammar 13/13, temper-core 100 tests, and
alloy, templight, blimp-highlight, temper_snake and the `main` example
all at 0 warnings. prismora no longer compiles anywhere: it compares two
`Space` instances with `==`, and js fails it the same way, 7 of 12.

## Outside be-elixir

A full `gradlew --continue build` on this machine failed in nine
modules. The same tasks on an untouched `e9ff0d25` fail in seven of them,
with the same 279 tests: no dotnet, lua or mypy here, a JDK version
string the harness cannot parse, and one be-cpp test upstream fails too.
The other two were this branch's.
[1526377b](https://github.com/notactuallytreyanastasio/temper/commit/1526377b14049a250c0bf7963e0c91e49e7a01f9)
fixes both: the stage test that came with E12's coroutine fix had goldens
printed before #494 (today the loop test prints as `i__1 <=> 4 < 0`), and
the user docs had no entry for `@actor`, whose KDoc is a builtin snippet.

[dbcad8ab](https://github.com/notactuallytreyanastasio/temper/commit/dbcad8ab787c043eb0a0a5c1cb395f6b60318d64)
copies `journal/guide.md` into the fork as `be-elixir/README.md`, brought
up to today's Temper: no rest parameters, no struct `==` among the
deliberate differences, a paragraph on comparisons, 64 tests, and links
back here for the journal, probes and examples.

## Decisions, not chapters

#5's description does not walk the 43 commits. It is organized around
eleven decisions the gap between Temper and the BEAM forced, from "what
an object is" to "a green suite is where checking starts", each with what
was chosen, what it beat, and why the obvious answer was wrong. The
chapter list is a table at the end. #5 merged into the fork's `main` at
21:35 UTC.

## Upstream

#507 was opened four minutes later from the fork's `main`, and both of
its checks failed.

DCO: "There are 43 commits incorrectly signed off." Temper's repository
checks every commit for a `Signed-off-by` line, and none of the chapters
had one.

build: the NullPointerException at the top of this entry.
`cliEnv[MixCommand]` force-unwraps the lookup of `mix`, so a machine
without Elixir got a trace instead of a reason.
[fe27dde7](https://github.com/notactuallytreyanastasio/temper/commit/fe27dde72fdd6953cbf14c7891efa2daa5495f06)
adds `erlef/setup-beam` (OTP 28, Elixir 1.19) to the workflow before the
Gradle step, and looks `mix` up with `which`. Run now with `mix` off the
path:

```
$ PATH=/usr/bin:/bin temper run -b elixir -w . --library cmp
## exception.msg: be-elixir needs `mix` (Elixir 1.15 or later) on the PATH:
   Command not found; none of [mix] were found in [/usr/bin, /bin]
```

Then every commit was rewritten with a sign-off and the fork's `main`
was force-pushed as a straight line on `e9ff0d25`, without #5's merge
commit. The rewrite changed messages and nothing else:
`897f6597` and `689602b3` differ by one trailer, and the tree at the end
of #5 is the tree under fe27dde7:

```
$ git rev-parse 825a81ef^{tree} 1526377b^{tree}
a6c8b59ac5c6a5cb2c13df47a7793a3844cc55d0
a6c8b59ac5c6a5cb2c13df47a7793a3844cc55d0
```

The next run, at 23:43 UTC, was green: DCO "All commits are signed off!",
and the build passed in 24 minutes on Elixir 1.19.6 and OTP 28. That run
also settles the question #5 left open: the seven modules that failed
here pass on a runner that has their toolchains.

#507 has kept moving since. It now carries #7's typespecs and review
fixes, 53 commits in all. Its one red run after this was a Dialyzer test
that outran JUnit's 30-second default, fixed by
[94efe3e0](https://github.com/notactuallytreyanastasio/temper/commit/94efe3e041321a6858bc33d51367de8fa2fd99c4);
both checks are green on it.

## What does not work

- **Marginalia does not rebuild from #507.** On today's Temper the
  build crashes in the interpreter before any backend runs
  (`IndexOutOfBoundsException ... compatRemoveLast`, on js as well).
  The fix is fork [#6](https://github.com/notactuallytreyanastasio/temper/pull/6),
  still open and not part of #507 when this was written. #5's description
  said Marginalia needed #6; #507's copy of that description dropped the
  sentence. (Since then #6 has merged into the fork's `main` on 2026-10-02 as [b77cfcdf](https://github.com/notactuallytreyanastasio/temper/commit/b77cfcdf06715984a4584e521710260deb9e13a7),
  so #507, whose head is fork `main`, now carries the fix.)
- **A rejected `==` panics with the frontend's internal message**, as
  above.
- **prismora** does not compile on any backend, for the `==` reason.
- **689602b3's message** numbers chapters by the first replay.
