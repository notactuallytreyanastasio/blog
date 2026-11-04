A function whose loop holds both a `return` and a `continue` or `break`,
with its result written as a trailing expression after the loop. Written
for journal entry 15. Before the frontend fix in that chapter, the
frontend dropped the trailing expression (`-7`, `42`), because its
terminal-expression analysis (`UnsetTerminalExpressions.kt`) walked the
loop body once and concluded that the `return` in it had always assigned
the result by the time the loop ended.

Before the fix:

```
interp   a: [1]   b: [1]   c: [0]   d: [-7]
js       TypeError: Cannot read properties of undefined (reading 'toString')
py       UnboundLocalError: cannot access local variable 'return_1' where it is not associated with a value
ruby     undefined local variable or method 'return_' for module Temper::Minus (NameError)
```

After it, all four print `a: [-7] b: [42] c: [-7] d: [-7]`. `d` has no
`return` in its loop and was always right.

    temper run -w . --library lost-trailing-value -b interp|js|py|ruby
