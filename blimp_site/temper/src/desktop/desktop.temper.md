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
closing the last window does not replay the splash.

    export let desk_href_of(cat: String, project: String, finder: String, museum: String, leica: String, m: String): String {
      let q = param("", "cat", cat);
      let q1 = param(q, "project", project);
      let q2 = param(q1, "finder", finder);
      let q3 = param(q2, "museum", museum);
      let q4 = param(q3, "leica", leica);
      let q5 = param(q4, "m", m);
      if (q5.isEmpty) { "/?booted=1" } else { "/?${q5}" }
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

## Window chrome

    export let desk_title_bar(close_href: String, title: String): String {
      "<div class=\"title-bar\"><a class=\"close-box\" href=\"${close_href}\" aria-label=\"Close\"></a><div class=\"title\">${title}</div><div class=\"resize-box\"></div></div>"
    }

    export let desk_menu_bar(epoch_s: Int): String {
      "<div class=\"menu-bar\"><div class=\"menu-left\"><span class=\"apple-menu\">&#63743;</span><span class=\"menu-item\">File</span><span class=\"menu-item\">Edit</span><span class=\"menu-item\">View</span></div><div class=\"menu-right\"><span>${desk_clock(epoch_s)}</span></div></div>"
    }

    export let desk_projects_icon(): String {
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\" width=\"28\" height=\"28\" style=\"image-rendering: pixelated;\"><rect x=\"2\" y=\"2\" width=\"28\" height=\"3\" fill=\"#000\" /><rect x=\"2\" y=\"2\" width=\"3\" height=\"28\" fill=\"#000\" /><rect x=\"2\" y=\"27\" width=\"28\" height=\"3\" fill=\"#000\" /><rect x=\"27\" y=\"2\" width=\"3\" height=\"28\" fill=\"#000\" /><rect x=\"7\" y=\"7\" width=\"18\" height=\"2\" fill=\"#000\" /><rect x=\"7\" y=\"11\" width=\"14\" height=\"2\" fill=\"#000\" /><rect x=\"7\" y=\"15\" width=\"18\" height=\"2\" fill=\"#000\" /><rect x=\"7\" y=\"19\" width=\"10\" height=\"2\" fill=\"#000\" /><rect x=\"7\" y=\"23\" width=\"16\" height=\"2\" fill=\"#000\" /></svg>"
    }

    export let desk_leica_icon_html(href: String): String {
      "<a class=\"desktop-icon-leica\" href=\"${href}\"><div class=\"desktop-icon-img\"><svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\" width=\"48\" height=\"48\" style=\"image-rendering: pixelated;\"><rect x=\"4\" y=\"8\" width=\"24\" height=\"16\" fill=\"#000\" /><rect x=\"6\" y=\"10\" width=\"20\" height=\"12\" fill=\"#333\" /><rect x=\"12\" y=\"12\" width=\"8\" height=\"8\" rx=\"4\" fill=\"#666\" /><rect x=\"14\" y=\"14\" width=\"4\" height=\"4\" rx=\"2\" fill=\"#999\" /><rect x=\"8\" y=\"9\" width=\"4\" height=\"2\" fill=\"#555\" /><rect x=\"24\" y=\"10\" width=\"2\" height=\"2\" fill=\"#c00\" /></svg></div><div class=\"desktop-icon-label\">MY FAV<br />LEICA SHOTS</div></a>"
    }

The warning dialog is plain HTML. Its "Load" button used to start the
zoom-and-pan viewer; now it opens the image itself.

    export let desk_leica_dialog(cancel: String): String {
      "<div class=\"leica-warning-overlay\"><div class=\"leica-warning-dialog\" id=\"leica-warning\">${desk_title_bar(cancel, "Warning")}<div class=\"leica-warning-content\"><div class=\"leica-warning-icon\">&#9888;</div><div class=\"leica-warning-text\"><strong>Large File Warning</strong><p>This collage is <strong>110 MB</strong> at full resolution (30,846 &times; 20,550 pixels).</p><p>It will take a while to download and may use significant memory. Not recommended on mobile devices.</p><p>It opens as a plain image in your browser, which can zoom it and scroll around it.</p></div><div class=\"leica-warning-buttons\"><a class=\"leica-btn primary\" href=\"https://bobbby-media.fsn1.your-objectstorage.com/leica/leica_6_by_6_full.jpg\">Load Full Resolution</a><a class=\"leica-btn\" href=\"${cancel}\">Cancel</a></div></div></div></div>"
    }

    export let desk_taskbar_html(finder_active: Boolean, museum_active: Boolean, blog_active: Boolean, apps_href: String, museum_href: String, blog_href: String): String {
      "<div class=\"mobile-taskbar\"><a class=\"${desk_active(finder_active, "mobile-taskbar-btn")}\" href=\"${apps_href}\">📁 Apps</a><a class=\"${desk_active(museum_active, "mobile-taskbar-btn")}\" href=\"${museum_href}\">Museum</a><a class=\"${desk_active(blog_active, "mobile-taskbar-btn")}\" href=\"${blog_href}\">Blog</a><a class=\"mobile-taskbar-btn\" href=\"${APPS_ORIGIN}/phish\">🐟 Phish</a></div>"
    }

    export let desk_boot_splash(): String {
      "<a class=\"mac-boot\" href=\"/?booted=1\"><div class=\"boot-screen\"><div class=\"boot-logo\"><svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\" width=\"128\" height=\"128\" style=\"image-rendering: pixelated;\"><rect x=\"12\" y=\"2\" width=\"8\" height=\"2\" fill=\"#000\" /><rect x=\"10\" y=\"4\" width=\"12\" height=\"2\" fill=\"#000\" /><rect x=\"8\" y=\"6\" width=\"16\" height=\"2\" fill=\"#000\" /><rect x=\"8\" y=\"8\" width=\"16\" height=\"2\" fill=\"#000\" /><rect x=\"10\" y=\"10\" width=\"12\" height=\"2\" fill=\"#000\" /><rect x=\"12\" y=\"12\" width=\"8\" height=\"2\" fill=\"#000\" /><rect x=\"14\" y=\"14\" width=\"4\" height=\"6\" fill=\"#000\" /><rect x=\"10\" y=\"20\" width=\"12\" height=\"2\" fill=\"#000\" /></svg></div><div class=\"boot-text\">Hi, this is Bobby's website</div><div class=\"boot-subtext\">I am a programmer, photographer, and artist living in NYC.<br />I prefer to use things in ways they were not intended, and evoke new directions of vision by playing with the social fabric that wraps us around a computer.</div><div class=\"boot-progress\"><div class=\"boot-progress-bar\"></div></div><div class=\"boot-hint\">Click anywhere to skip</div></div></a>"
    }

    export let desk_tech_tag(t: String): String {
      "<span class=\"museum-list-tech\">${escape_html(t)}</span>"
    }

## The Hangar: the pages that run on Blimp

One tile: a page, its pixel icon, its name and a one-line pitch. The href
and the icon come from data/hangar.tsv and data/*icons.txt, which the loader
checked; the name and pitch are escaped here.

    export let desk_hangar_tile(href: String, icon: String, name: String, pitch: String): String {
      "<a class=\"hangar-tile\" href=\"${escape_html(href)}\"><span class=\"hangar-icon\">${icon}</span><span class=\"hangar-text\"><span class=\"hangar-name\">${escape_html(name)}</span><span class=\"hangar-pitch\">${escape_html(pitch)}</span></span></a>"
    }

    export let desk_hangar_group(label: String, count: Int, tiles: String): String {
      "<div class=\"hangar-group\"><div class=\"hangar-group-label\">${escape_html(label)} <span>${count.toString()}</span></div><div class=\"hangar-tiles\">${tiles}</div></div>"
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

The blimp: an envelope, two fins and a gondola, in 1-bit.

    export let desk_blimp_svg(w: Int): String {
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 48 24\" width=\"${w.toString()}\" shape-rendering=\"crispEdges\" aria-hidden=\"true\"><path d=\"M9 9 L2 1 L13 4 Z M9 13 L2 21 L13 18 Z\" fill=\"#fff\" stroke=\"#000\" stroke-width=\"1.5\"/><ellipse cx=\"27\" cy=\"11\" rx=\"19\" ry=\"8\" fill=\"#fff\" stroke=\"#000\" stroke-width=\"1.5\"/><path d=\"M10 14 Q27 21 44 14\" fill=\"none\" stroke=\"#000\" stroke-width=\"1\" stroke-dasharray=\"1 1\"/><line x1=\"9\" y1=\"11\" x2=\"46\" y2=\"11\" stroke=\"#000\" stroke-width=\"1\"/><rect x=\"23\" y=\"19\" width=\"9\" height=\"4\" fill=\"#000\"/><rect x=\"25\" y=\"20\" width=\"1\" height=\"1\" fill=\"#fff\"/><rect x=\"28\" y=\"20\" width=\"1\" height=\"1\" fill=\"#fff\"/></svg>"
    }

## The live strip

The counters are fixed width, zero-padded like an odometer, because the bare
homepage is built once at boot and these are spliced into it per request
without touching its Content-Length. A number too wide to fit comes out
wider, and the caller renders the page in full instead.

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
      "<span class=\"odo\"><small>actors</small> ${desk_pad(actors, 3)}</span><span class=\"odo\"><small>requests since boot</small> ${desk_pad(served, 8)}</span><span class=\"odo\"><small>up</small> ${desk_uptime(up_s)}</span>"
    }

The commit is a checked 40-hex sha or empty; the render note is the page's
own ("1 ms", or "prebuilt at boot").

    export let desk_live_strip(counts: String, commit: String, short: String, render: String): String {
      let blimp = if (commit.isEmpty) {
        "<span class=\"odo\"><small>blimp</small> local build</span>"
      } else {
        "<span class=\"odo\"><small>blimp</small> <a href=\"https://github.com/notactuallytreyanastasio/blimp/commit/${commit}\">${short}</a></span>"
      };
      "<div class=\"hangar-live\" aria-label=\"The server, right now\">${counts}${blimp}<span class=\"odo\"><small>this page</small> ${render}</span></div>"
    }

## Desktop icons down the right edge

    export let desk_side_icon(href: String, svg: String, label: String): String {
      "<a class=\"side-icon\" href=\"${href}\"><span class=\"side-icon-img\">${svg}</span><span class=\"side-icon-label\">${label}</span></a>"
    }

Phoenix, which served this site until September 2026, still runs at
old.bobbby.online. It is in the Trash, which is not empty.

    export let desk_trash_svg(): String {
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\" width=\"40\" height=\"40\" shape-rendering=\"crispEdges\"><rect x=\"6\" y=\"8\" width=\"20\" height=\"3\" fill=\"#000\"/><rect x=\"13\" y=\"5\" width=\"6\" height=\"3\" fill=\"#000\"/><rect x=\"8\" y=\"11\" width=\"16\" height=\"18\" fill=\"#fff\" stroke=\"#000\" stroke-width=\"2\"/><rect x=\"12\" y=\"14\" width=\"2\" height=\"12\" fill=\"#000\"/><rect x=\"18\" y=\"14\" width=\"2\" height=\"12\" fill=\"#000\"/><rect x=\"9\" y=\"2\" width=\"4\" height=\"4\" fill=\"#000\"/><rect x=\"20\" y=\"1\" width=\"3\" height=\"5\" fill=\"#000\"/></svg>"
    }

## The menu bar, with menus that open

Each menu opens on hover or focus, with CSS alone, and every item is a link.
"Restart" is the bare homepage, so it plays the boot splash again.

    export let desk_menu_bar_links(epoch_s: Int, museum_href: String, finder_href: String): String {
      "<div class=\"menu-bar\"><div class=\"menu-left\"><div class=\"menu\" tabindex=\"0\"><span class=\"apple-menu\">&#63743;</span><div class=\"menu-drop\"><a href=\"/stack\">About This Site&#8230;</a><a href=\"/directory\">Directory</a></div></div><div class=\"menu\" tabindex=\"0\"><span class=\"menu-item\">File</span><div class=\"menu-drop\"><a href=\"/blog\">Open Blog</a><a href=\"${museum_href}\">Technical Museum</a><a href=\"${finder_href}\">Apps &amp; Games</a><a href=\"/very_direct_message\">Print on Bobby&#8217;s Desk&#8230;</a></div></div><div class=\"menu\" tabindex=\"0\"><span class=\"menu-item\">Edit</span><div class=\"menu-drop\"><span class=\"menu-off\">Can&#8217;t Undo</span><a href=\"/markdown-editor\">Markdown Editor</a><a href=\"/typewriter\">Typewriter</a></div></div><div class=\"menu\" tabindex=\"0\"><span class=\"menu-item\">View</span><div class=\"menu-drop\"><a href=\"/stack\">By Source</a><a href=\"/mirror\">View Source</a></div></div><div class=\"menu\" tabindex=\"0\"><span class=\"menu-item\">Special</span><div class=\"menu-drop\"><a href=\"/?booted=1\">Clean Up Desktop</a><a href=\"https://old.bobbby.online\">Open Trash</a><a href=\"/\">Restart</a></div></div></div><div class=\"menu-right\"><span class=\"menu-served\">served by Blimp</span><span>${desk_clock(epoch_s)}</span></div></div>"
    }

    export let desk_taskbar_links(hangar_active: Boolean, museum_active: Boolean, blog_active: Boolean, finder_active: Boolean, hangar_href: String, museum_href: String, blog_href: String, apps_href: String): String {
      "<div class=\"mobile-taskbar\"><a class=\"${desk_active(hangar_active, "mobile-taskbar-btn")}\" href=\"${hangar_href}\">Hangar</a><a class=\"${desk_active(museum_active, "mobile-taskbar-btn")}\" href=\"${museum_href}\">Museum</a><a class=\"${desk_active(blog_active, "mobile-taskbar-btn")}\" href=\"${blog_href}\">Blog</a><a class=\"${desk_active(finder_active, "mobile-taskbar-btn")}\" href=\"${apps_href}\">Apps</a></div>"
    }
