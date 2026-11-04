---
name: sentry-patch
description: Read a Sentry project's unresolved issues, keep only the ones whose failure is deterministic by a written rule, and for each open one PR with a failing test and the smallest fix. Meant to run on a schedule (/loop or /schedule). Use for "patch the Sentry issues", "run the sentry patcher", "what in Sentry can be fixed automatically", "sentry triage". Not a debugger for one issue (read it and fix it by hand), not for flaky or timeout errors (it refuses them by rule), and it never resolves anything in Sentry.
argument-hint: [--max N] [--dry-run]
---

# Sentry patch

Every issue goes through the same rule and ends up in one of two places: a
PR, or a line in the run report saying why not. There is no third place.
A run that patches nothing and reports twelve reasons is a correct run.

Config: `sentry.toml` next to this file (`sentry.local.toml` wins when it
exists; gitignored). The token comes from the environment variable it
names. What was verified against what: `README.md`. It was not run against
a live Sentry.

## The determinism rule

An issue is deterministic, and may be patched, when all three hold:

1. **Every fetched event has the same culprit and the same top in-app
   frame** (filename, function, line), and there are at least `min_events`
   of them. One event cannot show that the failure repeats; two that agree
   can. An issue whose events raise from different lines is something
   else (a race, bad data of several shapes) and is reported, not patched.
2. **The error is not a timeout, network, or resource error.** Exception
   type and value are matched against the patterns in `triage.py`
   (`TRANSIENT_TYPE`, `TRANSIENT_VALUE`: timeout, connection refused/reset,
   DNS, socket, rate limit, out of memory, no space left, pool checkout,
   502/503/504 and the HTTP-client error types). Those failures have the
   same frame every time and are still not bugs in the line that raised.
3. **The failing line can be reached by a unit test written from the
   event's arguments**: the top frame's `vars`, its `context` lines and the
   exception value. If no test can be written that reaches that line and
   fails with that exception type, the issue is not understood well enough
   to patch, whatever the stack trace looks like.

`triage.py` decides 1 and 2 from the API. Only writing the test decides 3.

## Step 1: Triage

```bash
python3 -I .claude/skills/sentry-patch/triage.py --config .claude/skills/sentry-patch/sentry.toml \
  --out <scratch>/sentry-report.json [--max N] \
  --skip "$(git ls-remote --heads origin 'sentry/*' | sed 's#.*refs/heads/sentry/##' | tr a-z A-Z | paste -sd, -)"
```

It fetches `GET /api/0/projects/{org}/{project}/issues/?query=is:unresolved`
and, per issue, `GET /api/0/organizations/{org}/issues/{id}/events/?full=true`,
applies clauses 1 and 2, caps the candidates at `--max` (default
`max_prs`), and prints a Markdown table of every issue with its verdict.
`--skip` keeps an issue that already has a `sentry/<id>` branch from being
patched twice on the next scheduled run. Read the JSON report: each
candidate carries the frame, its `vars`, its `context` and the exception.

With `--dry-run` in `$ARGUMENTS`, write the run report (Step 5) from this
table and stop.

## Step 2: Per candidate, the failing test first

For each candidate, in report order, on a branch from the base in
`write-pr/pr.toml`:

```bash
git switch -c sentry/<short-id lowercased> origin/<base>
```

1. Open the frame's file at the line. Read the function, not just the
   line.
2. Write a unit test in the suite's convention that calls the function
   with the arguments from `vars` (reconstructed; `vars` are the SDK's
   string renderings) and asserts the behaviour that should happen. Name
   it after the Sentry id, e.g. `test "BLOG-1: get_post_by_slug!/1 with an
   empty slug"`.
3. Run only that test (`one_test_command` with the file). It must fail,
   and fail with the exception type Sentry recorded. Keep the output.
   - If it passes, the arguments did not reproduce the failure: clause 3
     fails. Delete the branch, put the issue in the report as rejected
     with "test from event vars passes; not reproducible from the event",
     and move on.
   - If it fails with a different exception, the same: rejected, with
     both exception types in the reason.

## Step 3: The smallest change that passes it

Make the change that makes the test pass and nothing else. No refactor,
no second fix "while here", no new dependency. If the smallest change is
a behaviour decision (return `nil` or raise a clearer error? redirect or
404?), that is a product choice: reject with "fix needs a decision:
<the two choices>" and put both in the report for a person.

Run the one test again (must pass, keep the output), then the whole suite
(`test_command`). A suite failure elsewhere means the change was not the
smallest; fix or reject, never skip the suite.

## Step 4: One PR per issue

Commit with a message that leads with what the line did wrong, then open
the PR with write-pr's scripts, not by hand:

```bash
bash .claude/skills/write-pr/open.sh sentry/<id> <title-file> <body-file> --base <base>
```

Body, in order: the load-bearing sentence (what the line assumed and what
production sent it); the Sentry link and the event count; the failing
test's output **before** and **after**, pasted; the suite's count line;
what the fix does not do (the adjacent cases it leaves alone); the
attribution line. Title: a claim, e.g. `get_post_by_slug!/1 crashes on a
slug with no year`. Labels from `labels` in the config (`gh pr edit --add-label`).

Then the graph: an action node for the patch with `--commit HEAD`, an
outcome with the PR URL, linked under the run's goal.

Stop when `max_prs` PRs are open. The rest are in the report as "over the
cap; next run".

## Step 5: Run report

Write `<report_dir>/sentry-run-<YYYY-MM-DDTHHMM>.md`: the triage table,
then one line per patched issue with its PR URL, then the rejected ones
with their clause and reason (including the ones rejected in Steps 2 and
3, which triage could not know). Tell the user the path and the counts.
This file is the audit trail for a scheduled job nobody watched.

## Scheduling

The skill does not install a cron. Run it on a schedule with Claude Code:

```
/loop 6h /sentry-patch --max 2
```

or `/schedule` for a cloud routine. `--dry-run` for the first few runs
until the rejections look right.

## Rules that do not bend

- Never resolve, ignore or comment on the Sentry issue. The PR links it;
  a person closes it.
- Never push to the base branch. One branch, one PR, per issue.
- Never patch an issue that failed any clause, however obvious the fix
  looks. Put it in the report; a person can patch it.
- Never write the token anywhere but the environment.
