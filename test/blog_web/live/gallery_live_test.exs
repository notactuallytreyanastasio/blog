defmodule BlogWeb.GalleryLiveTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  # The gallery process is disabled in test (config/test.exs), so these cover
  # the unconfigured path — the page has to stand up without an album rather
  # than crash the request.

  test "renders the desktop with an empty album window", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/gallery")

    assert html =~ "gal-desktop"
    assert html =~ "0 items"
    assert html =~ "gal-albumwin"
  end

  test "tells you which env var is missing when no album is connected", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/gallery")

    assert html =~ "No album connected"
    assert html =~ "ICLOUD_ALBUM_TOKEN"
  end

  test "the viewer window ships in the markup so it can open without a round trip", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/gallery")

    assert html =~ ~s(id="gal-viewer")
    assert html =~ ~s(phx-hook="GalleryAmbient")
    # The hook reads its deck from here.
    assert html =~ "data-photos"
  end

  test "Slideshow is disabled with nothing to show", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/gallery")

    assert html =~ ~r/<button[^>]*disabled[^>]*>\s*Slideshow/s
  end
end
