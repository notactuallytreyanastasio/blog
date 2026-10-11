`before.rb` is what be-ruby generated for `stale.temper.md` before journal
entry 10, and `after.rb` is the fix. The difference is one line, `x = nil`
in the `else` branch. Without it a Ruby local keeps its value from the
previous pass of the loop, and the program prints `x is 5` three times.
JavaScript, Python, Java, Rust, C++ and Elixir print 5, -1, -1.
