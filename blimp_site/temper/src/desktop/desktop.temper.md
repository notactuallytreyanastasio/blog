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
