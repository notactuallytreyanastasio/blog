Functions used as values, written fresh for journal entry 15, on the js,
py and ruby backends and the interpreter. `sh run.sh <temper>`
regenerates `*.out`.

Ruby agrees with the interpreter on all sixteen lines. js prints nothing:
its module throws `builtin <> not supported by JS backend` while loading,
from the placeholder it writes for `identity<Int>`. py prints three lines
and then fails at `applyTwice(identity<Int>, 9)` with `TypeError:
'NotImplementedType' object is not callable`; the first two `<>` lines
print only because the frontend inlined `ints(5)` to `5`.
