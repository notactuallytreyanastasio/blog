A map program written fresh for journal entry 10, run on the js, py and
ruby backends. `sh run.sh <temper>` regenerates `*.out`.

Ruby and JavaScript disagree on one line, `getOr` for a key whose value is
null: JavaScript's runtime is `map.get(key) ?? fallback`, which answers
the fallback; Temper documents the fallback for a missing key only, and
Ruby and Python answer null. Python stops at "remove during forEach" with
`RuntimeError: dictionary changed size during iteration`, which Temper's
`orelse` does not catch, so its file is shorter.
