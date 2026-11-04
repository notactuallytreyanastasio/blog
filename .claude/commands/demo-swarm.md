---
description: Demonstration. An Opus lead coordinates four Sonnet workers building one Tetris, in iTerm2 or Ghostty panes
allowed-tools: Bash(deciduous demo-swarm:*)
argument-hint: "[--dry-run] [--ask] [--dir PATH]"
---

# /demo-swarm

Run this with the Bash tool, exactly, and nothing else first:

    deciduous demo-swarm $ARGUMENTS

It works only in iTerm2 or Ghostty on macOS. It creates a fresh repository
(default `~/deciduous-swarm/swarm-MMDD-HHMM`) and opens a new window. The lead
pane (Opus) walks through the setup, then four Sonnet workers start, each in
its own worktree and branch: the functional core, the imperative shell, the
view, and QA. They share one deciduous workspace, message each other
directly, and integrate through the lead, which merges only when unit tests,
the type check and browser tests pass. Every pane is recorded with timestamps
under `.swarm/rec/` for later replay.

Then tell the user, in two or three sentences, what opened: the arena path,
the workspace and the recording directory, all printed by the command, and
that the lead pane accepts instructions.

If it refuses because the terminal is not iTerm2 or Ghostty, or `claude` or
the deciduous MCP server is missing, say so in one sentence and stop. Do not
work around the check or start sessions another way.

This is a demonstration, not work on this project: log nothing to the graph
for it.
