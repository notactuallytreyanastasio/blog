# 2026-10-10: lists, and a sort that is stable at forty

Thirty-four of sixty-six. The new six are mostly lists: Temper's `List`,
`ListBuilder`, and the `Listed` interface they share, plus functions used
as values, because you cannot do much with a list without handing it a
function. A Temper list becomes a Ruby Array, which is the obvious choice
and the right one. This entry is about the places where an Array is
almost a list.

## A List is a frozen Array

Temper has two list types. A `List` is immutable, and `[1, 2]` makes one.
A `ListBuilder` is mutable. Ruby has one Array, and an Array can be
frozen, so a List is a frozen Array and a ListBuilder is an unfrozen one:

```ruby
VALS = [2, 3, 4].freeze
```

The freezing does real work. `toList()` on a ListBuilder has to copy,
because the builder can change later and the List must not. On a List,
`toList()` should give back the list itself, since copying an immutable
thing is just a way to spend memory. The frozen flag is how temper-core
tells the two apart at runtime:

```ruby
def self.list_to_list(list) = list.frozen? ? list : list.dup.freeze
```

JavaScript's Temper runtime does the same thing with `Object.freeze`,
which is reassuring. It means somebody else had this problem first, and
picked the same answer.

## Ruby's indexing is generous

Temper's `ls[i]` panics outside `[0, length)`. Ruby's is friendlier,
which is a problem when you are a compiler:

```
a[-1]  (Temper: panic)                       30
a[3]   (Temper: panic)                       nil
a.fetch(-1)                                  30
b = a.dup; b[5] = 1; b  (Temper: panic)      [10, 20, 30, nil, nil, 1]
[].pop  (Temper: panic)                      nil
a.insert(5, 1)  (Temper: panic)              [10, 20, 30, nil, nil, 1]
[].inject(&add)  (Temper reduce: panic)      nil
```

(`probes/19_arrays.rb`.) A negative index counts from the end. Reading
past the end is `nil`, which flows on until something three calls away
tries to add 1 to it. Writing past the end pads the array with nils,
which I find genuinely charming and would not want anywhere near a
program. `fetch` raises past the end but still takes `-1` as the last
element. So every index goes through temper-core, which checks it and
panics:

```ruby
def self.list_get(list, index)
  raise Panic, "index #{index} out of bounds" unless index >= 0 && index < list.length

  list.fetch(index)
end
```

Where Ruby's own method means exactly what Temper's does, the generated
code uses it: `length`, `empty?`, `push` for an `add` with no position,
`concat`, `clear`, `reverse!`, `dup` for `toListBuilder`, and `map` and
`select` with the function passed as a block, `VALS.map(&f).freeze`.

## The sort that was stable at forty

Temper's `sorted` and `sort` are stable: elements that compare equal keep
their order. Ruby's `sort` is a quicksort, and quicksort is not stable.
But I checked anyway, and the first check said it was:

```
sort stable for 40 items                     true
```

That would have been a nice afternoon. Then I tried other sizes:

```
sort stable for 8 items                      false
sort_by stable for 8 items                   false
sort stable for 40 items                     true
sort_by stable for 40 items                  true
sort stable for 100 items                    false
sort stable for 1000 items                   false
```

Forty is a coincidence of the pivots. Eight is not stable, a hundred is
not, a thousand is not. If the probe had stopped at its first size, which
was forty because forty is a nice round number, I would have believed it
and written `list.sort { ... }`. In fairness to the process, the
functional test would then have caught me. It sorts nine items, and
Ruby's sort puts them in the order `[3, 0, 6, 4, 1, 7, 2, 8, 5]` where
Temper wants `[0, 3, 6, 1, 4, 7, 2, 5, 8]`. (I had first written here that
nine came out right too, then checked, and it does not. The probes are
for my claims as much as for Ruby's.) But that is one test at one size,
standing between a wrong belief and a shipped bug, and I would rather
the belief had never formed.

So temper-core sorts with the original position as a tiebreak, which
makes any sort stable:

```ruby
def self.stable_sort(list, compare)
  list.each_with_index.sort do |(a, i), (b, j)|
    order = compare.(a, b)
    order.zero? ? i <=> j : order
  end.map(&:first)
end
```

Its test sorts at 8, 100 and 1000, because the lesson of the afternoon
is that one size is not a test.

## A function as a value, three ways

The frontend hoists a callback like `{ sum, n => sum + n }` into a module
function and passes the function by name. So the backend needs "a module
function, as a value", which Ruby spells `method(:fn)`. That runs. Steep
refuses it:

```
lib/m.rb:4:29: [error] Cannot pass a value of type `::Method` as an argument of type `^(::Integer) -> ::String`
```

(`probes/20_steep_method_value/`.) A Method is not a proc type, as far
as RBS is concerned. A lambda that calls the function is, so the second
draft wrote `->(a, b) do fn(a, b) end` at each use. Steep accepted that
when the lambda went to an ordinary method and refused it when the lambda
went to a generic one, like `TemperCore.listed_reduce`, which is
`[T] (Array[T], ^(T, T) -> T) -> T`:

```
lib/g.rb:11:58: [error] Cannot pass a value of type `T(3)` as an argument of type `::Integer`
```

Steep does not work out `T` from the list before it looks at the lambda,
so the lambda's parameters have no type. The same lambda stored in a
constant with a declared type is fine (`probes/21_steep_lambda_inference/`
has all six cases). So that is the third draft, and it is better on
every count I care about: the lambda is made once instead of at every
use, and it reads like something a person wrote:

```ruby
def self.hello(how)
  TemperCore.console_log("Called " + how + "!")
end
...
HELLO = ->(a) do
  hello(a)
end
hello("directly")
call_it(HELLO)
DelayedFunction.new(HELLO).call_it()
```

with `HELLO: (^(String) -> void)` in the signature. Along the same lines,
Steep cannot type `[].freeze`, an empty array with no element type, so
an empty List is `TemperCore.empty_list`, one shared frozen Array. Its
generic signature, `[T] () -> Array[T]`, lets Steep take the element type
from wherever it is going.

## The split that was not connected

`TypesListOperations` still fails, and why it fails is the best find of
the chapter. Its output was nearly right:

```
expected                     got
Split , g, , h, i - 5        Split g, h, i - 3
Split ,  - 2                 Split  - 0
Split  - 1                   Split  - 0
```

The generated code said `strings = string.split(sep)`. I had not written
anything for `String.split`. Here is what happened. Temper's builtin
methods are `@connected`, which means each backend supplies its own
version. When a backend does not supply one, the frontend falls back to an
ordinary method call by the member's name. Ruby has a `String#split`. It
is a fine method, and it is not Temper's:

```
" g  h i".split(" ")   ["g", "h", "i"]
" ".split(" ")         []
"".split(" ")          []
"a,b,,".split(",")     ["a", "b"]
```

A single space means "any run of whitespace, ignoring the ends", awk
style, and trailing empty strings are dropped. So the program ran and
printed something plausible. That is the exact failure the house rules
are about: no crash, no error, just a quietly wrong answer that happens to
look like an answer.

And `split` was not the only one. Every Temper builtin without a Ruby
mapping was silently becoming whatever Ruby method shared its name. So
the backend now answers every connected key it does not know with support
code that stops the build, naming the key:

```
TODO not connected: core.type String.split()
```

With that in, several tests that used to fail with a vague `ruby failed:
exit code 1` now stop at build time and name what is missing:
`String.get isEmpty()`, `String.toInt32()`, `String.toFloat64()`.
That is the to-do list for the next entry, and for once the compiler
wrote it.

## Nulls that mean "the default"

One more from `TypesListOperations`. Temper source can pass `null` for
an optional argument to mean "use the default":

```temper
ignore(copyThat.splice(null, 0, oldWords));
```

That arrives in Ruby as a real `nil`, which `Integer#clamp` does not
enjoy:

```
'TemperCore.list_builder_splice': undefined method 'clamp' for nil (NoMethodError)
```

So `splice`, `add` and `addAll` take nil as the default in temper-core:
from the start, everything, or the end.

## Where it stands

Thirty-four of sixty-six, all typed. temper-core is up to 32 minitest
runs and still passes Steep.

**Not done:** strings, which the new guard has now listed precisely
(`split`, `isEmpty`, `toInt32`, `toFloat64`, string indices,
StringBuilder). Then maps, `Deque` and `DenseBitVector`. A generic module
function used as a value stops the build, because a constant cannot be
generic. Closures written inline and handed straight to a generic method
probably have the same Steep problem as the lambdas above. No test has
done that yet, so the fix can wait for one.
