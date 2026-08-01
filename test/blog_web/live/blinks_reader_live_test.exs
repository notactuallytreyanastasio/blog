defmodule BlogWeb.BlinksReaderLiveTest do
  use BlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Blog.Blinks

  # A bsky-style thread carrying two images and a video still, plus a quoted
  # post with a picture of its own — the shapes the enricher actually writes.
  defp thread_with_media do
    %{
      "posts" => [
        %{
          "handle" => "someone.bsky.social",
          "text" => "a thread about trains",
          "images" => [
            %{"thumb" => "https://cdn.test/1-small.jpg", "full" => "https://cdn.test/1-BIG.jpg", "alt" => "a red train"},
            %{"thumb" => "https://cdn.test/2-small.jpg", "full" => "https://cdn.test/2-BIG.jpg", "alt" => ""}
          ],
          "quote" => %{
            "handle" => "quoted.bsky.social",
            "text" => "the original claim",
            "images" => [%{"thumb" => "https://cdn.test/q-small.jpg", "full" => "https://cdn.test/q-BIG.jpg", "alt" => "quoted pic"}]
          }
        },
        %{
          "handle" => "someone.bsky.social",
          "text" => "and here is the footage",
          "video" => %{"thumb" => "https://cdn.test/v-still.jpg"}
        }
      ]
    }
  end

  test "the reader shows the same links as /blinks", %{conn: conn} do
    {:ok, _} = Blinks.save_blink(%{"url" => "https://a.co/1", "title" => "First thing", "tags" => ["music"]})
    {:ok, _} = Blinks.save_blink(%{"url" => "https://b.co/2", "title" => "Second thing"})

    {:ok, _view, html} = live(conn, "/blinks-reader")

    assert html =~ "First thing"
    assert html =~ "Second thing"
    assert html =~ ~s(href="https://a.co/1")
  end

  test "thumbnails open a lightbox showing the full-size image, not the thumb", %{conn: conn} do
    {:ok, _} =
      Blinks.save_blink(%{"url" => "https://a.co/trains", "title" => "Trains", "thread" => thread_with_media()})

    {:ok, view, html} = live(conn, "/blinks-reader")

    # the sheet itself only ever loads thumbs
    assert html =~ "https://cdn.test/1-small.jpg"
    refute html =~ "https://cdn.test/1-BIG.jpg"
    refute html =~ "class=\"lb\""

    html = view |> element(~s(button.shot[phx-value-idx="0"])) |> render_click()

    # ...and the open lightbox swaps in the full-resolution copy
    assert html =~ "https://cdn.test/1-BIG.jpg"
    assert html =~ "a red train"
    assert html =~ "1 / 4"
  end

  test "arrow keys walk every picture on the page, wrapping at both ends", %{conn: conn} do
    {:ok, _} =
      Blinks.save_blink(%{"url" => "https://a.co/trains", "title" => "Trains", "thread" => thread_with_media()})

    {:ok, view, _html} = live(conn, "/blinks-reader")
    view |> element(~s(button.shot[phx-value-idx="0"])) |> render_click()

    # forward through the post's images into the quoted post's picture
    html = render_keydown(view, "media-key", %{"key" => "ArrowRight"})
    assert html =~ "https://cdn.test/2-BIG.jpg"

    html = render_keydown(view, "media-key", %{"key" => "ArrowRight"})
    assert html =~ "quoted pic"
    assert html =~ "3 / 4"

    # the video still is last, and says so rather than pretending to play
    html = render_keydown(view, "media-key", %{"key" => "ArrowRight"})
    assert html =~ "https://cdn.test/v-still.jpg"
    assert html =~ "still frame"
    assert html =~ "watch on"

    # wrap forward to the first, then back off the front to the last
    html = render_keydown(view, "media-key", %{"key" => "ArrowRight"})
    assert html =~ "1 / 4"

    html = render_keydown(view, "media-key", %{"key" => "ArrowLeft"})
    assert html =~ "4 / 4"
  end

  test "escape closes the lightbox", %{conn: conn} do
    {:ok, _} =
      Blinks.save_blink(%{"url" => "https://a.co/trains", "title" => "Trains", "thread" => thread_with_media()})

    {:ok, view, _html} = live(conn, "/blinks-reader")
    view |> element(~s(button.shot[phx-value-idx="0"])) |> render_click()
    assert render(view) =~ "https://cdn.test/1-BIG.jpg"

    html = render_keydown(view, "media-key", %{"key" => "Escape"})
    refute html =~ "https://cdn.test/1-BIG.jpg"
  end

  test "the gallery is numbered across links, so it walks from one into the next", %{conn: conn} do
    {:ok, _} = Blinks.save_blink(%{"url" => "https://a.co/one", "title" => "One", "image_url" => "https://cdn.test/og-one.jpg"})
    {:ok, _} = Blinks.save_blink(%{"url" => "https://a.co/two", "title" => "Two", "image_url" => "https://cdn.test/og-two.jpg"})

    {:ok, view, _html} = live(conn, "/blinks-reader")

    html = view |> element(~s(button.shot[phx-value-idx="0"])) |> render_click()
    assert html =~ "1 / 2"

    html = render_keydown(view, "media-key", %{"key" => "ArrowRight"})
    assert html =~ "2 / 2"
    # crossing a link boundary re-labels the caption with the new link
    assert html =~ "open a.co"
  end

  test "links with no pictures render no thumbnail strip", %{conn: conn} do
    {:ok, _} = Blinks.save_blink(%{"url" => "https://plain.co/text", "title" => "Just words"})

    {:ok, _view, html} = live(conn, "/blinks-reader")

    assert html =~ "Just words"
    refute html =~ "class=\"shot\""
  end

  test "search and tag filters narrow the sheet and survive in the URL", %{conn: conn} do
    {:ok, _} = Blinks.save_blink(%{"url" => "https://a.co/1", "title" => "Trains are good", "tags" => ["rail"]})
    {:ok, _} = Blinks.save_blink(%{"url" => "https://a.co/2", "title" => "Boats are fine", "tags" => ["sea"]})

    {:ok, view, _html} = live(conn, "/blinks-reader")

    html = view |> form("form.searchform", %{"q" => "trains"}) |> render_change()
    assert html =~ "Trains are good"
    refute html =~ "Boats are fine"
    assert_patched(view, "/blinks-reader?q=trains")
  end

  test "dead links grey out and point at the wayback copy, same as the front page", %{conn: conn} do
    {:ok, blink} = Blinks.save_blink(%{"url" => "https://gone.co/404", "title" => "Vanished"})

    {:ok, once} = Blog.Blinks.LinkCheck.record_result(blink, :dead)
    {:ok, _dead} = Blog.Blinks.LinkCheck.record_result(once, :dead)

    {:ok, _view, html} = live(conn, "/blinks-reader")

    assert html =~ "card dead"
    assert html =~ ~s(href="https://web.archive.org/web/2/https://gone.co/404")
  end
end
