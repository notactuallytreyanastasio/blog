defmodule BlogWeb.GalleryControllerTest do
  use BlogWeb.ConnCase

  # The gallery process is off in test, so no guid resolves. That is exactly
  # the case worth pinning: the route must answer rather than raise when the
  # album is unavailable, because these urls sit in <img> tags on a live page.

  describe "GET /gallery/img/:guid/:size" do
    test "404s for a guid the album does not have", %{conn: conn} do
      conn = get(conn, ~p"/gallery/img/#{"no-such-guid"}/display")

      assert response(conn, 404)
      assert get_resp_header(conn, "location") == []
    end

    test "answers for any size segment without raising", %{conn: conn} do
      for size <- ["thumb", "display", "banana"] do
        conn = get(conn, ~p"/gallery/img/#{"no-such-guid"}/#{size}")
        assert response(conn, 404)
      end
    end
  end
end
