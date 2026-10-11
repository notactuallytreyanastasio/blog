# 2026-10-10: maps, and a nil that equalled another nil

Fifty-one of sixty-seven. That is five more passing tests and one more
test, which I added because I found a bug that had been there since entry
7 and no test had noticed. The bug is the most interesting thing in this
entry, so I will get to it after the part you came for.

The part you came for is the remaining collections: `Map`, `MapBuilder`,
`Pair`, `Deque` and `DenseBitVector`. They are mostly unremarkable, which
is the nice thing about having already done lists. Two of them turned up
a disagreement with JavaScript's runtime anyway, and in both the
reference implementation is the one that is wrong.

## A Map is a frozen Hash

Same move as lists. A `Map` is a frozen Hash, a `MapBuilder` an unfrozen
one, and `toMap()` copies a builder and hands back a Map unchanged.
Ruby's Hash keeps insertion order, which Temper requires, and agrees with
JavaScript's `Map` on the details:

```
overwrite keeps position                       ["key", "other"]
delete then add goes to end                    ["other", "key"]
to_h, duplicate key: first position, last value {1 => :c, 2 => :b}
fetch with fallback, value nil                 nil
delete key whose value is nil                  nil
```

(`probes/25_hashes.rb`.) That last line is why removing a key goes
through temper-core. `Hash#delete` answers nil for a missing key and nil
for a key whose value is nil, and Temper's `remove` must bubble on one
and not the other. Here is the functional test's map, as generated:

```ruby
MESSAGES = TemperCore.map_from_pairs([TemperCore::Pair.new(200, "OK"), ...].freeze)
MESSAGE = TemperCore.mapped_get(MESSAGES, 200)
...
return MESSAGES.key?(code).to_s
...
BUILDER.store("Honduras", ["El Salvador", "Guatemala", "Nicaragua"].freeze)
```

Then one probe line that I would not have guessed:

```
each(&two) directly                            ArgumentError: wrong number of arguments (given 1, expected 2)
map(&two)                                      ["a=1"]
each_pair(&two)                                ArgumentError: wrong number of arguments (given 1, expected 2)
```

`two` is a lambda with two parameters. `Hash#map` will hand it a key and a
value. `Hash#each`, and `each_pair`, whose whole name is about pairs,
hand it a single `[key, value]` array, and the lambda's arity check
refuses it. So `forEach` is written out in temper-core with an explicit
`|key, value|` block, which works with everything.

## `getOr`, and a fallback for a key that exists

I wrote a fresh map program, about fifty lines of edge cases, and ran it
on JavaScript, Python and Ruby (`probes/31_fresh_maps/`). Ruby agrees with
JavaScript on twenty-two lines out of twenty-three. Here is the other one:

```
< getOr key with null value: [fallback]     (JavaScript)
---
> getOr key with null value: [null]         (Ruby, and Python)
```

The map has the key `"n"`, with the value `null`. Temper's documentation
says `getOr` falls back "when no such key exists". The key exists. Here is
JavaScript's runtime:

```js
export const mappedGetOr = (map, key, fallback) => {
  return map.get(key) ?? fallback;
}
```

`??` means "if the left side is null", and the left side is null, because
that is the value. So JavaScript answers the fallback for a key that is
present. Python's answer matches the documentation, and so does Ruby's
`fetch(key, fallback)`, which is Ruby's own method and means exactly what
Temper says. Last entry, Ruby sided with JavaScript wherever the two
references disagreed, on the theory that JavaScript is the reference.
That theory survives contact with an ambiguity. It does not survive
contact with the documentation.

## Steep and the key

RBS 4.2 types a Hash key as `Hash::_Key`, the interface for anything with
`hash` and `eql?`. An unbounded type parameter does not satisfy it, so
temper-core's `[K, V] (Hash[K, V] map, K key) -> V` could not even call
`map[key]`. Bound it, `[K < ::Hash::_Key, V]`, and `map[key]` is fine, and
then this happens:

```
lib/m.rb:5:37: [error] Unsatisfiable constraint `K <: K2(2) <: ::Hash::_Key` is generated through (K2(2)) { (K2(2)) -> X(3) } -> (V | X(3))
lib/m.rb:24:37: [error] Unsatisfiable constraint `K <: K(18) <: ::Hash::_Key` is generated through (::Hash[K(18), V(19)], K(18)) -> (V(19) | nil)
```

(`probes/26_steep_hash_key/`.) Steep cannot pass a type parameter bounded
by `_Key` on to a method that declares a bounded type parameter of its
own. `Hash#fetch` with a block is one of those methods. So is every other
temper-core function, once they are all bounded. So temper-core's map
functions take an unbounded `K`, and where they hand a key to `fetch`
they annotate it `untyped` first. That is a few lines of honest
`untyped` inside temper-core, in exchange for precise signatures for
everyone who calls it. The generated signatures go the other way: Temper's
`MapKey` bound becomes `::Hash::_Key`, which is what it means, and a
bounded parameter can be passed to an unbounded one.

```rbs
def self.list_keys: [K < ::Hash::_Key, V] (Hash[K, V] mapped_2) -> Array[K]
```

## A Deque is an Array, and a bit vector is bits

JavaScript's runtime implements `Deque.removeFirst` with a hidden count of
taken elements, and splices the array only now and then. That looks like
over-engineering until you time `shift` in node 24:

```
push 100000, then shift 100000, ms 628
push 1000000, then shift 1000000, ms 130016
```

Ten times the work, two hundred times the time, which is what you get if
each `shift` moves everything left. (`probes/27_shift.js`.) Here is CRuby:

```
push 100000, then shift 100000, seconds        0.006
push 1000000, then shift 1000000, seconds      0.058
```

(`probes/27_deque_and_bits.rb`.) Ten times the work, ten times the time.
Whatever CRuby does on a `shift`, it is not moving the rest of the array.
So a Deque is a temper-core class around a plain Array. It is a class so
that a Deque is not also a ListBuilder, and so that removing from an empty
one raises a panic, as Temper documents, where `shift` would answer nil.

A `DenseBitVector` is a binary String with eight bits to a byte. An Array
of booleans was 2.5 times faster to fill in the probe, and it spends 64
bits on each bit. A bit vector's only job is to save memory, so it should
use bits. Then I checked the edges on all three backends
(`probes/32_fresh_bits/`):

```
== js
set 1000 on an empty vector, get 1000: [false]
set 200 on a 16-bit vector, get 200: [false]
== py
set 1000 on an empty vector, get 1000: [true]
set 200 on a 16-bit vector, get 200: [true]
== ruby
set 1000 on an empty vector, get 1000: [true]
set 200 on a 16-bit vector, get 200: [true]
```

JavaScript's runtime grows its byte array by doubling it once. If the bit
is further out than that, the write lands past the end of a `Uint8Array`,
and a typed array ignores writes past its end without complaint. So
`set(1000, true)` does nothing, and `get(1000)` says false. temper-core
grows the String to at least double, and to however far the bit is if
that is further.

## The nil that equalled another nil

`AlgosMyersDiff` uses both new collections, and with them in place it ran
and printed the right diff. Reading its generated Ruby to see why Steep
still objected, I found this:

```ruby
while true
  if !cost_zero_edges.empty?
    diff_path = cost_zero_edges.remove_first
  elsif !cost_one_edges.empty?
    diff_path = cost_one_edges.remove_first
  else
  end
```

The Temper source says `else { null }`. That `null` is gone. Here is what
a missing `nil` costs, as a three-line program (`probes/28_stale_null/`):

```temper
for (var i = 0; i < 3; i += 1) {
  let x: Int? = if (i == 0) { 5 } else { null };
  console.log("x is ${(x ?? -1).toString()}");
}
```

JavaScript, Python, Java, Rust, C++ and Elixir all print 5, -1, -1. Ruby
printed:

```
x is 5
x is 5
x is 5
```

In Temper, `x` is a new variable on each pass. In Ruby, a local belongs to
the whole method and keeps its value from the previous pass, so if
nothing assigns it, it is still 5.

The cause is entry 7's fix. A Temper local declared with no value becomes
`x = nil` in a list of placeholders, and the translator removes the
placeholders Ruby does not need, because Steep would type a local that
starts as `nil` as nil forever. The list was a map keyed by the
assignment, and the code generator gives every Ruby node structural
equality. A placeholder `x = nil` and a real `x = nil` from `else { null
}` are therefore the same key, and removing one removed both. The fix
compares by identity, and the diff to the generated code is one line:

```
9a10
>         x = nil
```

The functional suite never caught this, for two reasons. Myers diff only
reaches that `else` when both queues are empty, which a successful diff
never does. And elsewhere, a dropped `nil` on the *first* pass is
harmless, because a Ruby local that has never been assigned reads as nil
anyway. You need a loop, a second pass and a null, and nothing in the
suite had all three in a place where it mattered. So that program is now
in the shared suite as `RegressionNullInLoop`. It passes on JavaScript,
Java 17 and Ruby through the harness, and on Python, Rust, C++ and Elixir
through `temper run`. It is a regression test for a bug that only ever
existed in Ruby, which is the cheapest kind of insurance.

## Steep, again, twice

With the nil back, Steep still had two complaints about Myers diff.

First, `path_elements = []`, an empty ListBuilder in a local, is
`UnannotatedEmptyCollection` in strict mode. Locals have no signature, so
the backend now writes Steep's inline annotation:

```ruby
path_elements = [] #: Array[DiffPath]
changes = [] #: Array[Change[untyped]]
```

The `untyped` in the second one is not laziness. `diff` is generic in `T`,
and a method's type parameters are not in scope in an inline annotation
(`probes/29_steep_annotation_scope/`):

```
lib/m.rb:7:24: [error] Cannot find type `::E`
lib/m.rb:15:15: [error] Cannot pass a value of type `T` as an argument of type `::M::T`
```

The second error is better. Name the parameter `T` while a constant `T`
is in scope, and the annotation means the constant. Every functional test
compiles into a module called `T`, so my first try declared `changes` as
an `Array[Change[::Temper::T]]`, changes of a module. `Array.new` would type-check, and the probe shows that it
also stops checking anything at all, without saying so. So the backend
writes each type parameter as `untyped` and keeps the rest of the type,
which leaves Steep everything it can check and shows the reader exactly
what it cannot.

Second, the early return. In entry 7 the frontend's "assign a temporary,
break out, return the temporary" pattern became a plain `return` when the
thing being broken out of was a labelled block. Here it was a `while
true` loop, so the translator now recognizes that too:

```ruby
          return Patch.new(TemperCore.list_to_list(changes))
        ...
      end
      raise "unreachable"
    end
```

The `raise` is for Steep. It types `while true` as nil like any other
`while`, and so it types the method as returning nil
(`probes/30_steep_endless_loop/`). A loop whose condition is `true` and
which nothing breaks out of can only end by returning, so the line really
is unreachable. `loop do` would also have satisfied Steep. But a local
first assigned inside a block belongs to the block, and this loop assigns
a dozen of them.

## Where it stands

Fifty-one of sixty-seven, all typed. temper-core is up to 48 minitest
runs, and still passes Steep.

**Not done**, sixteen tests: generators and async (four), names the
translator cannot find, mostly imports between libraries (four), regular
expressions (two), RBS for `Empty` and `Type` (two), `Date`, `@test`
blocks, a connected function from another library, and `SemanticsBroken`,
which is probably meant to fail everywhere. The JavaScript runtime's `getOr` and
`DenseBitVector.set` disagree with Temper's documentation. I have written
that down here, and nowhere a JavaScript maintainer would see it. The
placeholder bug makes me want a translator test that compiles small
programs and checks the Ruby, not just its output. be-ruby has none yet;
the functional suite is doing that job, and this entry is a fair
description of how well.
