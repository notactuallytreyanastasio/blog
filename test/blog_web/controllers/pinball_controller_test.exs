defmodule BlogWeb.PinballControllerTest do
  use BlogWeb.ConnCase, async: true

  @dir Path.join(:code.priv_dir(:blog), "static/static/pinball")

  test "GET /pinball serves the packaged table", %{conn: conn} do
    conn = get(conn, ~p"/pinball")

    assert html_response(conn, 200) =~ ~s(<canvas id="table"></canvas>)
    assert conn.resp_body =~ ~s(src="/static/pinball/spin.mjs")
    assert conn.resp_body =~ ~s(property="og:image" content="https://bobbby.online/static/pinball/og.png")
  end

  test "the share card the page names is on disk", %{conn: conn} do
    assert File.exists?(Path.join(@dir, "og.png"))
    conn = get(conn, "/static/pinball/og.png")
    assert conn.status == 200
    assert [type] = get_resp_header(conn, "content-type")
    assert type =~ "image/png"
  end

  # spin.mjs imports its siblings by relative path; a missing one is a blank
  # canvas in the browser and nothing in the server log.
  test "every module spin.mjs imports is on disk" do
    js = File.read!(Path.join(@dir, "spin.mjs"))

    refs = Regex.scan(~r{from "\./([^"]+)"}, js, capture: :all_but_first) |> List.flatten()
    assert "spin_glue.mjs" in refs

    for ref <- refs do
      assert File.exists?(Path.join(@dir, ref)), "missing #{ref}"
    end
  end

  test "the modules are served as JavaScript", %{conn: conn} do
    conn = get(conn, "/static/pinball/spin_glue.mjs")

    assert conn.status == 200
    assert [type] = get_resp_header(conn, "content-type")
    assert type =~ "javascript"
  end
end
