# 2026-10-10: `console.log` is not `puts`, and one test of sixty-six

The first functional test passes through real translation. It is
`AlgosHelloWorld`, which is a program that says hello, world, which you
could reasonably argue the placeholder translator already did. But now it
says it because the Temper told it to:

```temper
console.log("Hello, World!");
```

```ruby
# frozen_string_literal: true
require("temper_core")
module Temper
  module RubyHello
    TemperCore.console_log("Hello, World!")
  end
end
```

One of sixty-six. The other sixty-five are skipped, and
`onlyPasses(ruby(), Ft.AlgosHelloWorld)` in `FunctionalTestStatus.kt` is
the list that will grow.

## Why it is not `puts`

The obvious translation of `console.log(x)` into Ruby is `puts(x)`. It
is so obvious that it is what the placeholder printed with. It is also
wrong, in two ways that only show up on inputs nobody writes in a hello
world:

```
puts "a\n" [a
]
puts ["x", "y"] [x
y
]
write("a\n", "\n") [a

]
```

(`probes/08_puts.rb`; the brackets show where each call's output starts
and stops.) `puts` adds a newline *unless the string already ends in
one*. That is a lovely convenience if you are a person typing at a
terminal, and it means `console.log("a\n")`, which prints `a` and two
newlines everywhere else, prints one in Ruby. And `puts` of an array
prints each element on a line of its own, which is also a lovely
convenience, for someone. So `console.log` goes to temper-core:

```ruby
def self.console_log(message)
  $stdout.write(message, "\n")
  nil
end
```

The string, then a newline, no opinions. temper-core's tests pin both
cases: `console_log("a\n")` writes `"a\n\n"`, and `console_log("")`
writes `"\n"`.

## Where the console went

The translator also has to deal with the console *object*. Temper
writes `console.log("hi")` as a call to `log` with a receiver, and the
receiver is a module-level temporary the frontend injects, typed
`GlobalConsole`. be-elixir and be-rust skip that temporary entirely,
since Ruby has no console object and `console_log` ignores its receiver
anyway.

This passed the functional test and then failed on the very first
library I built by hand:

```
kotlin.NotImplementedError: An operation is not implemented: expression: console#0
```

In the test, the receiver is a direct call to `getConsole()`, which
becomes `nil`. In a real build it is a *reference* to the skipped
temporary, which the translator had never seen, because the test never
produced one. So the translator now remembers which names it skipped as
console temporaries, and a reference to one of those becomes `nil`.
A reference to anything else still stops the build with the node in the
message, which is the whole point of the TODOs: this one took two
minutes to find because it said exactly what it was.

## How far there is to go

With the skip list removed, the suite says where every other test stops
first:

```
50 module level declaration    (a top-level let or var)
11 type declaration            (a class or interface)
 3 module function             (a top-level function)
 1 callable                    (a method call on a value: 1.min(3))
```

That is only the first wall each test hits; there are walls behind it.
But fifty of sixty-five starting at the same place says where to start.

**Not done:** everything on that list. Also, generated code still has no
RBS signatures; the runtime is the only typed thing so far.
