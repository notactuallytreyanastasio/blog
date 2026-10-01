# 2026-10-01: std was there all along

The `Date`, `NetRequest`, `instanceof JsonArray` and regex failures looked
like four missing features. They had one cause. Building a program that
imports `std/json` produced this:

```
temper.out/elixir/std/mix.exs
temper.out/elixir/std/lib/temper_main.ex        4,149 lines
temper.out/elixir/stdjson/mix.exs
temper.out/elixir/stdjson/lib/temper_main.ex
```

std had been translated the whole time, as its own Mix project. Nothing
had ever compiled it. When I did, it compiled cleanly, apart from one
unused-variable warning. Linking it in was a different matter:

- both projects defined `TemperMain`
- the user's `mix.exs` depended only on temper-core
- an imported function came out as `parseJson.("[1, 2]")`, a call through
  an unbound variable

So the backend was translating libraries correctly and never linking them.
The first entry's "not done" list had a line for this: "every library is
`TemperMain`".

## A library is a root module

Each library now lives under `Temper.<Name>`. std becomes `Temper.Std`,
and `my-lib` becomes `Temper.MyLib`. The `Temper.` prefix means no
library can be named into Elixir's own `String` or `Enum`. Its app is
`:temper_<name>`, and its `mix.exs` depends on every library it imports
from:

```elixir
defp deps do
  [{:temper_core, path: "../temper-core"}, {:temper_std, path: "../std"}]
end
```

The program from above now compiles to:

```elixir
defmodule Temper.Stdjson do
  def __temper_init__() do
    TemperCore.init_once(:"Temper.Stdjson", fn ->
      Temper.Std.__temper_init__()
      TemperCore.Global.put(:"Temper.Stdjson.t__3", Temper.Std.parseJson("[1, 2]"))
      IO.puts("array? " <> Atom.to_string(TemperCore.is_a(TemperCore.Global.get(:"Temper.Stdjson.t__3"), Temper.Std.JsonArray)))
      nil
    end)
  end
  def main() do
    Temper.Stdjson.__temper_init__()
    TemperCore.Async.drain()
  end
end
```

It prints `array? true`. That value came from std's own JSON parser and
std's own type check.

The details, each of which turned out to matter:

- **A library's top levels run once.** They run inside
  `__temper_init__/0`, which first initializes the libraries it depends on.
  `TemperCore.init_once` records a key in the process dictionary, so a
  library that two others depend on is not initialized twice. `main/0` is
  init followed by draining the async queue.
- **Globals are keyed by library.** It used to be `:hexDigits__386`; it is
  now `:"Temper.Std.hexDigits__386"`. Two libraries share one process
  dictionary, and their generated names could collide.
- **An exported name is the same text in both libraries.** Exported names
  are rendered from their display name, so the importing side can name
  `Temper.Std.parseJson` without asking std's translation. An import's
  signature gives the arity for `&Temper.Std.parseJson/1`.
- **Types are traced to their library, not their import.** A function can
  return a std type the user never imported. So the backend maps each
  other library's root directory (taken from the imports'
  `CrossLibraryPath`) to its name, and finds a type's library from where
  its definition lives. A type from std is `Temper.Std.JsonArray`, and its
  methods dispatch dynamically. A Temper builtin still needs support code
  or fails the build. Before this, a std type looked like a builtin, which
  is why `instanceof JsonArray` was a TODO.
- **std's modules list no dependencies**, so `module.deps` alone gave an
  empty `mix.exs`. The libraries an import crosses into count as well.

## std's placeholders now say which one

The next failure was `** (TemperCore.Panic) panic`, raised inside std.
std declares some members `@connected` with no body:

```temper
@connected
public static regexCompileFormatted(data: RegexNode, formatted: String): AnyValue;
```

Every backend has to supply those itself. The frontend gives such a member
a body that only calls `pureVirtual()`, which is the same body an abstract
method gets. I first looked for a `panic()` there and found nothing; a
debug print showed the `pureVirtual` support code. I can't make the build
fail, because then every program that imports any part of std would fail
over regex. Instead, while translating std, a connected member whose body
is that placeholder and that has no Elixir support code now raises with
its key:

```
** (TemperCore.Panic) no Elixir support code for std/regex.type RegexFormatter.regexCompileFormatted()
```

Seven members of std are like this: six for regex, and `Date.today()`.
`Date.today()` is now `TemperCore.Temporal.today(Temper.Std.Date)`, which
reads `Date.utc_today()` and builds the date through std's own `Date`
constructor, so std's validation still runs.

## A type as a value

`ClassesAngleCall` returns `Void` from a function typed `Type`. be-java
gives a class literal for a type value, and be-js gives the type's name as
a string. Here a translated class is its module, whether from this library
or another, and a builtin type is an atom of its name, `:Void`.

**62 of 65** pass, up from 58: `ClassesAngleCall`, `TypesDate`,
`TypesJsonSyntaxTree`, `TypesNetresponse`.

**Not done:**

- Regex. The six std members above need the BEAM's regex engine.
- `SemanticsBroken`. Its input is code the frontend has already rejected,
  and it arrives as `<garbage "Cannot export non-parsed name!">`.
- Interop between libraries is checked only against std. Two user
  libraries importing each other have not been tried.
