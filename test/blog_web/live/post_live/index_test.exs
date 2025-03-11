defmodule BlogWeb.PostLive.IndexTest do
  use BlogWeb.LiveCase, async: true
  alias Blog.Content.Post
  alias Blog.Content.Tag
  
  setup do
    # Mock Blog.Content.Post.all function
    :meck.new(Post, [:passthrough])
    :meck.expect(Post, :all, fn ->
      [
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
          tags: [%Tag{name: "elixir"}, %Tag{name: "phoenix"}]
        }
      ]
    end)
    
    on_exit(fn -> :meck.unload(Post) end)
    
    :ok
  end
  
  test "renders list of posts", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    
    # Check that all posts are displayed
    assert html =~ "Test Post 1"
    assert html =~ "Test Post 2"
    assert html =~ "Test Post 3"
    
    # Check for formatted dates
    assert html =~ "Feb 01, 2025"
    assert html =~ "Jan 15, 2025"
    assert html =~ "Jan 01, 2025"
    
    # Check that tags are displayed
    assert html =~ "elixir"
    assert html =~ "phoenix"
    assert html =~ "liveview"
    assert html =~ "test"
  end
  
  test "clicking on a post navigates to the post page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    
    # Click on the first post
    render_click(view, "go-to-post", %{"slug" => "test-post-1"})
    
    # For LiveView navigation, we can check if redirect was triggered
    # This indirectly tests that clicking a post works
    assert_redirected(view, "/post/test-post-1")
  end
  
  test "posts are sorted by date in descending order", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    
    # Check posts exist in the HTML
    assert html =~ "Test Post 1"
    assert html =~ "Test Post 2"
    assert html =~ "Test Post 3"
    
    # Extract positions using string index
    pos1 = :binary.match(html, "Test Post 1") |> elem(0)
    pos2 = :binary.match(html, "Test Post 2") |> elem(0)
    pos3 = :binary.match(html, "Test Post 3") |> elem(0)
    
    # The first post (newest) should appear before the second,
    # and the second before the third (oldest)
    assert pos1 < pos2
    assert pos2 < pos3
  end
  
  test "displays tag filtering UI", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    
    # Check that tag filtering UI is present
    assert html =~ "Filter by tag"
    
    # All unique tags should be shown
    assert html =~ "elixir"
    assert html =~ "phoenix"
    assert html =~ "liveview"
    assert html =~ "test"
  end
  
  test "can filter posts by tag", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    
    # Click on the elixir tag to filter posts
    rendered = render_click(view, "filter-by-tag", %{"tag" => "elixir"})
    
    # Only posts with the "elixir" tag should be shown
    assert rendered =~ "Test Post 1"
    assert rendered =~ "Test Post 3"
    refute rendered =~ "Test Post 2"
    
    # The selected tag should be highlighted
    assert rendered =~ "class=\"selected-tag\""
    
    # Click the tag again to clear the filter
    rendered = render_click(view, "filter-by-tag", %{"tag" => "elixir"})
    
    # All posts should be shown again
    assert rendered =~ "Test Post 1"
    assert rendered =~ "Test Post 2"
    assert rendered =~ "Test Post 3"
  end
end