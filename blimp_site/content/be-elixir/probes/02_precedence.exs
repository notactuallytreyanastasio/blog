# does `not` bind tighter than ==? `not 1 == 2` errors if (not 1) == 2
r = try do
  Code.eval_string("not 1 == 2") |> elem(0)
rescue e -> {:raised, e.__struct__}
end
IO.inspect(r, label: "not 1 == 2")
IO.inspect(Code.eval_string("-2 ** 2") |> elem(0), label: "-2 ** 2")
IO.inspect(Code.eval_string("1 < 2 == true") |> elem(0), label: "1 < 2 == true")
IO.inspect(Code.eval_string("true or false and false") |> elem(0), label: "true or false and false")
IO.inspect(Code.eval_string("\"a\" <> \"b\" == \"ab\"") |> elem(0), label: "<> vs ==")
IO.inspect(Code.eval_string("[1] ++ [2] -- [2]") |> elem(0), label: "++ -- right assoc")
IO.inspect(Code.eval_string("10 - 2 - 3") |> elem(0), label: "10-2-3")
IO.inspect(Code.eval_string("2 * 3 + 1 < 8") |> elem(0), label: "2*3+1<8")
r2 = try do Code.eval_string("1 < 2 < 3") |> elem(0) rescue e -> {:raised, e.__struct__} end
IO.inspect(r2, label: "1 < 2 < 3")
IO.inspect(Code.eval_string("f = fn a, b -> a + b end; f.(1, 2)") |> elem(0), label: "fn call")
IO.inspect(Code.eval_string("x = if true, do: 1, else: 2; x") |> elem(0), label: "if expr")
