# 2026-10-10: a backend that says hello whatever you tell it

`temper build -b ruby` exists now. You give it a Temper library, and it
ignores the library and writes a gem that prints Hello, World!. This is on
purpose. It is how be-elixir started too, and the idea is that before you
translate anything you find out where the files go and how the program
gets run, so that when the real translator fails you know it was the
translator.

```
temper.out/ruby/ruby-hello/
  temper-ruby_hello.gemspec
  lib/temper/ruby_hello.rb
```

```
$ temper run -b ruby --library ruby-hello
Hello, World!
```

## The first version did not say hello

The first version said this:

```
lib/temper/ruby_hello.rb:2:in '<top (required)>': uninitialized constant Temper (NameError)

module Temper::RubyHello
       ^^^^^^
```

I had written `module Temper::RubyHello`, which is the tidy way to write a
module inside a module if the outer one already exists. If it does not,
Ruby will not make it for you; it raises. Fine, that is a loud failure,
and loud failures are the good kind. The quiet part is what happens once
`Temper` *does* exist, say because temper-core or another library defined
it first. Then the compact spelling works, and it means something slightly
different from the nested one:

```
module Outer::Inner (no Outer)           "NameError: uninitialized constant Outer"
nested: X inside Inner                   "Outer::X"
compact: X inside Outer::Inner           "NameError"
```

(`probes/05_nested_modules.rb`.) Constant lookup in Ruby is lexical. Inside
`module Outer; module Inner`, a constant defined in `Outer` is in scope.
Inside `module Outer::Inner` it is not, because `Outer` was never opened.
So the same generated file would either crash or not depending on which
gem happened to load first, and once it loaded, would see a different set
of names than its nested twin. The backend writes the nested form,
always:

```ruby
# frozen_string_literal: true
module Temper
  module RubyHello
    puts("Hello, World!")
  end
end
```

## Why `Temper::` at all

A Temper library called `set` would otherwise be `module Set`, which is
not a new module. It is Ruby's `Set`, reopened, with your library's
functions added to it. Ruby will let you do that to its own classes
without a word, which is a whole philosophy. Every library goes under
`Temper::`, and the gem is named `temper-<library>` with underscores,
because a dash in a gem name means a namespace by RubyGems convention
(`net-http` is required as `net/http`).

## No Bundler

A run is `ruby -I lib -e 'require "temper/ruby_hello"'` from the
library's directory. Requiring the library runs its top-level statements,
which is what running a Temper program means. Bundler is not involved: a
library's dependencies will be sibling directories, a load path is all
they need, and `bundle exec` costs real time per run across a test suite
of sixty-odd programs.

## What it tells the frontend

`RubySupportNetwork` makes the same choices Python's does: bubbles are
exceptions, function values are functions, there are no computed jumps,
and coroutines become generators (which will be `Fiber`s). The difference
from be-elixir is that every one of these is the natural Ruby thing rather
than a negotiated settlement.

It also maps no builtins at all yet, so a library that calls
`console.log` fails to build with `Cannot translate value fn getConsole`.
That is the next entry's problem, after the runtime exists.

**Not done:** any translation; temper-core; types; tests.
