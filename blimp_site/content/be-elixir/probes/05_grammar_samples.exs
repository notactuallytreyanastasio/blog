# Every expected rendering in be-elixir's ElixirGrammarTest, evaluated.
# Each entry is {source, bindings, expected value}; :module means "compiles".
samples = [
  {~S|IO.puts("Hello, World!")|, [], :ok},
  {"""
  defmodule Shapes.Point do
    @moduledoc false
    defstruct [:x, :y]
    def norm1(p) when p.x >= 0 do
      abs_sum(p.x, p.y)
    end
    defp abs_sum(a, b) do
      abs(a) + abs(b)
    end
  end
  """, [], :module},
  {"Shapes.Point.norm1(%Shapes.Point{x: 3, y: -4})", [], 7},
  {"""
  r = case {a, b} do
    {1, _} ->
    :one
    {_, y} when y > 1 ->
    z = y + 1
    {:big, z}
    _ ->
    :other
  end
  """, [a: 2, b: 5], {:big, 6}},
  {"""
  f = fn c, d ->
  c + d
  end
  f.(1, 2)
  """, [], 3},
  {~S'{%{:x => 1, "k" => 2}, %{m | :x => 3}, %Shapes.Point{x: 1, y: 2}}', [m: %{x: 0}],
   {%{"k" => 2, :x => 1}, %{x: 3}, :struct_point}},
  {"(a < b) < c", [a: 1, b: 2, c: 3], false},
  {"a < b == c", [a: 1, b: 2, c: true], true},
  {"(a == b) == c", [a: 1, b: 1, c: true], true},
  {"a - (b - c)", [a: 10, b: 2, c: 3], 11},
  {"a - b - c", [a: 10, b: 2, c: 3], 5},
  {"(a ++ b) ++ c", [a: [1], b: [2], c: [3]], [1, 2, 3]},
  {"a <> b <> c", [a: "x", b: "y", c: "z"], "xyz"},
  {"not (a == b)", [a: 1, b: 2], true},
  {"-(a ** 2)", [a: 3], -9},
  {"-a ** 2", [a: 3], 9},
  {"if ok do\n  1\nelse\n  2\nend", [ok: false], 2},
  {"cond do\n  x > 1 ->\n  :big\n  true ->\n  :small\nend", [x: 0], :small},
  {"try do\n  risky.()\nrescue\n  e ->\n  {:error, e.__struct__}\nend", [risky: fn -> raise ArgumentError end], {:error, ArgumentError}},
  {"[h | t] = [0 | [1, 2]]\n{h, t}", [], {0, [1, 2]}},
  {"%{:k => ^v} = m", [v: 1, m: %{k: 1}], %{k: 1}},
  {~S|"a\#{b}c \"q\" \\ \n\t\r \u{1}"|, [], "a" <> "#" <> "{b}c \"q\" \\ \n\t\r \u0001"},
  {~S|:"with spaces"|, [], :"with spaces"},
  {~S|:empty?|, [], :empty?},
  {"-0.0", [], -0.0},
  {"1.0E10", [], 1.0e10},
  {"# one\n#\n# two\n:after_comment", [], :after_comment},
]

results = for {src, binding, want} <- samples do
  {got, _} = Code.eval_string(src, binding)
  got = case got do
    {a, b, %{__struct__: Shapes.Point, x: 1, y: 2}} -> {a, b, :struct_point}
    other -> other
  end
  # a defmodule evaluates to {:module, name, bytecode, last}
  got = case got do
    {:module, _, _, _} -> :module
    other -> other
  end
  ok = got === want
  unless ok, do: IO.puts("MISMATCH #{inspect(src)}\n  got  #{inspect(got)}\n  want #{inspect(want)}")
  ok
end
IO.puts("#{Enum.count(results, & &1)} of #{length(results)} samples evaluate as the test says")
