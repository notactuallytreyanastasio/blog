# 2026-10-01: classes as modules, objects as structs or heap refs

Twenty-seven of Temper's functional tests pass, up from eleven. The sixteen
new ones are about classes: HelloWorldObject, casts, getters and setters,
statics, interfaces with and without bodies, overrides, imported types and
mutually referencing types.

## The decision from the first entry, in real output

This Temper

```temper
class Point(public x: Int, public y: Int) {
  public norm1(): Int { x + y }
}

class Counter {
  public var n: Int = 0;
  public bump(): Void { n += 1; }
}

let a = new Counter();
let b = a;
b.bump();
b.bump();
console.log(a.n.toString());
```

prints 2, through this Elixir (trimmed):

```elixir
defmodule TemperMain.Point do
  defstruct [:x__13, :y__14]
  def norm1(this__1) do
    TemperCore.int32(this__1.x__13 + this__1.y__14)
  end
  def new(x__18, y__19) do
    this__4 = %TemperMain.Point{}
    this__4 = %{this__4 | :x__13 => x__18}
    this__4 = %{this__4 | :y__14 => y__19}
    this__4
  end
end

defmodule TemperMain.Counter do
  def bump(this__3) do
    t___24 = TemperCore.int32(TemperCore.Heap.get(this__3, :n__20) + 1)
    TemperCore.Heap.put(this__3, :n__20, t___24)
    nil
  end
  def new() do
    this__7 = TemperCore.Heap.new(TemperMain.Counter, %{:n__20 => nil})
    TemperCore.Heap.put(this__7, :n__20, 0)
    this__7
  end
end
```

`Point` never changes after its constructor, so it is a struct: an ordinary
immutable Elixir value, and its constructor rebinds `this` as it fills the
fields in. `Counter` has a `var` and a setter, so its fields live in
`TemperCore.Heap`, and `a` and `b` are the same object.

The rule: a class with no setter, and no property write outside its
constructor, is a struct. Everything else is a heap ref.

## Calls

A method call goes through `TemperCore.call(obj, :method, args)`, which asks
the object for its class (`__struct__` for a struct, `class` for a heap ref)
and applies the function there. That is always right, including through an
interface-typed variable, at the cost of an `apply` on every call. Calling
the module directly when the receiver's static type is a class is an
optimisation for later.

Interface methods with bodies are copied into each class that does not
override them, as be-blimp does, so no call ever needs to find a super
implementation. `instanceof` checks the module against the class's
`__temper_supertypes__/0`; a builtin type is checked with its guard
(`is_binary`, `is_integer`, ...).

## An Elixir rule, met twice

`temper-core` stopped compiling when `TemperCore.class_of/1` matched on
`%TemperCore.Ref{}`, because `TemperCore.Ref` was defined further down the
same file:

```
error: TemperCore.Ref.__struct__/1 is undefined, cannot expand struct TemperCore.Ref
```

A struct must exist before a *pattern* in the same file names it. Probe 06
had already shown that *building* one inside a function body is fine, which
is why the generated constructors work in any order.

**Not done:** builtin types' statics (`String.begin`, `Float64.pi`) and
connected classes (`StringBuilder`, `Deque`, `DenseBitVector`), local
functions and closures (9 tests stop there), `@test` blocks, async, rest
parameters, and readable field names (`x`, not `x__13`).
