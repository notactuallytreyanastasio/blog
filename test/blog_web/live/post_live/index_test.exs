defmodule BlogWeb.PostLive.IndexTest do
  # async: false because :meck replaces Blog.Content.Post globally.
  use BlogWeb.LiveCase, async: false

  alias Blog.Content.Post
  alias Blog.Content.Tag

  @posts [
    %Post{
      title: "Test Post 1",
      body: "This is the first test post",
      written_on: ~N[2025-02-01 12:00:00],
      slug: "test-post-1",
      tags: [%Tag{name: "elixir"}, %Tag{name: "test"}]
    },
    %Post{
      title: "Test Post 2",
      body: "This is the second test post",
      written_on: ~N[2025-01-15 10:00:00],
      slug: "test-post-2",
      tags: [%Tag{name: "phoenix"}, %Tag{name: "liveview"}]
    },
    %Post{
      title: "Test Post 3",
      body: "This is the third test post",
      written_on: ~N[2025-01-01 09:00:00],
      slug: "test-post-3",
      tags: [%Tag{name: "cooking"}, %Tag{name: "music"}]
    }
  ]

  setup do
    # The /blog index loads posts via Blog.Content.Post.all/0, which reads from
    # markdown files. Mock it so the test controls the post set.
    # :no_link so the mock isn't torn down when the test process exits before
    # on_exit runs (on_exit executes in a separate process).
    :meck.new(Post, [:passthrough, :no_link])
    :meck.expect(Post, :all, fn -> @posts end)
    on_exit(fn -> :meck.unload(Post) end)
    :ok
  end

  test "renders all posts from Post.all/0", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    assert html =~ "Test Post 1"
    assert html =~ "Test Post 2"
    assert html =~ "Test Post 3"
  end

  test "renders each post's tags", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    for tag <- ~w(elixir test phoenix liveview cooking music) do
      assert html =~ tag
    end
  end

  test "formats post dates as '%B %d, %Y'", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    assert html =~ "February 01, 2025"
    assert html =~ "January 15, 2025"
    assert html =~ "January 01, 2025"
  end

  test "links each post to its slug page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    assert html =~ ~s(href="/post/test-post-1")
    assert html =~ ~s(href="/post/test-post-2")
    assert html =~ ~s(href="/post/test-post-3")
  end

  test "lists posts newest-first", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    pos1 = :binary.match(html, "Test Post 1") |> elem(0)
    pos2 = :binary.match(html, "Test Post 2") |> elem(0)
    pos3 = :binary.match(html, "Test Post 3") |> elem(0)

    # 2025-02-01 > 2025-01-15 > 2025-01-01
    assert pos1 < pos2
    assert pos2 < pos3
  end

  test "shows the post count in the status bar", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/blog")

    assert html =~ "3 posts"
  end
end
