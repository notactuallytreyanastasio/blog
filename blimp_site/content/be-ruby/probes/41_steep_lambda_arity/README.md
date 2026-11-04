Steep 2.1 accepts a lambda with two required parameters as a value of
type `^(String, ?String?) -> String`, though Ruby raises ArgumentError when
it is called with one argument. A lambda checks its arity; a proc would
not. `ruby lib/m.rb` prints one line and then raises; `steep check` says
"No type error detected".
