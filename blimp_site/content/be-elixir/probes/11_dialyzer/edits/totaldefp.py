# total's false spec, with its loop a named function instead of a closure
# passed to itself.
import os
d = os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(d, 'falsespecs.py')).read())
p = 'fixture/lib/temper_main.ex'
s = open(p).read()
old = """      ex_loop_1 = fn ex_loop_1, i, t ->
        if i < n do
          el = TemperCore.List.get(this, i)
          i = TemperCore.int32(i + 1)
          x = el
          t = TemperCore.int32(t + x)
          ex_loop_1.(ex_loop_1, i, t)
        else
          {i, t}
        end
      end
      {_i, t} = ex_loop_1.(ex_loop_1, i, t)"""
new = """      {_i, t} = total_loop(this, n, i, t)"""
assert old in s
s = s.replace(old, new)
s = s.replace("""  @spec lookup(""", """  defp total_loop(this, n, i, t) do
    if i < n do
      el = TemperCore.List.get(this, i)
      i = TemperCore.int32(i + 1)
      t = TemperCore.int32(t + el)
      total_loop(this, n, i, t)
    else
      {i, t}
    end
  end
  @spec lookup(""", 1)
open(p, 'w').write(s)
