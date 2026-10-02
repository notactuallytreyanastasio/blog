# loopret

Functions that `return` from inside loops: one loop, two nested loops, a
`continue` and a `break` beside the `return`, a labeled `continue` to the
outer loop, two loops in a row, a method, a local function, and a loop
inside an `if` in the middle of a list. Also `intOr`, a `return` of an
`orelse`, and `sign`, early returns with no loop. Entry 45 used it.

    cd journal/examples/loopret
    temper test -b elixir -w .
    temper test -b js -w .

Both print `Tests passed: 1 of 1`. The generated
`temper.out/elixir/loopret/lib/temper_main.ex` has one `throw(` left, in
`midIf`, the loop inside an `if` in the middle of a list. Before fork PR
#11 it had 22.
