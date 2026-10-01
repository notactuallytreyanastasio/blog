# 2026-10-01: regex, broken code, and 65 of 65

The last three failures were two regex tests and `SemanticsBroken`. All
65 functional tests now pass, counted from a run with nothing else in the
worktree.

## Regex is std's formatter and PCRE

std/regex does most of the work in Temper. It turns a regex tree into
pattern text with its own `RegexFormatter`, and asks a backend for six
things: compile the text, then `found`, `find`, `replace` and `split`,
plus a numeric escape for code points it cannot print. The last entry
made each missing one fail with its name. This chapter supplies all six
from `TemperCore.Regex`, over `:re`:

```elixir
def regexCompileFormatted(data__305, formatted__306) do
  t___420 = TemperCore.Regex.compile(formatted__266)
...
TemperCore.Regex.find(this__26.compiled__281, text__271, begin__272, Temper.Std.Match, Temper.Std.Group)
```

```temper
let catcher = /a+(?intro=b+)c/;
let text = "🌍aaabbc!";
let m = catcher.find(text);
console.log("${m.full.value} intro=${m.groups["intro"].value} at ${text.countBetween(String.begin, m.full.begin)}");
console.log(/(^|,)\s*/.replace("apples, bananas") { match => "|" });
```

```
aaabbc intro=bb at 1
|apples|bananas
```

Four details decided this:

- **Which flags.** Elixir's `~r//u` turns on `:unicode` and `:ucp`
  together. `:ucp` would make `\d` match `٣`. be-py compiles with
  `re.ASCII`, so `\d`, `\w` and `\s` stay ASCII. The runtime calls `:re`
  itself with `:unicode` alone: the subject is UTF-8 and `.` takes a
  whole code point, but the character classes stay ASCII. Both behaviors
  have a test.
- **Offsets.** `:re` reports byte offsets. A `StringIndex` here is a byte
  offset (entry 6), so a group's `begin` and `end` go straight into std's
  `Group` with no conversion. be-py has to rely on Python's code-point
  indices to get the same result.
- **Group order.** std promises that `Match.groups` iterates "in the
  order in which names appear in the pattern". `:re.inspect(mp,
  :namelist)` sorts the names alphabetically. So the compiled value is
  `{mp, names}`, with the names scanned from std's own formatted text
  (`(?<name>`, which std writes for every backend except Python). The
  scan is checked against `:re`'s list, and a mismatch panics instead of
  guessing.
- **Who builds a Match.** std's `Match` and `Group` are ordinary
  translated classes in `Temper.Std`. The support code passes those two
  modules in, so temper-core never names std, which it does not depend
  on.

`replace` uses `:re`'s `:global` run, which already steps past an empty
match, so `RegexZeroAdvance` (`/(^|,)\s*/` matching at position 0) needed
nothing extra. `split` keeps captured groups, as Python's `re.split`
does.

The first runtime test run failed four times, all with the same mistake:
I wrote `capture: [...], return: :index`. `:re` takes a single
`{:capture, spec, :index}` tuple and rejected the rest as "invalid
options".

## Broken code fails when it runs

`SemanticsBroken` gives backends code the frontend has already rejected
(an undefined name, a function that does not always return, `export
something() {}`) and tells the build to continue anyway. The test
expects the program to be translated and then to fail when it runs.

Every other unhandled case in this backend is a `TODO()` at build time.
Garbage is the exception, because the frontend has already done the
failing loudly. Each garbage node (top level, statement, expression,
callable) now becomes a raise that carries the frontend's diagnostic, as
it does in be-py and be-js:

```elixir
raise(TemperCore.Panic, "broken code: Cannot export non-parsed name!")
raise(TemperCore.Panic, "broken code: doesntExist not available from core")
```

The test passes for any run failure, including a `mix compile` error.
So I built the same code as a probe to check how it actually fails:

```
** (TemperCore.Panic) broken code: Cannot export non-parsed name!
    (temper_broken 0.1.0) lib/temper_main.ex:15: anonymous fn/0 in Temper.Broken.__temper_init__/0
```

With `GarbageCallable` handled, the call translator covers every kind of
callable, and its fallback `TODO("callable: ...")` is gone.

## The session ended in the middle of a test run

This chapter's previous session ended while `ft-one.sh` was running.
The script's `EXIT` trap restores `FunctionalTestStatus.kt`, but a
process that is killed outright runs no trap. The file was left with its
Elixir list cut down to the two regex tests. The scratchpad that held
the scripts was wiped too. The list came back from git (this branch
starts from main), and the scripts now live in an excluded `.tools/`
directory. They also trap `INT`, `TERM` and `HUP`. A `KILL` is still not
caught, so the rule is to look at that file before trusting a count.

**65 of 65.** temper-core: 74 tests, 0 failures.

**What "complete" still lacks:**

- the heap is never freed, and objects cannot cross processes
- output is hard to read: indentation after `fn ->`, names like `x__13`
- `ListBuilder` appends are quadratic
- tests run through `main`, with no `mix test` integration
- two user libraries importing each other have not been tried
