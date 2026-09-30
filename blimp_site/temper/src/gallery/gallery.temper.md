# The gallery's logic

What `/gallery` computes rather than fetches, for the poller and the page
in `src/99_gallery.blimp`. A port of the string-and-number half of
`Blog.Gallery.ICloud` (addresses, request bodies, the redirect host, dates,
url expiry), the timers of `Blog.Gallery`, and the markup of
`BlogWeb.GalleryLive` and its root layout. Walking the decoded JSON stays
Blimp: a Temper function takes strings and numbers, not a Blimp map.

    let { escape_html, starts_with, ends_with } = import("../text");

## Asking iCloud

A shared album's public website is two undocumented POSTs under the album's
token: `webstream` for the photos, `webasseturls` for signed CDN urls to
them. Every album is first asked for at partition 1, which answers 330 and
names the partition that holds it.

    export let gal_first_host = "p01-sharedstreams.icloud.com";

    export let gal_endpoint(host: String, token: String, path: String): String {
      "https://${host}/${token}/sharedstreams/${path}"
    }

The 330's host comes out of a response body, and the next request, token
and all, goes to it. Req followed whatever `X-Apple-MMe-Host` said; this
follows only a name under `icloud.com` made of the characters a host name
has.

    export let gal_apple_host(host: String): Boolean {
      host.end > String.begin && ends_with(host, ".icloud.com") && gal_host_chars(host, String.begin)
    }

    let gal_host_chars(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else {
        let c = s[i];
        if (c == 45 || c == 46) {
          gal_host_chars(s, s.next(i))
        } else if (c >= 48 && c <= 57) {
          gal_host_chars(s, s.next(i))
        } else if (c >= 97 && c <= 122) {
          gal_host_chars(s, s.next(i))
        } else {
          false
        }
      }
    }

Apple wants the JSON bodies as `text/plain`; `application/json` gets a 400
(the Elixir client's comment). The ctag is the last one seen, or none.

    export let gal_json_string(s: String): String {
      let a = s.split("\\").join("\\\\") { (p): String => p };
      let b = a.split("\"").join("\\\"") { (p): String => p };
      "\"${b}\""
    }

    export let gal_stream_body(ctag: String): String {
      if (ctag == "") {
        "{\"streamCtag\":null}"
      } else {
        "{\"streamCtag\":${gal_json_string(ctag)}}"
      }
    }

`webasseturls` answers an empty list with a 400 ("Validation Failed:
missing photoGuids", 2026-09-30), so the caller never sends one.

    export let gal_assets_body(guids: List<String>): String {
      let quoted = guids.join(",") { (g): String => gal_json_string(g) };
      "{\"photoGuids\":[${quoted}]}"
    }

## A photo's sizes

Each photo lists its derivatives under keys that are their pixel heights
(`"342"`, `"2049"`); a video's are `"720p"`, `"PosterFrame"`. Only the
all-digit keys are sizes, the smallest the thumbnail and the largest the
one the viewer shows. This is the key as a number, or -1 for one that is
not a size.

    export let gal_size_key(key: String): Int {
      if (key == "") { -1 } else { gal_digits(key, String.begin, 0) }
    }

    let gal_digits(s: String, i: StringIndex, acc: Int): Int {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        if (c < 48 || c > 57) { -1 } else { gal_digits(s, s.next(i), acc * 10 + c - 48) }
      }
    }

Apple writes a photo's width and height as strings. `Integer.parse`
read the leading digits and ignored the rest; so does this, with `dflt` when
there are none.

    export let gal_leading_int(s: String, dflt: Int): Int {
      gal_leading(s, String.begin, 0, false, dflt)
    }

    let gal_leading(s: String, i: StringIndex, acc: Int, any: Boolean, dflt: Int): Int {
      if (i >= s.end) {
        if (any) { acc } else { dflt }
      } else {
        let c = s[i];
        if (c < 48 || c > 57) {
          if (any) { acc } else { dflt }
        } else {
          gal_leading(s, s.next(i), acc * 10 + c - 48, true, dflt)
        }
      }
    }

## Dates

`dateCreated` is ISO 8601 with an offset, `2026-09-11T17:03:12Z`. The
Elixir read it with `DateTime.from_iso8601`, which moves it to UTC and
refuses one without an offset. Here it is seconds since 1970 in UTC, or 0
for anything that is not such a date, which the page calls Undated as the
Elixir did for nil. (An Int here is 32 bits: this runs out in 2038.)

    export let gal_ts(s: String): Int {
      if (s.end < s.step(String.begin, 19)) {
        0
      } else {
        let y = gal_field(s, 0, 4);
        let mo = gal_field(s, 5, 2);
        let d = gal_field(s, 8, 2);
        let h = gal_field(s, 11, 2);
        let mi = gal_field(s, 14, 2);
        let sec = gal_field(s, 17, 2);
        let off = gal_offset(s, s.step(String.begin, 19));
        if (y < 0 || mo < 1 || mo > 12 || d < 1 || d > 31 || h < 0 || h > 23 || mi < 0 || mi > 59 || sec < 0 || sec > 60 || off == -100000) {
          0
        } else {
          gal_days_of(y, mo, d) * 86400 + h * 3600 + mi * 60 + sec - off
        }
      }
    }

`n` digits at character `at`, or -1.

    let gal_field(s: String, at: Int, n: Int): Int {
      let from = s.step(String.begin, at);
      let to = s.step(from, n);
      gal_digits(s.slice(from, to), String.begin, 0)
    }

The offset in seconds east of UTC after the seconds field, skipping a
fraction; -100000 when there is none or it is not one.

    let gal_offset(s: String, i: StringIndex): Int {
      if (i >= s.end) {
        -100000
      } else {
        let c = s[i];
        if (c == 46 || (c >= 48 && c <= 57)) {
          gal_offset(s, s.next(i))
        } else if (c == 90) {
          if (s.next(i) >= s.end) { 0 } else { -100000 }
        } else if (c == 43 || c == 45) {
          let rest = s.slice(s.next(i), s.end);
          let oh = gal_field(rest, 0, 2);
          let om = if (rest.end > rest.step(String.begin, 2)) { gal_field(rest, 3, 2) } else { 0 };
          if (oh < 0 || om < 0) {
            -100000
          } else if (c == 43) {
            oh * 3600 + om * 60
          } else {
            0 - (oh * 3600 + om * 60)
          }
        } else {
          -100000
        }
      }
    }

days_from_civil and civil_from_days (Howard Hinnant), as `pl_days_of`
and `pl_civil` in the phish_lab module, kept here so this one stands
alone.

    let gal_div(a: Int, b: Int): Int {
      let q = (a / b) orelse panic();
      if (q * b > a) { q - 1 } else { q }
    }

    export let gal_days_of(y0: Int, m: Int, d: Int): Int {
      let y = if (m <= 2) { y0 - 1 } else { y0 };
      let era = gal_div(y, 400);
      let yoe = y - era * 400;
      let mp = if (m > 2) { m - 3 } else { m + 9 };
      let doy = gal_div(153 * mp + 2, 5) + d - 1;
      let doe = yoe * 365 + gal_div(yoe, 4) - gal_div(yoe, 100) + doy;
      era * 146097 + doe - 719468
    }

    export let gal_civil(ts: Int): List<Int> {
      let z = gal_div(ts, 86400) + 719468;
      let era = gal_div(z, 146097);
      let doe = z - era * 146097;
      let yoe = gal_div(doe - gal_div(doe, 1460) + gal_div(doe, 36524) - gal_div(doe, 146096), 365);
      let doy = doe - (365 * yoe + gal_div(yoe, 4) - gal_div(yoe, 100));
      let mp = gal_div(5 * doy + 2, 153);
      let d = doy - gal_div(153 * mp + 2, 5) + 1;
      let m = if (mp < 10) { mp + 3 } else { mp - 9 };
      let y = if (m <= 2) { yoe + era * 400 + 1 } else { yoe + era * 400 };
      [y, m, d]
    }

    export let gal_month_names: List<String> = [
      "January", "February", "March", "April", "May", "June", "July",
      "August", "September", "October", "November", "December"
    ];

    export let gal_month_name(m: Int): String {
      if (m < 1 || m > 12) { "" } else { gal_month_names[m - 1] }
    }

`Gallery.pretty_date/1`: `September 11, 2026`, or "" for none (nil there).

    export let gal_pretty_date(ts: Int): String {
      if (ts == 0) {
        ""
      } else {
        let c = gal_civil(ts);
        "${gal_month_name(c[1])} ${c[2].toString()}, ${c[0].toString()}"
      }
    }

The grid is cut into months as iCloud's own web album is: a run of photos
with the same key is one section, headed by its label.

    export let gal_month_key(ts: Int): Int {
      if (ts == 0) {
        0
      } else {
        let c = gal_civil(ts);
        c[0] * 100 + c[1]
      }
    }

    export let gal_month_label(ts: Int): String {
      if (ts == 0) {
        "Undated"
      } else {
        let c = gal_civil(ts);
        "${gal_month_name(c[1])} ${c[0].toString()}"
      }
    }

## Timers

A signed url carries its expiry as `e=`, seconds since 1970, roughly three
hours out. `ICloud.ttl/1`: the seconds left, and 0 for a url with no expiry
this understands, so it is treated as already stale rather than trusted
forever.

    export let gal_ttl(url: String, now: Int): Int {
      let q = url.split("?");
      if (q.length < 2) {
        0
      } else {
        let es = q[1].split("&").filter { (p): Boolean => starts_with(p, "e=") };
        if (es.length == 0) {
          0
        } else {
          let e = gal_size_key(es[0].split("=")[1]);
          if (e <= now) { 0 } else { e - now }
        }
      }
    }

The urls are fetched again before the soonest of them expires: at most 100
minutes on, 20 minutes before the soonest expiry, and never sooner than a
minute. A batch with no expiry this reads waits the 100 minutes.

    export let gal_urls_every_s = 6000;

    export let gal_urls_again_s(soonest_ttl: Int): Int {
      if (soonest_ttl <= 0) {
        gal_urls_every_s
      } else {
        let lead = soonest_ttl - 1200;
        let at_least = if (lead < 60) { 60 } else { lead };
        if (at_least > gal_urls_every_s) { gal_urls_every_s } else { at_least }
      }
    }

The album is asked every 15 minutes (the ctag makes an unchanged answer
nearly free), and every minute after a failure or while it looks empty.

    export let gal_poll_s(empty_streak: Int, failed: Boolean): Int {
      if (failed || empty_streak > 0) { 60 } else { 900 }
    }

Apple has served this album empty with its name and an unchanged ctag
(`cb9fad9`, 2026-09-11). An album that had photos keeps them through
three such answers in a row, about three minutes at the one-minute retry
(the Elixir's comment says 45 minutes, but it too retried every minute);
the fourth is believed.

    export let gal_empty_tolerance = 3;

    export let gal_keep_cached(new_count: Int, old_count: Int, empty_streak: Int): Boolean {
      new_count == 0 && old_count > 0 && empty_streak < gal_empty_tolerance
    }

## The page

`/gallery/img/:guid/:size` is the only way the page names a photo: it
302s to the signed url current when it is asked, so a page left up for a
day never holds a dead one. Anything but `thumb` is the display size, as
the controller had it.

    export let gal_size(s: String): String {
      if (s == "thumb") { "thumb" } else { "display" }
    }

    export let gal_img(guid: String, size: String): String {
      "/gallery/img/${guid}/${size}"
    }

One cell of the grid. The LiveView's `phx-click="open"` is `data-guid`,
read by the page's script.

    export let gal_cell(guid: String, caption: String, label: String): String {
      let title = if (caption == "") { label } else { caption };
      let alt = if (caption == "") { "Photo from ${label}" } else { caption };
      "<button class=\"gal-cell\" data-guid=\"${escape_html(guid)}\" title=\"${escape_html(title)}\"><img src=\"${escape_html(gal_img(guid, "thumb"))}\" loading=\"lazy\" decoding=\"async\" alt=\"${escape_html(alt)}\"></button>"
    }

    export let gal_group(label: String, cells: String): String {
      "<div class=\"gal-group\"><div class=\"gal-grouphead\">${escape_html(label)}</div><div class=\"gal-grid\">${cells}</div></div>"
    }

    export let gal_empty(configured: Boolean): String {
      let why = if (configured) {
        "This folder is empty. The album is still syncing from iCloud — it fills in within a minute or two of boot."
      } else {
        "No album connected. Set <code>ICLOUD_ALBUM_TOKEN</code> and restart."
      };
      "<div class=\"gal-empty\"><div class=\"gal-empty-icon\"></div><p>${why}</p></div>"
    }

    export let gal_items(count: Int): String {
      if (count == 1) { "1 item" } else { "${count.toString()} items" }
    }

    let gal_disabled(count: Int): String {
      if (count == 0) { " disabled" } else { "" }
    }

The whole document: the gallery root layout (its own head, `noindex`, no
app script) around `GalleryLive.render/1`. `grid` is the groups, or the
empty folder; `payload` is the deck's JSON, which goes in an attribute;
`css` is the LiveView's `<style>`; `tail` is what goes before `</body>`.

    export let gal_page(album: String, count: Int, grid: String, payload: String, css: String, tail: String): String {
      let a = escape_html(album);
      let about = "An ambient photo browser — a shared album drifting past in random order, in a System 7 window.";
      let off = gal_disabled(count);
      "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<title>${a}</title>\n<meta name=\"description\" content=\"${about}\">\n<meta property=\"og:title\" content=\"${a}\">\n<meta property=\"og:description\" content=\"${about}\">\n<meta property=\"og:type\" content=\"website\">\n<meta property=\"og:url\" content=\"https://bobbby.online/gallery\">\n<meta property=\"og:site_name\" content=\"bobbby.online\">\n<meta name=\"robots\" content=\"noindex\">\n<link rel=\"stylesheet\" href=\"/assets/app-3cfac71d5552d1426de906087a8be2fe.css\">\n<style>\n${css}</style>\n</head>\n<body style=\"margin:0;\">\n<div class=\"gal\" id=\"gal-desktop\" data-photos=\"${escape_html(payload)}\">\n<div class=\"gal-menubar\"><div class=\"gal-menu-left\"><span class=\"gal-apple\">&#63743;</span><span class=\"gal-menu-item\">File</span><span class=\"gal-menu-item\">Edit</span><span class=\"gal-menu-item\">View</span><span class=\"gal-menu-item\">Special</span></div><div class=\"gal-menu-right\">${a}</div></div>\n<div class=\"gal-deskspace\"><div class=\"gal-win gal-albumwin\">\n<div class=\"gal-titlebar\"><a href=\"/\" class=\"gal-close\" title=\"Close\"></a><div class=\"gal-title\">${a}</div><div class=\"gal-resize\"></div></div>\n<div class=\"gal-infobar\"><span data-gal=\"count\">${gal_items(count)}</span><span class=\"gal-sep\"></span><span class=\"gal-dim\">shared album</span><button class=\"gal-btn\" data-gal=\"slideshow\"${off}>Slideshow</button><button class=\"gal-btn\" data-gal=\"fullscreen\"${off}>Full Screen</button></div>\n<div class=\"gal-body\"><div class=\"gal-scroll\" data-gal=\"scroll\">${grid}</div><div class=\"gal-sbar\" data-gal=\"sbar\" aria-hidden=\"true\"><button class=\"gal-sb-arrow up\" data-gal=\"sb-up\"></button><div class=\"gal-sb-track\" data-gal=\"sb-track\"><div class=\"gal-sb-thumb\" data-gal=\"sb-thumb\"></div></div><button class=\"gal-sb-arrow down\" data-gal=\"sb-down\"></button></div></div>\n</div></div>\n<div class=\"gal-viewer\" id=\"gal-viewer\" hidden><div class=\"gal-win gal-viewerwin\" id=\"gal-viewerwin\">\n<div class=\"gal-titlebar\"><a class=\"gal-close\" data-gal=\"close\" title=\"Close\"></a><div class=\"gal-title\" data-gal=\"title\">Photo</div><div class=\"gal-resize\"></div></div>\n<div class=\"gal-stage\" data-gal=\"stage\"><div class=\"gal-backdrop\" data-gal=\"backdrop\"></div><img class=\"gal-layer\" data-gal=\"layer-a\" alt=\"\"><img class=\"gal-layer\" data-gal=\"layer-b\" alt=\"\"><button class=\"gal-nav prev\" data-gal=\"prev\" aria-label=\"Previous\">&#8249;</button><button class=\"gal-nav next\" data-gal=\"next\" aria-label=\"Next\">&#8250;</button></div>\n<div class=\"gal-controls\"><button class=\"gal-btn\" data-gal=\"prev\">&#9664;</button><button class=\"gal-btn gal-btn-default\" data-gal=\"toggle\">Pause</button><button class=\"gal-btn\" data-gal=\"next\">&#9654;</button><span class=\"gal-counter\" data-gal=\"counter\"></span><span class=\"gal-caption\" data-gal=\"caption\"></span><button class=\"gal-btn\" data-gal=\"fullscreen\" title=\"Full-screen mosaic\">Full Screen</button><button class=\"gal-btn\" data-gal=\"shuffle\" title=\"Reshuffle the deck\">Shuffle</button></div>\n</div></div>\n</div>\n<script src=\"/gallery/gallery.js\"></script>\n${tail}</body>\n</html>\n"
    }
