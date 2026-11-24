defmodule BlogWeb.SkeeControllerTest do
  use BlogWeb.ConnCase, async: true

  @static Path.join(:code.priv_dir(:blog), "static")
  @dir Path.join(@static, "static/skee")

  # The page names the build folder (a content hash), so new builds get new
  # URLs and no browser keeps running an old game.
  defp build_dir do
    html = File.read!(Path.join(@static, "skee.html"))
    [_, path] = Regex.run(~r|src="(/static/skee/[0-9a-f]{12})/skee.mjs"|, html)
    Path.join(@static, path)
  end

  test "GET /skee serves the packaged game", %{conn: conn} do
    conn = get(conn, ~p"/skee")

    assert html_response(conn, 200) =~ ~s(<canvas id="alley"></canvas>)
    assert conn.resp_body =~ ~r|src="/static/skee/[0-9a-f]{12}/skee.mjs"|
    assert conn.resp_body =~ ~r|href="/static/skee/[0-9a-f]{12}/style.css"|
    assert conn.resp_body =~ ~s(property="og:image" content="https://bobbby.online/static/skee/og.png")
    assert conn.resp_body =~ ~s(property="og:url" content="https://bobbby.online/skee")
  end

  test "the share card the page names is on disk", %{conn: conn} do
    assert File.exists?(Path.join(@dir, "og.png"))
    conn = get(conn, "/static/skee/og.png")
    assert conn.status == 200
    assert [type] = get_resp_header(conn, "content-type")
    assert type =~ "image/png"
  end

  # The modules import their siblings by relative path, and the audio
  # worklet is loaded by name next to skee_audio.mjs; a missing one is a
  # blank canvas or a silent game, and nothing in the server log.
  test "every module the build imports is on disk" do
    dir = build_dir()

    refs =
      for file <- ["skee.mjs", "skee_audio.mjs", "skee_worklet.mjs"],
          ref <- Regex.scan(~r{from "\./([^"]+)"}, File.read!(Path.join(dir, file)), capture: :all_but_first),
          uniq: true,
          do: hd(ref)

    assert "skee_glue.mjs" in refs
    assert "march_runtime.mjs" in refs

    for ref <- ["skee_synth_worklet.mjs", "style.css" | refs] do
      assert File.exists?(Path.join(dir, ref)), "missing #{ref}"
    end
  end

  test "the modules are served as JavaScript", %{conn: conn} do
    rel = Path.relative_to(build_dir(), @static)
    conn = get(conn, "/" <> rel <> "/skee_glue.mjs")

    assert conn.status == 200
    assert [type] = get_resp_header(conn, "content-type")
    assert type =~ "javascript"
  end
end
