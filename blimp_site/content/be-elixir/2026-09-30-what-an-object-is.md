# 2026-09-30: what an object is on the BEAM

The goal: a Temper backend that emits Elixir. `temper build -b elixir` should
produce a Mix project whose tests are Temper's own functional tests, run by
`mix test` on OTP.

## Why this is not starting from zero

This repository already holds a Temper backend for Blimp, `be-blimp`, in a
stack of 110-odd pull requests. Blimp and Elixir share the constraints that
make a Temper backend hard: no `while`, no `break`, no early `return`, no
reassignable locals. `be-blimp` lowers those into tail-recursive functions
and continuations, and it passes 65 of Temper's 67 shared functional tests.
(The repository README still says 18. It is stale.)

So `be-elixir` follows `be-blimp`'s first four chapters: an output grammar,
a backend scaffold, a core library written in the target language, then a
translator that turns `AlgosHelloWorld` green.

Elixir is easier than Blimp in three places: it has modules, so Temper's
module paths have somewhere to go; it has real exceptions, so Temper's
bubbles do too; and maps take any key.

## The decision: an object is a struct, or a reference into a heap

Temper objects are mutable and aliased: two variables can hold the same
object, and a write through one is seen through the other. The BEAM has no
mutable heap objects. Three ways out were on the table:

1. **Every object a process.** A GenServer per object and `GenServer.call`
   per method. The direct analogue of `be-blimp`'s actors, and the most
   "BEAM" answer. It is a message round trip for every field read, and a
   process is only freed when something stops it.
2. **Everything in a heap.** Each object is a `make_ref()` key into a
   per-process table. Simplest translator, uniform semantics, nothing
   idiomatic in the output, and nothing is ever freed.
3. **Struct when it can be, heap reference when it must.** A class with no
   `var` fields and no setters compiles to a `defstruct`: immutable,
   garbage-collected, the Elixir a person would write. Only classes with
   mutable state go to the heap.

Chosen: 3. The cost is named now rather than discovered later: a mutable
object, once made, is never freed. That is the same class of limit as
Blimp's actors, which are never collected either.

Why the obvious version, "just use structs everywhere", is wrong: an
immutable struct copied on write gives every holder its own copy, so this
Temper prints 0 where it must print 1 (a sketch, not yet run through the
Temper compiler; that happens once the backend can build anything):

```temper
let a = new Counter();
let b = a;
b.inc();
console.log(a.n.toString());
```

## What running Elixir said (Elixir 1.19.5, OTP 28)

Every one of these is a script in [probes/](probes/).

- **`#{` in a string literal interpolates.** A Temper string containing
  `#{` must be emitted with `\#{`. `\#` is a valid escape for `#`, so the
  string quoter escapes every `#` rather than looking ahead for `{`.
- **`div` truncates toward zero and `rem` takes the dividend's sign**
  (`div(-7, 2)` is -3, `rem(-7, 2)` is -1), which is Temper's `Int`
  behaviour. `/` is float division (`7 / 2` is 3.5), so Temper's `Int`
  division must never become `/`.
- **Elixir integers have no width.** Temper's `Int` is 32 bits and wraps;
  `2147483647 + 1` in Elixir is 2147483648. Arithmetic will need masking,
  and that is a later chapter's problem, named here so it is not forgotten.
- **`1 < 2 < 3` is `false`, not an error.** It parses as `(1 < 2) < 3`,
  which is `true < 3`, and in Erlang term order an atom is greater than any
  number. A chained comparison is silently wrong, so the grammar marks
  comparison and equality non-associative and parenthesises instead.
- **`not` and unary minus bind tighter than any binary operator.** `not 1
  == 2` raises ArgumentError because it is `(not 1) == 2`, and `-2 ** 2`
  is 4.
- **`++`, `--` and `<>` are right-associative**: `[1] ++ [2] -- [2]` is
  `[1]`.
- **Indentation means nothing to Elixir's parser; newlines do.** A `case`
  arm's body may follow `->` on the next lines, and the next `pattern ->`
  ends it. The formatter can indent for readers without changing meaning.
- `%{m | k => v}` updates an existing key, `%Point{x: 1}` builds a struct,
  `fn a, b -> ... end` takes clause parameters without parentheses, and
  calling it is `f.(a, b)`.

## Chapter 1: the output grammar

`temper/be-elixir/.../elixir.out-grammar` describes the Elixir this backend
will emit, and `kcodegen` turns it into `Elixir.kt`, a tree of node classes
that render themselves. 27 renderings are pinned by `ElixirGrammarTest`, and
[probes/05_grammar_samples.exs](probes/05_grammar_samples.exs) evaluates every
one of them in Elixir with real bindings: 27 of 27 mean what the tree says.

What the first run of the formatter got wrong, and why:

- **It broke the line after every `}`.** Temper's shared formatter assumes
  `}` closes a C-style block. In Elixir it closes a tuple or a map, and the
  break turned `case {a, b} do` into `case {a, b}` / `do`, which Elixir
  rejects. The Elixir hints never break after `}`.
- **`defstruct[:x, :y]`.** Without a space, that is Access syntax on the
  result of calling `defstruct`, not a struct definition.
- **`abs_sum((p.x), (p.y))`.** Valid, but the precedence check treated a
  call's arguments like an operator's operands. Arguments sit inside the
  call's own parentheses, so a postfix node never parenthesises them.
- **I expected `(a < b) == c` and got `a < b == c`.** The formatter was
  right: comparison binds tighter than equality in Elixir, so the
  parentheses say nothing. The case that needs them is `(a < b) < c`,
  and it gets them.

One more thing Elixir does that matters for code generation, from
[probes/06_struct_same_file.exs](probes/06_struct_same_file.exs): a struct
cannot be built by top-level code in the same compilation context that
defines it ("the struct was not yet defined"), but inside a function it is
fine, even in the defining module and even in a later module of the same
file. Generated code keeps top-level code inside functions.

**Not done:** clause bodies after `->` are not indented past their pattern,
because no token marks where a clause ends for the formatter to dedent on.
The output is valid and ugly:

```elixir
f = fn c, d ->
c + d
end
```

**Found on the way, not fixed yet:** running `kcodegen:updateGeneratedCode`
removed the functional test `TypesStringBuild` from the suite's generated
lists. Its source, `types/string/build/build.temper.md`, is not in this
repository at all: the root `.gitignore` has `build/`, which also matches
that test's directory, so it was dropped when Temper was extracted. The
suite still names the test, so it can only fail to load. The three
regenerated files are reverted for now; the fix (re-extract the file, and
anchor the ignore as `/temper/**/build/` or similar so it only matches
Gradle output) belongs with the chapter that first runs the suite.

## Chapter 2: a backend that always says hello

`ElixirBackend` registers as `-b elixir` and, whatever the input, writes a
Mix project that prints `Hello, World!`. That is the backend guide's advice
for a first step: prove the file plumbing and the run path before any real
translation. For a tiny library the output is

```
temper.out/elixir/elixir-hello/mix.exs
temper.out/elixir/elixir-hello/lib/temper_main.ex
```

and `mix compile`, then `mix run --no-compile -e "TemperMain.main()"`,
prints `Hello, World!`.

Why two commands and not `mix run`: on a fresh build `mix run` prints

```
Compiling 1 file (.ex)
Generated temper_main app
Hello, World!
```

all on stdout, and stdout is what a run is judged by. Compiling separately
keeps Mix's chatter out of the program's output; a failed compile is
returned as the result, diagnostics and all.

**Not done:** `temper build` still reports failure for any library that
calls `console.log`, before translation ever starts, because the support
network maps no builtins yet (`Cannot translate value fn getConsole`). The
files are written anyway, which is how the run above was checked. The
runner's path through `temper run` has not been exercised yet for the same
reason.

## Chapter 3: temper-core, written in Elixir

`temper-core` is the runtime the translated code calls into. Blimp cannot
import a second file, so `be-blimp` splices its core into every output.
Elixir can, so this one is a Mix project of its own, laid down at
`temper.out/elixir/temper-core`, and each library's `mix.exs` depends on it
by path:

```elixir
defp deps do
  [{:temper_core, path: "../temper-core"}]
end
```

Why the obvious version, a `temper_core.ex` copied into each library, is
wrong: two libraries would each define `TemperCore`, and a library that
depends on another would not compile.

It holds three things today, and `mix test` in its directory runs 8 tests:

- **`int32/1` and `int64/1`.** Temper's `Int` is 32-bit two's complement
  and wraps; Elixir integers have no width. The wrap is a binary
  round-trip, `<<v::signed-32>> = <<x::32>>`. Every expectation in its
  tests is a line from Temper's own `types/int/limits` functional test:
  `2147483647 + 1` is `-2147483648`, `-2147483648 / -1` is `-2147483648`.
- **`int32_div/2` and `int32_rem/2`.** `div` and `rem` already truncate
  toward zero the way Temper does; these add the wrap and turn division by
  zero into a `TemperCore.Bubble`.
- **`TemperCore.Heap`.** The decision from the first entry, made real. A
  mutable object is a `%TemperCore.Ref{class: ..., id: make_ref()}`, its
  fields live in the process dictionary under that ref, and every alias
  sees every write. A field the object does not have is a `KeyError`,
  never `nil`.

The test that pins the cost: a ref made in one process is not an object in
another. `Task.async` reading it raises `... is not an object in this
process`. That will matter the day Temper's async code is translated, and
the test is there so it cannot be forgotten.

## Chapter 4: AlgosHelloWorld is green

The first functional test passes through real translation. Temper's

```temper
console.log("Hello, World!");
```

becomes

```elixir
defmodule TemperMain do
  def main() do
    IO.puts("Hello, World!")
  end
end
```

Three pieces made that happen:

- **`console.log` is support code.** `core.getConsole()` becomes `nil` and
  `core.type Console.log()` becomes `IO.puts(message)`, dropping the `nil`
  receiver, as in be-blimp. `IO.inspect` would have quoted the string.
- **A Temper module's top-level statements become `main/0`.** Temper runs
  them when the module loads; a Mix project has no load-time code that
  `mix run` executes, so they run in order as the body of the function it
  calls.
- **`ElixirTranslator`** walks the module, and anything it does not know
  is `TODO()` carrying the node. Today it knows literals, calls to inline
  support code, and expression and block statements. That is all
  AlgosHelloWorld needs.

The first functional run failed, and not because of the translation:

```
Unchecked dependencies for environment dev:
* temper_core (../temper-core)
  the dependency is not available
```

`temper build` lays temper-core down beside the library, but the
functional harness only copies what `translate()` returned. be-rust's
functional test copies its core crate in by hand, and so does this one now.

To be sure the green is real, `console.log` was briefly sabotaged to print
"sabotage" instead: the test failed, and passed again once restored.
`temper run -b elixir --library elixir-hello` prints the right thing too,
so the runner's own path is exercised.

**Not done:** every library is `TemperMain` with app `:temper_main`, so
two libraries in one build would collide. The functional suite builds one
library at a time, so this waits until something needs two.
