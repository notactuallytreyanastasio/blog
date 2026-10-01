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

- `init_once` runs a library's top level **once per node**, however many
  processes and libraries ask for it. A process that arrives while another
  is still running it waits under a lock until it finishes.
- A library's init first calls the init of every library it imports from,
  so std's globals exist before the user's code reads them.
- `main/0` runs init, then the async queue (section 9).
- **Elixir code never has to call init.** Every exported function, and
  the constructor of every exported class, starts with
  `Temper.Lib.__temper_init__()`. The first call on the node runs the top
  level; every later one is a single ETS lookup, which costs nothing
  measurable across 100,000 GenServer requests. Code running inside the
  init itself skips the call, so there is no recursion.
- A module-level variable lives in `TemperCore.Global`, keyed by library,
  because a `def` cannot see variables outside its own parameters. Every
  process on the node sees the same module values: a value that can be
  shared (a number, string, list, map, `@imu` struct or actor) lives in an
  ETS table. A mutable object that is not an actor cannot be shared, since
  its ref only means something in the heap that made it, so each process
  gets its own copy the first time it reads it. Section 15 covers sharing
  mutable state safely.
- The ETS table, the actor registry and the actor supervisor belong to the
  `:temper_core` OTP application. It starts with any Mix project that
  depends on a translated library.

Another library is imported by its module directory: `import("std/json")`,
or `import("shapes/src")` for a library named `shapes` whose code is in
`src/`. An imported function is a direct call, `Temper.Std.parseJson(text)`,
and `mix.exs` depends on the library it comes from:

```elixir
defp deps do
  [{:temper_core, path: "../temper-core"}, {:temper_std, path: "../std"}]
end
```

Two user libraries work together the same way. `journal/examples/twolibs`
has an `app` that uses `shapes`: its interface and an `@imu` class through
a list typed by the interface, a mutable class, and a module-level actor.
It prints the same line as the JS backend,
`total=10.0 isSquare=true stack=2 tally=6`.

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
| `List<T>` | `%TemperCore.Vec{t: tuple}`; a literal is `%TemperCore.Vec{t: {1, 2, 3}}` |
| `ListBuilder<T>` | a heap object holding an Erlang `:array` |
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

**Lists.** A Temper `List` is a tuple in a struct, so `xs[i]` and
`xs.length` take constant time. As an Elixir list, an indexed loop over
16,000 items took 236 ms, because both walk the list. A `ListBuilder`
holds an `:array`, so appending is `O(log n)`; as a list, every append
copied, and 16,000 appends took 1.2 s. Now a million items build in 186 ms
and sum by index in 20 ms.

`TemperCore.Vec` is `Enumerable`, so Elixir code can `Enum` over a list a
Temper library returns, and every Temper list operation also accepts a
plain Elixir list:

```elixir
Temper.Lists.build(5)            #=> #TemperCore.Vec<[0, 1, 2, 3, 4]>
Temper.Lists.sumIndexed([1, 2, 3])   #=> 6
```

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

- **A class marked `@imu`** is a `defstruct`. Copies are free, and it is an
  ordinary Elixir value that can go anywhere, including other processes.
  The frontend enforces `@imu` ("Class P claims imu but has a `var`
  property"), so the struct can never be written after construction.
- **A class marked `@actor`** is a process per instance,
  `%TemperCore.Actor{class, id}`, that any process may hold (section 15).
- **Any other class** is a `%TemperCore.Ref{class, id}` into a heap kept in
  the process dictionary.

The choice follows the annotation, not the class body. If it were
inferred, a later version of a library that added a setter would silently
turn a struct into a ref. Consumers' `%Lib.Point{}` patterns would stop
matching, values that crossed processes freely no longer would, and `==`
would compare identity instead of fields. With `@imu` as the contract,
that change can only happen by removing the annotation. An unannotated
class that never mutates is a ref, which is slower but consistent. std's
value classes are annotated: the JSON tree, regex nodes, `Match`, `Group`
and `Date`. That is 30 structs in all, so a parsed JSON tree is plain data
that crosses processes as it is. Two names for one object see each other's
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
| a property read on a value whose type did not compile, such as an object of a rejected class | the same raise, naming the property |

## 12. Tests

A `test("name") { ... }` block is a module function that takes a
`TemperCore.Test`. Soft asserts record a failure and carry on, and hard
asserts bubble, following std/testing line for line. A library with tests
gets two ways to run them.

**`mix test`.** The backend writes `test/temper_test.exs`, with one ExUnit
test per Temper test, named by the test's own sentence:

```elixir
defmodule Temper.Tested.TemperTest do
  use ExUnit.Case

  setup_all do
    Temper.Tested.__temper_init__()
    :ok
  end

  test "doubling works" do
    TemperCore.Test.check(&Temper.Tested.doublingWorks__12/1)
  end
  ...
```

`setup_all` runs the library's top level, which tests read from.
`TemperCore.Test.check/1` runs one test the way std/testing would and
raises an ExUnit assertion error carrying its messages:

```
  2) test a failing test (Temper.Tested.TemperTest)
     test/temper_test.exs:13
     2 should not double to 5
     nor 3 to 7
```

A test that bubbles without a failed hard assert reports `Bubble`, as
std/testing does. ExUnit's own tools work: `mix test --seed`, `--only`, and
a line number to run one test.

**The harness.** `temper test -b elixir` and the functional suite run
`main/0`, then `__temper_tests__/0`, which writes the JUnit XML that
`reportTestResults` writes to `test-results.xml`. Each test is also
registered with the CLI under its function name, the name that XML
carries. So a failure is reported by its sentence, and a library whose
init raises before any test runs reports `0 of 30 (30 not run)`, not
`0 of 0`.

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
| a binding nothing reads | Elixir's `_` prefix: `{_i, total} = loop.(...)` |

Names are per function: Elixir variables belong to their function, so a
frontend id only has to separate names that share a base inside one
function.

Generated code compiles without warnings, std included, where it used to
print about 200. A last pass over each function (`ElixirTidy.kt`) gives
every binding that nothing reads the `_` prefix. It works backwards
through each block and follows Elixir's scoping, where a binding inside
an `if`, `case` or `fn` does not leak out. The same pass drops the
binding from `t = raise(...)`, which Elixir's type checker reports as a
pattern that can never match, and ends the block at the raise. Elixir
checks every variable a function reads, reachable or not, so a later read
of `t` would not compile ("undefined variable"); nothing after a raise in
its block can run anyway (`probes/10_unbound_after_raise.exs`).

## 14. Long-running programs

Mutable objects live in their process's heap, which leaves two problems
for a program that keeps running. `TemperCore.Heap` provides a tool for
each.

**Freeing.** Nothing frees an object on its own, but a heap dies with its
process. A process holding 200,000 objects used 36 MB, and BEAM process
memory fell from 50 MB to 17 MB when it exited. So the first answer is
the usual BEAM one: a process per request or per job, and nothing more to
do.

A process that lives on, such as a GenServer, needs no code either.
Every exported function runs its body through `TemperCore.Heap.entry`:

```elixir
def handle(n) do
  TemperCore.Heap.entry(fn ->
    sb = TemperCore.StringBuilder.new()
    ...
  end)
end
```

That is a small generational collector. Objects made during the outermost
call into a library are young. When the call returns, or raises, the
young objects nothing reaches are freed. "Reaches" means from the
result, from Temper's globals and the rest of the process dictionary, or
from an older object that the call wrote to: a write barrier in
`Heap.put` remembers those older objects. Older objects are never
touched, so whatever the caller still holds from earlier calls stays
alive. Nested calls (Temper code calling exported functions) collect only
at the outermost one. The same service as below, with no `collect` in it
at all, ran 100,000 requests and ended with 1 object (its counter) in
26 KB, in 270 ms.

What `entry` cannot free: an object the caller kept and later dropped,
or anything made outside an exported function (Elixir calling a
constructor or method directly). For those,
`TemperCore.Heap.collect(roots)` is a full mark and sweep, called between
calls into Temper code:

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
| no collector (before `entry`) | 200,001 | 49,364 KB | 492 ms |
| `collect` after each call | 1 | 18 KB | 194 ms |
| `entry` alone, nothing in the server | 1 | 26 KB | 270 ms |

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
shared. The receiving process does not have to initialize anything: every
exported function and constructor runs the library's `__temper_init__/0`
first (entry 24).

## 15. Actors

A class marked `@actor` has instances that are processes. Any number of
processes can hold one and change it, and all of them see the same object.

```temper
@actor export class Account(public owner: String) {
  public var balance: Int = 0;
  public deposit(n: Int): Int { balance += n; balance }
  public withdraw(n: Int): Int throws Bubble {
    if (n > balance) { bubble() }
    balance -= n;
    balance
  }
  public transferTo(other: Account, n: Int): Void throws Bubble {
    withdraw(n);
    other.deposit(n);
  }
}
```

`@actor` is a decorator in Temper core, declared next to `@imu`. Every
other backend ignores it, so there the class is an ordinary class. On the
BEAM:

```elixir
def new(owner) do
  TemperCore.Actor.start(Temper.Bank.Account, fn ->
    this = TemperCore.Actor.init_self(Temper.Bank.Account, %{:owner => nil, :balance => nil})
    ...
    this
  end)
end
def deposit(this, n) do
  TemperCore.Actor.run(this, fn ->
    ...
  end)
end
```

`new` starts a GenServer and runs the constructor inside it. The object
is `%TemperCore.Actor{class, id}`: an ordinary term that can be sent,
stored and compared. The id is registered to whichever process runs the
actor now, so the identity survives a restart. Its fields exist only inside its own process. Each
method body runs through `TemperCore.Actor.run`. From inside the actor
(`this.m()`) that is a plain call. From anywhere else it is a
`GenServer.call`, which costs about 1.6 µs. Calls stay synchronous, as
Temper expects. Driven from Elixir (`journal/examples/bank/`):

```
after 1000 concurrent deposits: 1000
after transfer: ann 700, bob 300
withdraw too much: bubbled back to the caller (TemperCore.Bubble)
cycle: Panic: actor call cycle: Temper.Bank.Account is already waiting on this call
mutable argument: Panic: an argument to Temper.Bank.Account is a mutable Temper.Bank.Box, which cannot be shared with another process; make its class @imu to pass a copy, or @actor to share it
actor whose creator ended: Panic: Temper.Bank.Account actor has ended
```

The rules, one per line of that output:

- **One object, one process.** A thousand processes depositing at once
  lose no update, because the actor handles one call at a time.
- **Actors call actors.** `transferTo` runs in `ann`'s process and calls
  `bob`.
- **Errors cross.** A bubble or panic raised in the actor is raised again
  in the caller, so `orelse` works across processes.
- **No deadlocks from cycles.** If A is waiting on B and B calls A, A can
  never answer. Each call carries the chain of actors it passed through,
  so the call back raises a `Panic` instead of hanging.
- **Only values cross.** Messages copy, and copying a mutable object
  would break Temper's sharing. Arguments, results and captured values
  are checked, and a mutable non-actor object raises a `Panic` that names
  it. Immutable values and other actors cross freely: strings, numbers,
  lists, maps, `@imu` structs. This is Erlang's own rule.
- **Lifetime.** By default an actor ends when the process that created it
  ends, for any reason. It is linked to its creator and also monitors it,
  because a link alone ignores a normal exit.
- **Supervision.** Actors created inside
  `TemperCore.Actor.supervised(fn -> ... end)` start under the
  `TemperCore.Actors` supervisor instead. They outlive their creator. After
  a crash they restart by re-running their constructor with the same
  arguments: fresh state, the same identity, as OTP does. A call that
  reaches the dead process retries once on the new one. It never ran,
  because an actor only stops after replying to the call that crashed it.
  `TemperCore.Actor.stop/1` ends either kind.
- **Errors and crashes are different.** A Temper bubble or panic is the
  result of one call, and the actor carries on. Any other exception (an
  Elixir error, an exit) crashes the actor, after the caller gets the error.

```
supervised actor whose creator ended: 5
```

**Sharing mutable module state.** An actor created by a library's top
level belongs to the node: top levels run supervised, so it does not end
with whichever process ran the init. That makes an `@actor` the way to
share mutable state between processes:

```temper
@actor export class Ledger {
  public var entries: Int = 0;
  public record(): Int { entries += 1; entries }
}
export let ledger = new Ledger();
```

Every account, in every process, records into the same ledger. After the
thousand concurrent deposits it holds exactly 1000. A plain shared `var`
would not be safe for this. Two processes doing `count += 1` can both
read 4 and both write 5, because the read and the write are separate
steps, and Temper has no locks. A counter shared across processes belongs
in an actor, whose single process makes each update one step.

Each call runs through `Heap.entry` inside the actor, so garbage from a
method is freed when the method returns.

## 16. Using it in an app

[Marginalia](https://github.com/notactuallytreyanastasio/marginalia), a
Phoenix app, runs its core text logic from Temper this way: paragraph and
word diffs, sentence splitting, PDF reflow, and the manuscript segmenter.
The case study is
[marginalia#6](https://github.com/notactuallytreyanastasio/marginalia/pull/6),
and entry 26 covers what it taught the backend.

**Commit the generated code.** The Temper libraries live in `temper/`, and
the Elixir generated from them in `temper/out/`, used as a path
dependency. Building, testing and deploying then need no JVM:

```elixir
{:temper_marginalia_core, path: "temper/out/marginalia-core"},
...
"temper.check": ["cmd bin/temper-gen --check"],
precommit: ["temper.check", "compile --warnings-as-errors", ...]
```

`bin/temper-gen` runs `temper build -b elixir` in a scratch copy, deletes
the `*.map` files, replaces `temper/out`, and records the compiler's commit
in `temper/out/TEMPER_COMMIT`. `--check` rebuilds and fails if the result
differs from what is committed, which works because the output is
deterministic and compiles without warnings. A Dockerfile needs
`COPY temper/out temper/out` before `mix deps.get`.

**Keep the Elixir modules as facades.** Each module keeps its API and
calls the generated library, turning `@imu` structs back into whatever its
callers already match on:

```elixir
def rows(before_text, after_text) do
  Core.rows(before_text || "", after_text || "") |> Enum.map(&row/1)
end

defp row(%Core.Row{kind: "same", left: l, right: r}), do: {:same, l, r}
```

**Export only the API.** Every exported function runs the library's init
check and `TemperCore.Heap.entry` (section 14). That is cheap once per call
from Elixir, but a helper called once per character pays it once per
character. Un-exporting Marginalia's helpers was most of a 3x-to-5x
slowdown.

**Let the host answer what Temper cannot know.** Temper's core strings carry
no Unicode character data. Questions like "is this code point `\p{Lu}`"
are `@connected` declarations, answered in `_connected.ex` by the engine the
original code used, with an ASCII fast path:

```elixir
def isUnicodeUpper(cp) when cp < 128, do: cp >= ?A and cp <= ?Z
def isUnicodeUpper(cp), do: Regex.match?(~r/\A\p{Lu}\z/u, <<cp::utf8>>)
```

**Check a port against the code it replaces.** Keep the original modules
as fixtures, run old and new on random inputs, and count which rules the
inputs reached. Marginalia's ports agreed on more than 90,000 inputs, and
being faithful turned up a regex bug the original had always had.

**What it costs.** Code that walks strings is about 3x slower than
hand-written Elixir that runs regexes over whole binaries. In Marginalia
that is a few milliseconds per document. PDF reflow, which the original did
with a regex per line, got 3.5x faster.

## 17. Limits

- **Async is single-process.** `async` is a queue inside one process, not
  BEAM concurrency. Concurrency comes from `@actor` classes, or from host
  processes using export and import.
- **A shared module `var` is not atomic.** Every process sees writes to it,
  but a read followed by a write can race. Shared mutable state that must
  stay consistent belongs in an `@actor`.
- **A module-level mutable non-actor object is per process.** Each process
  gets its own copy on first read.

## 18. Where things are

- Backend: `temper/be-elixir/src/commonMain/kotlin/lang/temper/be/elixir/`
- Runtime: `temper/be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core/`
- Probes, which check claims about Elixir and the BEAM: `journal/probes/`
- Runnable examples: `journal/examples/bank/` (actors, a shared ledger,
  supervision, driven from Elixir) and `journal/examples/twolibs/` (one
  library using another)
- Used in an app: [marginalia#6](https://github.com/notactuallytreyanastasio/marginalia/pull/6)
  (section 16)
- How each part came about: the dated entries in `journal/`, listed in
  `journal/README.md`
