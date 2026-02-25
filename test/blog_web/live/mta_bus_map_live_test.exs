defmodule BlogWeb.MtaBusMapLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders the page with expected elements", %{conn: conn} do
      {:ok, view, html} = live(conn, "/mta-bus-map")

      assert html =~ "MTA Bus Map - Live Transit Tracker"
      assert html =~ "CHOOSE BUSES"
      assert has_element?(view, "#mta-bus-map")
    end

    test "shows default selected routes count in status bar", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/mta-bus-map")

      assert html =~ "Routes: 4"
    end

    test "shows Manhattan as the default borough", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/mta-bus-map")

      assert html =~ "Manhattan MTA Bus Tracker"
      assert html =~ "Borough: Manhattan"
    end
  end

  describe "select_borough" do
    test "switches to Brooklyn", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      html = render_click(view, "select_borough", %{"borough" => "brooklyn"})

      assert html =~ "Brooklyn MTA Bus Tracker"
      assert html =~ "Borough: Brooklyn"
    end

    test "switches to Queens", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      html = render_click(view, "select_borough", %{"borough" => "queens"})

      assert html =~ "Queens MTA Bus Tracker"
      assert html =~ "Borough: Queens"
    end

    test "switches to All Boroughs", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      html = render_click(view, "select_borough", %{"borough" => "all"})

      assert html =~ "All Boroughs MTA Bus Tracker"
      assert html =~ "Borough: All Boroughs"
    end
  end

  describe "toggle_modal" do
    test "opens and closes route selection modal", %{conn: conn} do
      {:ok, view, html} = live(conn, "/mta-bus-map")

      refute html =~ "Select Bus Routes"

      html = render_click(view, "toggle_modal", %{})
      assert html =~ "Select Bus Routes"

      html = render_click(view, "toggle_modal", %{})
      refute html =~ "Select Bus Routes"
    end
  end

  describe "toggle_route" do
    test "adds a route when toggled on", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      # M42 is not in the initial selection
      render_click(view, "toggle_route", %{"route" => "M42"})
      html = render(view)

      # Should now have 5 routes (4 initial + 1 added)
      assert html =~ "Routes: 5"
    end

    test "removes a route when toggled off", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      # M21 is in the initial selection
      render_click(view, "toggle_route", %{"route" => "M21"})
      html = render(view)

      # Should now have 3 routes (4 initial - 1 removed)
      assert html =~ "Routes: 3"
    end
  end

  describe "UI elements" do
    test "renders borough selector buttons", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      assert has_element?(view, "button[phx-value-borough='manhattan']")
      assert has_element?(view, "button[phx-value-borough='brooklyn']")
      assert has_element?(view, "button[phx-value-borough='queens']")
      assert has_element?(view, "button[phx-value-borough='all']")
    end

    test "renders fetch/update button", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      assert has_element?(view, "button[phx-click='fetch_buses']")
    end

    test "renders the map container with phx-hook", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/mta-bus-map")

      assert has_element?(view, "#mta-bus-map[phx-hook='MtaBusMap']")
    end

    test "renders WinXP window chrome", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/mta-bus-map")

      assert html =~ "os-window-winxp"
      assert html =~ "os-titlebar"
      assert html =~ "os-menubar"
      assert html =~ "os-statusbar"
    end
  end
end
