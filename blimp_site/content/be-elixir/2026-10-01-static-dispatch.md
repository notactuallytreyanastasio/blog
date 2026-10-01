# 2026-10-01: a concrete class is the class

Every method call, getter and setter on a translated object used to go
through `TemperCore.call(obj, :m, args)`. That is an `apply` on a module
looked up from the object at run time. It is correct, but it is slower
than a direct call, and the reader cannot see which method runs.

Most of those lookups were unnecessary. Temper does not allow extending a
concrete class, which I checked against the compiler, not the docs:

```temper
class A { public m(): Int { 1 } }
class B extends A { public m(): Int { 2 } }
```

```
[-work/src/s.temper.md:4+20-21]@S: Cannot extend concrete type(s) A
Build failed
```

So when a receiver's static type is a concrete class, the object belongs
to exactly that class, and the call can name its module directly. This
covers classes from other libraries too, like std's. From the tour in the
guide:

```elixir
Temper.Tour.Point.plus(Temper.Tour.Point.new(1, 2), Temper.Tour.Point.new(3, 4))
Temper.Tour.Counter.bump(TemperCore.Global.get(:"Temper.Tour.c__25"))
Temper.Tour.Point.get_x(o)
```

Only a receiver typed as an interface still waits until run time:

```elixir
TemperCore.call(TemperCore.Global.get(:"Temper.Tour.s__27"), :area, [])
```

The type comes from the receiver's static type (`passType`), not from the
type that declares the method. A method declared in an interface and
copied into a class is still called on the class when the receiver is
typed as that class.

In translated std, `TemperCore.call` sites went from 182 to 105, and
every one left is an interface-typed receiver. 65 of 65 still pass.

## The guide, rewritten

The guide had been written one chapter at a time. Its first seven
sections described a backend that no longer existed: NaN as a compile
error, a single `TemperMain` module, and every method call dynamic. It is
now one document, written against a single program, *the tour*, whose
real output it quotes. Its last section lists the limits a program
actually runs into.
