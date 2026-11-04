# TOOLS.md additions: write-ticket, write-pr, sentry-patch

Three rows for the Portable section of `TOOLS.md`, in its table format.
Written on branch `skills/tickets-pr-sentry`; `TOOLS.md` itself is owned
by another session and not edited here. The entries follow the file's
rule: what the tool produces, what it verifies against, what it does not
do.

### write-ticket

Turns a request, a bug, or a piece of the decision graph into a tracker
ticket in house style (title is a claim, load-bearing fact first,
checkable acceptance criteria, out-of-scope line), confirms, files it
through an adapter, and puts the URL on the graph node. JIRA and GitHub
Projects v2 ship; a third tracker is one new file in `adapters/`.

| | |
|---|---|
| Skill | `.claude/skills/write-ticket/SKILL.md` |
| Code | `file.sh` (dispatcher), `adapters/{jira.sh,github-projects.sh,toml-get.py,adf.py}`, `mock/{jira_mock.py,gh}`; `tracker.toml` is the only app-specific file (placeholders; `tracker.local.toml` is gitignored for real values) |
| Reference | `.claude/skills/write-ticket/README.md`; adapter contract in `adapters/README.md` |
| Verified | JIRA against a local mock only (no instance): request shape checked against Atlassian's v3 reference for `POST /rest/api/3/issue`, description sent as ADF, mock recorded the full request and returned the documented 201 body, URL printed. GitHub: every type, field and mutation the adapter uses confirmed by live schema introspection; repo id and label lookup run live against `notactuallytreyanastasio/blog`; the create/add/set-status flow against a mock `gh`; the `gh api` array syntax (`-f 'l[]=id'`, not `-F 'l=[...]'`) checked live, which caught a bug. Both run under `/bin/bash` 3.2 (2026-10-14) |
| Does not | list or read Bobby's GitHub Projects: the `gh` token here lacks `read:project` (`INSUFFICIENT_SCOPES`), so no project or Status field was read; create anything on a real tracker; render inline Markdown in Jira (backticks stay backticks); retry a create that timed out |

### write-pr

Writes a PR body in house style from the diff, the commits and the
graph nodes on the branch, lints it, and opens or updates the PR with
`gh --body-file`. A branch named `NN-slug` (with or without a prefix) is
based on the previous chapter's branch.

| | |
|---|---|
| Skill | `.claude/skills/write-pr/SKILL.md` |
| Code | `gather.sh`, `lint-body.py`, `open.sh`; `pr.toml` is the only app-specific file (base, body dir, attribution line, test command) |
| Reference | `.claude/skills/write-pr/README.md` |
| Verified | `gather.sh` run on this branch and on `blimp-blog/03-prefork-server-and-pages` (base detected as `blimp-blog/02-server-side-highlighting`); `lint-body.py` passes all 18 existing bodies in `.prs/` and fails a built-to-fail one on five counts; `deciduous writeup` run and its output quoted with what it gives and lacks; `.prs/` found to be ignored by `.git/info/exclude`, not `.gitignore` (2026-10-14) |
| Does not | open a PR in the verification (`gh pr create` was not run); see nodes written through the MCP remote in `deciduous nodes -b` (local db only; the skill queries both); write the body for you, `deciduous writeup` is one input |

### sentry-patch

On a schedule: fetches a project's unresolved Sentry issues, applies a
written determinism rule (same culprit and top in-app frame across every
event; not a timeout/network/resource error; reachable by a unit test
from the event's arguments), writes the failing test first, makes the
smallest change, runs the suite, opens one PR per issue through write-pr,
and reports every rejection with its clause.

| | |
|---|---|
| Skill | `.claude/skills/sentry-patch/SKILL.md` |
| Code | `triage.py` (fetch + clauses 1 and 2 + cap + skip + report), `mock/sentry_mock.py`; `sentry.toml` is the only app-specific file (`sentry.local.toml` gitignored) |
| Reference | `.claude/skills/sentry-patch/README.md` |
| Verified | Not run against a live Sentry. Fetch and rule run against a local mock serving three issues in the API reference's response shape (issue list, `events/?full=true`): the ArgumentError issue became the one candidate with frame, vars, context and exception in the report; the `DBConnection.ConnectionError` timeout was rejected under clause 2; a MatchError whose events raise from two different lines was rejected under clause 1. Missing token stops before any request; `--max 0` and `--skip` exercised (2026-10-14) |
| Does not | decide clause 3 (only writing the test does); resolve or comment on Sentry issues; install a schedule (`/loop 6h /sentry-patch --max 2`); follow pagination past 100 issues; steps 2 to 5 (branch, test, fix, PR) were not run end to end |
