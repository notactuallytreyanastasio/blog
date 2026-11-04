---
name: walkthrough
description: Drive the app in a visible browser, step by step at human pace, through a workflow given as an action/outcome table or a plain-English description, for a person to watch. Use for "walk me through <flow>", "show me <flow> in the browser", "run this workflow so I can watch", demos and manual-QA style passes. Not for writing browser tests and not for hunting bugs on production.
argument-hint: <action/outcome table, plain-English flow, or path to a workflow .json>
---

# Walkthrough

Turn the user's flow into a workflow file, then run it in a headed browser,
one step at a time, slowly enough to follow. A person is watching the screen:
nothing runs in parallel, and nothing is sped up to save time.

Reference for the workflow format, targets, actions, expectations and the
adapter: `walkthrough/README.md`. Read it before writing a workflow.

## Input

`$ARGUMENTS` is one of:

- **A path to a workflow `.json`**: skip to Step 4.
- **A table** of actions and expected outcomes, e.g.

  | Action                       | Outcome                        |
  | ---------------------------- | ------------------------------ |
  | Open the blog index          | The post list loads            |
  | Click the newest post        | The article and comments show  |

- **Plain English**: "open the newest post, scroll to the comments, leave one
  as Walkthrough and check it shows up".

## Step 1: Preflight

Run these read-only checks and fix what is missing before anything else:

```bash
ls walkthrough/node_modules/.bin/playwright          # deps installed?
curl -s -o /dev/null -w '%{http_code}' http://localhost:4000/   # server up?
```

- No deps: `cd walkthrough && npm install && npm run browser`.
- No server: start `mix phx.server` (use `PORT=<n>` if 4000 is taken and set
  `WALKTHROUGH_BASE_URL=http://localhost:<n>` to match) and wait for it.
- Never point the run at anything but localhost. `WALKTHROUGH_ALLOW_REMOTE=1`
  exists for a read-only demo against a deployed site and nothing else; a
  workflow that fills a form or clicks a submit button does the real thing
  there.

## Step 2: Turn the input into steps

Split the flow into steps a person would name: one action each, followed by
the outcomes they would look for. Plain English usually hides outcomes; add
the obvious ones ("the page loads", "the form clears") so a broken step is
caught where it breaks, not three steps later.

For each step, find real selectors. Never guess them:

1. Find the route in `lib/blog_web/router.ex` and the LiveView or controller
   that serves it.
2. Read its template and use `data-testid`, then `id`, then role and
   accessible name, then label or placeholder, then visible text. `css:` is a
   last resort; this app has few test ids, so stable class names on
   structural elements (`.blog-post-row`, `.mac-title`) are acceptable when
   nothing better exists.
3. Reuse targets from an existing workflow in `walkthrough/workflows/` when
   one covers the same page.

If a step cannot be targeted without a selector the page does not have, say so
and ask whether to add a `data-testid` to the template or fall back to text.

## Step 3: Data and secrets

There is no sandbox: the run uses whatever the server's database holds, and
what the workflow creates stays. Say so in the workflow's `description` when
a step writes anything.

- Put values the steps share in `vars` and refer to them as `{{var.name}}`.
- Passwords (the `/admin` pages) come from the environment as
  `{{env.NAME}}`. Never write one into a workflow or the adapter.
- If a run needs records that do not exist, create them the way a user would
  (as earlier steps) or in the adapter's `prepare`, which can call the app's
  endpoints and return ids for `{{var.*}}`.

Write the workflow to `walkthrough/runs/workflows/<slug>.json`, which is
gitignored, unless the user wants to keep it; keepers go in
`walkthrough/workflows/`. The runner validates the file's structure before the
browser opens. For a dry run without a window, add `WALKTHROUGH_HEADLESS=1
WALKTHROUGH_PACE=fast`, but only when the user asks for one.

## Step 4: Show the plan, then run

Show the user the step table you parsed (step, action, target, outcomes) so
they know what they are about to watch. Ask only if something was ambiguous;
otherwise start.

Run it in the background, from `walkthrough/`:

```bash
WALKTHROUGH_FILE=<absolute path to workflow.json> \
WALKTHROUGH_PACE=normal \
npm run walk
```

`WALKTHROUGH_PACE=slow` for a demo, `fast` only when the user asks to rerun
quickly. Tell the user the browser is opening. Do not drive anything else
against the same server while it runs.

## Step 5: Report

When it finishes, read `report.md` from the run folder it prints and give the
user a per-step summary: which steps passed, which failed and why, and any
console errors, 5xx responses or crashed views, with the step they happened
on. Screenshots are saved in one folder per step
(`NN-<step>/1-after-action.png`, `2-after-checks.png` or `2-failed.png`); tell
the user the run folder, and look at a failed step's screenshot before
explaining the failure.

If a step failed because of the workflow (wrong selector, outcome checked
before it could appear), fix the workflow and offer to rerun. If the app is
wrong, say so plainly; that is a finding, not a workflow bug.

## Notes

- The root layout's sidebar carries an `<h1>` on every page under the
  `:browser` pipeline, so `css:h1` matches the sidebar, not the page.
  Target headings as `css:main h1`. Pages with their own root layout
  (`/knicks`, `/sky`, `/phish`, `/gallery`, `/cameras`, `/blinks`, the
  makers) have no sidebar.
- The home page shows an 8-second boot splash, then a first-visit tour.
  Click `css:.boot-hint` to skip the splash and `role:button:Skip tour` to
  dismiss the tour before touching the desktop. The Finder window is closed
  by default.
- Several games open on a modal that intercepts every click underneath it:
  Wordle (`role:button:Got it!`), the chess variant (`role:button:play →`),
  2048 (`role:button:START`). Dismiss it as its own step; the click log
  says `intercepts pointer events` when a workflow forgot to.
- `walkthrough/walk-all.sh` runs every kept workflow in order; use it after
  a change that touches many pages.
- Wordle starts in hard mode (`role:button:HARD MODE` toggles it), which
  rejects guesses that ignore a discovered letter. The chess board marks
  state with `data-selected`, `data-legal` and `data-sq` attributes, not the
  overlay classes in the template. A `count` expectation counts every match;
  every other target resolves to the first match unless `nth` is given.
- Pages that depend on a secret or an outside service render less without
  it: Lolly and Rooted show no tabs until the chat is unlocked, the website
  pics icon needs the iCloud album, the Python demo shows the value of the
  last expression and cannot print.
- `/who` sends nothing of its graph until the gate opens. `who.json` checks
  the gate; `who_unlocked.json` takes the password from
  `WHO_CHAT_PASSWORD` (the server falls back to `ZIGGY_CHAT_PASSWORD`) and
  its last step asks the chat a real question, which costs DeepSeek credit
  and needs `DEEPSEEK_API_KEY` on the server. `walk-all.sh` skips it.
- The default `settle` waits for LiveView to reconnect and finish any
  `phx-*-loading` state after each action; a plain controller page passes
  straight through.
- `handoff` opens the Playwright inspector so the watcher can take over
  mid-flow and resume.
- Pages that stream outside data (the Bluesky and Phish views, the maps) show
  whatever is live at the time; an expectation on their content is a guess.
