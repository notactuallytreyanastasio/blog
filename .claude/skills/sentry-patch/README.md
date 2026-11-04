# sentry-patch: what was verified, against what

**Not run against a live Sentry.** There is no Sentry project reachable
from this machine, so the fetch and the rule were run against
`mock/sentry_mock.py`, which serves three issues built to the response
shapes in Sentry's API reference (2026-10-14):

- `GET /api/0/projects/{organization_id_or_slug}/{project_id_or_slug}/issues/`:
  array of issue objects with `id`, `shortId`, `title`, `culprit`,
  `permalink`, `count`, `userCount`, `firstSeen`, `lastSeen`, `level`,
  `status`, `type`, `metadata`, `project`, `stats`. The reference marks it
  deprecated in favour of `/api/0/organizations/{org}/issues/?project=<id>`;
  it is still served and takes the project *slug*, which is why it is
  used. `query` defaults to `is:unresolved`; the script sends it anyway.
- `GET /api/0/organizations/{org}/issues/{issue_id}/events/?full=true`:
  array of events, each with `eventID`, `groupID`, `title`, `culprit`,
  `dateCreated`, `platform`, `tags[{key,value}]`, `metadata{type,value}`
  and `entries[]`; the `exception` entry has `data.values[]` with `type`,
  `value`, `module`, `mechanism`, `stacktrace.frames[]`; a frame has
  `filename`, `absPath`, `module`, `function`, `lineNo`, `colNo`, `inApp`,
  `context` (`[[lineNo, source], ...]`) and `vars`. `full=true` caps the
  page at 10 (`events_per_issue` defaults to that).
- `.../events/latest/` is also served by the mock; `triage.py` does not
  use it, since the rule needs every event, not the latest one.

The mock's values (an Elixir blog, three issues) are invented. The field
names and nesting are the reference's. Whether a real Sentry fills
`vars` depends on the SDK: the reference example has `"vars": null` on a
JavaScript frame, and the Elixir SDK does not send locals by default, so
clause 3 will often have only `context` and the exception value to work
from. The skill says so.

## The run

```bash
python3 -I mock/sentry_mock.py 8766 &
cat > /tmp/sentry.toml <<'EOF'
base_url = "http://127.0.0.1:8766"
org = "mock-org"
project = "blog"
token_env = "SENTRY_AUTH_TOKEN"
max_prs = 3
min_events = 2
events_per_issue = 10
in_app_prefixes = ["lib/"]
EOF
python3 -I triage.py --config /tmp/sentry.toml --out /tmp/report.json
```

Without the token:

```
triage.py: $SENTRY_AUTH_TOKEN is not set; no request made
exit=1
```

The mock without a Bearer header (what a bad token would get):

```
$ curl -s http://127.0.0.1:8766/api/0/projects/mock-org/blog/issues/
{"detail": "Authentication credentials were not provided."}
```

With `SENTRY_AUTH_TOKEN=fake`:

```
| issue | title | verdict | why |
|---|---|---|---|
| [BLOG-1](https://mock-org.sentry.io/issues/1001/) | ArgumentError: errors were found at the given arguments | candidate | lib/blog/posts.ex:118 Blog.Posts.get_post_by_slug!/1 raises ArgumentError in all 3 events |
| [BLOG-2](https://mock-org.sentry.io/issues/1002/) | DBConnection.ConnectionError: tcp recv (idle): timeout | rejected | exception type 'DBConnection.ConnectionError' matches the timeout/network/resource pattern |
| [BLOG-3](https://mock-org.sentry.io/issues/1003/) | MatchError: no match of right hand side value | rejected | top in-app frame differs across events: lib/blog/feeds.ex:57 Blog.Feeds.parse/1; lib/blog/feeds.ex:30 Blog.Feeds.refresh/0 |

3 unresolved; 1 candidate(s) under the cap of 3; 2 rejected; 0 skipped; report at /tmp/report.json
exit=0
```

The brief asked for two issues, one deterministic and one timeout.
BLOG-3 was added so that clause 1's "same top in-app frame" is exercised
by something other than its absence: its two events raise `MatchError`
from `feeds.ex:30` and `feeds.ex:57`.

Requests the mock logged for that run:

```
GET /api/0/projects/mock-org/blog/issues/?query=is%3Aunresolved&limit=100
GET /api/0/organizations/mock-org/issues/1001/events/?full=true&per_page=10
GET /api/0/organizations/mock-org/issues/1002/events/?full=true&per_page=10
GET /api/0/organizations/mock-org/issues/1003/events/?full=true&per_page=10
```

The candidate as written to `report.json`, which is what Step 2 of the
skill writes the test from:

```json
{
  "short_id": "BLOG-1",
  "id": "1001",
  "title": "ArgumentError: errors were found at the given arguments",
  "culprit": "Blog.Posts.get_post_by_slug!/1",
  "permalink": "https://mock-org.sentry.io/issues/1001/",
  "count": "21",
  "events_fetched": 3,
  "verdict": "candidate",
  "exception": {
    "type": "ArgumentError",
    "value": "errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n",
    "module": null
  },
  "frame": {
    "filename": "lib/blog/posts.ex",
    "function": "Blog.Posts.get_post_by_slug!/1",
    "lineNo": 118,
    "context": [
      [116, "  def get_post_by_slug!(slug) when is_binary(slug) do"],
      [117, "    [year, rest] = String.split(slug, \"-\", parts: 2)"],
      [118, "    Repo.get_by!(Post, year: String.to_integer(year), slug: rest)"]
    ],
    "vars": {"slug": "\"\"", "year": "\"\"", "rest": "nil"}
  },
  "distinct_values": ["errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n"],
  "latest_event_id": "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1",
  "tags": {"environment": "prod", "level": "error", "handled": "no", "url": "https://bobbby.online/posts/"},
  "needs": "clause 3: a unit test from frame.vars / exception.value that reaches frame.lineNo and fails with exception.type"
}
```

Cap and skip, the two things a scheduled run depends on:

```
$ SENTRY_AUTH_TOKEN=fake python3 -I triage.py --config /tmp/sentry.toml --max 0 --skip BLOG-3
| [BLOG-1](...) | ... | rejected | over the per-run cap of 0; next run |
| [BLOG-2](...) | ... | rejected | exception type 'DBConnection.ConnectionError' matches ... |
| [BLOG-3](...) | ... | skipped | a sentry/ branch or PR already exists for it |

3 unresolved; 0 candidate(s) under the cap of 0; 2 rejected; 1 skipped
```

`--skip` did not fetch BLOG-3's events (one fewer `events/` request in the
mock log for that run).

## What is not verified

- Anything about a real Sentry: auth scopes (the reference says
  `event:read`), rate limits, pagination past 100 issues (`limit=100`, no
  cursor following), whether `per_page` is honoured on the events
  endpoint (the reference does not list it; `full=true` caps at 10
  regardless).
- Clause 3 end to end: no test was written from the candidate, no branch
  or PR was made. Steps 2 to 5 of the skill were not run; they are
  written to use write-pr's `open.sh`, which was run in its own README.
- The transient patterns against real exception names outside Elixir and
  Python. A type like `java.net.SocketTimeoutException` matches `socket`
  and `timeout`; one like `Faraday::ConnectionFailed` matches
  `connection(...)`; an unusual one will slip through to clause 3, where
  the test is supposed to catch it, since a timeout cannot be reproduced
  from the event's arguments.
