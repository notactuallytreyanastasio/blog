# Gives eight exported functions a return spec their code contradicts.
import re
p = 'fixture/lib/temper_main.ex'
s = open(p).read()
false = {'total': 'String.t()', 'lookup': 'String.t()', 'half': 'String.t()', 'big': 'String.t()',
         'flip': 'integer()', 'contains': 'integer()', 'shout': 'integer()', 'upTo': 'integer()'}
for name, ret in false.items():
    s, n = re.subn(r'(@spec %s\(.*\)) :: .*' % name, r'\1 :: ' + ret, s)
    assert n == 1, name
open(p, 'w').write(s)
