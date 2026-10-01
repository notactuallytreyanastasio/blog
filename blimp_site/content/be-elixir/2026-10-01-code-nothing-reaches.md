# 2026-10-01: code nothing reaches

Entry 29 moved whatever production can't reach to the test side. For
Temper's std, which has no tests, that meant a `test/support/` holding its
unused internals, a `test_helper.exs`, and `elixirc_paths` in its
`mix.exs`. The tests never call any of it, because nothing does.

The backend now walks twice: from production's roots, then from the tests
(every `test`, and whatever the frontend marked as test-only). A
non-exported function or value that production can't reach goes to the
test side if a test reaches it. If nothing reaches it, it isn't generated.

The backend test now has both kinds. `foldedAway` is called only from a
test the frontend evaluated while compiling, so nothing calls it, and it is
gone. Only its name survives, inside the folded assert's message. `helper`
is called only from a test that runs, so it goes to `test/support/`:

```temper
let foldedAway(x: Int): Int { x + 1 }
test("folds") { assert(foldedAway(2) == 3); }
let helper(x: Int): Int { x + 1 }
let check(test: Test, x: Int): Void { assert(helper(x) == x + 1); }
test("runs") { test => check(test, 2); }
```

Regenerating Marginalia deletes `std/test/` and std's `elixirc_paths`.
The functional suite is 65 of 65, alloy 225 of 225, templight 140 of 140,
and Marginalia's 26 Temper tests pass.
