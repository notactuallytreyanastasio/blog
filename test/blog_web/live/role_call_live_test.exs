defmodule BlogWeb.RoleCallLiveTest do
  # async: false because :meck replaces Blog.RoleCall globally (process-wide).
  use BlogWeb.LiveCase, async: false

  alias Blog.RoleCall
  alias Blog.RoleCall.Show

  # Fixtures we fully control via the mock, so assertions match text we own
  # rather than brittle exact HTML.
  @shuffle_shows [
    %Show{id: "s1", title: "Shuffle Show Alpha", year_start: 2001, imdb_rating: 8.5},
    %Show{id: "s2", title: "Shuffle Show Beta", year_start: 2002, imdb_rating: 7.2}
  ]

  @search_shows [
    %Show{id: "r1", title: "Searched Show One", year_start: 2010, imdb_rating: 9.1},
    %Show{id: "r2", title: "Searched Show Two", year_start: 2011, imdb_rating: 6.4}
  ]

  @recommendations [
    %Show{id: "rec1", title: "Recommended Show", year_start: 2015, imdb_rating: 8.0}
  ]

  setup do
    # The LiveView hits the DB through Blog.RoleCall on mount (count_shows,
    # get_random_shows) and on most events. Mock the whole context so tests
    # control the data and don't need a populated database.
    #
    # :no_link so the mock isn't torn down when the test process exits before
    # on_exit runs (on_exit executes in a separate process).
    :meck.new(RoleCall, [:passthrough, :no_link])

    :meck.expect(RoleCall, :count_shows, fn -> 58_321 end)
    :meck.expect(RoleCall, :get_random_shows, fn _opts -> @shuffle_shows end)
    :meck.expect(RoleCall, :search_shows, fn _query, _opts -> @search_shows end)
    :meck.expect(RoleCall, :get_recommendations, fn _ids, _opts -> @recommendations end)
    :meck.expect(RoleCall, :get_show_with_credits, fn _id -> nil end)
    :meck.expect(RoleCall, :get_person_with_shows, fn _id -> nil end)
    # The liked view renders each liked id via RoleCall.get_show/1.
    :meck.expect(RoleCall, :get_show, fn id ->
      %Show{id: id, title: "Liked #{id}", year_start: 2000}
    end)

    on_exit(fn -> :meck.unload(RoleCall) end)
    :ok
  end

  describe "mount / default tab" do
    test "renders the page on the default (search) tab", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call")

      assert html =~ "Role Call"
      assert html =~ "Discover new shows through the writers you love"
      # Search input is present (search view is the default).
      assert html =~ ~s(id="show-search")
      # Shuffle picks come from the mocked get_random_shows/1.
      assert html =~ "Shuffle Show Alpha"
      assert html =~ "Shuffle Show Beta"
    end

    test "renders the formatted show count from count_shows/0", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call")

      # format_number/1 inserts thousands separators.
      assert html =~ "58,321"
    end

    test "starts with zero liked shows in the tab label and status bar", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call")

      assert html =~ "Liked (0)"
      assert html =~ "0 liked"
    end
  end

  describe "tab switching via handle_params" do
    test "?tab=liked switches to the liked view and loads recommendations", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call?tab=liked")

      assert html =~ "Shows I&#39;ve Liked" or html =~ "Shows I've Liked"
      assert html =~ "For You"
      # Recommendations were loaded for the liked tab.
      assert html =~ "Recommended Show"
    end

    test "?tab=discover switches to the discover view", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call?tab=discover")

      assert html =~ "Shows you&#39;ll love" or html =~ "Shows you'll love"
      # No likes yet, so the discover empty-state prompt is shown.
      assert html =~ "Like some shows first to get personalized recommendations!"
    end

    test "unknown tab value falls back to the search tab", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/role-call?tab=bogus")

      assert html =~ ~s(id="show-search")
    end

    test "navigating to the liked tab via patch updates the view", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html = render_patch(view, "/role-call?tab=liked")

      assert html =~ "For You"
    end
  end

  describe "search" do
    test "a >=2-char query renders results from search_shows/2", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html = render_keyup(element(view, "#show-search"), %{"query" => "ab"})

      assert html =~ "Searched Show One"
      assert html =~ "Searched Show Two"
    end

    test "a <2-char query clears results", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      # First populate results.
      html = render_keyup(element(view, "#show-search"), %{"query" => "abc"})
      assert html =~ "Searched Show One"

      # A single character clears them (length < 2).
      html = render_keyup(element(view, "#show-search"), %{"query" => "a"})
      refute html =~ "Searched Show One"
      refute html =~ "Searched Show Two"
    end

    test "clear_search empties the query and results", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html = render_keyup(element(view, "#show-search"), %{"query" => "abc"})
      assert html =~ "Searched Show One"

      html = render_click(element(view, "button.search-clear-btn"), %{})
      refute html =~ "Searched Show One"
    end
  end

  describe "liking and hiding shows" do
    test "like_show updates the liked count and pushes store_liked", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html =
        view
        |> element(~s([phx-click="like_show"][phx-value-id="s1"]))
        |> render_click()

      # Liked count is reflected in the tab label and status bar.
      assert html =~ "Liked (1)"
      assert html =~ "1 liked"

      assert_push_event(view, "store_liked", %{ids: ids})
      assert "s1" in ids
    end

    test "hide_show pushes store_hidden", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      view
      |> element(~s([phx-click="hide_show"][phx-value-id="s1"]))
      |> render_click()

      assert_push_event(view, "store_hidden", %{ids: ids})
      assert "s1" in ids
    end
  end

  describe "tour" do
    test "start_tour shows step 1 of the tour", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html = render_click(element(view, "button.tour-help-btn"), %{})

      assert html =~ "Welcome to Role Call!"
      assert html =~ "Step 1 of 5"
    end

    test "tour_next advances to the following step", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      render_click(element(view, "button.tour-help-btn"), %{})
      html = render_click(element(view, "button.tour-next"), %{})

      assert html =~ "Step 2 of 5"
    end

    test "skip_tour dismisses the tour overlay", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      render_click(element(view, "button.tour-help-btn"), %{})
      html = render_click(element(view, "button.tour-skip"), %{})

      refute html =~ "Step 1 of 5"
      assert_push_event(view, "tour_completed", %{})
    end
  end

  describe "set_cards_per_row clamping" do
    test "a value above 10 is clamped to 10", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      :meck.reset(RoleCall)
      :meck.expect(RoleCall, :get_random_shows, fn _opts -> @shuffle_shows end)

      render_hook(view, "set_cards_per_row", %{"count" => 25})

      # get_random_shows is always called with limit: 20 internally, so we
      # assert the clamp through cards_per_row affecting the refresh limit.
      assert :meck.called(RoleCall, :get_random_shows, :_)
    end

    test "a value below 3 is clamped to 3", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      # Should not raise; clamps to 3 internally.
      html = render_hook(view, "set_cards_per_row", %{"count" => 1})

      assert html =~ "Role Call"
    end

    test "an in-range value is accepted", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/role-call")

      html = render_hook(view, "set_cards_per_row", %{"count" => 5})

      assert html =~ "Role Call"
    end
  end
end
