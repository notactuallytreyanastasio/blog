# blinks parity fixtures

What production (Phoenix) answered on 2026-09-30 to every public GET that
/blinks serves, so a Blimp port can be diffed against it byte for byte.
There were 163 blinks and 218 tags at the time.

`INDEX` lists each fixture's name and the exact path and query string that
was sent. `capture.sh` walks it with curl. Each fixture has two files:

- `NAME`: the body as received.
- `NAME.head`: the status line and response headers, with CRs stripped and
  the headers that change per request (date, cf-*, report-to, nel,
  content-length, ...) removed.

To recapture production, run `./capture.sh`. It only sends GETs. To capture
the same set from a Blimp build into a scratch directory and diff it:

    BASE=http://localhost:4100 ./capture.sh /tmp/blimp-blinks
    diff -r --exclude=INDEX --exclude=capture.sh --exclude=README.md . /tmp/blimp-blinks

## What is not stable

The JSON API is deterministic: lists are ordered by `inserted_at desc, id
desc`, and `sort=popular` by save count, then recency. Three things are not.

- `api_comments_*.json` carry a `post_token` (a Phoenix.Token with the time
  it was issued in it). Compare everything except that field.
- `api_random*.json`, `stumble.txt`, `page_surf.html`, `page_tv.html` pick
  a random blink. Compare their shape and headers, not their content.
- The LiveView pages (`page_*.html`) differ from one render to the next only
  in the CSRF token and in LiveView's session attributes. After this
  normalization two renders of the same page are identical (checked on
  `/blinks` and `/blinks-reader`):

      N='s/(csrf-token" content=")[^"]*/\1X/; s/id="phx-[A-Za-z0-9_-]+"/id="phx-X"/g; s/data-phx-(session|static)="[^"]*"/data-phx-\1="X"/g'
      sed -E "$N" page_blinks.html

A Blimp page has no LiveView session, so for the pages the target is the
normalized markup inside `data-phx-main`, not the whole document.

## Behaviour captured as it is, bugs included

- `api_blinks_offset_abc.txt` is a 500: `String.to_integer("abc")` raises in
  `BlinkController.index`. A port should answer 400 on purpose and note that
  it differs here, rather than copy the crash.
- `api_blinks_limit501_offset160.json` shows the limit clamp (500) and an
  offset past most of the list.
- `api_comments_missing.json` is a 200 with an empty list for a blink that
  does not exist. `api_comments_bad_id.json` is a 400.
- `api_lookup_no_token.json` and `api_export_no_token.json` are the 401s:
  `lookup` and `export` are token-gated, unlike the other reads.
- `blinks-sw.js.head` has `cache-control: max-age=14400`, although
  `BlinkFeedController.service_worker` sets `no-cache`. Neither the
  Caddyfile nor lib/ says 14400. It is Cloudflare's default browser cache
  TTL, which is the likely source. A port that sends `no-cache` will still
  differ here until that is settled.
- `page_review_no_key.txt` is the 302 to /blinks that `/blinks/review`
  gives without `?key=`.
- The data changes whenever a link is saved, so recapture production and
  the Blimp build at the same time.
