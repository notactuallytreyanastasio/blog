# Sorts every argument and return type in a library's @specs by what it says.
#   elixir precision.exs lib_dir...
# "any Temper object": a type that is an interface's t() (or the union itself)
# "any heap object":   TemperCore.Ref.t() / TemperCore.Actor.t()
# "term()":            term()
# "nil, no_return, supertypes": nil, no_return(), [module()] (__temper_supertypes__)
# "precise":           anything else
# `| nil` is ignored when sorting.
#   elixir precision.exs --before lib_dir...
# sorts them as they were before each class had its own type: a heap class's
# or actor's t() as "any heap object", an interface's t() as term().
{before, dirs} = case System.argv() do ["--before" | ds] -> {true, ds}; ds -> {false, ds} end
files = Enum.flat_map(dirs, &Path.wildcard(Path.join(&1, "**/*.ex")))
asts = for f <- files, do: Code.string_to_quoted!(File.read!(f))

ifaces =
  for ast <- asts, {:defmodule, _, [mod, [do: body]]} <- elem(Macro.prewalk(ast, [], fn
        {:defmodule, _, _} = n, acc -> {n, [n | acc]}
        n, acc -> {n, acc}
      end), 1),
      {:@, _, [{:type, _, [{:"::", _, [{:t, _, _}, rhs]}]}]} <- (case body do {:__block__, _, xs} -> xs; x -> [x] end),
      Macro.to_string(rhs) == "%TemperCore.Ref{} | %TemperCore.Actor{} | struct()",
      into: MapSet.new(),
      do: Macro.to_string(mod) <> ".t()"

classes = fn ast ->
  {_, acc} = Macro.prewalk(ast, [], fn
    {:defmodule, _, [mod, [do: body]]} = n, acc ->
      ts = for {:@, _, [{:type, _, [{:"::", _, [{:t, _, _}, rhs]}]}]} <- (case body do {:__block__, _, xs} -> xs; x -> [x] end),
             String.starts_with?(Macro.to_string(rhs), ["%TemperCore.Ref{class:", "%TemperCore.Actor{class:"]), do: Macro.to_string(mod) <> ".t()"
      {n, ts ++ acc}
    n, acc -> {n, acc}
  end)
  acc
end
heap = asts |> Enum.flat_map(classes) |> MapSet.new()

types =
  for ast <- asts, reduce: [] do
    acc ->
      {_, acc} = Macro.prewalk(ast, acc, fn
        {:@, _, [{:spec, _, [{:"::", _, [{_name, _, args}, ret]}]}]} = n, acc ->
          {n, Enum.map(List.wrap(args) ++ [ret], &Macro.to_string/1) ++ acc}
        n, acc -> {n, acc}
      end)
      acc
  end

strip = fn s -> s |> String.replace_suffix(" | nil", "") end
kind = fn t ->
  t = strip.(t)
  cond do
    t == "term()" -> "term()"
    t in ["nil", "no_return()", "[module()]"] -> "nil, no_return, supertypes"
    before and t in heap -> "any heap object"
    before and t in ifaces -> "term()"
    t in ["TemperCore.Ref.t()", "TemperCore.Actor.t()"] -> "any heap object"
    t in ifaces or t == "%TemperCore.Ref{} | %TemperCore.Actor{} | struct()" -> "any Temper object"
    true -> "precise"
  end
end
n = length(types)
IO.puts("#{length(files)} files, #{n} argument and return types, #{MapSet.size(ifaces)} interfaces")
for {k, c} <- types |> Enum.frequencies_by(kind) |> Enum.sort_by(fn {_, c} -> -c end) do
  IO.puts(String.pad_trailing(k, 18) <> String.pad_leading("#{c}", 6) <> String.pad_leading("#{round(100 * c / n)}%", 6))
end
