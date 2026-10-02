# The eight false specs, with Heap.entry the function it was before a93b6577.
import os
d = os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(d, 'falsespecs.py')).read())
exec(open(os.path.join(d, 'entryfn.py')).read())
