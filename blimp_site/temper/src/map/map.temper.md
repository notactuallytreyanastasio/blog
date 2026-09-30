# Tag a Wook

What `/map` computes rather than stores, shared by the server's room
(`src/97_map.blimp`) and the page's program (`static/map/map.blimp`): the
player a link embeds as, whether a tag may be saved, and the popup a pin
opens. A port of the pure parts of `BlogWeb.MapLive`, `Blog.TagIn`'s
changeset and the MapHook's popup. Who is on the page and the rows in
Postgres are the room's, and stay Blimp.

## The player a link embeds as

`generate_embed_url/1`: a link that mentions `music.apple.com` is an Apple
Music link, whatever else it says, and one that mentions `open.spotify.com`
a Spotify one. Anything else, or a link of either kind that does not parse,
embeds as nothing, which is `""` here and was `nil` there.

    export let geo_embed_url(link: String): String {
      if (geo_has(link, "music.apple.com")) {
        geo_apple_embed(link)
      } else if (geo_has(link, "open.spotify.com")) {
        geo_spotify_embed(link)
      } else {
        ""
      }
    }

    let geo_has(s: String, find: String): Boolean {
      s.split(find).length > 1
    }

### Spotify

The LiveView ran `~r"open\.spotify\.com/(?:[^/]+/)?track/([a-zA-Z0-9]+)"`
and took the first match. Without a regex, that is: at each
`open.spotify.com/`, leftmost first, try one path segment and then
`track/<id>`, and then `track/<id>` straight away, the order the optional
group is tried in. The segment is everything up to the next `/`: `[^/]+`
can give characters back, but none it gives back is a `/`. What follows an
occurrence runs on to the end of the link, through any later occurrence
(`open.spotify.com/xopen.spotify.com/track/abc` matches with the segment
`xopen.spotify.com`).

    let geo_spotify_embed(link: String): String {
      let pieces = link.split("open.spotify.com/");
      let id = geo_spotify_from(pieces, 1);
      if (id.isEmpty) { "" } else { "https://open.spotify.com/embed/track/${id}" }
    }

    let geo_spotify_from(pieces: List<String>, k: Int): String {
      if (k >= pieces.length) {
        ""
      } else {
        let rest = pieces.slice(k, pieces.length).join("open.spotify.com/") { (p): String => p };
        let id = geo_spotify_at(rest);
        if (id.isEmpty) { geo_spotify_from(pieces, k + 1) } else { id }
      }
    }

    let geo_spotify_at(rest: String): String {
      let segs = rest.split("/");
      let seg = segs[0];
      let with_seg = if (!seg.isEmpty && segs.length > 1) {
        geo_track_id(geo_after(rest, "${seg}/"))
      } else {
        ""
      };
      if (with_seg.isEmpty) { geo_track_id(rest) } else { with_seg }
    }

`track/` and one or more ASCII letters and digits: the id is all of them.

    let geo_track_id(s: String): String {
      if (geo_starts(s, "track/")) {
        let r = geo_after(s, "track/");
        r.slice(String.begin, geo_alnum_end(r, String.begin))
      } else {
        ""
      }
    }

    let geo_alnum_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && geo_is_alnum(s[i])) { geo_alnum_end(s, s.next(i)) } else { i }
    }

    let geo_is_alnum(c: Int): Boolean {
      if (c < 48) {
        false
      } else if (c <= 57) {
        true
      } else if (c < 65) {
        false
      } else if (c <= 90) {
        true
      } else if (c < 97) {
        false
      } else {
        c <= 122
      }
    }

    let geo_starts(s: String, prefix: String): Boolean {
      s.end >= prefix.end && s.slice(String.begin, prefix.end) == prefix
    }

`s` without `prefix`, which it starts with.

    let geo_after(s: String, prefix: String): String {
      s.slice(prefix.end, s.end)
    }

### Apple Music

`parse_apple_music_link_to_embed_url/1` parsed the link with `URI.parse/1`
and, when its host was exactly `music.apple.com` and it had a path, put the
path and query on `https://embed.music.apple.com`, dropping the scheme, any
user or port, and the fragment. `URI.parse/1` is RFC 3986's appendix B: an
optional scheme (a letter, then letters, digits, `+`, `-`, `.`, then `:`),
then `//` and an authority up to the first `/`, `?` or `#`, then the path up
to `?` or `#`, then the query up to `#`. The host is the authority after its
last `@` and before its first `:`. No `//`, no host; an empty path is no
path; a `?` with nothing after it is an empty query, and kept.

    let geo_apple_embed(link: String): String {
      let rest = link.slice(geo_scheme_end(link), link.end);
      if (!geo_starts(rest, "//")) {
        ""
      } else {
        let after_slashes = geo_after(rest, "//");
        let auth_end = geo_until(after_slashes, String.begin, true);
        let authority = after_slashes.slice(String.begin, auth_end);
        let tail = after_slashes.slice(auth_end, after_slashes.end);
        let path_end = geo_until(tail, String.begin, false);
        let path = tail.slice(String.begin, path_end);
        let more = tail.slice(path_end, tail.end);
        if (geo_host(authority) != "music.apple.com" || path.isEmpty) {
          ""
        } else if (geo_starts(more, "?")) {
          let q = geo_after(more, "?");
          "https://embed.music.apple.com${path}?${q.split("#")[0]}"
        } else {
          "https://embed.music.apple.com${path}"
        }
      }
    }

    let geo_host(authority: String): String {
      let at = authority.split("@");
      at[at.length - 1].split(":")[0]
    }

Where the characters that end an authority (`/`, `?`, `#`) or a path (`?`,
`#`) first appear, or the end.

    let geo_until(s: String, i: StringIndex, slash: Boolean): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        if (c == 63 || c == 35 || (slash && c == 47)) { i } else { geo_until(s, s.next(i), slash) }
      }
    }

Just past the scheme's `:`, or the start when there is no scheme.

    let geo_scheme_end(s: String): StringIndex {
      if (s.isEmpty || !geo_is_letter(s[String.begin])) {
        String.begin
      } else {
        geo_scheme_scan(s, s.next(String.begin))
      }
    }

    let geo_scheme_scan(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        String.begin
      } else {
        let c = s[i];
        if (c == 58) {
          s.next(i)
        } else if (geo_is_alnum(c) || c == 43 || c == 45 || c == 46) {
          geo_scheme_scan(s, s.next(i))
        } else {
          String.begin
        }
      }
    }

    let geo_is_letter(c: Int): Boolean {
      (c >= 65 && c <= 90) || (c >= 97 && c <= 122)
    }

## Whether a tag may be saved

The LiveView named an unnamed tagger `Anonymous Wook`, and only when the
field was exactly empty.

    export let geo_user_name(name: String): String {
      if (name.isEmpty) { "Anonymous Wook" } else { name }
    }

Then `Blog.TagIn.changeset/2` refused a tag whose name or link is blank,
and one off the globe. Ecto 3.12 casts a string that is empty once trimmed
to nil, and `validate_required` refuses nil, so a name of three spaces is
refused although the LiveView kept it. Trimmed is `String.trim/1`'s: every
Unicode `White_Space` character. A blank note is cast to nil and saved as
NULL; `geo_note` says what is saved.

The problem with a tag, as Ecto's message named it, or `""` for none.

    export let geo_tag_problem(name: String, link: String, lat: Float64, lng: Float64): String {
      if (geo_blank(name)) {
        "user_name can't be blank"
      } else if (geo_blank(link)) {
        "spotify_link can't be blank"
      } else if (lat < -90.0 || lat > 90.0) {
        "latitude must be between -90 and 90"
      } else if (lng < -180.0 || lng > 180.0) {
        "longitude must be between -180 and 180"
      } else {
        ""
      }
    }

    export let geo_note(note: String): String {
      if (geo_blank(note)) { "" } else { note }
    }

    export let geo_blank(s: String): Boolean {
      geo_blank_from(s, String.begin)
    }

    let geo_blank_from(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else if (geo_is_space(s[i])) {
        geo_blank_from(s, s.next(i))
      } else {
        false
      }
    }

    let geo_is_space(c: Int): Boolean {
      if (c <= 32) {
        c == 32 || (c >= 9 && c <= 13)
      } else if (c < 133) {
        false
      } else if (c == 133 || c == 160 || c == 5760) {
        true
      } else if (c >= 8192 && c <= 8202) {
        true
      } else {
        c == 8232 || c == 8233 || c == 8239 || c == 8287 || c == 12288
      }
    }

## The popup a pin opens

MapHook's `addSongMarkerToMap`: the tagger's name in bold, the note if
there is one, and the player, 300 by 152. A pin whose link embeds as
nothing got a bare name and a "Listen on Spotify" link instead, whatever
the link was. The name and note are escaped as the hook's `escapeHtml` did
(`'` as `&#039;`), and here also where the hook did not: the name in that
fallback and in the iframe's title. The link and the player's URL were
not escaped at all; here the link is (see `geo_href`) and a `"` in the
player's URL is, so neither can end the attribute it sits in. `n` makes the iframe's title
unique, which the hook did with `Date.now()`.

    export let map_popup_html(name: String, note: String, embed: String, link: String, n: Int): String {
      let who = if (name.isEmpty) { "Anonymous" } else { name };
      let href = if (link.isEmpty) { "#" } else { geo_href(link) };
      if (embed.isEmpty) {
        "<b>${map_escape(who)}</b><br><a href=\"${href}\" target=\"_blank\" rel=\"noopener noreferrer\">Listen on Spotify</a>"
      } else {
        let note_html = if (note.isEmpty) {
          ""
        } else {
          "<p style=\"margin-bottom: 5px; white-space: pre-wrap;\">${map_escape(note)}</p>"
        };
        "<div style=\"margin-bottom: 8px;\"><strong>${map_escape(who)}</strong></div>${note_html}<iframe title=\"Spotify Embed ${map_escape(who)} ${n.toString()}\" style=\"border-radius:12px\" src=\"${geo_quote(embed)}\" width=\"300\" height=\"152\" frameBorder=\"0\" allowfullscreen=\"\" allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\" loading=\"lazy\"></iframe>"
      }
    }

    export let map_escape(s: String): String {
      let s1 = s.split("&").join("&amp;") { (piece): String => piece };
      let s2 = s1.split("<").join("&lt;") { (piece): String => piece };
      let s3 = s2.split(">").join("&gt;") { (piece): String => piece };
      let s4 = s3.split("\"").join("&quot;") { (piece): String => piece };
      s4.split("'").join("&#039;") { (piece): String => piece }
    }

    let geo_quote(s: String): String {
      s.split("\"").join("&quot;") { (piece): String => piece }
    }

## A song in the drawer

The drawer's list, one `spotify-embed-container` per tag: the player, or,
for a link that embeds as nothing, a grey box linking to it. Blimp's `el`
will not make an iframe (nothing that loads a document of its own), so the
program puts this in the container as HTML. HEEx escaped the link in the
`href`, and so does this.

    export let map_song_html(embed: String, link: String): String {
      if (embed.isEmpty) {
        "<div style=\"padding: 20px; background: #f0f0f0; border-radius: 8px; text-align: center; color: #666;\"><a href=\"${geo_href(link)}\" target=\"_blank\" style=\"color: #1DB954;\">Open in Spotify</a></div>"
      } else {
        "<iframe src=\"${map_escape(embed)}\" width=\"100%\" height=\"152\" frameBorder=\"0\" allowtransparency=\"true\" allow=\"encrypted-media\" style=\"border-radius: 12px;\"></iframe>"
      }
    }

A link a tagger typed, for an `href`: escaped, and `#` if it is a
`javascript:` URL, however a browser would read one (leading spaces and
control characters skipped, any case). Neither MapLive nor its hook
checked, so a tag could carry a script to whoever clicked it.

    export let geo_href(link: String): String {
      if (geo_scripted(link, String.begin)) { "#" } else { map_escape(link) }
    }

    let geo_scripted(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        false
      } else if (s[i] <= 32) {
        geo_scripted(s, s.next(i))
      } else {
        let rest = s.slice(i, s.end);
        rest.end >= "javascript:".end && geo_lower_ascii(rest.slice(String.begin, "javascript:".end)) == "javascript:"
      }
    }

The eleven characters it is tested on, lower-cased, by an accumulator
rather than a `ListBuilder` (an actor on this backend, never collected).

    let geo_lower_ascii(s: String): String {
      geo_lower_from(s, String.begin, "")
    }

    let geo_lower_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        let n = s.next(i);
        if (c >= 65 && c <= 90) {
          let letters = "abcdefghijklmnopqrstuvwxyz";
          let at = letters.step(String.begin, c - 65);
          geo_lower_from(s, n, "${acc}${letters.slice(at, letters.next(at))}")
        } else {
          geo_lower_from(s, n, "${acc}${s.slice(i, n)}")
        }
      }
    }
