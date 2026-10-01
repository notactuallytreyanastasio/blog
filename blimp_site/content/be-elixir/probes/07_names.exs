# Does a module function named like a Kernel import conflict? Defining it, and calling it unqualified.
for src <- [
  "defmodule N1 do\n  def length(x), do: x\nend\n:defined_only",
  "defmodule N2 do\n  def length(x), do: x\n  def go, do: length(1)\nend\nN2.go()",
  "defmodule N3 do\n  def go, do: __MODULE__.length(1)\n  def length(x), do: x\nend\nN3.go()",
  "defmodule N4 do\n  def fib(x), do: x\n  def go, do: fib(2)\nend\nN4.go()",
  "case = 1\ncase",
  "_x = 1\n_x",
] do
  r = try do
    {v, _} = Code.eval_string(src); {:ok, v}
  rescue e -> {:error, e.__struct__, Exception.message(e) |> String.slice(0, 90)}
  end
  IO.inspect(r, label: String.replace(src, "\n", " ") |> String.slice(0, 50))
end
names = (Kernel.__info__(:functions) ++ Kernel.__info__(:macros)) |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.sort()
IO.puts("KERNEL " <> Enum.join(names, " "))
