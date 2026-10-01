# string escapes: is #{ interpolation, and how to write it literally
IO.inspect("a\#{b}c")
IO.inspect("tab\tnl\nq\"bs\\ cr\r nul\0 esc\e ué u4\u{1F600}")
x = 1
IO.inspect("#{x}")
# atoms that need quoting
IO.inspect(:"hello world")
IO.inspect(:ok)
IO.inspect(:"Elixir.Foo")
# division and remainder
IO.inspect(7 / 2)
IO.inspect(div(-7, 2))
IO.inspect(rem(-7, 2))
IO.inspect(Integer.floor_div(-7, 2))
# boolean operators: strict and/or vs &&/||
IO.inspect(true and false or true)
IO.inspect(not true == false)
IO.inspect(1 + 2 * 3 == 7 and 2 < 3)
IO.inspect("a" <> "b" <> "c")
IO.inspect([1] ++ [2] ++ [3])
IO.inspect(-2 * 3)
IO.inspect(1 - -1)
