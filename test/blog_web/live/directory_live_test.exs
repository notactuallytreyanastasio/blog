defmodule BlogWeb.DirectoryLiveTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders the directory", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/directory")
    assert html =~ "Everything running on one box"
    assert html =~ "Technical Museum"
    assert html =~ "lumines.bobbby.online"
    assert html =~ "Loose Ends"
  end

  test "serves an open graph card", %{conn: conn} do
    html = conn |> get("/directory") |> html_response(200)

    assert html =~ ~s(<title>The bobbby.online Directory)
    assert html =~ ~s(property="og:title" content="The bobbby.online Directory")
    assert html =~ ~s(property="og:image" content="https://www.bobbby.online/images/og-directory.png")
    assert html =~ ~s(name="twitter:card" content="summary_large_image")
    assert html =~ ~s(name="twitter:image" content="https://www.bobbby.online/images/og-directory.png")
  end

  test "the open graph image exists at the advertised size" do
    path = Path.join(:code.priv_dir(:blog), "static/images/og-directory.png")
    assert File.exists?(path)

    # PNG IHDR: 8-byte signature, 4-byte length, "IHDR", then width and height.
    <<_::binary-size(16), width::32, height::32, _rest::binary>> = File.read!(path)
    assert {width, height} == {1200, 630}
  end
end
