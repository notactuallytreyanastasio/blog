# Walkthrough

A walkthrough drives the app through a workflow in a **visible browser, one
step at a time, at human pace**, so a person can watch it. It is for demos,
manual-QA style passes and "show me this flow": not a test suite, never run
in CI, and the spec skips itself unless `WALKTHROUGH_FILE` is set.

This folder is self-contained. It has its own `package.json`, knows nothing
about the app beyond `adapter.ts`, and can be copied into any repo that serves
HTML. Use `/walkthrough` to turn an action/outcome table or a plain-English
description into a workflow file and run it.

## Running

```bash
cd walkthrough
npm install && npm run browser        # once

WALKTHROUGH_FILE=workflows/read_a_post.json npm run walk
```

| Variable                  | Default                 | Meaning                                                   |
| ------------------------- | ----------------------- | --------------------------------------------------------- |
| `WALKTHROUGH_FILE`        | (required)              | Workflow JSON to run                                      |
| `WALKTHROUGH_BASE_URL`    | `adapter.ts`'s URL      | Where the app is; must be localhost (see below)           |
| `WALKTHROUGH_PACE`        | `normal`                | `slow`, `normal` or `fast`                                |
| `WALKTHROUGH_SLOWMO`      | `150`                   | Extra ms Playwright waits on every browser operation      |
| `WALKTHROUGH_HOLD_MS`     | `15000`                 | How long a failed step stays on screen                    |
| `WALKTHROUGH_END_HOLD_MS` | `4000`                  | How long the final screen stays up                        |
| `WALKTHROUGH_HEADLESS`    | unset                   | `1` to run without a window (checking a workflow)         |
| `WALKTHROUGH_OUT`         | `walkthrough/runs`      | Where run reports are written                             |
| `WALKTHROUGH_ALLOW_REMOTE`| unset                   | `1` to allow a non-localhost base URL. Everything is real there. |

Substitution is one pass: a `vars` value that itself says `{{env.NAME}}`
is inserted as that text, not expanded. Put `{{env.NAME}}` in the step.

`workflows/` holds the kept tours of the site. One per surface:
`home_desktop`, `home_windows`, `read_a_post`, `arcade`, `tools`, `feeds`,
`maps_and_data`, `site_and_media`, `makers`, `spectators`, `static_pages`,
`smart_steps`, `blinks_modes`, `memory_apps`, `who`. Deeper sessions on one
thing: `wordle_full_game`, `blackjack_round`, `chess_move`,
`editor_session`, `who_unlocked`. `known_broken` visits the routes that
error, so the report keeps a record of them until they are fixed.
`leave_a_comment` writes a comment, and `who_unlocked` needs
`WHO_CHAT_PASSWORD` and asks the model a real question; both are skipped by
the script below. `./walk-all.sh` runs the rest in order and lists the ones
that failed.

Every run saves screenshots, one folder per step, under
`runs/<timestamp>-<name>/` (gitignored):

```
runs/2026-10-14T18-56-21-110Z-read-a-post/
├── report.md                     # per-step table linking every screenshot
├── report.json
├── 01-open-the-blog-index/
│   ├── 1-after-action.png        # once the action ran and the page settled
│   └── 2-after-checks.png        # with the result banner, after the expectations
├── 02-open-the-newest-post/
│   ├── 1-after-action.png
│   └── 2-failed.png              # in place of after-checks when the step fails
└── ...
```

A failed action is saved as `action-failed.png`; `screenshot` actions and
downloaded files go in the folder of the step that took them.

While it runs, a banner in the bottom-left corner shows the current step and
turns green or red with the result, and each element is outlined just before
it is clicked or typed into. Console errors, uncaught page errors, HTTP 5xx
responses and crashed views are recorded against the step they happened in.

## The adapter

`adapter.ts` is the only file that knows about the app:

```ts
export const adapter: Adapter = {
  baseURL: baseURL("http://localhost:4000"),
  // prepare?: async ({ page, request }) => ({ ...values for {{var.*}} }),
  // cleanup?: async (ctx) => { ... },
  // settle?:  async (page, timeoutMs) => { ... },
  // crashed?: async (page) => "message" | null,
};
```

- `prepare` runs once before the first step: log in, create records through
  the app's own endpoints, run a seed script. Whatever it returns is available
  to steps as `{{var.<name>}}` and wins over the workflow's own `vars`.
- `cleanup` runs once after the last step, pass or fail.
- `settle` waits for the app to finish rendering after each action. The
  default understands Phoenix LiveView (socket connected, no `phx-*-loading`
  class left) and passes straight through on any other page.
- `crashed` is checked after every step. The default reports a LiveView
  wearing `phx-error`.

The runner never imports app code and never touches a database. If a run needs
data, the adapter makes it the way a user would, or through an endpoint the
app exposes for exactly that.

## Workflow format

```json
{
  "name": "Leave a comment",
  "description": "Optional, shown in the report",
  "vars": { "slug": "building-this-blog" },
  "onFailure": "stop",
  "timeoutMs": 15000,
  "pace": { "stepDelayMs": 1500 },
  "steps": [
    {
      "do": "Open the post",
      "action": { "type": "goto", "url": "/post/{{var.slug}}" },
      "expect": [{ "type": "visible", "target": "id:post-content" }]
    }
  ]
}
```

- Any string in a step may use `{{var.<name>}}` (from `vars` or `prepare`,
  dotted paths allowed) or `{{env.<NAME>}}` (from the environment, for
  passwords that must not be written into a file). A reference with no value
  fails the run before the browser opens.
- `onFailure`: `stop` (default) holds the failed screen, then skips the rest;
  `continue` holds it, then carries on.
- A step needs an `action`, an `expect` list, or both. Expectations are
  checked after the action and after the page has settled; each waits up to
  the step timeout.

### Targets

A target is a shorthand string or an object. Prefer them in this order: test
id, then id, then role, then label or placeholder, then text. `css:` is a last
resort for pages that offer nothing better.

| Shorthand               | Object                                   |
| ----------------------- | ---------------------------------------- |
| `testid:save-button`    | `{ "testid": "save-button" }`            |
| `id:post-content`       | `{ "id": "post-content" }`               |
| `role:button:Save`      | `{ "role": "button", "name": "Save" }`   |
| `label:Email`           | `{ "label": "Email" }`                   |
| `placeholder:Search`    | `{ "placeholder": "Search" }`            |
| `text:Saved` or `Saved` | `{ "text": "Saved" }`                    |
| `css:.foo > .bar`       | `{ "css": ".foo > .bar" }` (last resort) |

Objects also take `exact`, `hasText` (filter by contained text), `within`
(another target to search inside) and `nth` (0-based; the first match is used
otherwise), e.g.
`{ "css": ".blog-post-row", "hasText": "Chess", "within": "css:.blog-posts-list" }`.

### Actions

| `type`                                 | Fields                 | Notes                                                                         |
| -------------------------------------- | ---------------------- | ----------------------------------------------------------------------------- |
| `goto`                                 | `url`                  | Relative to the base URL                                                      |
| `click`, `dblclick`, `hover`, `scroll` | `target`               |                                                                               |
| `fill`                                 | `target`, `value`      | Clears, then types key by key at the pace                                     |
| `clear`                                | `target`               |                                                                               |
| `select`                               | `target`, `option`     | Matches the option's value or label                                           |
| `check`, `uncheck`                     | `target`               |                                                                               |
| `press`                                | `key`, `target?`       | e.g. `Enter`, `Escape`, `Control+A`                                           |
| `download`                             | `target`               | Clicks and saves the file into the run folder                                 |
| `wait`                                 | `ms`                   |                                                                               |
| `waitFor`                              | `target`, `timeoutMs?` | Until visible                                                                 |
| `screenshot`                           | `name`                 | Extra screenshot besides the per-step one                                     |
| `narrate`                              | `message`, `ms?`       | Shows a note in the banner, holds (4s default)                                |
| `handoff`                              | `message?`             | Opens the Playwright inspector; the watcher takes over and resumes from there |

### Expectations

| `type`                                                | Fields                                                           |
| ----------------------------------------------------- | ---------------------------------------------------------------- |
| `visible`, `hidden`, `enabled`, `disabled`, `checked` | `target`                                                         |
| `text`                                                | `target`, `contains` or `equals`                                 |
| `value`                                               | `target`, `equals`                                               |
| `count`                                               | `target`, `equals`                                               |
| `url`                                                 | `contains` or `matches` (regex)                                  |
| `title`                                               | `contains`                                                       |
| `flash`                                               | `contains` (an element with `role="alert"`)                      |
| `download`                                            | `filenameMatches?`, `contains?` (applies to the last `download`) |

## Rules

- Local only. The base URL must be localhost unless `WALKTHROUGH_ALLOW_REMOTE=1`
  is set for that run, and then everything the workflow does is real: it
  posts the comment, it saves the record.
- Never write a secret into a workflow or the adapter. Use `{{env.NAME}}`.
- Workflows are data. Selectors are interpreted in `src/runner.ts` and nowhere
  else; if a page needs a selector it does not have, add a `data-testid` to
  the template rather than reaching for a brittle CSS path.
