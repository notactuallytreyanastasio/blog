# Blinks, the live half

What `/blinks` computes once it is live and editable, beside what
`../blinks` computes for reading: how many rows a page holds once the
paper has been measured, which of the push bell's faces to show, the
tour's steps and where its tooltip goes, and the small list work on the
ids a device has hidden. The page is a Blimp program in the browser
(`static/blinks/paper.blimp`); a decoded JSON row is a Blimp map, which a
Temper function cannot take, so what comes here is numbers, strings and
lists of them.

No classes: a Temper class on the Blimp backend is an actor, and actors are
never collected. Every name starts `blkl_`.

## How many rows a page holds

The `PaperFit` hook measures how many rows fit the paper and reports twice
that, less a row, so a page is two screenfuls and you can scroll exactly
one screen before MORE. BlinksLive clamps what it is told to 8..120.

    export let blkl_fit_size(count: Int): Int {
      let twice = count * 2;
      if (twice < 8) { 8 } else if (twice > 120) { 120 } else { twice }
    }

The hook's own arithmetic, for a paper `height` pixels tall whose rows
average `avg` (the JavaScript reports `Math.max(6, (floor(h / avg) - 1) * 2)`
and ignores a change of less than 4 from what it last said).

    export let blkl_fit_count(height: Int, avg: Int): Int {
      if (avg <= 0) { 6 } else {
        let rows = (height / avg) orelse 0;
        let n = (rows - 1) * 2;
        if (n < 6) { 6 } else { n }
      }
    }

## Shuffle

`shuffle_on` in `reload/1`: only the live view shuffles; `?shuffle=1` and
`?shuffle=0` say so outright, and without either the always-shuffle
cookie decides.

    export let blkl_shuffle_on(live: Boolean, param: String, always: Boolean): Boolean {
      if (!live) { false } else if (param == "1") { true } else if (param == "0") { false } else { always }
    }

## Rooms

A link's chat room is `blink:<id>`, and its occupancy is how many of the
presence topic's members say they are in it.

    export let blkl_room(id: Int): String { "blink:${id.toString()}" }

    export let blkl_count(rooms: List<String>, room: String): Int {
      rooms.filter { (r: String): Boolean => r == room }.length
    }

The chat link's tail when anyone is in the room.

    export let blkl_here_now(n: Int): String {
      if (n > 0) { " · ${n.toString()} here now" } else { "" }
    }

## Hiding

The ids a device has hidden live in `localStorage.blinksHidden`, a JSON
list; the page adds an id itself (a Temper list grows only through a
`ListBuilder`, which is an actor), and this is what it stores.

    export let blkl_ids_json(ids: List<Int>): String {
      "[${ids.join(",") { (x: Int): String => x.toString() }}]"
    }

    export let blkl_hidden_label(n: Int): String {
      "${n.toString()} hidden by you · "
    }

## Admin

The confirm `data-confirm` asks before a delete.

    export let blkl_delete_confirm(title: String, has_title: Boolean, url: String): String {
      let what = if (has_title) { title } else { url };
      "delete “${what}” and its chat forever?"
    }

## The push bell

Which face the bell shows, in the order the template's `cond` tries them:
"" (no VAPID key: nothing at all), "ios" (an iPhone outside the home
screen: 🔔 get alerts), "on" (subscribed), "blocked", "notify" (can
subscribe), or "none" (the browser has no push).

    export let blkl_bell(vapid: Boolean, ios: Boolean, standalone: Boolean, subscribed: Boolean, supported: Boolean, permission: String): String {
      if (!vapid) { "" } else if (ios && !standalone) { "ios" } else if (subscribed) { "on" } else if (supported && permission == "denied") { "blocked" } else if (supported) { "notify" } else { "none" }
    }

`push-state`'s unprompted ask: phones only, once per browser, never when
the answer was already no.

    export let blkl_push_auto_open(vapid: Boolean, mobile: Boolean, subscribed: Boolean, seen: Boolean, permission: String): Boolean {
      vapid && mobile && !subscribed && !seen && permission != "denied"
    }

## The tour

`build_tour_steps/1`: each step is `[target, title, content]`, `target`
the `data-joyride` it points at. Four steps, then two about the chat
window when one is open or one about it when not.

    export let blkl_tour_steps(chat_open: Boolean): List<List<String>> {
      let search = ["search", "Search everything", "Titles, tags, and notes are all searchable from here."];
      let tags = ["tags-box", "Browse by tag", "Click tags to combine them — you'll see links matching any of them. Click a tag again to drop it."];
      let chat = ["chat-link", "Every link is a chat room", "This opens an AIM window that's both a comments section and a live discussion."];
      let hide = ["hide-link", "Not your thing?", "Hide any link and it stays hidden for you on this device."];
      if (chat_open) {
        [search, tags, chat, hide,
          ["chat-window", "The chat window", "Drag it by the title bar; grab the bottom-right corner to resize. On phones it goes fullscreen."],
          ["chat-window", "Markdown + votes", "Messages support markdown — links become clickable, **bold**, lists, code. Hover a message to 👍/👎 it. Votes only exist on comments; links themselves can't be voted on."]]
      } else {
        [search, tags, chat, hide,
          ["chat-link", "Inside the chat", "Once open: drag the title bar, resize from the corner, write markdown (links become clickable), and hover messages to 👍/👎 them. Votes are for comments only — links don't have votes."]]
      }
    }

LiveJoyride's three styles for a target at `x, y` of `w` by `h` in a
window `ww` by `wh`: the overlay is clipped around the target with 8px to
spare, the spotlight is drawn over that gap, and the tooltip goes 20px
under the target unless that runs off the bottom, then 20px over it.

    export let blkl_tour_clip(x: Int, y: Int, w: Int, h: Int): String {
      let x1 = x - 8;
      let y1 = y - 8;
      let x2 = x + w + 8;
      let y2 = y + h + 8;
      "clip-path: polygon(0% 0%, 0% 100%, ${x1.toString()}px 100%, ${x1.toString()}px ${y1.toString()}px, ${x2.toString()}px ${y1.toString()}px, ${x2.toString()}px ${y2.toString()}px, ${x1.toString()}px ${y2.toString()}px, ${x1.toString()}px 100%, 100% 100%, 100% 0%);"
    }

    export let blkl_tour_spot(x: Int, y: Int, w: Int, h: Int): String {
      "top:${(y - 8).toString()}px;left:${(x - 8).toString()}px;width:${(w + 16).toString()}px;height:${(h + 16).toString()}px;"
    }

    export let blkl_tour_tip(x: Int, y: Int, w: Int, h: Int, ww: Int, wh: Int): String {
      let top = y + h + 20;
      let half = (w / 2) orelse 0;
      let left0 = x + half - 160;
      let left1 = if (left0 > ww - 340) { ww - 340 } else { left0 };
      let left = if (left1 < 16) { 16 } else { left1 };
      if (top + 200 > wh) {
        "bottom:${(wh - y + 20).toString()}px;left:${left.toString()}px;"
      } else {
        "top:${top.toString()}px;left:${left.toString()}px;"
      }
    }

    export let blkl_tour_progress(i: Int, n: Int): String {
      "${(i + 1).toString()} of ${n.toString()}"
    }
