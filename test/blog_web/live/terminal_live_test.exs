defmodule BlogWeb.TerminalLiveTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  # The desktop only renders after the boot splash is dismissed; without this
  # every assertion below would be made against the splash screen instead.
  defp desktop(conn, path \\ "/") do
    {:ok, live, _} = live(conn, path)
    render_click(live, "skip_splash")
    live
  end

  # The bare class names "leica-warning-overlay" / "leica-viewer-window" are
  # unreliable needles: the component's <style> block is rendered on every
  # page (it's not conditional on @show_leica), and it defines CSS rules for
  # both of those classes. So a bare substring match "passes" whether or not
  # the element is actually on the page. Matching on the opening tag with its
  # id/class attribute avoids the false positive.
  defp warning_open?(html), do: html =~ ~s(class="leica-warning-overlay")
  defp viewer_open?(html), do: html =~ ~s(id="leica-viewer-window")

  describe "leica viewer: warning -> loading -> viewing" do
    test "the desktop icon opens the size warning, not the viewer", %{conn: conn} do
      live = desktop(conn)

      html = render_click(live, "toggle_leica")

      assert warning_open?(html)
      assert html =~ "Large File Warning"
      refute viewer_open?(html)
    end

    test "confirming the warning starts the download shell with the image hidden", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")

      html = render_click(live, "confirm_leica")

      refute warning_open?(html)
      assert viewer_open?(html)
      assert html =~ "Downloading 110 MB..."
      # The full-res image is in the DOM already so the <img> load event can
      # fire, but it stays invisible until the hook shows it.
      assert html =~ ~s(class="leica-img" style="opacity: 0;")
    end

    test "leica_loaded flips the assign to :viewing without unmounting the viewer", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")

      # Note: nothing in assets/js/hooks/leica_viewer.js actually pushes this
      # event back to the server — the hook only flips local DOM/opacity on
      # image load. So :viewing is currently reachable only by firing the
      # event by hand, as below; this test pins the server-side half of the
      # state machine so a future wiring-up doesn't regress it silently.
      html = render_click(live, "leica_loaded")

      assert viewer_open?(html)
    end

    test "?leica=1 skips the warning and lands straight in the loading state", %{conn: conn} do
      live = desktop(conn, "/?leica=1")

      html = render(live)

      refute warning_open?(html)
      assert viewer_open?(html)
      assert html =~ "Downloading 110 MB..."
    end

    test "closing from any state fully resets it, so reopening starts at the warning again", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")
      render_click(live, "leica_loaded")

      html = render_click(live, "close_leica")
      refute warning_open?(html)
      refute viewer_open?(html)

      # Reopening after a full viewing session goes back to the warning step,
      # not straight to the viewer — there's no "remember this session" state.
      html = render_click(live, "toggle_leica")
      assert warning_open?(html)
      refute viewer_open?(html)
    end

    test "a late leica_loaded arriving after close reopens the viewer", %{conn: conn} do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")
      render_click(live, "close_leica")

      # handle_event("leica_loaded", ...) sets show_leica: :viewing
      # unconditionally, with no check that a viewer is still open. A stale
      # event (e.g. an <img> load that resolves after the user already
      # closed the window) reopens it straight into :viewing.
      html = render_click(live, "leica_loaded")

      assert viewer_open?(html)
    end
  end
end
