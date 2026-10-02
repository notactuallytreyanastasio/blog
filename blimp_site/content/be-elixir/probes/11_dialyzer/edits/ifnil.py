# orEmpty's null check written as the `if` it was before 62dddaef.
p = 'fixture/lib/temper_main.ex'
s = open(p).read()
old = """      case subject do
        nil ->
          %TemperCore.Vec{t: {}}
        subject ->
          subject
      end"""
new = """      if subject === nil do
        %TemperCore.Vec{t: {}}
      else
        subject
      end"""
assert old in s
open(p, 'w').write(s.replace(old, new))
