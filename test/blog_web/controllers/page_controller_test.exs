defmodule BlogWeb.PageControllerTest do
  use BlogWeb.ConnCase

  # The root path "/" is served by BlogWeb.TerminalLive (a LiveView), not by the
  # default Phoenix PageController/home template that this test originally covered.
  # On a plain HTTP GET the LiveView is not yet connected, so it renders the
  # ":desktop" boot phase (the splash screen only appears once the socket connects).
  # We assert on stable, unconditional markup from that dead render.
  test "GET / renders the Terminal desktop", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    # Menu bar items are always present in the desktop render.
    assert body =~ "menu-item"
    assert body =~ "File"

    # The Museum window is shown by default (show_museum: true) with this title.
    assert body =~ "Technical Museum"

    # The chat toggle button is always rendered in the desktop view.
    assert body =~ "Chat Room"
  end
end
