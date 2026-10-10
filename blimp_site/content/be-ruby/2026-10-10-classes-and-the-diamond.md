# 2026-10-10: classes, and who wins the diamond

Twenty-eight of sixty-six functional tests pass, up from eleven. Seventeen
new ones in a chapter is a lot, and it is because classes are the thing
Ruby already has. A Temper class becomes a Ruby class, mostly by writing
it down:

```ruby
class C
  attr_reader(:x, :y)
  def initialize(x, y)
    @x = x
    @y = y
  end
  def echo(input)
    TemperCore.console_log(input)
  end
end
```

That is `AlgosHelloWorldObject`, and you could hand it to a Ruby
programmer without explaining anything. Most of this entry is about the
two places where writing it down was not enough, plus one place where the
first draft was wrong in a way that was briefly very confusing.

## The first draft passed `this` to everything

```
'Temper::T::C#initialize': wrong number of arguments (given 2, expected 3) (ArgumentError)
    |       def initialize(this, x, y)
```

A Temper method's `this` arrives in TmpL as an ordinary first parameter,
and the first draft dutifully gave every Ruby method a parameter called
`this`. Ruby's `self` is implicit, so every call came up one argument
short. That one crashed loudly, which is the good kind. While fixing it,
two pieces of noise went too: getters that only return their own field
(`def x; return @x; end`) are now `attr_reader`, since that is what
`attr_reader` is, and the `return nil` that ended every void method is
gone, since Ruby returns the last value anyway and nobody reads it.

## Temper classes only extend interfaces

That turns out to be the convenient fact. Temper has no class
inheritance, so there is no question of what a Ruby superclass would be.
An interface becomes a Ruby module, a class `include`s its interfaces, and
`is_a?` sees an included module:

```ruby
module Shape
  def describe()
    return "a shape with area " + TemperCore.float_to_string(area)
  end
end
class Square
  include(Shape)
  ...
```

A method the class defines beats one from a module it includes, which is
what Temper's override means. An interface method with no body is simply
not emitted. A class that forgot to implement it gets a NoMethodError,
which is loud, rather than a stub that has to decide what to raise.

## Who wins the diamond

Here is where writing it down stops working. Temper's functional suite
has a test, `ClassesCallOverrideFromSubtype`, that exists to pin down one
question: when two of a class's interfaces both inherit a default method,
whose do you get?

```temper
interface ADeep { a(): String { "A wins!" } }
interface B1Deep extends ADeep { a(): String { "B1 wins!" } }
interface B2Deep extends B1Deep {}
interface CDeep extends ADeep {}

class DDeep extends B2Deep & CDeep {}   // B1 wins!
class EDeep extends CDeep & B2Deep {}   // A wins!
```

The test's own comment on the second one is that it is "different from
Python's C3 linearization", which is the test's way of telling you it is
a trap. Temper's rule is breadth-first: look at the class's direct
interfaces, then their parents, and so on, and the nearest level that
defines the method wins, ties going to declaration order. For `EDeep`,
level two is CDeep's parent ADeep and B2Deep's parent B1Deep, in that
order, so ADeep wins.

Ruby's rule is not that:

```
DDeep  B1 wins!   [DDeep, B2Deep, B1Deep, CDeep, ADeep]
EDeep  B1 wins!   [EDeep, CDeep, B2Deep, B1Deep, ADeep]
EDeep, one include at a time: B1 wins!
EDeep with a forwarder: A wins!
```

(`probes/14_include_order.rb`.) Ruby's ancestor chain puts ADeep last
whichever way round you include things, because a module is only added
once and ADeep is already behind B1Deep. So Ruby says B1 for both, Temper
says B1 for one and A for the other, and the first draft printed `B1
wins!` twice and failed the test. You can see why the test exists.

The fix is to stop relying on Ruby's lookup exactly where it disagrees.
The translator walks the class's interfaces the way Temper does, and for
every method that more than one of them defines, writes a forwarder that
names the winner:

```ruby
class EDeep
  include(CDeep)
  include(B2Deep)
  def a(...)
    ADeep.instance_method(:a).bind_call(self, ...)
  end
end
```

`instance_method` pulls the method off the module, `bind_call` runs it
with `self` as the receiver, and `...` passes every argument through. A
method only one interface defines gets no forwarder, because then Ruby
finds the same one Temper does, and most classes look like they were
written by hand.

## Private properties are protected

A private Temper property is read as `other.backing` inside its class's
methods (an `equals` comparing two instances is the usual reason), so its
reader has to work on another instance from inside the class and not from
outside. That is Ruby's `protected`, and the probe confirms that a bare
`protected()` followed by `attr_reader(:backing)` gets exactly that:

```
other.backing inside the class: true
a.backing outside: protected method 'backing'
```

(`probes/15_protected_attrs.rb`.)

## The names a method may not take

Last entry, a module function was kept off the 177 names a Ruby module
already answers to. A class's methods have the same problem with a
different list: an instance method called `hash` or `freeze` would
override Object's, and Hash keys and the garbage collector rely on those.
`probes/10_taken_names.rb object` lists 111. Static methods are `def
self.` on the class, so they get the module's list plus the six a class
adds, the memorable one being `new`. A Temper class with a static method
called `new` would otherwise have replaced its own constructor.

## Module state from inside a class

Last entry's TODO was that a class's method could not read a module's
`@ivar`, because inside the class `@calls` means the instance's. Now it
writes `Lib.calls`, through a singleton accessor the backend adds to the
module only for the variables some class actually reads:

```ruby
singleton_class.attr_accessor(:calls)
```

Module functions called from a class are `Lib.fib(n)` for the same
reason: inside the module, `self` is the module and `fib(n)` works; inside
a class's method it is the instance, and `fib(n)` would be a NoMethodError.

## Where it stands

Twenty-eight of sixty-six. With the skip list off, the remaining
thirty-eight stop mostly at the standard library: String methods, List
and ListBuilder, Map, StringBuilder, Deque, Date, regular expressions.
After that come functions used as values, generators and async, and
`@test` blocks.

**Not done:** classes from other libraries (imports across libraries),
static `var`s, a property's getter inherited from another library's
interface. And still no RBS for generated code, which matters more now:
a class is where Temper's types have the most to say, and the next entry
is going to make them say it.
