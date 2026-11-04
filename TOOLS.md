# The tool suite

Every tool here is a Claude Code skill or command: a folder under
`.claude/skills/<name>/` with a `SKILL.md` that says when it triggers and
what it does, plus whatever code it drives. Each one started life in one
repo for one job. This file is the index of the ones that have been made
portable, where each lives, and what has been checked.

The rule for an entry: it says what the tool produces, what it verifies
against, and what it does not do. A tool that cannot show its output
working is listed as unverified.

## Portable

### walkthrough

Drives the app in a visible browser, one step at a time, at human pace, so
a person can watch a flow. Input is an action/outcome table, a plain-English
description, or a workflow JSON. Output is a run folder with a screenshot
per step, a `report.md`, and the console errors, 5xx responses and crashed
views seen on each step.

| | |
|---|---|
| Skill | `.claude/skills/walkthrough/SKILL.md` |
| Code | `walkthrough/` (own `package.json`; Playwright; `adapter.ts` is the only app-specific file) |
| Reference | `walkthrough/README.md` |
| Verified | 21 kept workflows in `walkthrough/workflows/` covering every routed surface, run headless against a local dev server with `walk-all.sh` (2026-10-14). The first tour surfaced six routes that 500, a tour tooltip that cannot be clicked, a map that cannot cluster markers, and a Python demo that cannot print; those live in `known_broken.json` and in the workflow descriptions |
| Does not | seed data, log in, or sandbox anything by itself; an adapter `prepare` does that per app |

The original lives in the galileo repo, wired into that app's e2e sandbox,
YAML seed fixtures and developer login. The portable version replaced those
with `{{var.*}}` / `{{env.*}}` substitution and an adapter with four
optional hooks (`prepare`, `cleanup`, `settle`, `crashed`). The runner,
overlay, report and workflow format are byte-for-byte the same idea.

### type-design

Designs the types for a feature before its logic: a states table, a
boundary parser, one variant per state, and a probe that the checker
rejects. Elixir, TypeScript, Rust.

| | |
|---|---|
| Skill | `.claude/skills/type-design/SKILL.md` |
| References | `elixir.md`, `typescript.md`, `rust.md` in the same folder, each with the checker's real output |
| Verified | Elixir 1.19.5 (`incompatible types given to`, `unknown key`), tsc 5.9.3 (TS2345, TS2339, TS2366), rustc 1.96.0 (E0004, E0026, E0423, E0599). Dialyzer output not reproduced. |
| Does not | enforce struct field types in Elixir (the compiler ignores `@type`); says so in `elixir.md` |

Same files in both repos.

### deslop

Removes the patterns that mark prose as machine-written. User-level skill,
not in either repo: `~/.claude/skills/deslop/`.

### Decision graph

`/decision`, `/recover`, `/work`, `/sync`, `/document`, `/serve-ui`, and
the `/pulse`, `/narratives`, `/archaeology` skills, under
`.claude/commands/` and `.claude/skills/`. Generated and updated by
`deciduous`; see `CLAUDE.md` for the workflow they enforce.

## Repo-specific (galileo)

Listed by name so the suite is complete; each is wired to that app's
services and is not portable as it stands.

- `write-e2e-test`: Playwright test from a flow description, with page
  objects and seed fixtures.
- `create-ecto-migration`: schema-change migrations through the Mix
  generator, with the column-type rules.
- `update-beam-versions`: bump Erlang/Elixir and keep the Docker base image
  in lockstep.
- `dependabot-review`: security and freshness review of a dependency-bump
  PR.
- `galileo-health-triage`, `triage-marketing-data-discrepancies`:
  production diagnosis runbooks for that system.
- `playwright`: headed browser agents that hunt for errors and file bugs.

## Adding a tool

1. It gets a `SKILL.md` whose description says the phrases that trigger it
   and the things it is *not* for.
2. Anything it claims about a language, runtime or app is run, and the
   output goes in the reference file.
3. The app-specific part is one file, named, so the next repo replaces that
   file and nothing else.
4. It gets a row here with what was verified.
