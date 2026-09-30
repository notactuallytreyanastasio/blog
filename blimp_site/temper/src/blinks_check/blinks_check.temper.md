# Blinks, the dead-link sentinel's rules

`Blog.Blinks.LinkCheck` re-checks every saved url once a day. Finding a
dead page is the easy part; the rules here are about refusing to call a
page dead when the checker only failed to look at it, which is what
happened on 2026-07-24, when a billing block null-routed the host and 38
links "died" inside four minutes. So a check has three answers, a link
needs two dead answers in a row, and a sweep that looks broken on our side
is thrown away whole. The HTTP, the schedule and the writes are
`src/99_blinkscheck.blimp`'s.

No classes; every name starts `blc_`.

## One check

`check_url/1`: an answer below 400 is `ok`; 404 and 410 are `dead`; any
other status (a 403 from a bot wall, a 429, a 5xx) is `unknown`, a page we
could not read rather than one that stopped existing.

    export let blc_status_verdict(status: Int): String {
      if (status < 400) {
        "ok"
      } else if (status == 404 || status == 410) {
        "dead"
      } else {
        "unknown"
      }
    }

A request that got no answer is `unknown`, except a host that no longer
resolves, the classic way a link rots. Req says `:nxdomain`; `http_result`
says `UnknownHostName`. (The interpreter's resolver has other names for a
failing name server, `NameServerFailure` and the like; Erlang's resolver
folds most failures into `:nxdomain`. Only the one that means "no such
name" is taken as dead here, which can only err towards `unknown`.)

    export let blc_error_verdict(reason: String): String {
      if (reason == "UnknownHostName") { "dead" } else { "unknown" }
    }

## A sweep that smells like our outage

`commit_sweep/1`: with at least 5 links checked, a sweep where more than
30% did not come back `ok` is discarded, `dead` and `unknown` alike. In
integers, so 3 of 10 is kept and 4 of 10 is not.

    export let blc_discard(total: Int, failed: Int): Boolean {
      total >= 5 && failed * 10 > total * 3
    }

## Writing a result

`record_result/2`, as the values the row gets: `[fail_count, dead_at]`,
where `fail_count` is -1 for "leave it" and `dead_at` is 0 to leave it, 1
to clear it and 2 to set it to now unless it is already set.

- `ok`: the link is alive, whatever it was.
- `unknown`: only `last_checked_at` moves; a strike already on the board
  stays, and so does a death.
- `dead`: one more strike, counted from the `fail_count` the sweep read.
  Two strikes and it is dead, keeping the first death's time; one strike
  is not dead (and a `dead_at` left from before is cleared, as
  `if(fails >= 2, do: ...)` is nil).

In code:

    export let blc_record(verdict: String, fail_count: Int): List<Int> {
      if (verdict == "ok") {
        [0, 1]
      } else if (verdict == "dead") {
        let fails = fail_count + 1;
        [fails, if (fails >= 2) { 2 } else { 1 }]
      } else {
        [-1, 0]
      }
    }
