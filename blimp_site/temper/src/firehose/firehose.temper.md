# The firehose pages' logic

What `/reddit-links`, `/emoji-skeets` and `/jetstream_comparison` compute
rather than store, shared by the server (`src/98_firehose.blimp`, which
holds the connections to the relays and the YouTube grid) and the pages'
programs (`static/firehose/*.blimp`, which filter and draw). A port of the
pure parts of `BlueskyHose`, `BlogWeb.RedditLinksLive`,
`BlogWeb.EmojiSkeetsLive` and `BlogWeb.JetstreamComparisonLive`. Lower-casing
stays Blimp: Temper's `String` has no case mapping.

## YouTube ids

`RedditLinksLive.extract_youtube_id/1` tried four regexes in order and took
the first that matched anywhere in the URL: `youtu\.be\/`, then
`youtube\.com\/watch\?v=`, `youtube\.com\/v\/` and `youtube\.com\/embed\/`, each
followed by `([a-zA-Z0-9_-]+)`.

A regex match is the leftmost place where the prefix is followed by at least
one id character, which is not always the first place the prefix appears:
`youtu.be/?u=youtu.be/abc` is `abc`. So each prefix is looked for again after
an occurrence that has no id after it. `/shorts/` and `/live/` links match
none of the four, as in the LiveView (`test/firehose_test.blimp` checks this
against the Elixir regexes' answers for every YouTube link in the recorded
frames).

    let fh_id_char(c: Int): Boolean {
      if (c >= 97 && c <= 122) {
        true
      } else if (c >= 65 && c <= 90) {
        true
      } else if (c >= 48 && c <= 57) {
        true
      } else if (c == 95) {
        true
      } else {
        c == 45
      }
    }

Where the run of id characters that starts at `i` ends.

    let fh_id_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        i
      } else if (fh_id_char(s[i])) {
        fh_id_end(s, s.next(i))
      } else {
        i
      }
    }

The id after the first occurrence of `prefix` at or after `from` that has
one, or "".

    let fh_after(s: String, prefix: String, from: StringIndex): String {
      let found = s.indexOf(prefix, from);
      if (found is StringIndex) {
        let start = s.slice(found, s.end);
        let rest = start.slice(prefix.end, start.end);
        let stop = fh_id_end(rest, String.begin);
        if (stop > String.begin) {
          rest.slice(String.begin, stop)
        } else {
          fh_after(s, prefix, s.next(found))
        }
      } else {
        ""
      }
    }

    export let fh_youtube_id(url: String): String {
      let a = fh_after(url, "youtu.be/", String.begin);
      if (!a.isEmpty) {
        a
      } else {
        let b = fh_after(url, "youtube.com/watch?v=", String.begin);
        if (!b.isEmpty) {
          b
        } else {
          let c = fh_after(url, "youtube.com/v/", String.begin);
          if (!c.isEmpty) { c } else { fh_after(url, "youtube.com/embed/", String.begin) }
        }
      }
    }

`BlueskyHose.derive_youtube_embed_link/2`: a post's link card goes to the
YouTube page when its URI says `youtube.com` or `youtu.be`.

    export let fh_contains(s: String, find: String): Boolean {
      s.indexOf(find) is StringIndex
    }

    export let fh_is_youtube(uri: String): Boolean {
      fh_contains(uri, "youtube.com") || fh_contains(uri, "youtu.be")
    }

## The embed

Blimp's `el()` will not make an `<iframe>` (nor anything else that loads a
document of its own), so the page puts the LiveView's iframe in its cell as
HTML. The id is the only thing in it that came off the network, and it is
used only if it is nothing but id characters, which is all
`fh_youtube_id` ever answers: a server, or a relay, that sent anything else
gets an empty cell, not markup.

    export let fh_is_id(id: String): Boolean {
      !id.isEmpty && fh_id_end(id, String.begin) >= id.end
    }

    export let fh_embed_html(id: String): String {
      if (fh_is_id(id)) {
        "<iframe src=\"https://www.youtube.com/embed/${id}\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen class=\"absolute inset-0 w-full h-full\"></iframe>"
      } else {
        ""
      }
    }

## The grid

Fifty cells. A new video fills the next empty cell; once all fifty are
full it replaces the oldest, in place, so nothing else on the page moves
(`handle_info({:reddit_link, _}, _)`).

    export let fh_max_videos = 50;

    export let fh_slot(next_pos: Int): Int {
      (next_pos % fh_max_videos) orelse panic()
    }

## Search

The search pages show nothing until something is typed, then every post
whose lower-cased text contains the lower-cased, trimmed term
(`filter_skeets/2`). The caller lower-cases both.

    export let fh_matches(lower_text: String, lower_term: String): Boolean {
      !lower_term.isEmpty && fh_contains(lower_text, lower_term)
    }

The first `n` characters of `s`, and `...` when there were more, as the
comparison page cut DIDs (30) and post text (200) with `String.slice/3`.
That counted graphemes; this counts code points, which differs only for a
flag or a family emoji straddling the cut.

    let fh_nth(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { fh_nth(s, s.next(i), n - 1) }
    }

    export let fh_cut(s: String, n: Int): String {
      let stop = fh_nth(s, String.begin, n);
      if (stop >= s.end) { s } else { "${s.slice(String.begin, stop)}..." }
    }

## Lines the pages print

    export let fh_filtering(term: String): String { "Filtering for: \"${term}\"" }

    export let fh_showing(shown: Int, total: Int): String {
      "Showing ${shown.toString()} of ${total.toString()} skeets"
    }

    export let fh_no_match(term: String): String {
      "No skeets match your search term: \"${term}\"."
    }

    export let fh_feed_empty(feed: String, term: String): String {
      if (term.isEmpty) {
        "Enter a search term to see ${feed} skeets"
      } else {
        "No ${feed} skeets match \"${term}\""
      }
    }
