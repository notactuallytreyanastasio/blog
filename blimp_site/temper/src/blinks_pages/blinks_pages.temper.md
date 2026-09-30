# Blinks, the other pages

What `/blinks/surf`, `/blinks/walk`, `/blinks/tv` and `/blinks/review`
compute rather than fetch, for their Blimp versions under `/blinks-next`
(`static/blinks/{surf,walk,tv,review}.blimp`). Postgres picks the random
link and ranks the similar ones, as it does for Phoenix; what is left is
list work on ids, and dates. A row is a decoded JSON map, which a Temper
function cannot take, so the pages hand over ids and strings.

No classes: a Temper class on the Blimp backend is an actor, and actors are
never collected. Every name starts `blkp_`.

    let { blk_stamp } = import("../blinks");

## Dates

Surf stamps its card `saved Jul 21, 2026` (`%b %-d, %Y`), TV its screen
`SAVED Aug 19 2026` (`%b %-d %Y`). `sep` is what goes between the day and
the year. The year is the first four characters of `inserted_at`
(`2026-07-21T14:02:11`); a string too short for one gives "".

    export let blkp_saved(iso: String, sep: String): String {
      let day = blk_stamp(iso);
      let four = iso.step(String.begin, 4);
      if (day == "" || four > iso.end) { "" } else { "${day}${sep}${iso.slice(String.begin, four)}" }
    }

## Channels

TV's channel number, `String.pad_leading("#{idx}", 2, "0")`: two digits
at least, more when there are more.

    export let blkp_pad2(n: Int): String {
      if (n >= 0 && n < 10) { "0${n.toString()}" } else { n.toString() }
    }

`Integer.mod/2`: the result takes the divisor's sign, so channel 0 minus
one is the last channel, not -1.

    export let blkp_mod(a: Int, n: Int): Int {
      let r = (a % n) orelse panic();
      if (r < 0) { r + n } else { r }
    }

## Lists of ids

The first `n` of `ids` that are not in `skip`. Walk's doors are the first
three of twelve similar links it has not walked
(`list_similar(12) |> Enum.reject(walked) |> Enum.take(3)`); Surf's "more
like this" takes three it has not stumbled onto, then picks one at random.

    export let blkp_first_not_in(ids: List<Int>, skip: List<Int>, n: Int): List<Int> {
      let fresh = ids.filter { (id: Int): Boolean => !blkp_has(skip, id) };
      if (fresh.length <= n) { fresh } else { fresh.slice(0, n) }
    }

    export let blkp_has(ids: List<Int>, id: Int): Boolean {
      ids.filter { (x: Int): Boolean => x == id }.length > 0
    }

Where `id` is in `ids`, or -1. Walk's rewind splits its trail at the crumb
clicked (`Enum.split_while(trail, &(&1.id != id))`).

    export let blkp_index(ids: List<Int>, id: Int): Int {
      blkp_index_from(ids, id, 0)
    }

    let blkp_index_from(ids: List<Int>, id: Int, i: Int): Int {
      if (i >= ids.length) { -1 } else if (ids[i] == id) { i } else { blkp_index_from(ids, id, i + 1) }
    }

The first `max` of `ids`. TV keeps the last 25 links it showed out of the
next pick (`Enum.take([blink.id | recent], 25)`); the page puts the new id
on the front, which is Blimp's `[id | ids]` (a Temper list grows only
through a `ListBuilder`, which is an actor).

    export let blkp_keep(ids: List<Int>, max: Int): List<Int> {
      if (ids.length <= max) { ids } else { ids.slice(0, max) }
    }

What a pick sends the server as `?exclude=`: the ids, comma separated,
the way `/api/blinks/random` reads them.

    export let blkp_csv(ids: List<Int>): String {
      ids.join(",") { (id: Int): String => id.toString() }
    }
