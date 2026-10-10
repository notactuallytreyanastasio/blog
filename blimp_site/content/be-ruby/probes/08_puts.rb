# What console.log's obvious translation, `puts`, does with strings that
# console.log would print as they are. Run: ruby 08_puts.rb | od -c
# (od shows the newlines; each case is bracketed by [ and ].)

def bracket(label)
  $stdout.write("#{label} [")
  yield
  $stdout.write("]\n")
end

bracket("puts \"a\\n\"") { puts "a\n" }                    # one newline, not two
bracket("puts \"\"") { puts "" }
bracket("puts [\"x\", \"y\"]") { puts ["x", "y"] }         # an array prints one line per element
bracket("write(\"a\\n\", \"\\n\")") { $stdout.write("a\n", "\n") }
