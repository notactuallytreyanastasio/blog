# 2026-10-01: a library may have a `main`

Entry 32 ended on a collision. ormery exports a function called `main`, and
be-elixir named its own entry point `main/0`, so the module had two:

```
warning: clauses with the same name and arity ... "def main/0" was previously defined
```

In Elixir the first clause wins, and the library's came first. Running the
program called the library's `main` though nothing asked for it, and never
reached the entry point's `TemperCore.Async.drain()`. Four lines show it:

```temper
console.log("top level ran");
export let main(): Void { console.log("user main ran"); }
```

```
$ mix run --no-compile -e 'Temper.Mainclash.main()'
top level ran
user main ran
```

`main` is the most likely name for a library to export, and js never calls
it. So the entry point moves out of its way, into the names the backend
already keeps for itself next to `__temper_init__` and `__temper_tests__`:

```
$ mix run --no-compile -e 'Temper.Mainclash.__temper_main__()'
top level ran
$ mix run --no-compile -e 'Temper.Mainclash.main()'
top level ran
user main ran
```

The program runs its top level and drains its queue; the library's own
`main` is still there for Elixir code to call, and it initializes the
library first, as every exported function has since entry 24.

The other way round, renaming the library's function when it is called
`main`, would have kept the command for running a program. It would have
broken the one thing a library's `main` is for: being called by that name.

## What changed

One constant, `ElixirBackend.MAIN_FUNCTION`, which the harness in
`ElixirSpecifics` reads too, so `temper run`, `temper test` and the
functional suite moved with it. The command in section 1 of the guide is
now `mix run --no-compile -e "Temper.MyLib.__temper_main__()"`. Marginalia
is unaffected: it calls exported functions such as
`Temper.MarginaliaCore.diff/2`, which have initialized the library
themselves since entry 24.

## Checking

A sixth `ElixirBackendTest` case, red first: a library exporting `main`
has exactly one `def main(` and a `def __temper_main__(`. The four-line
library compiles with no warnings. ormery's duplicate-clause warning is
gone; it still has a `main/0` of its own, which is now just a function.
alloy 225/225, prismora 12/12, templight 140/140, blimp-highlight 11/11 and
temper_snake 31/31 are unchanged and compile without a warning.

65 of 65 functional tests pass.
