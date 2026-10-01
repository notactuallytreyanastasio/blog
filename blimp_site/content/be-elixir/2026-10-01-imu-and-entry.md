# 2026-10-01: `@imu` is the contract, and the heap collects itself

Two changes that came out of a review of the guide.

## Struct or ref is the annotation's call

The reviewer asked: if someone later adds a field write after
construction, does a library's generated code change in a way that breaks
its consumers? It did. A class was a struct whenever its body happened
not to mutate. Adding one setter turned it into a heap ref, which breaks
consumers three ways:

- `%Lib.Point{}` patterns in Elixir code stop matching
- a value that crossed processes freely no longer does
- `==` goes from comparing fields to comparing identity

Temper already has a way to say "this is immutable", and I checked that
the compiler enforces it:

```temper
@imu class P(public x: Int) {
  public var y: Int = 0;
  ...
```

```
[-work/src/i.temper.md:4+16-27]@G: Class P claims imu but has a `var` property, y
Build failed
```

So now `@imu` means struct and anything else means ref. The old inference
remains as a build-time check: an `@imu` class with a write outside its
constructor is a `TODO` that names it, instead of a struct that silently
drops the write. The tour's `Point` has no `@imu`, so it is now a ref.

The cost shows up in std. Translated std went from 39 structs to 1. Only
`Date` is marked `@imu`, so the JSON node classes, among others, are now
heap refs. A parsed JSON tree that reaches Elixir code is now a set of refs
that needs `export` to cross processes, where before it was plain values.
In return, the representation can never change behind a consumer's back.
The fix belongs in Temper's std: mark those classes `@imu`, which the
compiler would then enforce, and they become structs again.

## A nursery at the library's edge

Entry 15 left `TemperCore.Heap.collect(roots)` as something the host
calls by hand between calls into Temper. Freeing at every exported
function's return, keeping that call's arguments and result, looks
simpler but is wrong. It would free objects the caller got from *earlier*
calls and still holds, a GenServer's state for example, because nothing
in the current call mentions them.

The safe version is generational. `TemperCore.Heap.entry(fun)` wraps the
body of every exported function:

- On the outermost entry, a nursery opens and every `Heap.new` records its
  object as young.
- `Heap.put` on an older object while the nursery is open adds that object
  to a remembered set. This is the write barrier: an old object may now
  point at a young one.
- When the outermost call returns, or raises, marking starts from the
  result, the process dictionary (Temper's globals, the async queue) and
  the remembered objects' fields. It goes only through young objects and
  stops at old ones. Young objects left unmarked are freed.
- Nested entries (Temper calling exported functions, in its own library or
  another) only count depth. Only the outermost one collects.

Nothing older than the call is ever freed, so whatever the caller holds
stays alive. The cost is that something the caller kept and later dropped
is never freed by `entry`; `collect/1` still covers that.

The GenServer from entry 15, with its `collect` call removed, over 100,000
requests:

```
no manual collect: 1 objects, 26 KB, tally 100000, 270 ms for 100k requests
```

Before `entry`, the same run kept 200,001 objects in 49 MB. The one object
left is the long-lived counter, with its count right.

One mistake of mine, caught before any test ran: I keyed the nursery's
bookkeeping as `{TemperCore.Heap, :depth}`. That has the same shape as an
object's key, `{TemperCore.Heap, id}`, so `size/0` would have counted the
bookkeeping as objects and `collect/1` would have deleted it. It now lives
under `TemperCore.Heap.Nursery`.

temper-core: 82 tests, 0 failures, including entry's own tests. They cover
garbage freed, results and older objects kept, a young object an old one
points at, globals and closures, nested entries, and a raise.
