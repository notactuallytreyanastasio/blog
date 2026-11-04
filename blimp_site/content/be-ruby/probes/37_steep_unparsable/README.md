`lib/m.rb` defines a constant named `BEGIN`, which is a keyword, so Ruby
cannot parse the file (`ruby -c lib/m.rb`). It also has a plain type error.
Steep 2.1 reports "No type error detected" and exits 0. The be-ruby
harness therefore compiles every generated file before running Steep.
