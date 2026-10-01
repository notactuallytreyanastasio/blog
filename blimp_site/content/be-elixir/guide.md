# How be-elixir works

be-elixir compiles Temper to Elixir that runs on the BEAM. This guide
covers the backend as it is now, in the order you need it: how to run it,
what each Temper construct becomes, and where it falls short. The dated
journal entries tell how each piece came about. Every Elixir snippet here
is real output, mostly from one small program, *the tour*, reproduced
whole in section 3.

## 1. Running it

You need Elixir 1.15 or later with `mix` on the path. It was developed
against Elixir 1.19.5 on OTP 28, and `~> 1.15` has not been tested below
1.19. You also need JDK 21 to build Temper itself.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
cd temper
./gradlew :cli:installDist                      # a `temper` that knows -b elixir
cli/build/install/temper/bin/temper build -b elixir -w path/to/my-lib
cd path/to/my-lib/temper.out/elixir/my-lib
mix compile && mix run --no-compile -e "Temper.MyLib.main()"
```

`temper.out/elixir/` holds one Mix project per Temper library, next to
`temper-core`, the runtime. If the library imports std, `std/` is there
too:

```
temper.out/elixir/
  temper-core/     the runtime, a Mix project with its own tests
  std/             Temper's standard library, translated
  my-lib/          mix.exs depends on ../temper-core and ../std
```

`temper run -b elixir` and the functional-test harness do the same through
`ElixirSpecifics`. They run `mix compile` first, so Mix's "Compiling"
lines never mix with the program's own output, and the run includes a
60-second watchdog. A program that never finishes halts with "timed out
after 60000 ms" instead of hanging whatever called it.

To check the backend:

```bash
./gradlew :be-elixir:jvmTest :be-elixir:ktlintCheck     # unit, grammar and functional tests
cd be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core && mix test
```

The functional tests are Temper's shared suite of 65 programs, each with
its expected output. All 65 pass. The ones that run for Elixir are the
`onlyPasses(elixir(), ...)` list in `FunctionalTestStatus.kt`.

## 2. How a backend is put together

A Temper backend never prints target code as strings. The frontend
lowers Temper to TmpL, an intermediate tree shared by every backend.
`ElixirTranslator` turns TmpL into a tree of Elixir nodes, and Temper's
formatter renders that tree. The pieces:

| File | What it does |
|------|--------------|
| `elixir.out-grammar` | the Elixir syntax tree. `./gradlew kcodegen:updateGeneratedCode` turns it into `Elixir.kt`, one class per node |
| `ElixirOperatorDefinition.kt` | the precedence ladder, which decides every parenthesis. Comparisons are non-associative on purpose, since `1 < 2 < 3` is legal Elixir and means `false` |
| `ElixirFormattingHints.kt` | spaces, line breaks, indentation. `do` and `fn` indent, `end` dedents |
| `ElixirHelpers.kt` | literals: strings with `#` escaped, atoms quoted when needed, floats always with a point |
| `ElixirBackend.kt` | one Mix project per library: `mix.exs`, `lib/temper_main.ex`, the root module |
| `ElixirTranslator.kt` | TmpL to Elixir: statements, classes, closures, calls |
| `ElixirSupportNetwork.kt` | tells the frontend how this target differs: bubbles are exceptions, coroutines are state machines, void is `nil` |
| `ElixirSupportCode.kt` | each builtin operator and `@connected` member, as an Elixir expression |
| `ElixirNames.kt` | legal and readable names |
| `ElixirSpecifics.kt` | compiling and running the output |
| `temper-core/` | the runtime library, `TemperCore.*` |

Anything the translator does not handle is a `TODO()` carrying the TmpL
node, so it fails at build time and says where. The backend never emits
plausible-looking code it has not checked. The one deliberate exception
is code the frontend has already rejected (section 11).

## 3. The tour

This program is used throughout:

```temper
class Point(public x: Int, public y: Int) {
  public plus(o: Point): Point { new Point(x + o.x, y + o.y) }
}

class Counter {
  public var count: Int = 0;
  public bump(): Void { count += 1 }
}

interface Shape { public area(): Float64; }
class Square(public side: Float64) extends Shape {
  public area(): Float64 { side * side }
}

let sum(xs: List<Int>): Int {
  var total = 0;
  for (var i = 0; i < xs.length; ++i) {
    total += xs[i];
  }
  total
}

let firstNegative(xs: List<Int>): Int {
  for (var i = 0; i < xs.length; ++i) {
    if (xs[i] < 0) { return i; }
  }
  -1
}

let p = new Point(1, 2).plus(new Point(3, 4));
let c = new Counter();
let alias = c;
c.bump();
alias.bump();
let s: Shape = new Square(1.5);
var calls = 0;
let tick(): Int { calls += 1; calls }
tick();
tick();
console.log("p=${p.x},${p.y} count=${c.count} area=${s.area()} calls=${calls}");
console.log("sum=${sum([1, 2, 3])} neg=${firstNegative([4, -1, 5])} big=${1.7976931348623157e308 * 2.0}");
```

```
p=4,6 count=2 area=2.25 calls=2
sum=6 neg=1 big=Infinity
```

## 4. A library is a root module

Each Temper library becomes one root module: `tour` is `Temper.Tour`,
`std` is `Temper.Std`, and `my-lib` is `Temper.MyLib`. The `Temper.` prefix
keeps a library from landing on Elixir's own `String` or `Enum`. The Mix
app is `:temper_tour`. Its functions live in the root module, and each
class gets a module beneath it, `Temper.Tour.Point`.

A Temper module runs its top level when it loads. That code becomes
`__temper_init__/0`:

```elixir
def __temper_init__() do
  TemperCore.init_once(:"Temper.Tour", fn ->
    TemperCore.Global.put(:"Temper.Tour.p__24", Temper.Tour.Point.plus(Temper.Tour.Point.new(1, 2), Temper.Tour.Point.new(3, 4)))
    TemperCore.Global.put(:"Temper.Tour.c__25", Temper.Tour.Counter.new())
    ...
    nil
  end)
end
def main() do
  Temper.Tour.__temper_init__()
  TemperCore.Async.drain()
end
```

- `init_once` records the library in the process dictionary, so a library
  that two others depend on runs its top level only once.
- A library's init first calls the init of every library it imports from,
  so std's globals exist before the user's code reads them.
- `main/0` runs init, then the async queue (section 9).
- A module-level variable lives in `TemperCore.Global`, the process
  dictionary, under a key that includes its library, because a `def`
  cannot see variables outside its own parameters.

An imported function is a direct call, `Temper.Std.parseJson(text)`, and
`mix.exs` depends on the library it comes from:

```elixir
defp deps do
  [{:temper_core, path: "../temper-core"}, {:temper_std, path: "../std"}]
end
```

## 5. Values

| Temper | Elixir |
|--------|--------|
| `Int` (32-bit) | an integer, wrapped after arithmetic: `TemperCore.int32(total + x)` |
| `Int64` | an integer, wrapped with `TemperCore.int64` |
| `Float64` | a float, or `:infinity`, `:neg_infinity` or `:nan` |
| `Boolean` | `true` / `false` |
| `String` | a UTF-8 binary |
| `StringIndex` | a byte offset; `String.begin` is `0`, "no index" is `-1` |
| `StringBuilder` | a heap object holding the string so far |
| `List<T>` | an Elixir list |
| `ListBuilder<T>` | a heap object holding an Elixir list |
| `Map<K, V>` | `%TemperCore.Map{keys, map}`: insertion order kept beside an Elixir map |
| `MapBuilder` | a heap object holding the same two |
| `Pair` | `%TemperCore.Pair{key, value}` |
| `Deque` | an Erlang `:queue`, on the heap |
| `DenseBitVector` | the set bits, in a map on the heap |
| `null`, `void` | `nil` |
| `Empty` | `:empty` |
| a type used as a value | its module, or a builtin's name as an atom: `:Void` |

**Integers.** Elixir integers have no width. Temper's `Int` wraps at 32
bits, so every `+`, `-` and `*` passes through `TemperCore.int32`.
Division and remainder also bubble on zero. Bitwise operations use
`Bitwise`, wrapped the same way.

**Floats.** The BEAM's floats have no infinity or NaN. Overflow,
`1.0 / 0.0` and `:math.sqrt(-1.0)` all raise `ArithmeticError`, and an
infinity's bits cannot even be matched out of a binary. So a `Float64`
can also be one of three atoms, and no float operation is a bare
operator:

```elixir
TemperCore.Float.mul(this.side, this.side)
```

`mul` runs the BEAM's `*` inside a `try` and turns a raise into the IEEE
result. On ten million adds that cost about 10%. Comparisons follow
Temper's total order:

    -Infinity < ... < -0.0 < 0.0 < ... < Infinity < NaN,   and NaN == NaN

`near` is Python's `math.isclose`. `toString` prints the way JavaScript
does, `1.0e+25` and `0.000001`, always with a point.

**Strings.** A `StringIndex` is a byte offset into the UTF-8 binary, so
`s[i]` is a binary match and stepping (`next`, `prev`) moves over a whole
code point. `countBetween` counts code points, not graphemes.

## 6. Functions and control flow

Elixir has no mutable variables and no loops. Temper has both.

**Locals are rebound.** `var x = 1; x = x + 1` becomes `x = 1` then
`x = TemperCore.int32(x + 1)`. An `if` that assigns hands its variables
back as a value: `x = if c do ...; x else x end`.

**A loop is a function that calls itself.** It carries every variable it
assigns, and hands them back when it ends:

```elixir
ex_loop_13 = fn ex_loop_13, i, total ->
  if i < TemperCore.List.length(xs) do
    total = TemperCore.int32(total + TemperCore.List.get(xs, i))
    i = TemperCore.int32(i + 1)
    ex_loop_13.(ex_loop_13, i, total)
  else
    {i, total}
  end
end
{i, total} = ex_loop_13.(ex_loop_13, i, total)
```

The recursive call is a tail call, so the stack does not grow.

**Exits are folded where they can be.** A statement list is translated
together with what falling off its end means: return `nil`, go round the
loop again, or hand back the assigned variables. An `if` whose branch
always exits pulls the rest of the list into its other branch, so most
`return`, `break` and `continue` statements become a value or a call.

**The rest throw.** `firstNegative` returns from inside a loop, and the
loop is a function, so the `return` becomes a tagged `throw`. The function
catches its own tag. The loop's recursive call stays outside any `try`,
which would otherwise break the tail call:

```elixir
def firstNegative__22(xs) do
  try do
    ...
            if TemperCore.List.get(xs, i) < 0 do
              return = i
              throw({:temper_break, :ex_block_16, return})
    ...
  catch
    {:temper_return, :ex_return_15, ex_value_20} ->
      ex_value_20
  end
end
```

**Calls.** A module function is always called qualified,
`Temper.Tour.tick__23()`. That works from inside a class module and never
collides with a Kernel import of the same name. An omitted optional
argument is passed as `nil`. A rest parameter is one list. A function
used as a value is a capture, `&Temper.Std.parseJson/1`.

## 7. Closures

| Temper | Elixir |
|--------|--------|
| `let f(x) { ... }` inside a function | `f = fn x -> ... end` |
| a local function that calls itself | it is passed to itself: `rec = fn rec, x -> ... rec.(rec, ...) end` |
| a local that a closure reads and anyone assigns | a cell: `TemperCore.Heap.new(:cell, %{v: x})` |
| local functions that call each other | cells created at the top of the block, so either can call the other |

Elixir closures capture values, and Temper closures capture variables.
The difference only shows when a captured variable is assigned, so only
those variables become cells.

## 8. Classes and objects

A class is a module. What an object *is* depends on whether it can
change:

- **A class with no setter and no field writes outside its constructor**
  is a `defstruct`. Copies are free, and it is an ordinary Elixir value
  that can go anywhere, including other processes.
- **Any other class** is a `%TemperCore.Ref{class, id}` into a heap kept in
  the process dictionary. Two names for one object see each other's
  writes, which is what Temper requires (`c` and `alias` above both bump
  one count).

```elixir
defmodule Temper.Tour.Point do
  defstruct [:x, :y]
  ...
  def new(x, y) do
    this = %Temper.Tour.Point{}
    this = %{this | :x => x}
    this = %{this | :y => y}
    this
  end
end

defmodule Temper.Tour.Counter do
  def bump(this) do
    ...
    TemperCore.Heap.put(this, :count, return)
  end
  def new() do
    this = TemperCore.Heap.new(Temper.Tour.Counter, %{:count => nil})
    ...
```

**Dispatch.** Temper does not allow extending a concrete class ("Cannot
extend concrete type(s) A"). So when a receiver's static type is a
concrete class, the object belongs to exactly that class, and the call
goes straight to the class's module: `Temper.Tour.Point.plus(a, b)`,
`Temper.Tour.Counter.bump(c)`. Only a receiver typed as an interface
waits until run time:

```elixir
TemperCore.call(TemperCore.Global.get(:"Temper.Tour.s__27"), :area, [])
```

`TemperCore.call` finds the module from the struct or ref and applies the
method to it.

| Temper | Elixir |
|--------|--------|
| `new C(a)` | `Temper.Lib.C.new(a)` |
| `obj.m(a)`, `obj` a concrete class | `Temper.Lib.C.m(obj, a)` |
| `obj.m(a)`, `obj` an interface | `TemperCore.call(obj, :m, [a])` |
| `obj.p` / `obj.p = v` | `get_p(obj)` / `set_p(obj, v)`, dispatched the same way |
| `C.s(a)` (static) | `Temper.Lib.C.s(a)` |
| `x is I`, `x as I` | `TemperCore.is_a(x, Temper.Lib.I)`, using each class's `__temper_supertypes__/0` |

An interface's method bodies are copied into each class that implements
it, so there is no `super`. An abstract method left unimplemented raises
`TemperCore.Panic` if it is ever called.

## 9. Generators and async

The obvious BEAM answer, one process per coroutine, does not work here. A
generator in its own process would see an empty heap, and every object it
had been given would be a dangling ref. So the frontend's
`TranslateToRegularFunction` strategy, the one be-rust and be-java use,
rewrites a generator body into a state machine: a step function that
switches on a `caseIndex` cell.

```elixir
convertedCoroutine = fn generator ->
  caseIndexLocal = TemperCore.Heap.get(caseIndex, :v)
  TemperCore.Heap.put(caseIndex, :v, -1)
  cond do
    caseIndexLocal == 0 ->
      IO.puts("one")
      TemperCore.Heap.put(caseIndex, :v, 1)
      {:value, :empty}
    caseIndexLocal == 1 ->
      IO.puts("two")
      :done
    true ->
      :done
  end
end
```

| Temper | Elixir |
|--------|--------|
| a generator | `TemperCore.Generator.adapt(step)`, a heap object |
| `g.next()` | `{:value, v}` or `:done`. Anything else is a panic, so a lowering bug cannot pass for "not done" |
| `new PromiseBuilder()` | `TemperCore.Promise.new()`. The builder and its promise are one heap object; the first settle wins |
| `async { ... }` | queued on a FIFO run queue in the process dictionary |
| `await p` | park the generator on `p`; settling `p` queues it again |

`main/0` ends by draining that queue. It pops one generator, steps it
once, and repeats. No step runs inside another, so a long chain of awaits
is a loop and not a deeper stack. A million settled awaits drained in
444 ms.

## 10. Builtins, `@connected`, and std

Temper's builtins reach Elixir as support code. `ElixirSupportCode.kt`
maps each builtin operator and each `@connected` member to an Elixir
expression, usually a `TemperCore` call: `console.log` becomes `IO.puts`,
`list.length` becomes `TemperCore.List.length`. A builtin method that has
no entry fails the build and names itself.

std is translated like any library and compiles like one. A few std
members are `@connected` without a body, which means every backend has
to supply them:

| std member | Elixir |
|------------|--------|
| `Date.today()` | `TemperCore.Temporal.today(Temper.Std.Date)`, built by std's own `Date` constructor |
| regex compile, `found`, `find`, `replace`, `split` | `TemperCore.Regex` over `:re` |

Regex patterns compile with `:unicode` but not `:ucp`. A `.` matches a
whole code point, while `\d`, `\w` and `\s` stay ASCII, as they are in
be-py. `:re` reports byte offsets, which is what a `StringIndex` is. Groups
iterate in the order they appear in the pattern, which `:re.inspect`
does not give, so the compiled regex carries the names itself. A
connected std member with no Elixir support raises
`no Elixir support code for <key>` if it is ever called.

A user library's own `@connected` functions call `TemperConnected.name`,
from the `_connected.ex` file next to its Temper source.

## 11. Errors

| Temper | Elixir |
|--------|--------|
| a bubble (`throws Bubble`, a failed `as`, `orelse`) | `raise TemperCore.Bubble`, caught with `rescue _ in TemperCore.Bubble` |
| `panic()` | `raise TemperCore.Panic` |
| code the frontend rejected but was told to build anyway | `raise(TemperCore.Panic, "broken code: <the frontend's diagnostic>")`, where it stands |

## 12. Tests

A `test("name") { ... }` block is a module function that takes a
`TemperCore.Test`. Soft asserts record a failure and keep going; hard
asserts bubble. A test run calls `main()` first, so tests can read
module values, then `__temper_tests__/0`. That writes JUnit XML to
`test-results.xml` for the harness, following std/testing line for line.

## 13. Names and layout

| Temper | Elixir |
|--------|--------|
| a local declared once in its function | its plain name: `xs`, `total`, `sourceText` |
| a name declared more than once in one function | numbered in order: `t1`, `t2` |
| a module function or global | keeps its frontend id: `sum__21`, `:"Temper.Tour.calls__28"` |
| a field | its plain name, `:x`, since a class has one member of each name |
| `if a ... else if b ... else ...` | one `cond` with an arm per branch |
| a name Elixir reserves or Kernel imports | a trailing `_`: `length_` |
| a name starting with a capital or `_` | a `v_` or `u` prefix |
| the translator's own temporaries | `ex_loop_13`, `ex_return_15`, which no Temper name can collide with |

Names are per function: Elixir variables belong to their function, so a
frontend id only has to separate names that share a base inside one
function.

## 14. Long-running programs

Mutable objects live in their process's heap, which leaves two problems
for a program that keeps running. `TemperCore.Heap` provides a tool for
each.

**Freeing.** Nothing frees an object on its own, but a heap dies with its
process. A process holding 200,000 objects used 36 MB, and BEAM process
memory fell from 50 MB to 17 MB when it exited. So the first answer is
the usual BEAM one: a process per request or per job, and nothing more to
do.

A process that lives on, such as a GenServer, calls
`TemperCore.Heap.collect(roots)` between calls into Temper code:

```elixir
def handle_call({:req, n}, _from, state) do
  reply = Temper.Svc.handle(n)
  TemperCore.Heap.collect([state])
  {:reply, reply, state}
end
```

`collect` is mark and sweep. It keeps every object reachable from the
roots it is given, from the rest of the process dictionary (Temper's
globals, the async queue) and from closures, which it traces through
`:erlang.fun_info(f, :env)`. It frees everything else, cycles included.
It cannot see the stack, so it is only safe when no Temper function is
partway through. Here is a service whose every request makes two objects
and keeps one long-lived counter, run for 100,000 requests:

| | objects left | process memory | time |
|---|---|---|---|
| no collect | 200,001 | 49,364 KB | 492 ms |
| `collect` after each call | 1 | 18 KB | 194 ms |

Collecting after each call is cheap when little survives, because each
pass costs as much as the live heap. A process that keeps a large heap
would collect every N calls instead.

**Crossing processes.** A ref sent as is fails loudly in the receiving
process: `...is not an object in this process`. Instead, send
`TemperCore.Heap.export(value)` and call `TemperCore.Heap.import/1` where
it arrives. Export copies every object the value reaches. Objects keep
their ids, which are unique across processes and nodes, so aliasing
inside the value survives and a ref captured by a closure still works.
Like any BEAM message it is a copy: later writes on either side are not
shared. The receiving process must have run the library's
`__temper_init__/0` if the code it calls reads module values.

## 15. Limits

- **Code is single-process.** Async is a queue inside one process, not
  BEAM concurrency. Using several processes is up to the host, through
  export and import.
- **A `ListBuilder` append copies the list,** so building a list one item
  at a time is quadratic.
- **No `mix test` integration.** Tests run through `main/0`.
- **Two user libraries importing each other** have not been tried; only
  libraries importing std have.

## 16. Where things are

- Backend: `temper/be-elixir/src/commonMain/kotlin/lang/temper/be/elixir/`
- Runtime: `temper/be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core/`
- Probes, which check claims about Elixir and the BEAM: `journal/probes/`
- How each part came about: the dated entries in `journal/`, listed in
  `journal/README.md`
