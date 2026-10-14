---
name: write-pr
description: Write a pull request body in house style from the branch's diff, commits and decision-graph nodes, then open the PR or update the existing one with gh. Use for "write the PR", "open a PR for this", "PR body for <branch>", "update the PR description", "publish this as a PR". Handles the stacked-PR shape (a branch named NN-slug is based on the previous chapter's branch). Not for tickets (write-ticket) and not for commit messages, though the body it writes is the right source for a squash message.
argument-hint: [branch] [--base <branch>] [--draft] [--no-open]
---

# Write PR

The body is written from three sources, in this order: the diff (what
changed), the commits (what the author said while changing it), and the
decision graph (why). Then it is checked by `lint-body.py` and passed to
`gh` from a file. Never type a body on a `gh` command line; the quoting
breaks on the first backtick.

Repo-specific values (default base, body directory, attribution line, test
command) are in `pr.toml` next to this file: the one file the next repo
swaps. What `gather.sh` printed on a real branch, and what `deciduous
writeup` does and does not give: `README.md`.

## Step 1: Gather

```bash
bash .claude/skills/write-pr/gather.sh [branch] [--base <branch>]
```

It prints, in sections: the base it chose and why, the commits since the
base, the diff stat, the full diff (capped; read the file it names for the
rest), the graph nodes tagged with the branch from the local deciduous db,
any existing PR for the branch, and the body file path. If the branch is
`NN-slug` (with or without a `prefix/`), the base is the highest-numbered
`MM-*` branch with `MM < NN` and the same prefix; otherwise `pr.toml`'s
`base`. `--base` overrides.

The local `deciduous nodes -b <branch>` is one view; nodes written through
the MCP server live on the remote and may not be in the local db. Use the
MCP `query_nodes` with `branch` set as well, and take the union.

Read all of it before writing a word. The diff is the story; the body
explains the diff, it does not replace reading it.

## Step 2: Find the load-bearing fact

One sentence, first in the body: the thing a reviewer must know to read the
diff correctly. Usually one of:

- the surprising measurement (the pruning that made the render 4.6s
  instead of 7.6s),
- the reason the obvious version is wrong (why it is not just a flag),
- the constraint that shaped everything (the interpreter copies every
  top-level binding into every closure).

If the graph has a decision node for the branch, its rationale is usually
this sentence, or the reason the first attempt was replaced. If nothing in
the branch is surprising, say what it does in one plain sentence and keep
the body short; padding a small change is worse than a short body.

## Step 3: Write the body

To `<body_dir>/<last path component of branch>.md` (`.prs/` here; ignored
by `.git/info/exclude`, not `.gitignore`, so a fresh clone needs `open.sh`
to add the rule, which it does). Order:

1. The load-bearing fact.
2. What changed, by file or module, with real code or real output where a
   snippet says it better than a sentence. Before/after numbers come from
   a run you did, with the command.
3. **What does not work**, by name: the untested path, the case that
   still crashes, the TODO with the node it carries. Unfinished is fine;
   vague is not.
4. Test output: the suite's count line (`N tests, 0 failures`), not "tests
   pass".
5. For a stacked chapter: one line saying which chapter it follows and what
   the next one does.
6. The attribution line from `pr.toml`, last, after a blank line. It is this
   repo's convention and the only place an emoji is allowed.

Not in the body: "This PR adds", bullet padding, adjectives about the code
(robust, clean, comprehensive), emoji, a restatement of the diff stat.

Title: `N. Claim` for a stacked chapter (`3. Pruning is load-bearing`),
otherwise a claim under 70 characters. Write it to a sibling file
`<body_dir>/<slug>.title`.

## Step 4: Lint, show, confirm

```bash
python3 -I .claude/skills/write-pr/lint-body.py <body-file> .claude/skills/write-pr/pr.toml
```

It fails on a missing or misplaced attribution line, emoji elsewhere,
`This PR adds`-style openers, and a short list of marketing words; it warns
when there is no code block and no number, since that usually means the
output was described instead of shown. Fix what it names, then show the
user the title, the base and the body, and wait for a yes. A PR is visible
to everyone with the repo.

## Step 5: Open or update

```bash
bash .claude/skills/write-pr/open.sh <branch> <title-file> <body-file> [--base <branch>] [--draft]
```

Creates the PR with `gh pr create --body-file`, or if one exists for the
branch, `gh pr edit --body-file` and updates the title. Prints the PR URL.
With `--no-open` in `$ARGUMENTS`, stop after Step 4 and give the paths.

Then put the URL on the graph: an outcome under the branch's action node
(`deciduous add outcome "PR #n opened: <title>" --commit HEAD` and link it,
or MCP `add_node` with `parent_id`).

## Stacked series

When several `NN-slug` branches are published together, open them in
order, each based on the previous, so each diff shows only its chapter:

```bash
prev=main
for b in 01-x 02-y 03-z; do
  bash .claude/skills/write-pr/open.sh "$b" .prs/$b.title .prs/$b.md --base "$prev"
  prev=$b
done
```

Write the bodies before opening any of them; a chapter that turns out to
contain a mistake and its correction should say so, and you only know that
after reading the whole series.
