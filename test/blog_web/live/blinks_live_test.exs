defmodule BlogWeb.BlinksLiveTest do
  use BlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Blog.{Blinks, Chat}

  test "NO DORK STUFF hides blinks carrying dork tags", %{conn: conn} do
    {:ok, _} =
      Blinks.save_blink(%{"url" => "https://d.co/1", "title" => "Dorky post", "tags" => ["elixir"]})

    {:ok, _} =
      Blinks.save_blink(%{"url" => "https://d.co/2", "title" => "Cool post", "tags" => ["music"]})

    Blinks.set_dork_tags(["elixir", "  Programming "])
    dork = Blinks.dork_tags()
    # custom tag added on top of the always-on baseline, normalized and deduped
    assert "elixir" in dork
    assert "code" in dork and "ai" in dork
    assert Enum.count(dork, &(&1 == "programming")) == 1

    {:ok, view, html} = live(conn, "/blinks")
    assert html =~ "CLICK TO HIDE THE ULTRA NERDY STUFF"
    assert html =~ "Dorky post"

    view |> element("button.dork-btn") |> render_click()

    html = render(view)
    refute html =~ "Dorky post"
    assert html =~ "Cool post"
    # tag cloud also drops the hidden blink's tags
    refute html =~ ">elixir<"
  end

  test "each link is a chat room: sign on, send, message persists to its room", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/1", "title" => "Chatty link"})

    {:ok, view, html} = live(conn, "/blinks?chat=#{blink.id}")
    assert html =~ "AOL Instant Messenger"
    assert html =~ "Sign On"

    view
    |> element("form[phx-submit=sign-on]")
    |> render_submit(%{"screen_name" => "xXbobbyXx"})

    view
    |> element("form[phx-submit=send-chat-message]")
    |> render_submit(%{"message" => "first!!"})

    assert render(view) =~ "first!!"
    assert [message] = Chat.list_messages("blink:#{blink.id}")
    assert message.content == "first!!"
    assert message.chatter.screen_name == "xXbobbyXx"

    # room messages stay out of the frontpage terminal room
    assert Chat.list_messages("terminal") == []
  end

  test "screen names are sticky: returning chatters are signed on already", %{conn: conn} do
    # 127.0.0.1 is what the test conn's RemoteIp resolves to
    {:ok, _} = Chat.find_or_create_chatter("oldtimer", "127.0.0.1")
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/3", "title" => "Prompted"})

    {:ok, view, html} = live(conn, "/blinks?chat=#{blink.id}")
    assert html =~ "send-chat-message"
    assert html =~ "chatting as oldtimer"
    refute html =~ "Sign On"

    # "not you?" drops back to the sign-on box
    view |> element("a[phx-click=sign-off]") |> render_click()
    assert render(view) =~ "Sign On"
  end

  test "first-time visitors still get the sign-on prompt", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/8", "title" => "Fresh face"})
    {:ok, _view, html} = live(conn, "/blinks?chat=#{blink.id}")
    assert html =~ "Sign On"
    refute html =~ "send-chat-message"
  end

  test "replies thread one deep and flatten beyond that", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/4", "title" => "Threaded"})
    room = "blink:#{blink.id}"
    {:ok, chatter} = Chat.find_or_create_chatter("threader", "9.9.9.9")

    {:ok, top} = Chat.create_message(chatter, "top level", room)
    {:ok, reply} = Chat.create_message(chatter, "a reply", room, reply_to_id: top.id)
    # replying to a reply attaches to the top-level parent
    {:ok, deep} = Chat.create_message(chatter, "reply to reply", room, reply_to_id: reply.id)

    assert reply.reply_to_id == top.id
    assert deep.reply_to_id == top.id

    {:ok, view, _html} = live(conn, "/blinks?chat=#{blink.id}")
    view |> element("form[phx-submit=sign-on]") |> render_submit(%{"screen_name" => "replier"})

    view |> element("a[phx-value-id='#{top.id}'].reply-link") |> render_click()
    assert render(view) =~ "replying to"

    view
    |> element("form[phx-submit=send-chat-message]")
    |> render_submit(%{"message" => "@threader nice find"})

    html = render(view)
    assert html =~ "aim-reply"
    assert html =~ "@threader"
    assert [%{reply_to_id: parent_id} | _] =
             Chat.list_messages(room) |> Enum.filter(&(&1.content =~ "nice find"))

    assert parent_id == top.id
  end

  test "who's here button renders with presence count", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/5", "title" => "Peopled"})
    {:ok, view, _} = live(conn, "/blinks?chat=#{blink.id}")

    html = render(view)
    assert html =~ "People (1)"

    view |> element("form[phx-submit=sign-on]") |> render_submit(%{"screen_name" => "herenow"})
    view |> element("div.win95-menubar span[phx-click=toggle-buddies]") |> render_click()

    html = render(view)
    # who's here opens as its own win95 window
    assert html =~ "buddies-window"
    assert html =~ "Buddy List"
    assert html =~ "WHO&#39;S HERE"
    assert html =~ "herenow"
  end

  test "@mention autocomplete suggests names while typing", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/6", "title" => "Completable"})
    {:ok, chatter} = Chat.find_or_create_chatter("mentionable", "8.8.8.8")
    {:ok, _} = Chat.create_message(chatter, "hi", "blink:#{blink.id}")

    {:ok, view, _} = live(conn, "/blinks?chat=#{blink.id}")
    view |> element("form[phx-submit=sign-on]") |> render_submit(%{"screen_name" => "typer"})

    html =
      view
      |> element("form[phx-submit=send-chat-message]")
      |> render_change(%{"message" => "yo @men"})

    assert html =~ "complete-mention"
    assert html =~ "mentionable"

    view
    |> element("button[phx-click=complete-mention][phx-value-name=mentionable]")
    |> render_click()

    assert render(view) =~ "yo @mentionable"
  end

  test "tag sidebar: cloud for repeats, one-offs behind an expandable panel", %{conn: conn} do
    for i <- 1..2 do
      Blinks.save_blink(%{"url" => "https://t.co/pop#{i}", "tags" => ["popular"]})
    end

    Blinks.save_blink(%{"url" => "https://t.co/solo", "tags" => ["oneoff"]})

    {:ok, view, html} = live(conn, "/blinks")
    assert html =~ "popular"
    # singles are collapsed until expanded
    refute html =~ ">oneoff<"
    assert html =~ "1 one-offs"

    view |> element("span.singles-link") |> render_click()
    assert render(view) =~ "oneoff"
  end

  test "chat messages thumb up/down with toggle and switch", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/7", "title" => "Votable"})
    {:ok, author} = Chat.find_or_create_chatter("author", "7.7.7.7")
    {:ok, msg} = Chat.create_message(author, "vote on me", "blink:#{blink.id}")

    {:ok, view, _} = live(conn, "/blinks?chat=#{blink.id}")
    view |> element("form[phx-submit=sign-on]") |> render_submit(%{"screen_name" => "voter"})

    up = "a[phx-click=vote-msg][phx-value-id='#{msg.id}'][phx-value-val='1']"
    down = "a[phx-click=vote-msg][phx-value-id='#{msg.id}'][phx-value-val='-1']"

    view |> element(up) |> render_click()
    assert Chat.vote_counts([msg.id])[msg.id] == {1, 0}
    assert render(view) =~ "👍1"

    # same thumb again removes the vote
    view |> element(up) |> render_click()
    assert Chat.vote_counts([msg.id]) == %{}

    # opposite thumb switches
    view |> element(down) |> render_click()
    assert Chat.vote_counts([msg.id])[msg.id] == {0, 1}
  end

  test "links always render in two columns", %{conn: conn} do
    for i <- 1..4 do
      Blinks.save_blink(%{"url" => "https://cols.co/#{i}", "title" => "Col #{i}"})
    end

    {:ok, _view, html} = live(conn, "/blinks")
    assert length(String.split(html, ~s(class="col"))) - 1 == 2

    blink = Blog.Blinks.get_by_url("https://cols.co/1")
    {:ok, _view, html} = live(conn, "/blinks?chat=#{blink.id}")
    assert length(String.split(html, ~s(class="col"))) - 1 == 2
  end

  test "no timestamps shown on the link list", %{conn: conn} do
    Blinks.save_blink(%{"url" => "https://ts.co/1", "title" => "Fresh"})
    {:ok, _view, html} = live(conn, "/blinks")
    refute html =~ "saved just now"
    refute html =~ "minutes ago"
  end

  test "chat renders markdown with safe hyperlinks, headings capped at h3", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://md.co/1", "title" => "MD"})
    room = "blink:#{blink.id}"
    {:ok, c} = Chat.find_or_create_chatter("mdguy", "6.6.6.6")

    Chat.create_message(c, "check [this](https://cool.site) **bold** and https://bare.link", room)
    Chat.create_message(c, "# huge heading\n<script>alert(1)</script> [bad](javascript:alert(1))", room)

    {:ok, view, _} = live(conn, "/blinks?chat=#{blink.id}")
    view |> element("form[phx-submit=sign-on]") |> render_submit(%{"screen_name" => "reader"})
    html = render(view)

    assert html =~ ~s(href="https://cool.site")
    assert html =~ "<strong>bold</strong>"
    assert html =~ ~s(href="https://bare.link")
    assert html =~ ~s(target="_blank")
    refute html =~ "huge heading</h1>"
    assert html =~ "huge heading</h3>"
    refute html =~ "<script>alert"
    refute html =~ ~s(href="javascript:)
  end

  test "hide removes a link for this visitor; unhide-all restores", %{conn: conn} do
    {:ok, a} = Blinks.save_blink(%{"url" => "https://h.co/1", "title" => "Keep me"})
    {:ok, b} = Blinks.save_blink(%{"url" => "https://h.co/2", "title" => "Hide me"})

    {:ok, view, html} = live(conn, "/blinks")
    assert html =~ "Hide me"

    view |> element("a[phx-click=hide][phx-value-id='#{b.id}']") |> render_click()
    html = render(view)
    refute html =~ "Hide me"
    assert html =~ "Keep me"
    assert html =~ "1 hidden by you"

    # a fresh mount pushes localStorage prefs up through the hook
    {:ok, view2, _} = live(conn, "/blinks")
    render_hook(view2, "prefs", %{"ids" => [b.id], "seenTour" => true})
    refute render(view2) =~ "Hide me"

    view |> element("span[phx-click=unhide-all]") |> render_click()
    assert render(view) =~ "Hide me"
    _ = a
  end

  test "tour: auto-starts for browsers that haven't seen it, restartable", %{conn: conn} do
    Blinks.save_blink(%{"url" => "https://t.co/tour", "title" => "Tourable"})

    {:ok, view, html} = live(conn, "/blinks")
    assert html =~ "blinks-tour"
    assert html =~ ~s(data-joyride="search")
    assert html =~ ~s(data-joyride="tags-box")
    assert html =~ ~s(data-joyride="chat-link")
    assert html =~ ~s(data-joyride="hide-link")

    # a browser that has never seen the tour reports seenTour: false → runs
    render_hook(view, "prefs", %{"ids" => [], "seenTour" => false})
    assert render(view) =~ "blinks-tour"

    # manual restart from the header
    view |> element("a.tour-link") |> render_click()
    assert render(view) =~ "blinks-tour"
  end

  test "quotes accumulate and the first becomes the headline", %{conn: conn} do
    {:ok, _} =
      Blinks.save_blink(%{
        "url" => "https://q.co/1",
        "title" => "Real Title",
        "quotes" => ["the first great line"]
      })

    {:ok, b} =
      Blinks.save_blink(%{
        "url" => "https://q.co/1",
        "quotes" => ["a second banger", "the first great line"]
      })

    assert b.quotes == ["the first great line", "a second banger"]

    {:ok, _view, html} = live(conn, "/blinks")
    assert html =~ "“the first great line”"
    # original title demoted to subtitle
    assert html =~ ~s(class="subtitle">Real Title)
    assert html =~ "2 QUOTES"
  end

  test "bluesky threads unroll into a single-post view", %{conn: conn} do
    node = fn did, text, at, replies ->
      %{
        "post" => %{
          "author" => %{"did" => did, "handle" => "bob.bsky", "displayName" => "Bob"},
          "record" => %{"text" => text, "createdAt" => at}
        },
        "replies" => replies
      }
    end

    other = node.("did:other", "nice thread!", "2026-01-01T03:00:00Z", [])
    third = node.("did:me", "post three", "2026-01-01T02:00:00Z", [])
    second = node.("did:me", "post two", "2026-01-01T01:00:00Z", [third, other])
    thread = node.("did:me", "post one", "2026-01-01T00:00:00Z", [other, second])

    posts = Blog.Blinks.Enricher.unroll_posts(thread)
    assert Enum.map(posts, & &1["text"]) == ["post one", "post two", "post three"]

    {:ok, b} =
      Blinks.save_blink(%{"url" => "https://bsky.app/profile/bob.bsky/post/abc", "title" => "t"})

    {:ok, _} =
      b
      |> Blog.Blinks.Blink.changeset(%{thread: %{"posts" => posts}})
      |> Blog.Repo.update()

    {:ok, _view, html} = live(conn, "/blinks")
    # row shows only the top-level post as headline plus a thread marker
    assert html =~ "post one"
    assert html =~ "🧵 3"
    assert html =~ "post three"
    refute html =~ "nice thread!"
    refute html =~ "UNROLL THREAD"
  end

  test "comment counts show on the list", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/2", "title" => "Counted"})
    {:ok, chatter} = Chat.find_or_create_chatter("counter", "1.2.3.4")
    {:ok, _} = Chat.create_message(chatter, "hello", "blink:#{blink.id}")

    {:ok, _view, html} = live(conn, "/blinks")
    assert html =~ "1 comment"
  end
end
