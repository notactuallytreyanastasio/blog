# Heap.entry as it was before a93b6577: a function that takes the closure.
p = 'temper-core/lib/temper_core.ex'
s = open(p).read()
a = s.index('  defmacro entry({:fn, _, [{:->, _, [[], body]}]}) do')
b = s.index('  defmacro entry(fun), do: quote(do: TemperCore.Heap.run(unquote(fun)))')
b = b + len('  defmacro entry(fun), do: quote(do: TemperCore.Heap.run(unquote(fun)))')
s = s[:a] + '  def entry(fun), do: run(fun)' + s[b:]
open(p, 'w').write(s)
