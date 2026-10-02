# 2026-10-01: one class is not another

Once the generated code had typespecs, a `Query`, a `Schema` and a `Table`
in the ORM all had one type, `TemperCore.Ref.t()`. Every class without
`@imu` is a reference into the process heap, and that is what its `@type t`
said. Over the ORM's specs, 44% of argument and return types meant "some heap
object", and another 19% were `term()`, because an interface's type was
`term()`. Dialyzer could not tell a `Query` from a `Schema`, so a spec that
mixed them up passed.

The fix to the types was one line per class. Getting Dialyzer to use them
also meant changing every constructor. The test written to guard that change
does not actually depend on it, and I get to that below.

This is fork PR [#8](https://github.com/notactuallytreyanastasio/temper/pull/8),
commit [`59ea289d`](https://github.com/notactuallytreyanastasio/temper/commit/59ea289d919049edc2df98e8c5935d4db856a952),
on top of the typespecs from
[#7](https://github.com/notactuallytreyanastasio/temper/pull/7). It was still
open against the fork's `main` when this was written, and merged on
2026-10-02.

## The class was already in the struct

A heap reference has always been `%TemperCore.Ref{class: C, id: id}`, and an
actor `%TemperCore.Actor{class: C, id: id}`, because `TemperCore.call` reads
`class` to dispatch. So the type can name the class. Here is
`journal/examples/classtypes/`, built with the fork's CLI:

```elixir
defmodule Temper.Classes.Shape do
  @type t() :: %TemperCore.Ref{} | %TemperCore.Actor{} | struct()
...
defmodule Temper.Classes.Counter do
  @type t() :: %TemperCore.Ref{class: Temper.Classes.Counter, id: reference()}
...
defmodule Temper.Classes.Tally do
  @type t() :: %TemperCore.Actor{class: Temper.Classes.Tally, id: reference()}
```

Before, these were `term()`, `TemperCore.Ref.t()` and `TemperCore.Actor.t()`.
An interface still can't name a class. Its values may be a heap object, an
actor or an `@imu` struct, from any library, so its type is the union of the
three. That is weaker than it looks: `struct()` lets in any struct at all,
including a `%MapSet{}`. It still rules out an integer or a string, which
`term()` did not.

## Why the types alone caught nothing

According to the commit, with only the types changed, a constructor whose
spec named the wrong class still passed Dialyzer. I reproduced that state
by putting the old constructor back into today's output, so the types are
new and the constructor is old:

```elixir
  @spec new() :: Temper.Classes.Square.t()      # wrong: this is Counter.new
  def new() do
    Temper.Classes.__temper_init__()
    this = TemperCore.Heap.new(Temper.Classes.Counter, %{:count => nil})
    TemperCore.Heap.put(this, :count, 0)
    this
  end
```

```
== heap-new_no-fresh_ctor-says-square
SPEC-TOTAL 0
```

`Heap.new/2` is `@spec new(module(), map()) :: Ref.t()`, and `Ref.t()` is
`%Ref{class: module(), id: reference()}`. Dialyzer does not specialize a
function to the arguments at one call site, so the literal
`Temper.Classes.Counter` passed in does not come back out. To Dialyzer, the
constructor returns a reference of some class. That overlaps `Square.t()`,
and overlap is all Dialyzer requires of a spec. The same goes for an
actor's `new`, which got its struct back from `Actor.start/2`.

The obvious fix is to give `Heap.new` a more precise spec, and it can't be
done. Writing the result as "a ref whose class is the argument" needs a
type variable tied to a value, and Erlang typespecs have no such thing.
The class has to appear as a literal at the place where the struct is
built. So the constructor now builds the struct itself, and the heap only
stores the fields:

```elixir
  @spec new() :: Temper.Classes.Counter.t()
  def new() do
    Temper.Classes.__temper_init__()
    this = %TemperCore.Ref{class: Temper.Classes.Counter, id: make_ref()}
    TemperCore.Heap.init(this, %{:count => nil})
    TemperCore.Heap.put(this, :count, 0)
    this
  end
```

An actor builds its own struct around the id that `Actor.start_id/2`
returns:

```elixir
  def new() do
    Temper.Classes.__temper_init__()
    %TemperCore.Actor{class: Temper.Classes.Tally, id: TemperCore.Actor.start_id(Temper.Classes.Tally, fn ->
      this = TemperCore.Actor.init_self(Temper.Classes.Tally, %{:n => nil})
      ...
    end)}
  end
```

`Heap.init/2` and `Actor.start_id/2` are new in temper-core. `Heap.new/2` and
`Actor.start/2` are still there for Elixir code that makes objects. Now
the wrong spec is reported at the constructor:

```
SPEC temper_main.ex:24: Invalid type specification for function 'Elixir.Temper.Classes.Counter':new/0.
 The success typing is 'Elixir.Temper.Classes.Counter':new
          () ->
             #{'__struct__' := 'Elixir.TemperCore.Ref',
               'class' := 'Elixir.Temper.Classes.Counter',
               'id' := reference()}
 But the spec is 'Elixir.Temper.Classes.Counter':new
          () -> 'Elixir.Temper.Classes.Square':t()
 The return types do not overlap
```

## What a caller adds, and what the test checks

The other mix-up the commit checks for is a method whose spec wants the
wrong class: `@spec bump(Square.t())` on `Counter.bump`. Nothing inside
`bump` can catch that. The body only passes `this` to `Heap.get` and
`Heap.put`, which accept any `Ref.t()`. A spec narrower than its body is
not a contradiction for Dialyzer. It only becomes one at a call that
passes something else. That is why the commit added `fresh()` to the test
fixture:

```temper
export let fresh(): Int {
  let c = new Counter();
  c.bump();
  c.count
}
```

With a caller in place, `bump` is reported at the call:

```
SPEC temper_main.ex:109:35: The call 'Elixir.Temper.Classes.Counter':bump
         (_c@1 ::
              #{'__struct__' := 'Elixir.TemperCore.Ref',
                'class' := 'Elixir.Temper.Classes.Counter',
                'id' := reference()}) breaks the contract
          ('Elixir.Temper.Classes.Square':t()) -> 'nil'
```

`journal/examples/classtypes/swaps.sh` makes each of these edits to a copy
of the generated library and runs the backend's own `dialyze.exs` on each
copy. In the table, "built in place" is this chapter's constructor and
"`Heap.new`" is the old one, with the new types in both:

| constructor | `fresh()` | spec edit | spec warnings |
|---|---|---|---|
| built in place | yes | none | 0 |
| built in place | yes | `Counter.new` returns `Square.t()` | 1, at `new` |
| built in place | no  | `Counter.new` returns `Square.t()` | 1, at `new` |
| built in place | yes | `Counter.bump` takes `Square.t()` | 2, at the call in `fresh` |
| built in place | no  | `Counter.bump` takes `Square.t()` | **0** |
| built in place | yes | `Tally.new` returns an actor of `Counter` | 1, at `new` |
| `Heap.new` / `Actor.start` | yes | none | 0 |
| `Heap.new` | no  | `Counter.new` returns `Square.t()` | **0** |
| `Heap.new` | no  | `Counter.bump` takes `Square.t()` | **0** |
| `Heap.new` | yes | `Counter.new` returns `Square.t()` | 2, at the call in `fresh` |
| `Heap.new` | yes | `Counter.bump` takes `Square.t()` | 2, at the call in `fresh` |
| `Actor.start` | yes | `Tally.new` returns an actor of `Counter` | **0** |

The row "`Heap.new`, no `fresh()`" matches the commit's claim that the
types alone caught nothing, since the fixture had no caller then. The
second-to-last `Heap.new` row says something the commit doesn't. With a
caller present, the old constructor catches the wrong `new` spec too,
because Dialyzer trusts the spec at the call site. It concludes that
`Counter.new()` returns a `Square` and reports the call to `bump`, which
is correct:

```
SPEC temper_main.ex:107:35: The call 'Elixir.Temper.Classes.Counter':bump
         (_c@1 ::
              #{'__struct__' := 'Elixir.TemperCore.Ref',
                'class' := 'Elixir.Temper.Classes.Square',
                'id' := reference()}) breaks the contract
          (t()) -> 'nil'
```

So building in place does more than catch the mistake: it moves the report
to the function that is wrong, and it works whether or not anything calls
that function.

It also means
[`ElixirTypespecTest.dialyzerTellsOneClassFromAnother`](https://github.com/notactuallytreyanastasio/temper/blob/59ea289d919049edc2df98e8c5935d4db856a952/be-elixir/src/commonTest/kotlin/lang/temper/be/elixir/ElixirTypespecTest.kt)
checks less than its doc comment says. It makes both edits to the
fixture's generated `temper_main.ex` and requires at least one `SPEC`
line. I made the test's two edits to the fixture's current output with the
constructors switched back to `Heap.new`:

```
== test fixture, Heap.new constructors, swap ctor
SPEC temper_main.ex:311: Invalid type specification for function 'Elixir.Temper.Specfix':fresh/0.
SPEC temper_main.ex:316:35: The call 'Elixir.Temper.Specfix.Counter':bump
SPEC-TOTAL 2
== test fixture, Heap.new constructors, swap bump
SPEC temper_main.ex:311: Invalid type specification for function 'Elixir.Temper.Specfix':fresh/0.
SPEC temper_main.ex:316:35: The call 'Elixir.Temper.Specfix.Counter':bump
SPEC-TOTAL 2
```

Both edits are still caught, so the test would pass with this chapter's
constructor change reverted. What it does pin down is that the types are
distinct: with `TemperCore.Ref.t()` for both classes, neither edit gives a
warning. To pin the constructor as well, the test would need to make the
`new` edit without `fresh()`, or require the warning to be the one at line
`new/0`. I ran this through Dialyzer directly, not through the Kotlin
test.

## How much the specs say now

`journal/examples/classtypes/precision.exs` sorts every argument and return
type in a library's `@spec`s. `--before` sorts the same output as it would
have been before #8: a heap class's or actor's `t()` counts as "any heap
object" and an interface's as `term()`. That simulates the old output; I
did not rebuild the old compiler. The input is alloy at `8a52073`, built
with the fork's current CLI, which also includes the later #9 to #11:

```
== orm --before                              == orm
any heap object      346   44%               precise              480   61%
precise              163   21%               any Temper object    152   19%
term()               152   19%               nil, no_return, supertypes   120   15%
nil, no_return, supertypes   120   15%       any heap object       29    4%

== std --before                              == std
precise              531   58%               precise              641   70%
nil, no_return, supertypes   144   16%       nil, no_return, supertypes   144   16%
term()               119   13%               any Temper object    116   13%
any heap object      116   13%               any heap object        6    1%
                                             term()                 3    0%
```

The commit gives the ORM as 26% precise before and 68% after, and std as 70%
and 82%. Its 44% and 18% match mine, and the precise share rises by about
40 points in both counts. My "precise" is lower because I count `nil`,
`no_return()` and `__temper_supertypes__`'s `[module()]` separately, and
the commit didn't say how it counted those. A type like
`TemperCore.Vec.t(Temper.Orm.Query.t())` counts as precise either way.

## What still says little

- **Interfaces.** 19% of the ORM's types and 13% of std's are "any Temper
  object", and since that union includes `struct()`, any struct passes.
  Dialyzer can't express "a class that implements `Shape`".
- **Builders, generators, promises.** These are still `TemperCore.Ref.t()`
  (29 types in the ORM, 6 in std). Their classes live in temper-core, not
  in a module this backend writes.
- **Type parameters.** These are still `term()`. A spec can name a
  variable (`@spec get(t) :: t when t: var`, and temper-core's own `cast/2`
  does), but Dialyzer checks it as `term()` and does not connect the
  argument to the result. Writing `Box<T>`'s `get` that way would look
  more precise without checking anything more.
- **Elixir callers.** An object made with `Heap.new/2` or `Actor.start/2`
  from hand-written Elixir is still "some class" to Dialyzer.

The numbers below are from the commit, and I did not rerun them. be-elixir
has 17 backend, 64 functional, 13 grammar, 1 support-code and 3 typespec
tests; ktlint and detekt are clean; temper-core has 106 tests. Spec
warnings stay at 0 on alloy (with std), templight, blimp-highlight,
temper_snake and mainclash, and each one still passes its tests with 0
compile warnings. The swaps above ran on Elixir 1.18.4, OTP 28.
