defmodule BlogWeb.CursorTrackerLive.PureFunctionTest do
  @moduledoc """
  Unit tests for extracted pure functions in CursorTrackerLive.
  These tests require no database or LiveView connection.
  """
  use ExUnit.Case, async: true
  alias BlogWeb.CursorTrackerLive

  # --------------------------------------------------------------------------
  # generate_user_color/1
  # --------------------------------------------------------------------------

  describe "generate_user_color/1" do
    test "returns an rgb string" do
      color = CursorTrackerLive.generate_user_color("abc123")
      assert color =~ ~r/^rgb\(\d+, \d+, \d+\)$/
    end

    test "is deterministic for the same user ID" do
      assert CursorTrackerLive.generate_user_color("user1") ==
               CursorTrackerLive.generate_user_color("user1")
    end

    test "produces different colors for different user IDs" do
      refute CursorTrackerLive.generate_user_color("user1") ==
               CursorTrackerLive.generate_user_color("user2")
    end

    test "ensures minimum brightness (r, g, b >= 100)" do
      color = CursorTrackerLive.generate_user_color("zero")
      [r, g, b] = parse_rgb(color)
      assert r >= 100
      assert g >= 100
      assert b >= 100
    end

    test "clamps values at 255" do
      color = CursorTrackerLive.generate_user_color("high_values")
      [r, g, b] = parse_rgb(color)
      assert r <= 255
      assert g <= 255
      assert b <= 255
    end
  end

  # --------------------------------------------------------------------------
  # calculate_next_clear/0
  # --------------------------------------------------------------------------

  describe "calculate_next_clear/0" do
    test "returns a map with hours, minutes, seconds, and total_seconds" do
      result = CursorTrackerLive.calculate_next_clear()

      assert is_integer(result.hours)
      assert is_integer(result.minutes)
      assert is_integer(result.seconds)
      assert is_integer(result.total_seconds)
    end

    test "total_seconds is consistent with h/m/s components" do
      result = CursorTrackerLive.calculate_next_clear()
      computed = result.hours * 3600 + result.minutes * 60 + result.seconds
      assert computed == result.total_seconds
    end

    test "values are within expected ranges" do
      result = CursorTrackerLive.calculate_next_clear()

      assert result.hours in 0..0
      assert result.minutes in 0..59
      assert result.seconds in 0..59
      assert result.total_seconds > 0
      assert result.total_seconds <= 3600
    end
  end

  # --------------------------------------------------------------------------
  # build_point/1
  # --------------------------------------------------------------------------

  describe "build_point/1" do
    test "creates a point map from assigns" do
      assigns = %{
        relative_x: 42,
        relative_y: 99,
        user_color: "rgb(100, 200, 150)",
        user_id: "u1"
      }

      point = CursorTrackerLive.build_point(assigns)

      assert point.x == 42
      assert point.y == 99
      assert point.color == "rgb(100, 200, 150)"
      assert point.user_id == "u1"
      assert %DateTime{} = point.timestamp
    end
  end

  # --------------------------------------------------------------------------
  # format_time_component/1
  # --------------------------------------------------------------------------

  describe "format_time_component/1" do
    test "pads single digits" do
      assert CursorTrackerLive.format_time_component(5) == "05"
    end

    test "leaves double digits as-is" do
      assert CursorTrackerLive.format_time_component(42) == "42"
    end

    test "handles zero" do
      assert CursorTrackerLive.format_time_component(0) == "00"
    end
  end

  # --------------------------------------------------------------------------
  # point_author_label/2
  # --------------------------------------------------------------------------

  describe "point_author_label/2" do
    test "returns 'you' when IDs match" do
      assert CursorTrackerLive.point_author_label("abc", "abc") == "you"
    end

    test "returns truncated ID when IDs differ" do
      assert CursorTrackerLive.point_author_label("abcdef1234", "other") == "abcdef"
    end

    test "handles nil point user_id" do
      assert CursorTrackerLive.point_author_label(nil, "other") == ""
    end

    test "handles nil current user_id" do
      assert CursorTrackerLive.point_author_label("abc", nil) == ""
    end
  end

  # --------------------------------------------------------------------------
  # Helpers
  # --------------------------------------------------------------------------

  defp parse_rgb(color_string) do
    ~r/rgb\((\d+), (\d+), (\d+)\)/
    |> Regex.run(color_string, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule BlogWeb.CursorTrackerLiveTest do
  @moduledoc """
  LiveView integration tests for CursorTrackerLive.
  """
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias Blog.CursorPoints

  setup do
    # Stop any existing CursorPoints process to avoid ETS table conflicts
    case GenServer.whereis(CursorPoints) do
      nil -> :ok
      pid -> GenServer.stop(pid, :normal, 5_000)
    end

    # Allow ETS table cleanup to complete
    Process.sleep(10)

    start_supervised!(CursorPoints)
    CursorPoints.clear_points()
    :ok
  end

  # --------------------------------------------------------------------------
  # Mount and render
  # --------------------------------------------------------------------------

  describe "mount and render" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, ~p"/cursor-tracker")

      assert disconnected_html =~ "CURSOR POSITION TRACKER"
      assert render(page_live) =~ "CURSOR POSITION TRACKER"
    end

    test "displays initial UI elements", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "CURSOR POSITION TRACKER"
      assert html =~ "ACTIVE USERS:"
      assert html =~ "X-COORDINATE"
      assert html =~ "Y-COORDINATE"
      assert html =~ "CURSOR VISUALIZATION"
      assert html =~ "CLEAR POINTS"
      assert html =~ "AUTO-CLEAR IN:"
      assert html =~ "SYSTEM LOG"
    end

    test "displays initial coordinates as 0", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")
      assert html =~ ">0<"
    end

    test "shows active users count", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")
      assert html =~ "ACTIVE USERS: 1"
    end

    test "displays visualization area prompt", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "Move cursor here to visualize position"
      assert html =~ "Click anywhere in the visualization area to save a point"
    end

    test "has auto-clear timer display", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ ~r/\d{2}:\d{2}:\d{2}/
      assert html =~ "AUTO-CLEAR IN:"
    end

    test "generates user color when connected", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      html = render(page_live)
      assert html =~ "background-color: rgb("
      assert html =~ "YOU"
    end

    test "has glitch-text CSS class", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")
      assert html =~ "glitch-text"
    end

    test "uses crosshair cursor in visualization area", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")
      assert html =~ "cursor-crosshair"
    end
  end

  # --------------------------------------------------------------------------
  # Mousemove
  # --------------------------------------------------------------------------

  describe "handle_event mousemove" do
    test "updates cursor position", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{"x" => 100, "y" => 200})

      html = render(page_live)
      assert html =~ ">100<"
      assert html =~ ">200<"
    end

    test "handles relative coordinates", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      html = render(page_live)
      assert html =~ "X: 50, Y: 75"
    end

    test "shows cursor in visualization when in_visualization is true", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      html = render(page_live)
      assert html =~ "left: calc(50px - 8px)"
      assert html =~ "top: calc(75px - 8px)"
      assert html =~ "animate-pulse"
    end

    test "hides visualization when not in visualization area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "inVisualization" => false
      })

      html = render(page_live)
      assert html =~ "Move cursor here to visualize position"
    end
  end

  # --------------------------------------------------------------------------
  # Save point
  # --------------------------------------------------------------------------

  describe "handle_event save_point" do
    test "saves point when in visualization area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      page_live
      |> element("#visualization-area")
      |> render_click()

      html = render(page_live)
      assert html =~ "Saved points: 1"
      assert html =~ "Point 1:"
    end

    test "does not save point when outside visualization area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#visualization-area")
      |> render_click()

      html = render(page_live)
      refute html =~ "Saved points:"
    end

    test "saved point appears in visualization with correct style", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      page_live
      |> element("#visualization-area")
      |> render_click()

      html = render(page_live)
      assert html =~ "left: 50px; top: 75px"
      assert html =~ "rounded-full"
    end
  end

  # --------------------------------------------------------------------------
  # Clear points
  # --------------------------------------------------------------------------

  describe "handle_event clear_points" do
    test "clears all saved points", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      page_live
      |> element("#visualization-area")
      |> render_click()

      assert render(page_live) =~ "Saved points: 1"

      page_live
      |> element("button", "CLEAR POINTS")
      |> render_click()

      refute render(page_live) =~ "Saved points:"
    end

    test "clears points from ETS storage", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      point = %{
        x: 50,
        y: 75,
        color: "rgb(100, 255, 100)",
        user_id: "test_user",
        timestamp: DateTime.utc_now()
      }

      CursorPoints.add_point(point)
      assert length(CursorPoints.get_points()) == 1

      page_live
      |> element("button", "CLEAR POINTS")
      |> render_click()

      assert CursorPoints.get_points() == []
    end
  end

  # --------------------------------------------------------------------------
  # handle_info messages
  # --------------------------------------------------------------------------

  describe "handle_info messages" do
    test "handles new point messages from other users", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      new_point = %{
        x: 100,
        y: 150,
        color: "rgb(255, 100, 100)",
        user_id: "other_user",
        timestamp: DateTime.utc_now()
      }

      send(page_live.pid, {:new_point, new_point})

      assert render(page_live) =~ "Saved points: 1"
    end

    test "handles clear points messages from other users", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      new_point = %{
        x: 100,
        y: 150,
        color: "rgb(255, 100, 100)",
        user_id: "other_user",
        timestamp: DateTime.utc_now()
      }

      send(page_live.pid, {:new_point, new_point})
      assert render(page_live) =~ "Saved points: 1"

      send(page_live.pid, {:clear_points, %{user_id: "other_user"}})

      refute render(page_live) =~ "Saved points:"
    end

    test "handles tick messages for timer updates", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      initial_html = render(page_live)
      assert initial_html =~ ~r/\d{2}:\d{2}:\d{2}/

      send(page_live.pid, :tick)

      assert render(page_live) =~ ~r/\d{2}:\d{2}:\d{2}/
    end
  end

  # --------------------------------------------------------------------------
  # System log display
  # --------------------------------------------------------------------------

  describe "system log display" do
    test "shows current position in log", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{"x" => 123, "y" => 456})

      assert render(page_live) =~ "Current position: X:123 Y:456"
    end

    test "shows visualization area coordinates when in area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      assert render(page_live) =~ "Cursor in visualization area: X:50 Y:75"
    end

    test "shows saved points count and details", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      page_live
      |> element("#visualization-area")
      |> render_click()

      html = render(page_live)
      assert html =~ "Saved points: 1"
      assert html =~ "Point 1: X:50 Y:75 by you"
    end

    test "limits displayed points to 5 with overflow message", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      for i <- 1..7 do
        point = %{
          x: i * 10,
          y: i * 15,
          color: "rgb(100, 255, 100)",
          user_id: "other_user",
          timestamp: DateTime.utc_now()
        }

        send(page_live.pid, {:new_point, point})
      end

      html = render(page_live)
      assert html =~ "Saved points: 7"
      assert html =~ "... and 2 more points"
    end

    test "shows auto-clear timer in log", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "Auto-clear scheduled in"
      assert html =~ ~r/\d+h \d+m \d+s/
    end
  end

  # --------------------------------------------------------------------------
  # Accessibility and UX
  # --------------------------------------------------------------------------

  describe "accessibility and UX" do
    test "has proper semantic HTML", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "<h1"
      assert html =~ "<button"
      assert html =~ "text-xs opacity-70"
    end

    test "provides user feedback for interactions", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "Click anywhere in the visualization area to save a point"
      assert html =~ "Move cursor here to visualize position"
    end
  end
end
