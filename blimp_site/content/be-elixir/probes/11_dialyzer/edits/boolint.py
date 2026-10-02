# Boolean mapped to integer(), on purpose.
p = 'fixture/lib/temper_main.ex'
s = open(p).read()
open(p, 'w').write(s.replace('boolean()', 'integer()'))
