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

  test "links render in the height-constrained column container", %{conn: conn} do
    for i <- 1..4 do
      Blinks.save_blink(%{"url" => "https://cols.co/#{i}", "title" => "Col #{i}"})
    end

    {:ok, _view, html} = live(conn, "/blinks")
    # columns are CSS multicol (column-fill: auto) inside the fixed shell
    assert html =~ ~s(class="paper")
    assert html =~ "columns: 2"
    assert html =~ "column-fill: auto"
    assert html =~ "Col 1"
    assert html =~ "Col 4"
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
    view |> element("a[phx-click=start-tour]") |> render_click()
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

    # standalone single post: just itself, and no 🧵 marker on the row
    single = node.("did:solo", "just one post", "2026-01-01T00:00:00Z", [])
    assert [%{"text" => "just one post"}] = Blog.Blinks.Enricher.unroll_posts(single)

    # a reply saved out of someone ELSE's thread shows only that reply
    my_reply = Map.put(node.("did:me", "my hot take", "2026-01-01T01:00:00Z", []), "parent", other)
    assert [%{"text" => "my hot take"}] = Blog.Blinks.Enricher.unroll_posts(my_reply)

    # quote posts carry the quoted record's author + text
    quoting =
      put_in(
        node.("did:me", "pirate math", "2026-01-01T00:00:00Z", []),
        ["post", "embed"],
        %{
          "$type" => "app.bsky.embed.record#view",
          "record" => %{
            "$type" => "app.bsky.embed.record#viewRecord",
            "author" => %{"handle" => "quoted.bsky", "displayName" => "Q"},
            "value" => %{"text" => "the original hot take"}
          }
        }
      )

    assert [%{"quote" => %{"handle" => "quoted.bsky", "text" => "the original hot take"}}] =
             Blog.Blinks.Enricher.unroll_posts(quoting)

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

  test "the list updates live when a link is saved elsewhere", %{conn: conn} do
    {:ok, view, html} = live(conn, "/blinks")
    refute html =~ "Hot Off The Press"

    {:ok, _} = Blinks.save_blink(%{"url" => "https://live.co/1", "title" => "Hot Off The Press"})

    html = render(view)
    assert html =~ "Hot Off The Press"
    assert html =~ "1 saved"
    # freshly arrived rows tune in from static
    assert html =~ "thing fresh"
  end

  test "live-room dots: the list shows who's in a room right now", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://live.co/room", "title" => "Roomy"})

    # viewer A sits in the room; viewer B watches the list
    {:ok, _in_room, _} = live(conn, "/blinks?chat=#{blink.id}")
    {:ok, list_view, _} = live(conn, "/blinks")

    html = render(list_view)
    assert html =~ "live-dot"
    assert html =~ "1 here now"
  end

  test "dead links point at the wayback copy with a skull", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://gone.co/404", "title" => "Vanished"})
    {:ok, dead} = Blog.Blinks.LinkCheck.record_result(blink, :dead)
    assert dead.dead_at

    {:ok, _view, html} = live(conn, "/blinks")
    refute html =~ "💀"
    assert html =~ "thing dead"
    assert html =~ ~s(href="https://web.archive.org/web/2/https://gone.co/404")

    # recovery clears the flag and keeps last_checked_at fresh
    {:ok, alive} = Blog.Blinks.LinkCheck.record_result(dead, :ok)
    refute alive.dead_at
    assert alive.last_checked_at
  end

  test "stumble redirects to a random saved link", %{conn: conn} do
    {:ok, _} = Blinks.save_blink(%{"url" => "https://only.co/one", "title" => "Sole"})

    conn2 = get(conn, "/blinks/stumble")
    assert redirected_to(conn2, 302) == "https://only.co/one"
  end

  test "bookmark review: upvote blinks it, downvote dismisses, key required", %{conn: conn} do
    2 =
      Blinks.import_candidates([
        %{"url" => "https://bm.co/keeper", "title" => "Keeper", "folder" => "postgres"},
        %{"url" => "https://bm.co/meh", "title" => "Meh", "folder" => "Favorites"},
        %{"url" => "javascript:alert(1)", "title" => "bookmarklet"}
      ])

    # no key → bounced to /blinks
    assert {:error, {:redirect, %{to: "/blinks"}}} = live(conn, "/blinks/review")

    {:ok, view, html} = live(conn, "/blinks/review?key=dev-blinks-token")
    assert html =~ "Keeper"
    assert html =~ "0 / 2 reviewed"

    view
    |> element("span.arrow.up[phx-value-id='#{candidate_id("https://bm.co/keeper")}']")
    |> render_click()

    blink = Blinks.get_by_url("https://bm.co/keeper")
    assert blink.title == "Keeper"
    assert "bookmarks" in blink.tags
    assert "postgres" in blink.tags

    view
    |> element("span.arrow.down[phx-value-id='#{candidate_id("https://bm.co/meh")}']")
    |> render_click()

    refute Blinks.get_by_url("https://bm.co/meh")
    assert render(view) =~ "queue zero"

    # re-import skips urls that already became blinks
    assert Blinks.import_candidates([%{"url" => "https://bm.co/keeper", "title" => "Keeper"}]) == 0
  end

  test "admin unlock enables delete; deletes take the chat room along", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://del.co/1", "title" => "Doomed"})
    {:ok, chatter} = Chat.find_or_create_chatter("mourner", "5.5.5.5")
    {:ok, _} = Chat.create_message(chatter, "rip", "blink:#{blink.id}")

    {:ok, view, html} = live(conn, "/blinks")
    refute html =~ ">delete<"

    # wrong key rejected
    view |> element("form[phx-submit=unlock-admin]") |> render_submit(%{"key" => "wrong"})
    html = render(view)
    assert html =~ "not it"
    refute html =~ ">delete<"

    view
    |> element("form[phx-submit=unlock-admin]")
    |> render_submit(%{"key" => "dev-blinks-token"})

    view |> element("a.del[phx-value-id='#{blink.id}']") |> render_click()

    refute Blinks.get_by_url("https://del.co/1")
    assert Chat.list_messages("blink:#{blink.id}") == []
    refute render(view) =~ "Doomed"

    # a stored key unlocks straight from prefs on the next visit
    {:ok, view2, _} = live(conn, "/blinks")
    render_hook(view2, "prefs", %{"ids" => [], "seenTour" => true, "adminKey" => "dev-blinks-token"})
    assert render(view2) =~ "unlocked"
  end

  defp candidate_id(url) do
    Blog.Repo.get_by!(Blog.Blinks.BookmarkCandidate, url: url).id
  end

  test "comment counts show on the list", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://c.co/2", "title" => "Counted"})
    {:ok, chatter} = Chat.find_or_create_chatter("counter", "1.2.3.4")
    {:ok, _} = Chat.create_message(chatter, "hello", "blink:#{blink.id}")

    {:ok, _view, html} = live(conn, "/blinks")
    assert html =~ "1 comment"
  end
end
