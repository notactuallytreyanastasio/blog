# Desktop

The homepage's parts that are functions of strings and numbers. This was
half of `src/60_desktop.blimp`; the other half, everything that reads or
builds a record (a museum project, a Finder item, the query-string state,
the loaded desktop), stays there, because a record here would be a class,
and a Temper class is a Blimp actor that is never collected.

    let { escape_html, is_alnum, starts_with } = import("../text");

    let APPS_ORIGIN = "https://bobbby.online";

## Values from the snapshot files

export.sh writes \ as \\, newline as \n and tab as \t. Splitting on the
escaped backslash first keeps "\\n" (a backslash, then n) from turning into a
newline.

    export let desk_unescape(s: String): String {
      s.split("\\\\").join("\\") { (p): String =>
        p.split("\\n").join("\n") { (a): String => a }.split("\\t").join("\t") { (b): String => b }
      }
    }

    export let desk_split_tech(s: String): List<String> {
      if (s.isEmpty) { [] } else { s.split(",") }
    }

Slugs and categories go into links as they are, so the loader refuses any
that would need escaping in a URL or in HTML.

    export let desk_url_safe(s: String): Boolean {
      !s.isEmpty && url_safe_from(s, String.begin)
    }

    let url_safe_from(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else {
        let c = s[i];
        if (c == 45) {
          url_safe_from(s, s.next(i))
        } else if (c == 95) {
          url_safe_from(s, s.next(i))
        } else if (c == 46) {
          url_safe_from(s, s.next(i))
        } else if (is_alnum(s.slice(i, s.next(i)))) {
          url_safe_from(s, s.next(i))
        } else {
          false
        }
      }
    }

## Links

A finder path the Blimp site serves stays relative; every other app is still
on the Phoenix site.

    export let desk_app_href(path: String): String {
      if (path == "/") {
        path
      } else if (path == "/blog") {
        path
      } else if (path == "/tetris") {
        path
      } else if (starts_with(path, "/post/")) {
        path
      } else {
        "${APPS_ORIGIN}${path}"
      }
    }

The link to a state, already escaped for an href: every value is a known
slug, category or flag. A link to the empty state says booted=1, so that
closing the last panel does not replay the splash.

    export let desk_href_of(cat: String, project: String, leica: String): String {
      let q = param("", "cat", cat);
      let q1 = param(q, "project", project);
      let q2 = param(q1, "leica", leica);
      if (q2.isEmpty) { "/?booted=1" } else { "/?${q2}" }
    }

    let param(acc: String, key: String, value: String): String {
      if (value.isEmpty) {
        acc
      } else if (acc.isEmpty) {
        "${key}=${value}"
      } else {
        "${acc}&amp;${key}=${value}"
      }
    }

    export let desk_active(active: Boolean, cls: String): String {
      if (active) { "${cls} active" } else { cls }
    }

## The clock: Calendar.strftime(DateTime.utc_now(), "%I:%M %p")

    export let desk_clock(epoch_s: Int): String {
      let day = epoch_s % 86400;
      let h24 = day / 3600;
      let minute = (day % 3600) / 60;
      let h = h24 % 12;
      let h12 = if (h == 0) { 12 } else { h };
      let ampm = if (h24 < 12) { "AM" } else { "PM" };
      "${pad2(h12)}:${pad2(minute)} ${ampm}"
    }

    let pad2(n: Int): String {
      if (n < 10) { "0${n.toString()}" } else { n.toString() }
    }

## The boot splash

Kept exactly as it was on the old desktop: the first thing a bare "/" shows.

    export let desk_boot_splash(): String {
      "<a class=\"mac-boot\" href=\"/?booted=1\"><div class=\"boot-screen\"><div class=\"boot-logo\"><svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\" width=\"128\" height=\"128\" style=\"image-rendering: pixelated;\"><rect x=\"12\" y=\"2\" width=\"8\" height=\"2\" fill=\"#000\" /><rect x=\"10\" y=\"4\" width=\"12\" height=\"2\" fill=\"#000\" /><rect x=\"8\" y=\"6\" width=\"16\" height=\"2\" fill=\"#000\" /><rect x=\"8\" y=\"8\" width=\"16\" height=\"2\" fill=\"#000\" /><rect x=\"10\" y=\"10\" width=\"12\" height=\"2\" fill=\"#000\" /><rect x=\"12\" y=\"12\" width=\"8\" height=\"2\" fill=\"#000\" /><rect x=\"14\" y=\"14\" width=\"4\" height=\"6\" fill=\"#000\" /><rect x=\"10\" y=\"20\" width=\"12\" height=\"2\" fill=\"#000\" /></svg></div><div class=\"boot-text\">Hi, this is Bobby's website</div><div class=\"boot-subtext\">I am a programmer, photographer, and artist living in NYC.<br />I prefer to use things in ways they were not intended, and evoke new directions of vision by playing with the social fabric that wraps us around a computer.</div><div class=\"boot-progress\"><div class=\"boot-progress-bar\"></div></div><div class=\"boot-hint\">Click anywhere to skip</div></div></a>"
    }

## The museum's pieces

    export let desk_tech_tag(t: String): String {
      "<span class=\"ex-tech\">${escape_html(t)}</span>"
    }

The Leica warning is plain HTML. Its "Load" button used to start a
zoom-and-pan viewer; now it opens the image itself, which the browser can
zoom and scroll.

    export let desk_leica_dialog(cancel: String): String {
      "<div class=\"leica-veil\"><div class=\"leica-card\" id=\"leica-warning\" role=\"dialog\" aria-labelledby=\"leica-h\"><div class=\"plate-label\">Large file</div><h2 id=\"leica-h\">My favourite Leica shots, in one collage</h2><p>It is <strong>110 MB</strong> at full resolution (30,846 &times; 20,550 pixels), so it will take a while to download and may use a lot of memory. Not recommended on a phone.</p><p>It opens as a plain image, which your browser can zoom and scroll around.</p><div class=\"leica-actions\"><a class=\"btn primary\" href=\"https://bobbby-media.fsn1.your-objectstorage.com/leica/leica_6_by_6_full.jpg\">Load Full Resolution</a><a class=\"btn\" href=\"${cancel}\">Cancel</a></div></div></div>"
    }

## The manifest: the pages that run on Blimp

One line: a page, its pixel icon, its name and a one-line pitch. The href
and the icon come from data/hangar.tsv and data/*icons.txt, which the loader
checked; the name and pitch are escaped here.

    export let desk_hangar_tile(href: String, icon: String, name: String, pitch: String): String {
      "<li><a class=\"mf-row\" href=\"${escape_html(href)}\"><span class=\"mf-icon\">${icon}</span><span class=\"mf-name\">${escape_html(name)}</span><span class=\"mf-pitch\">${escape_html(pitch)}</span></a></li>"
    }

    export let desk_hangar_group(label: String, count: Int, tiles: String): String {
      "<section class=\"mf-group\"><h3 class=\"plate-label\">${escape_html(label)} <span>${desk_pad(count, 2)}</span></h3><ul>${tiles}</ul></section>"
    }

    export let desk_hangar_label(group: String): String {
      if (group == "games") {
        "Games"
      } else if (group == "wire") {
        "Off the wire, live"
      } else if (group == "numbers") {
        "Numbers"
      } else {
        "Tools & toys"
      }
    }

The blimp: an envelope, two fins and a gondola. Its colours are the page's
(currentColor and the sheet behind it), so it follows light and dark.

    export let desk_blimp_svg(w: Int): String {
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 48 24\" width=\"${w.toString()}\" shape-rendering=\"crispEdges\" aria-hidden=\"true\" class=\"blimp-svg\"><path class=\"b-fill\" d=\"M9 9 L2 1 L13 4 Z M9 13 L2 21 L13 18 Z\" stroke-width=\"1.5\"/><ellipse class=\"b-fill\" cx=\"27\" cy=\"11\" rx=\"19\" ry=\"8\" stroke-width=\"1.5\"/><path class=\"b-line\" d=\"M10 14 Q27 21 44 14\" fill=\"none\" stroke-width=\"1\" stroke-dasharray=\"1 1\"/><line class=\"b-line\" x1=\"9\" y1=\"11\" x2=\"46\" y2=\"11\" stroke-width=\"1\"/><rect class=\"b-car\" x=\"23\" y=\"19\" width=\"9\" height=\"4\"/></svg>"
    }

## The gauges

The counters are fixed width, zero-padded like an odometer, because the bare
homepage is built once at boot and these are spliced into it per request
without touching its Content-Length. A number too wide to fit comes out
wider, and the caller renders the page in full instead. Each value sits in
its own element, which static/blimp/home.js keeps current from the live
feed once the page is open.

    export let desk_pad(n: Int, width: Int): String {
      if (width <= 1) {
        n.toString()
      } else if (n < pow10(width - 1)) {
        "0${desk_pad(n, width - 1)}"
      } else {
        n.toString()
      }
    }

    let pow10(k: Int): Int {
      if (k <= 0) { 1 } else { 10 * pow10(k - 1) }
    }

    export let desk_uptime(s: Int): String {
      let days = s / 86400;
      let hours = (s % 86400) / 3600;
      let minutes = (s % 3600) / 60;
      "${desk_pad(days, 3)}d ${desk_pad(hours, 2)}h ${desk_pad(minutes, 2)}m"
    }

    export let desk_live_counts(actors: Int, served: Int, up_s: Int): String {
      "<div class=\"gauge\"><dt>actors</dt><dd id=\"g-actors\">${desk_pad(actors, 3)}</dd></div><div class=\"gauge\"><dt>requests since boot</dt><dd id=\"g-served\">${desk_pad(served, 8)}</dd></div><div class=\"gauge\"><dt>up</dt><dd id=\"g-up\">${desk_uptime(up_s)}</dd></div>"
    }

The commit is a checked 40-hex sha or empty; the render note is the page's
own ("1 ms", or "prebuilt at boot").

    export let desk_live_strip(counts: String, commit: String, short: String, render: String): String {
      let blimp = if (commit.isEmpty) {
        "<div class=\"gauge\"><dt>blimp</dt><dd>local build</dd></div>"
      } else {
        "<div class=\"gauge\"><dt>blimp</dt><dd><a href=\"https://github.com/notactuallytreyanastasio/blimp/commit/${commit}\">${short}</a></dd></div>"
      };
      "<dl class=\"gauges\" aria-label=\"The server, right now\">${counts}${blimp}<div class=\"gauge\"><dt>this page</dt><dd>${render}</dd></div></dl>"
    }
