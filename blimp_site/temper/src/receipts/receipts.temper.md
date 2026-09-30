# Very direct messages

What `/very_direct_message` decides rather than stores: the pure parts of
`BlogWeb.ReceiptMessageLive`. Which files the form takes and what type
they are kept as, who sent the message, and the queue panel's markup.
`src/99_receipts.blimp` reads the request and talks to Postgres. Every
name starts `rx_`: the site has one flat namespace.

    let { escape_html, trim } = import("../text");

## The image

`allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif))`. LiveView's
`UploadConfig.accepted?/2` takes a file when the browser's type for it is
one of the three those extensions name, or else when its own extension,
lower-cased in ASCII, is one of the four. So `photo.HEIC` sent as
`image/png` is taken, and so is `x.JPG` sent as `application/octet-stream`.

    export let rx_accepted(client_type: String, ext_lower: String): Boolean {
      client_type == "image/jpeg" || client_type == "image/png" || client_type == "image/gif" ||
        ext_lower == ".jpg" || ext_lower == ".jpeg" || ext_lower == ".png" || ext_lower == ".gif"
    }

The type the row keeps comes from the extension alone, `image/jpeg` when it
names none of the four: the file above that was taken for its type, not its
name, is stored as a JPEG whatever it is. The printer is told the same.

    export let rx_content_type(ext_lower: String): String {
      if (ext_lower == ".png") {
        "image/png"
      } else if (ext_lower == ".gif") {
        "image/gif"
      } else {
        "image/jpeg"
      }
    }

`Path.extname/1` of the browser's file name, checked against Elixir:
`"a.JPG"` is `".JPG"`, `"..jpg"` is `".jpg"`, `"a."` and `".."` are `"."`,
and `".jpg"`, `"."` and `"x/.jpg"` have none, a name that is only a dot
and a word being a hidden file, not an extension.

    export let rx_extname(name: String): String {
      let segs = name.split("/");
      let base = segs[segs.length - 1];
      let pieces = base.split(".");
      if (pieces.length < 2) {
        ""
      } else if (pieces.length == 2 && pieces[0] == "") {
        ""
      } else {
        ".${pieces[pieces.length - 1]}"
      }
    }

## Who sent it

`BlogWeb.Plugs.RemoteIp`: the first entry of `X-Forwarded-For`, trimmed,
which Caddy sets from Cloudflare's `CF-Connecting-IP`. Without the header
Phoenix fell back to the socket's peer, which this server cannot see.

    export let rx_client_ip(forwarded_for: String): String {
      trim(forwarded_for.split(",")[0])
    }

## The queue

`toggle_queue` showed the ten newest messages, whoever sent them: content,
status and `Calendar.strftime(inserted_at, "%b %d, %I:%M %p")`, which
Postgres writes as `Mon DD, HH12:MI AM` (src/99_receipts.blimp). The content
div is `white-space: pre-wrap`, so nothing may stand between its tags and
the text.

    export let rx_queue_item(content: String, status: String, at: String): String {
      "<div class=\"queue-item\">\n  <div class=\"queue-item-content\">${escape_html(content)}</div>\n  <div class=\"queue-item-meta\">\n    <span>${escape_html(status)}</span>\n    <span>${escape_html(at)}</span>\n  </div>\n</div>"
    }

    export let rx_queue_panel(items: List<String>): String {
      let body = if (items.length == 0) {
        "<div class=\"queue-empty\">No messages yet</div>"
      } else {
        items.join("\n") { (item): String => item }
      };
      "<div class=\"queue-panel\">\n<div class=\"queue-header\">Recent Messages</div>\n${body}\n</div>"
    }
