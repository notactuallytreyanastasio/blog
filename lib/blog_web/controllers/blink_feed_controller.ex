defmodule BlogWeb.BlinkFeedController do
  use BlogWeb, :controller
  alias Blog.Blinks

  def rss(conn, params) do
    tags =
      (params["tags"] || params["tag"] || "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    blinks = Blinks.list_blinks(tags: tags, limit: 100)

    title =
      case tags do
        [] -> "blinks"
        tags -> "blinks: #{Enum.join(tags, " + ")}"
      end

    items =
      Enum.map_join(blinks, "\n", fn b ->
        desc =
          [b.description, "tags: " <> Enum.join(b.tags, ", ")]
          |> Enum.reject(&(&1 in [nil, "tags: "]))
          |> Enum.join(" — ")

        date =
          b.inserted_at
          |> DateTime.from_naive!("Etc/UTC")
          |> Calendar.strftime("%a, %d %b %Y %H:%M:%S GMT")

        """
        <item>
          <title>#{xml_escape(b.title || b.url)}</title>
          <link>#{xml_escape(b.url)}</link>
          <guid isPermaLink="false">blink-#{b.id}</guid>
          <pubDate>#{date}</pubDate>
          <description>#{xml_escape(desc)}</description>
        </item>
        """
      end)

    body = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>#{xml_escape(title)}</title>
        <link>https://bobbby.online/blinks</link>
        <description>bobby's links</description>
        #{items}
      </channel>
    </rss>
    """

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, body)
  end

  @doc "StumbleUpon, at home: bounce to a random saved link."
  def stumble(conn, _params) do
    case Blinks.random_blink() do
      nil -> redirect(conn, to: "/blinks")
      blink -> redirect(conn, external: blink.url)
    end
  end

  # Privacy policy for the blinks iOS app (App Store requires a URL).
  def privacy(conn, _params) do
    html(conn, """
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>blinks — privacy</title>
      <style>
        body { font-family: 'American Typewriter', 'Courier New', monospace;
               background: #f7f3ea; color: #26221d; max-width: 60ch;
               margin: 3rem auto; padding: 0 1rem; line-height: 1.6; }
        h1 { font-size: 1.6rem; }
        a { color: #369; }
      </style>
    </head>
    <body>
      <h1>blinks. privacy policy</h1>
      <p>blinks is a reading app for links curated by one person.</p>
      <p><b>What it collects: nothing.</b> No accounts, no analytics, no
      tracking, no third-party services. Settings stay on your device.</p>
      <p><b>Push notifications:</b> if you allow notifications, Apple issues
      your device an anonymous push token, which this server stores solely to
      send you a notification when a new link is published. The token
      identifies your device to Apple's push service only — not you — and is
      deleted automatically when it stops working (e.g. after you uninstall
      the app or revoke notification permission).</p>
      <p><b>Reading:</b> fetching the public link feed sends this server the
      ordinary information any web request carries (IP address, user agent),
      which is not logged beyond standard short-lived server logs and never
      shared.</p>
      <p>Questions: <a href="mailto:bobbbygrayson@gmail.com">bobbbygrayson@gmail.com</a></p>
    </body>
    </html>
    """)
  end

  defp xml_escape(s) do
    s
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  @doc "The PWA service worker. Root path so `scope: /blinks` is allowed; never cached long."
  def service_worker(conn, _params) do
    path = Application.app_dir(:blog, "priv/static/static/blinks-pwa/sw.js")

    conn
    |> put_resp_content_type("application/javascript")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("service-worker-allowed", "/blinks")
    |> send_file(200, path)
  end
end
