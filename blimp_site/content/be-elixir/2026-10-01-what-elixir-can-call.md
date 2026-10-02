# 2026-10-01: what Elixir can call

Until this chapter every function in a generated library was a public
`def`, exported in Temper or not. Marginalia's generated module had 146
`def` and no `defp`, against about ten real entry points. The problem
was not only that it looked untidy. A non-exported function has no
`__temper_init__()` call at the top, because only exported functions get
one, so an Elixir caller that reaches it first runs it before the
library's module values exist:

```temper
let names = ["a", "b", "c"];
let pick(i: Int): String { names[i] }
export class Picker(public i: Int) {
  public get(): String { pick(i) }
}
```

```
$ mix run -e 'IO.inspect(Temper.Early.Picker.get(Temper.Early.Picker.new(1)))'
"b"
$ mix run -e 'IO.inspect(Temper.Early.pick(1))'
** (ArgumentError) module-level :"Temper.Early.names" read before it was set
    (temper_core 0.1.0) lib/temper_core.ex:303: TemperCore.Global.get/1
    (temper_early 0.1.0) lib/temper_main.ex:29: Temper.Early.pick/1
```

That output is from today's build, after the change, and `pick` is
still `def`. Most of this chapter is about why it has to be.

[fork #9](https://github.com/notactuallytreyanastasio/temper/pull/9)
([513a7fdd](https://github.com/notactuallytreyanastasio/temper/commit/513a7fddd6d17e3d007b4903ae310cd2f8d05868))
makes a function `defp` when Temper does not export it and nothing
outside the root module calls it.
[fork #10](https://github.com/notactuallytreyanastasio/temper/pull/10)
([0d43bf11](https://github.com/notactuallytreyanastasio/temper/commit/0d43bf11406ed385953c8415be401acbf4777fcd))
turns Temper doc comments into `@doc` and `@moduledoc`. Both are stacked
on #8. They were open when this was written and merged on 2026-10-02.

## Three helpers, three outcomes

`journal/examples/shelf/` is a small library with three non-exported
helpers:

```temper
/** Clamps a count to zero or more. */
let clamp(n: Int): Int { if (n < 0) { 0 } else { n } }

let label(n: Int): String { "#${n.toString()}" }

export class Shelf(public books: Int) {
  /** The shelf with [k] more books, never fewer than none. */
  public add(k: Int): Shelf { new Shelf(clamp(books + k)) }
  public describe(): String { label(books) }
}

/** A shelf of [n] books, or of none if [n] is negative. */
export let shelfOf(n: Int): Shelf { new Shelf(clamp(n)) }

/** Rounds down to a multiple of ten. */
let tens(n: Int): Int { n - n % 10 }

/** A shelf of [n] books, rounded down to tens. */
export let shelfOfTens(n: Int): Shelf { new Shelf(tens(clamp(n))) }
```

`temper build -b elixir` gives, in the root module:

```elixir
defmodule Temper.Shelf do
  require TemperCore.Heap
  @doc false
  @spec clamp(integer()) :: integer()
  def clamp(n) do
  ...
  @doc false
  @spec label(integer()) :: String.t()
  def label(n) do
    "\#" <> TemperCore.int_to_string(n)
  end
  ...
  @spec tens(integer()) :: integer()
  defp tens(n) do
    TemperCore.int32(n - rem(n, 10))
  end
  @doc """
  A shelf of [n] books, rounded down to tens.
  """
  @spec shelfOfTens(integer()) :: Temper.Shelf.Shelf.t()
  def shelfOfTens(n) do
    Temper.Shelf.__temper_init__()
    TemperCore.Heap.entry(fn ->
      Temper.Shelf.Shelf.new(tens(Temper.Shelf.clamp(n)))
    end)
  end
```

Only `tens` became private. `clamp` and `label` are called from
`Shelf.add` and `Shelf.describe`, and those live in
`Temper.Shelf.Shelf`, a different module. A call from there is a remote
call, `Temper.Shelf.clamp(...)`, and a remote call cannot reach a `defp`.
The same is true of the test side, which is its own module,
`Temper.Shelf.Tests`. So the obvious version, "`defp` everything Temper
doesn't export", does not compile for any library whose classes use its
helpers, and that is most of them.

The rule the backend uses is narrower. Its placement pass already worked
out what is test-only and what is unused. Now it also walks every class
declaration, every test, and everything only tests reach, and collects
every name they mention. A non-exported module function that is in
production and is not on that list is `defp`. Calls to it from the root
module become local calls (`tens(...)`), and captures become
`&tens/1`. Every other module function call stays qualified, so a call
from a class module still works and a name never runs into a Kernel
import. A function a class or a test does name stays `def` under
`@doc false`, which means callable but not API:

```
shelfOfTens(37): 30
%UndefinedFunctionError{
  module: Temper.Shelf,
  function: :tens,
  arity: 1,
  reason: nil,
  message: nil
}
```

(`Temper.Shelf.Shelf.get_books(Temper.Shelf.shelfOfTens(37))`, then
`Temper.Shelf.tens(37)` under `rescue`.)

The commit counts the result on the libraries at hand:

```
orm   def 318 defp 2   (291 in class modules; of the root module's 27, 5 are helpers its classes call, @doc false)
std   def 366 defp 16
templight        def 4   defp 14
blimp-highlight  def 12  defp 16
```

The orm line was rewritten twice before it was pushed. The first
version said "316 of the 318 are class members, init or API", and the
second said "mostly class methods". Both amends changed only the
message; the code was the same in all three. The breakdown that ended up
in the commit is the one that adds up: 291 in class modules and 27 in
the root module, 5 of those 27 being helpers kept public for the classes.
In orm, `defp` hardly applies, because nearly all of its code lives in
classes.

The `std` count reproduces on today's build: generating a library that
imports `std/temporal` produces a `std` with 366 `def` and 16 `defp`.

## Unused, because the caller was rejected

The first version gave temper_snake's game, server and client modules
new warnings:

```
function fn_/0 is unused
function parseInput/1 is unused
```

The frontend's tree does reach those functions, but only from top-level
code the frontend rejected. They use Blimp-only builtins such as
`readLine` and `wsConnect`, and the backend turns rejected code into a
broken-code `raise`. Then the tidy pass ends a block at its
first raise, because Elixir would reject a later read of the binding the
raise was supposed to produce. So the call that made the function
reachable is gone from the output. In Temper the function is used, but
the Elixir has no call to it.

This reproduces in a few lines:

```temper
let parseInput(s: String): Boolean { s == "y" }

export let ok(): Int { 1 }

readLine();
for (var i = 0; i < ok(); ++i) {
  console.log(parseInput(i.toString()).toString());
}
```

```elixir
def __temper_init__() do
  TemperCore.init_once(:"Temper.Broken", fn ->
    raise(TemperCore.Panic, "broken code: readLine not available from core")
  end)
end
```

With `parseInput` as `defp`, edited by hand to show the first version's
output:

```
    warning: function parseInput/1 is unused
    │
  4 │   defp parseInput(s) do
    │        ~
    │
    └─ lib/temper_main.ex:4:8: Temper.Broken (module)
```

The placement pass can't fix this, because it runs on the frontend's
tree, before tidy has removed anything. The fix is a second pass,
`publishUncalled`, which runs on the root module after tidy. It starts
from everything public, follows calls and captures through private
functions, and turns each private function it never reaches back into a
`def`, putting `@doc false` in front of its `@spec`. The generated
module now has

```elixir
@doc false
@spec parseInput(String.t()) :: boolean()
def parseInput(s) do
```

and compiles with no warnings. It is the only way the backend can know
which calls survived. A function nothing calls stays public because
public functions are never reported unused.

`onlyExportedFunctionsArePublic` pins the rule: `helper` is `defp` and
called as `helper(x)`, and `shared`, which a method calls, is `def` after
`@doc false`. The typespec test's regex had matched only `def`, so it now
matches `defp?`: a private function still has its `@spec`.

## A doc comment is the `@doc`

be-py already turned Temper doc comments into docstrings. be-elixir
dropped them, so `h Temper.Std.Date` showed nothing. Now an exported
function's doc comment becomes its `@doc`, a class's becomes its
`@moduledoc`, and a member's becomes its `@doc`, placed before the
`@spec` the way hand-written Elixir places it. From the shelf:

```
$ mix run -e 'IEx.Helpers.h(Temper.Shelf.shelfOf); IEx.Helpers.h(Temper.Shelf.clamp); IEx.Helpers.h(Temper.Shelf.Shelf)'
                                 def shelfOf(n)

  @spec shelfOf(integer()) :: Temper.Shelf.Shelf.t()

A shelf of [n] books, or of none if [n] is negative.

No documentation for Temper.Shelf.clamp was found

                               Temper.Shelf.Shelf

A shelf holds a number of books.

Use `"""` sparingly, and `\n` and `#{x}` mean nothing here.
```

The obvious way to emit a doc is to put the comment's text inside
`"""`, and in three cases the output would then mean something other
than the comment. `#{x}` is interpolation: unescaped, the module does
not compile (`error: undefined variable "x"`). `\n` becomes a newline.
And a line that starts with `"""` ends the heredoc early (`missing
terminator`). A `"""` in the middle of a line is actually harmless, but
the backend escapes every `"""`, which is simpler and costs nothing. The
class doc above shows all three:

```elixir
defmodule Temper.Shelf.Shelf do
  @moduledoc """
  A shelf holds a number of books.

  Use `\"""` sparingly, and `\\n` and `\#{x}` mean nothing here.
  """
```

A heredoc is a new leaf in the output grammar, `Heredoc(value)`, and it
renders its text through `elixirHeredocText`. It has to be its own leaf
because the existing `StringLit` writes one line with `\n` escapes, and
a doc written that way is unreadable in the source. Indentation is the
other half of the problem. Elixir strips the closing `"""`'s indentation
from every line, so the backend indents the text and the closing
delimiter two spaces to match the module's items, and the doc reads back
as written. Blank lines get no indentation at all. A text line indented
less than the delimiter is not an error, only a warning (`outdented
heredoc line`), so a mistake here would have passed every test that
didn't compile with warnings as errors. `journal/probes/12_doc_attributes.exs`
checks each of these against Elixir 1.18.4:

```
doc on defp warns: true
indent stripped: "First line.\n\nSecond paragraph.\n"
outdented line warns: true
escaped: "Use `\"\"\"` sparingly, and `\\n` and `\#{x}` mean nothing here.\n"
@doc false: :hidden, P5.helper(1) = 2
```

Chapter #9 left three kinds of function, and #10 gives each one a
different `@doc`:

- **Exported:** the doc comment, or nothing if there isn't one (`total`
  above reads back as `:none`).
- **Private (`defp`):** none. Elixir discards a `@doc` on a private
  function and warns about it, `defp helper/1 is private, @doc attribute
  is always discarded`, and the backend's rule is no warnings. So
  `tens`'s "Rounds down to a multiple of ten." doesn't appear anywhere in
  the output.
- **Public but not exported:** `@doc false`, and its doc comment is
  dropped too. `clamp` has one, "Clamps a count to zero or more.", and
  `h` says "No documentation ... was found", which is right, because
  `clamp` is not API.

On std this adds 23 `@doc` and 5 `@moduledoc`, and both counts reproduce
on today's build. `Code.fetch_docs(Temper.Std.Date)` gives the class doc
back exactly: `"A Date identifies a day in the proleptic Gregorian
calendar.\nIt is unconnected to a time of day or a timezone.\n"`.

Generating std's docs also published a mistake in std. Its own comment on
`Date.dayOfWeek` gets day 3 wrong, and now `h` shows it:

```elixir
  @doc """
  ISO 8601 weekday number.

  | Number | Weekday  |
  | ------ | -------- |
  |      1 | Monday   |
  |      2 | Tuesday  |
  |      3 | Monday   |
  |      4 | Thursday |
```

ISO 8601's day 3 is Wednesday. The mistake is in
`frontend/src/commonMain/resources/std/temporal/temporal.temper.md`, line
214, not in the backend, and the backend copies it as written. This
chapter does not change it.

## What does not work

- **`@doc false` is not private.** `clamp`, `label` and `pick` are still
  callable from Elixir, and they still skip init, as the `pick` crash at
  the top shows. All that `@doc false` does is keep them out of `h` and
  ExDoc. An init call in each of them would close it, at the
  per-call price section 16 of the guide warns about for helpers. That
  has not been done.
- **Property docs are dropped.** In `export class Box(/** How many
  things are in it. */ public n: Int)`, and on a `public var` with a doc
  comment, `get_n`, `get_tag` and `set_tag` get no `@doc`. A computed
  getter's doc (`public get twice()`) and a static method's
  (`static empty()`) do come through. Constructors (`new`) get no doc.
  An exported module value, `/** The answer. */ export let answer = 42`,
  is a `TemperCore.Global` key, not a function, so its doc has nowhere
  to go.
- **Temper's doc syntax is not ExDoc's.** The text is copied as
  written: `[n]` in the shelf's comments, meant as a reference to the
  parameter, is plain brackets to ExDoc.
  std's `Capture` doc links `(#groups)`, an anchor in std's source that
  doesn't exist in ExDoc's output.

be-elixir after #10: 19 backend, 64 functional, 13 grammar, 1
support-code and 3 typespec tests; ktlint and detekt are clean. Every
library on hand compiles with 0 warnings and passes its tests, with spec
warnings 0 and Dialyzer's totals unchanged (from the commit messages).
The shelf, `broken` and `early` probes above compile with 0 warnings
on today's build.
