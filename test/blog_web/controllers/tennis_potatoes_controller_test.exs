defmodule BlogWeb.TennisPotatoesControllerTest do
  use BlogWeb.ConnCase, async: true

  test "GET /tennis-potatoes serves the packaged page", %{conn: conn} do
    conn = get(conn, ~p"/tennis-potatoes")

    assert html_response(conn, 200) =~ ~s(<div id="app"></div>)
    assert conn.resp_body =~ "/static/tennis-potatoes/assets/"
  end

  test "every asset the page references is on disk" do
    html = File.read!(Path.join(:code.priv_dir(:blog), "static/tennis_potatoes.html"))

    refs = Regex.scan(~r{/static/tennis-potatoes/assets/[^"]+}, html) |> List.flatten()
    assert refs != []

    for ref <- refs do
      assert File.exists?(Path.join(:code.priv_dir(:blog), "static" <> ref)), "missing #{ref}"
    end
  end
end
