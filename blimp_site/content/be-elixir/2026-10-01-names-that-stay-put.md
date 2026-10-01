# 2026-10-01: names that stay put

Marginalia commits the Elixir it generates. When I added two lines of
Temper to one of its files, the regenerated library's diff ran to about
1,500 lines. Almost all of them were renames:

```
-    ex_loop_227 = fn ex_loop_227, i, newlines ->
+    ex_loop_224 = fn ex_loop_224, i, newlines ->
...
-  def identicalProseIsAllSame(test__635) do
+  def identicalProseIsAllSame(test__641) do
```

Two counters ran across the whole library. The frontend numbers every
name it resolves (`moveRight__489`), and be-elixir numbered its own
temporaries (`ex_loop_227`, `ex_return_130`) from one count per library.
So adding a declaration renumbered every name after it.

Now nothing is numbered across the library:

- **Module-level names are plain.** Module functions, module values and
  tests keep their own names: `moveRight`, `:"Temper.MarginaliaCore.landor"`.
  A name the library declares more than once is numbered within its own
  group, in declaration order: `fn`, `fn__2`. Exported names are claimed
  first, so a private name can never take one.
- **Temporaries count from 0 in each function.** `ex_loop_0` in one
  function cannot meet `ex_loop_0` in another: a loop's closure, a
  `return`'s tag and a `break`'s tag all live and are caught inside the
  function that made them.
- **A test's `test` parameter is a local** like any other parameter. It
  had been missed, which is where `test__635` came from.

The same two-line addition to Marginalia now changes 9 lines, all of
them the new code:

```
>   def addedHelper(x) do
>     TemperCore.int32(x + 1)
>   end
>   def usesIt(x) do
>     Temper.MarginaliaCore.__temper_init__()
>     TemperCore.Heap.entry(fn ->
>       Temper.MarginaliaCore.addedHelper(x)
>     end)
>   end
```

A backend test checks this. It generates a library, then the same library
with a declaration added in front, and requires every function of the
first output to appear unchanged in the second. It fails with the naming
switched off.

Rebuilding the guide's tour turned up two mistakes in the guide itself.
`public bump(): Void { count += 1 }` doesn't compile: the method's last
expression is the `Int` that `+=` produces, so the body needs a `;`. And
`sum` and `firstNegative` were private functions called only with
constants. The frontend evaluates those calls while compiling, so since
entry 30 neither function is generated at all. The tour now exports them,
and every snippet in the guide is that build's real output again.

The functional suite is 65 of 65, alloy 225 of 225 and templight 140 of
140. Marginalia's harnesses, 1,158 app tests and 26 Temper tests pass.
