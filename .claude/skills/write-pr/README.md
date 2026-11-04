# write-pr: what was verified, against what

The gather and lint steps were run on this repo, on the branch the skill
was written on (`skills/tickets-pr-sentry`) and on a stacked chapter
branch. No PR was opened: `open.sh` was not run, and `gh pr create` is
the one command in this skill that was not executed. Its flags
(`--base`, `--head`, `--title`, `--body-file`, `--draft`) are the ones
the repo's own `CLAUDE.md` shows in use.

## gather.sh on this branch (2026-10-14)

```
$ bash .claude/skills/write-pr/gather.sh
## branch
skills/tickets-pr-sentry

## base
main  (branch is not NN-slug; pr.toml base)

## commits (origin/main..skills/tickets-pr-sentry)

## diff stat (origin/main...skills/tickets-pr-sentry)

## diff (0 bytes; full copy at /var/folders/.../T//write-pr-skills_tickets-pr-sentry.diff)

## decision graph nodes on skills/tickets-pr-sentry (local db: deciduous nodes -b)
No nodes found matching filters.
(also run MCP query_nodes with branch="skills/tickets-pr-sentry"; nodes written through the remote may not be here)

## existing PR
[]

## files
body:  /Users/bg/code/blog-skills/.prs/tickets-pr-sentry.md
title: /Users/bg/code/blog-skills/.prs/tickets-pr-sentry.title
ignored: yes
```

Empty commits and diff because it was run before the first commit. Two
things that output caught:

- The first version diffed against local `main`, which in this worktree
  is 40-odd commits behind `origin/main`, so every merged `be-elixir`
  sync since showed up as this branch's commits. `gather.sh` now uses
  `origin/<base>` whenever it exists.
- "No nodes found" is true of the *local* deciduous db even though the
  branch has a goal, options, a decision and three actions on the graph:
  they were written through the MCP server, whose store is remote
  (`[remote] url` in `.deciduous/config.toml`). `deciduous nodes -b` sees
  only the local db. The skill says to query both.

## Base detection on a chapter branch

```
$ bash .claude/skills/write-pr/gather.sh blimp-blog/03-prefork-server-and-pages
## branch
blimp-blog/03-prefork-server-and-pages

## base
blimp-blog/02-server-side-highlighting  (previous chapter of 03-prefork-server-and-pages (highest MM-* with MM < 3 under 'blimp-blog/'))
```

The chapters in this repo are `blimp-blog/NN-slug`, not bare `NN-slug`,
so the match is on the last path component and the previous chapter must
share the prefix. Candidates come from local heads and `origin/*`.

## lint-body.py

Over the 18 bodies already in `.prs/` (the published temper-blimp
series and later): all 18 pass. The first version failed every one of
them, because they end with the attribution line *and then* a
`https://claude.ai/code/session_...` line; that one trailing line is now
allowed. The attribution check is otherwise exact: the line from
`pr.toml`, last.

A body built to fail:

```
$ printf 'This PR adds a robust and seamless thing 🚀\n\nstuff\n' > /tmp/bad.md
$ python3 -I lint-body.py /tmp/bad.md pr.toml
warn: no code block and no number: show real output rather than describing it
fail: line 3: last line must be the attribution line, got: 'stuff'
fail: line 1: emoji outside the attribution line
fail: line 1: opens with a 'This PR adds' sentence; lead with the load-bearing fact
fail: line 1: marketing word 'seamless'
fail: line 1: marketing word 'robust'
exit=1
```

## `.prs/` is not in `.gitignore`

`git check-ignore -v .prs/x.md` here answers
`/Users/bg/code/blog/.git/info/exclude:22:.prs/`. The rule is in the
repo's local exclude file, which a fresh clone does not have, so a clone
that writes a body has an untracked `.prs/` waiting for a careless `git
add`. `open.sh` checks and appends `<body_dir>/` to
`$(git rev-parse --git-common-dir)/info/exclude` when it is missing
(`--git-common-dir`, so it works from a worktree, where `.git` is a
file).

## What `deciduous writeup` gives, and what it lacks

`deciduous writeup --help`: `-t title`, `-r roots` (node ids, traverses
children), `-n nodes` (ids or ranges), `--png`/`--auto` to embed a graph
image, `--no-dot`, `--no-test-plan`. On two nodes:

```
$ deciduous writeup -n 163-164 --no-dot -t "Sample"
## Summary

## Implementation

- Bought Epson TM-M50 (same model as Henry Zoo) - bluetooth/wifi model

## Test Plan

- [ ] Verify implementation
- [ ] Run test suite

## Decision Graph Reference

This PR corresponds to deciduous nodes: 163, 164
```

Gives: the node titles under fixed headings, a node-id reference line, and
optionally a DOT graph and a PNG link. Useful as the list of what the
graph says happened, for the body's "why" paragraph.

Lacks, for a body in this house style: anything from the diff or the
commits; any real output; the load-bearing fact (titles are not
sentences about consequences); a "what does not work" section; the
attribution line. The test plan is a placeholder. With no `-n`/`-r` it
prints every goal in the db (567 nodes on `main` here), and it takes
local numeric ids, which differ per machine and do not cover nodes
written through the remote. So: run it with the branch's node ids as one
input to Step 2, and write the body yourself.
