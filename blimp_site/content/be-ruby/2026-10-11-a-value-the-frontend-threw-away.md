# 2026-10-11: functions as values, and a value the frontend threw away

Sixty-eight of sixty-eight. Entry 14 ended with two things that still
stopped the build, both about using a function as a value rather than
calling it: a generic one, and one from another library. No test used
either, which is how they survived to the end, and also how you know
they were next. So this chapter began with a fresh program about
function values (`probes/40_fresh_function_values/`), and the most
interesting thing in it turned out not to be about function values.
Function values first.

## A generic function is not a value until you say which one

My first draft passed `identity` where an `fn (Int): Int` was wanted.
Temper refuses:

```
Cannot assign to fn (Int32): Int32 from fn<T__0 extends AnyValue>(T__0): T__0
```

which is fair, if strict. You have to pick the instance yourself,
`identity<Int>`. Temper's interpreter runs that. Then I asked the other
backends. JavaScript writes this near the top of the module:

```js
const fLtGt = (() => {
    throw "builtin <> not supported by JS backend";
})();
```

so the module throws while it loads and prints nothing at all. Python
writes `('<<notSupported(<>): Builtin(<>, null, species=Pure)>>',
NotImplemented)[1]` wherever the function value goes, and fails when one
is called: `TypeError: 'NotImplementedType' object is not callable`. It
prints three lines first, only because the frontend had already inlined
`ints(5)` to `5`. So the reason no test does this may be that no backend
can.

Here is why. When `identity<Int>` is called, the frontend strips the
`<Int>` and the backend sees a plain call. When it is a value, the
frontend leaves it as a call to a builtin function named `<>`, with the
function and the type as arguments, and asks each backend for support
code for `<>`. Nobody has any.

Ruby has no type arguments to apply, so at run time `identity<Int>` is
just `identity`. The interesting part is the type. Entry 7 made a module
function used as a value into a constant holding a lambda, declared with
its proc type, because Steep will not accept `method(:fn)` where a proc
is wanted (probe 20). The obvious version for a generic function is the
same constant with its types erased, `^(untyped) -> untyped`. That would
pass Steep, and it would also pass everything else, which is not what a
type checker is for. A constant's type cannot be generic in RBS, but each
use of `<>` names a concrete type, so each instantiation gets its own
constant:

```ruby
IDENTITY = lambda do |a|
  identity(a)
end
IDENTITY_2 = lambda do |a|
  identity(a)
end
```

```rbs
IDENTITY: (^(Integer) -> Integer)
IDENTITY_2: (^(String) -> String)
```

and Steep checks each lambda's body against its own signature. Getting
that signature took two tries. The `<>` call's own type should have been
the instantiated function type, and it arrives as `Invalid`, which is
also why the frontend logs `Cannot translate Invalid` beside it. So the
translator substitutes the type arguments into the function's signature
itself. The function reference's type carries the parameter types in
terms of `T` but not the list of formals, so the formals come from the
declaration. Turning the result into RBS needs the frontend's
`TypeTranslator`, which is internal to the `be` module, so `be` now has a
public `translateSignatureForBackend`. Until now this branch had changed
nothing outside be-ruby except the shared functional test suite. That
helper is the first change to the compiler itself, and the fix two
sections down is the second.

Another library's function as a value is the same constant with a
receiver, typed from the reference:

```ruby
ENTIRE = lambda do |a|
  Temper::Std.entire(a)
end
```

What still stops the build is the combination, another library's
*generic* function with type arguments, `listJsonAdapter<Boolean>`. Its
declaration is in the other library, so the formals are nowhere this
library can see them. I checked: the interpreter runs it, and Ruby stops
with `type formals of listJsonAdapter__0, from another library`.

## A lambda that counts its arguments, and a checker that does not

`greet(name: String, punctuation: String = "!")` as a value came out as:

```ruby
GREET = lambda do |a, a_2|
  greet(a, a_2)
end
```

```rbs
GREET: (^(String, ?String?) -> String)
```

The signature says the second argument is optional. The lambda says it
is not, and a Ruby lambda checks: `GREET.("you")` raises `wrong number of
arguments (given 1, expected 2)`. I asked Steep about exactly this
(`probes/41_steep_lambda_arity/`):

```
ruby:
"hello you!"
lib/m.rb:5:in 'block in <module:M>': wrong number of arguments (given 1, expected 2) (ArgumentError)
steep check:
No type error detected. 🫖
```

Temper happens not to let you call it with one argument (it rejects
`greet` as an `fn (String): String`), so nothing could go wrong today. But
the signature was false, and the lambda now matches it, `|a, a_2 = nil|`.
That is the second time Steep has said "No type error detected" about
something Ruby will not run (entry 12 was the first), so Steep's silence
here is one piece of evidence, not the proof I might like it to be.

## The value the frontend threw away

Ruby printed all fifteen lines of the fresh program correctly, matching
the interpreter. Then I ran Steep on it, because the harness would, and
Steep said:

```
lib/temper/fresh_function_values.rb:51:13: [error] Type `singleton(::Temper::FreshFunctionValues)` does not have method `return_`
       return return_
```

That is entry 12's error, a `return` of a temporary nobody assigned, in
this function:

```temper
let firstOk(f: fn (String): Int throws Bubble, inputs: List<String>): Int {
  for (var i = 0; i < inputs.length; ++i) {
    let r = f(inputs[i]) orelse continue;
    return r;
  }
  -1
}
```

and the Ruby had no `-1` in it anywhere. Neither did JavaScript's: it
returned an unassigned `return_28`, so `undefined`. So the frontend had
thrown the `-1` away before any backend saw it, and every backend had
dutifully translated what was left. The test program never asked for a
case where nothing parses, so all four runtimes agreed, and only the type
checker could see the hole.

My first theory was that Temper reads the `}` followed by `-1` on the
next line as one subtraction, the loop minus one. I wrote that theory
down and then tested it, and it was wrong: a loop with a `return` in it
followed by `-1` works fine. What it takes is a `return` in the loop and
also a `continue` or `break` (`probes/42_lost_trailing_value/`):

```temper
let a(inputs: List<String>): Int {
  for (var i = 0; i < inputs.length; ++i) {
    if (inputs[i] == "") { continue; }
    return i;
  }
  -7
}
```

Called with `[""]`, which skips the `return`:

```
interp   a: [1]   b: [1]   c: [0]   d: [-7]
js       TypeError: Cannot read properties of undefined (reading 'toString')
py       UnboundLocalError: cannot access local variable 'return_1' where it is not associated with a value
ruby     undefined local variable or method 'return_' for module Temper::Minus (NameError)
```

`b` is the same function with `42` instead of `-7`, `c` uses `break`,
and `d` has no `return` in its loop. The three backends at least fail.
The interpreter, which is the reference everything else is checked
against, answers `1` and `0`, which are the values `i` had when the loop
ended. I have not found out why it returns those in particular, and with
the fix it no longer matters.

The cause is in the frontend pass that turns a function's last expression
into its result (`UnsetTerminalExpressions.kt`). The `return` macro
leaves behind an assignment to the function's `return` variable, and the
pass does not treat an expression as the result if every path to it has
already made that assignment. It walks the code once, front to back, and
for a loop it walks the body and carries what it learned out of the loop.
A body that ends `return i;` has always assigned `return` by its last
line, so after the loop, the pass concluded, the result was settled and
the `-7` was dead code. But a loop can end without finishing its body:
the condition can fail before the first pass, and a `continue` or `break`
can jump past the `return`. Actually, no path that reaches the code after
a loop has been through a `return` inside it, because `return` leaves the
function. The fix merges what was known before the loop with what was
known after it, which says "sometimes", which is the truth:

```kotlin
// a loop can be left without finishing its body: the condition can fail
// first, and a `break` or `continue` can skip what follows it
notes = mergeNotes(beforeLoop, notes)
```

The new unit test (`assignmentInLoopBodyMayNotHappen`) fails without that
line and passes with it. The frontend's 721 tests, be-js's 200 and
be-ruby's all pass. The probe now prints `-7`, `42`, `-7`, `-7` on the
interpreter, JavaScript, Python and Ruby, and the program is a shared
functional test, `RegressionTrailingValueAfterLoop`, which passes on the
interpreter, JavaScript and Ruby. be-py's harness stops here at its mypy
step, for the same environmental reasons as before, so Python's result
comes from the command line, not the harness.

So a Ruby backend's type checker found a bug in Temper's frontend that
made Temper's own interpreter return the wrong number without
complaining. That is a good argument for running Steep on everything,
and also a slightly awkward fact about the reference implementation.

## Where it stands

Sixty-eight of sixty-eight, all typed, with no skip list. The fresh
function-value program agrees with the interpreter on all sixteen lines,
and passes Steep. The four earlier fresh programs give the same Ruby
output as before this chapter. temper-core is still at 66 minitest runs.
Fifteen entries and forty-two numbered probes.

**Not done**: another library's generic function as a value with type
arguments stops the build with a TODO. JavaScript and Python cannot use
a generic function as a value at all, which I have written down here and
reported nowhere, along with entry 14's list. *Entry 16: two items on entry 14's list had been
reported, as #556 and #579.*
