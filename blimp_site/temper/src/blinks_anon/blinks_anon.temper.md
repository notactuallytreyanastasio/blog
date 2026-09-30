# Blinks, the anonymous writes' rules

The numbers `BlinkController` and `BlinkCommentController` enforce on
anonymous visitors, and the arithmetic around them. The server side
(`src/99_blinksanon.blimp`) holds the state: the rate limiter is an actor,
and the rows are Postgres's. What is decided here is only ever a function of
its arguments.

No classes; every name starts `blka_`.

## Fixed windows

`Blog.RateLimiter.allow?(key, limit, window)` counts hits in the window
`div(now, window)`: every hit counts, the refused ones too, and the count
starts again when the window turns over. So a limit of 4 a minute lets 8
through across a minute boundary, as it does in Phoenix. The window is named
by the second it starts at. Seconds since 1970 are `Int64`: they pass
`Int`'s 2^31 in 2038.

    export let blka_window_start(now: Int64, window: Int64): Int64 {
      now - ((now % window) orelse panic())
    }

    export let blka_window_end(now: Int64, window: Int64): Int64 {
      blka_window_start(now, window) + window
    }

    export let blka_allowed(count: Int, limit: Int): Boolean { count <= limit }

The limits, as `{limit, window}` pairs in the controllers:

| key               | limit | window   | on refusal                         |
|-------------------|-------|----------|------------------------------------|
| `save:`           | 30    | 60 s     | 400 `device_id required`           |
| `suggest:`        | 3     | 60 s     | 429 `rate limited`                 |
| `suggest_day:`    | 20    | 86,400 s | 429 `rate limited`                 |
| `comment:`        | 4     | 60 s     | 429 `rate limited`                 |
| `comment_day:`    | 60    | 86,400 s | 429 `rate limited`                 |
| `comment_report:` | 10    | 60 s     | 429 `rate limited`                 |
| `react:`          | 30    | 60 s     | 429 `rate limited`                 |

A refused save is a 400 because `with_device/3` folds the limit into the
same `and` as the `device_id` check, so both answer alike.

## Who a visitor is

A device id is 8 to 64 bytes (`byte_size(device_id) in 8..64`), bytes and
not characters.

    export let blka_device_id_ok(bytes: Int): Boolean {
      bytes >= 8 && bytes <= 64
    }

## The comment token

`post_token` is issued by `GET /comments` and must be at least 3 seconds
old when it comes back (bots post the instant they load a form), and at
most 2 hours, which `Phoenix.Token.verify/4` checks as `max_age`.

    export let blka_min_token_age = 3i64;
    export let blka_max_token_age = 7200i64;

    export let blka_token_old_enough(issued: Int64, now: Int64): Boolean {
      now - issued >= blka_min_token_age
    }

## Moderation

Three reports hide a comment (the UPDATE compares against this). The count
keeps going up after that, and a comment is hidden once, at the report that
reaches 3.

    export let blka_hide_at = 3;

Comment limits, in graphemes (Ecto's `validate_length/3` counts with
`String.length/1`):

    export let blka_max_author = 40;
    export let blka_max_content = 500;
    export let blka_max_links = 2;
