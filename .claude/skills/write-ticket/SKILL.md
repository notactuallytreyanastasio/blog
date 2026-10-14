---
name: write-ticket
description: Turn a request, a bug, or a piece of the deciduous decision graph into a tracker ticket in house style and file it through the configured adapter (JIRA or a GitHub Projects v2 board; others by adding one file). Use for "write a ticket for <x>", "file this in JIRA", "put this on the board", "make an issue for <x>", "ticket this". Not for pull request bodies (that is write-pr) and not for commit messages; a ticket describes work that has not been done yet.
argument-hint: <what the ticket is about, or a deciduous node id>
---

# Write ticket

The output is a filed ticket whose URL is on the decision graph. The body is
written the way this repo writes everything else: the load-bearing fact
first, acceptance criteria somebody can check, and the out-of-scope line, so
the person who picks the ticket up knows when they are done.

Config is `tracker.toml` next to this file (`tracker.local.toml` wins when it
exists, and is gitignored). Adapter contract: `adapters/README.md`. What was
verified against what: `README.md`.

## Step 1: Gather

Three sources, in this order. Take what exists; do not invent the rest.

1. **The request, verbatim.** If the user said it in this conversation,
   quote it. If `$ARGUMENTS` is a node id or change-id prefix, the request
   is that node's `prompt`.
2. **The graph.** `deciduous nodes` for the current branch, or the MCP
   `query_nodes` / `show_node` tools, for the goal and any options,
   decisions, observations already attached. A ticket for work that was
   already decided should say which option was chosen and why; the graph
   has that.
3. **The files.** Which files the work touches, from the graph node's
   `files`, from `git diff --stat` if there is a branch, or from the
   conversation. Name them in the ticket. A ticket that says "the auth code"
   when the file is `lib/blog_web/plugs/admin_auth.ex` costs the next
   person a search.

## Step 2: Draft

Write the title and body to two files in the scratchpad (never in the repo).

**Title is a claim**, not a label: "Admin login accepts an expired session
cookie" rather than "Admin login bug". Under 80 characters.

**Body**, in this order, all plain Markdown:

1. The load-bearing fact, as the first sentence. What is wrong, or what
   will be true after the work, and why the obvious version is not enough
   if that applies.
2. The request, quoted, if it came from a person.
3. What is known: files, the graph node's reasoning, a real error, real
   output. Paste it; do not paraphrase a stack trace.
4. **Acceptance criteria**: a checklist where every line is something a
   reviewer can run or look at. "Tests pass" is not one; "`mix test
   test/blog_web/plugs/admin_auth_test.exs` has a case for an expired
   cookie and it passes" is.
5. **Out of scope**: one or more lines naming adjacent work this ticket does
   not do.
6. A `Graph:` line with the deciduous node id(s) when there are any.

No marketing language, no emoji, no "this ticket aims to".

## Step 3: Confirm

Show the user the title, the body, the adapter that will be used and the
labels, and ask before filing. Filing is a write to a shared system other
people watch; this is the one step that is never skipped.

## Step 4: File

```bash
bash .claude/skills/write-ticket/file.sh <title-file> <body-file> [label,label]
```

`file.sh` reads `tracker.toml`, picks `adapters/<adapter>.sh`, and prints the
ticket URL on stdout. Anything else goes to stderr and the exit code is
non-zero; do not retry a failed filing without reading the error, since the
first attempt may have created the ticket (JIRA creates before it reports a
field error on a transition).

The token is read from the environment variable named in the config. If it
is not set the adapter stops before any request and says which variable it
wanted.

## Step 5: Record

Put the URL on the graph node the ticket came from, so the graph and the
tracker point at each other:

```bash
deciduous add observation "Filed <KEY or #n>: <title>" -c 95 -f <files>
deciduous link <node_id> <new_id> -r "ticket"
```

or through MCP, `add_node` with `parent_id` set to that node and the URL in
the description. Then tell the user the URL.

## When not to

- The work is already done and on a branch: that is a PR, use write-pr.
- The user wants a note to self: a graph observation is enough.
- The tracker is not configured (`tracker.toml` still has placeholders):
  write the draft, show it, and say which fields need filling in. Do not
  guess a project key.
