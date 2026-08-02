defmodule BlogWeb.PhishLabLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders the laboratory chrome", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/phish_lab")

      assert html =~ "Phish Lab"
      assert html =~ "CHART-O-MATIC.EXE"
      assert html =~ "ANOMALY.LOG"
      assert html =~ "About This Laboratory"
    end

    test "defaults to the shows dataset with date × avg song length", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      assert has_element?(view, ~s(#plab-ds option[value="shows"][selected]))
      assert has_element?(view, ~s(#plab-x option[value="d"][selected]))
      assert has_element?(view, ~s(#plab-y option[value="avg_song"][selected]))
    end
  end

  describe "chart config" do
    test "switching dataset resets axes to that dataset's defaults", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      view
      |> element("form[phx-change=set-config]")
      |> render_change(%{"ds" => "songs", "chart" => "scatter", "x" => "d", "y" => "avg_song"})

      assert has_element?(view, ~s(#plab-x option[value="plays"][selected]))
      assert has_element?(view, ~s(#plab-y option[value="avg"][selected]))
    end

    test "presets apply a full config", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      view
      |> element(~s(button[phx-value-name="anomaly-scan"]))
      |> render_click()

      assert has_element?(view, ~s(#plab-ds option[value="perfs"][selected]))
      assert has_element?(view, ~s(#plab-y option[value="z"][selected]))
    end

    test "histogram mode hides the Y axis picker", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      view
      |> element("form[phx-change=set-config]")
      |> render_change(%{"ds" => "shows", "chart" => "hist", "x" => "dur"})

      refute has_element?(view, "#plab-y")
    end
  end

  describe "leaderboards" do
    test "picking a board swaps the entry list", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      html =
        view
        |> element("form[phx-change=set-lb]")
        |> render_change(%{"lb" => "songs_bustouts"})

      assert html =~ "Sabotage"
    end

    test "clicking an entry jumps the chart to that board's preset", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      view
      |> element("button.plab-lb-row", "Tweezer Reprise")
      |> render_click()

      assert has_element?(view, ~s(#plab-ds option[value="perfs"][selected]))
      assert has_element?(view, ~s(#plab-y option[value="z"][selected]))
    end
  end

  describe "inspector" do
    test "inspect event opens the properties window with the scorecard", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      html =
        view
        |> element("#plab-chart")
        |> render_hook("inspect", %{"ds" => "shows", "key" => "1997-11-17"})

      assert html =~ "McNichols"
      assert html =~ "PJJ SCORECARD"
      assert html =~ "phish.in/1997-11-17"
    end

    test "inspecting a performance uses its numeric index", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      html =
        view
        |> element("#plab-chart")
        |> render_hook("inspect", %{"ds" => "perfs", "key" => 0})

      assert html =~ "1993-02-03"
    end

    test "close-inspect clears the panel", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/phish_lab")

      view
      |> element("#plab-chart")
      |> render_hook("inspect", %{"ds" => "songs", "key" => "Tweezer"})

      html =
        view
        |> element("button[phx-click=close-inspect]")
        |> render_click()

      assert html =~ "Click a point on the chart"
    end
  end
end
