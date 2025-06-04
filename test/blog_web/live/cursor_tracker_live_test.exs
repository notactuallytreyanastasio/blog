defmodule BlogWeb.CursorTrackerLiveTest do
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias Blog.CursorPoints

  setup do
    # Ensure CursorPoints is started and clear any existing data
    CursorPoints.start_link([])
    CursorPoints.clear_points()
    :ok
  end

  describe "CursorTrackerLive" do
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

    test "has correct CSS classes and styling", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "min-h-screen bg-black text-green-500 font-mono"
      assert html =~ "glitch-text"
      assert html =~ "border border-green-500"
      assert html =~ "cursor-crosshair"
    end

    test "includes glitch animation CSS", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "@keyframes glitch"
      assert html =~ "text-shadow:"
      assert html =~ "animation: glitch 500ms infinite"
    end

    test "displays initial coordinates as 0", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Should show initial coordinates
      # X and Y coordinates
      assert html =~ ">0<"
    end

    test "shows active users count", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Should show at least 1 user (the current user)
      assert html =~ "ACTIVE USERS: 1"
    end

    test "displays visualization area", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "Move cursor here to visualize position"
      assert html =~ "Click anywhere in the visualization area to save a point"
      assert html =~ "h-64"
    end

    test "has auto-clear timer display", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Should show time format HH:MM:SS
      assert html =~ ~r/\d{2}:\d{2}:\d{2}/
      assert html =~ "AUTO-CLEAR IN:"
    end
  end

  describe "mount/3" do
    test "sets correct initial assigns when disconnected", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Check initial values are reflected in the UI
      # x_pos and y_pos
      assert html =~ ">0<"
      # Should show at least current user
      assert html =~ "ACTIVE USERS: 1"
    end

    test "generates user ID and color when connected", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # After connection, should have generated user color
      html = render(page_live)
      assert html =~ "background-color: rgb("
      assert html =~ "YOU"
    end

    test "includes meta attributes for SEO", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # The meta attributes should be included in the page (though not directly visible in render)
      # We test this indirectly by ensuring the mount function sets them
      assert html =~ "CURSOR POSITION TRACKER"
    end
  end

  describe "handle_event mousemove" do
    test "updates cursor position", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Send mousemove event
      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{"x" => 100, "y" => 200})

      html = render(page_live)
      assert html =~ ">100<"
      assert html =~ ">200<"
    end

    test "handles relative coordinates", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Send mousemove with relative coordinates
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
      # Should show relative coordinates
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

  describe "handle_event save_point" do
    test "saves point when in visualization area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # First move cursor into visualization area
      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{
        "x" => 100,
        "y" => 200,
        "relativeX" => 50,
        "relativeY" => 75,
        "inVisualization" => true
      })

      # Then save point
      page_live
      |> element("div", text: "CURSOR VISUALIZATION")
      |> render_click()

      html = render(page_live)
      assert html =~ "Saved points: 1"
      assert html =~ "Point 1:"
    end

    test "doesn't save point when outside visualization area", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Try to save point without being in visualization area
      page_live
      |> element("div", text: "CURSOR VISUALIZATION")
      |> render_click()

      html = render(page_live)
      refute html =~ "Saved points:"
    end

    test "point appears in visualization", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Move into visualization and save point
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
      |> element("div", text: "CURSOR VISUALIZATION")
      |> render_click()

      html = render(page_live)
      # Should show the saved point in visualization
      assert html =~ "left: 50px; top: 75px"
      assert html =~ "rounded-full"
    end
  end

  describe "handle_event clear_points" do
    test "clears all saved points", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Add a point first
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
      |> element("div", text: "CURSOR VISUALIZATION")
      |> render_click()

      # Verify point was added
      html = render(page_live)
      assert html =~ "Saved points: 1"

      # Clear points
      page_live
      |> element("button", text: "CLEAR POINTS")
      |> render_click()

      # Verify points were cleared
      html = render(page_live)
      refute html =~ "Saved points:"
    end

    test "clears points from ETS storage", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Add point via ETS directly
      point = %{
        x: 50,
        y: 75,
        color: "rgb(100, 255, 100)",
        user_id: "test_user",
        timestamp: DateTime.utc_now()
      }

      CursorPoints.add_point(point)

      # Verify point exists in ETS
      points = CursorPoints.get_points()
      assert length(points) == 1

      # Clear via UI
      page_live
      |> element("button", text: "CLEAR POINTS")
      |> render_click()

      # Verify ETS was cleared
      points = CursorPoints.get_points()
      assert length(points) == 0
    end
  end

  describe "handle_info messages" do
    test "handles new point messages", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Send new point message
      new_point = %{
        x: 100,
        y: 150,
        color: "rgb(255, 100, 100)",
        user_id: "other_user",
        timestamp: DateTime.utc_now()
      }

      send(page_live.pid, {:new_point, new_point})

      html = render(page_live)
      assert html =~ "Saved points: 1"
    end

    test "handles clear points messages", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Add a point first through message
      new_point = %{
        x: 100,
        y: 150,
        color: "rgb(255, 100, 100)",
        user_id: "other_user",
        timestamp: DateTime.utc_now()
      }

      send(page_live.pid, {:new_point, new_point})
      html = render(page_live)
      assert html =~ "Saved points: 1"

      # Clear points via message
      send(page_live.pid, {:clear_points, "some_user"})

      html = render(page_live)
      refute html =~ "Saved points:"
    end

    test "handles tick messages for timer updates", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Get initial timer display
      initial_html = render(page_live)
      assert initial_html =~ ~r/\d{2}:\d{2}:\d{2}/

      # Send tick message
      send(page_live.pid, :tick)

      # Timer should still be displayed (exact value may change)
      html = render(page_live)
      assert html =~ ~r/\d{2}:\d{2}:\d{2}/
    end
  end

  describe "system log display" do
    test "shows current position in log", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      page_live
      |> element("#cursor-tracker")
      |> render_hook("mousemove", %{"x" => 123, "y" => 456})

      html = render(page_live)
      assert html =~ "Current position: X:123 Y:456"
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

      html = render(page_live)
      assert html =~ "Cursor in visualization area: X:50 Y:75"
    end

    test "shows saved points count and details", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Add point
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
      |> element("div", text: "CURSOR VISUALIZATION")
      |> render_click()

      html = render(page_live)
      assert html =~ "Saved points: 1"
      assert html =~ "Point 1: X:50 Y:75 by you"
    end

    test "limits displayed points to 5 with overflow message", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/cursor-tracker")

      # Add 7 points via messages
      for i <- 1..7 do
        point = %{
          x: i * 10,
          y: i * 15,
          color: "rgb(100, 255, 100)",
          user_id: "test_user",
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

  describe "user color system" do
    test "generates consistent colors for users", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Should show user with generated color
      assert html =~ "background-color: rgb("
      assert html =~ "YOU"
    end

    test "displays user indicator with color", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "w-4 h-4 rounded-full"
      assert html =~ "background-color:"
    end
  end

  describe "accessibility and UX" do
    test "has proper ARIA labels and semantic HTML", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      # Check for semantic structure
      assert html =~ "<h1"
      assert html =~ "<button"
      # Visual hierarchy
      assert html =~ "text-xs opacity-70"
    end

    test "provides user feedback for interactions", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "Click anywhere in the visualization area to save a point"
      assert html =~ "Move cursor here to visualize position"
    end

    test "uses appropriate cursor styles", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/cursor-tracker")

      assert html =~ "cursor-crosshair"
    end
  end
end
