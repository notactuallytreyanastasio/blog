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

  defp xml_escape(s) do
    s
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
