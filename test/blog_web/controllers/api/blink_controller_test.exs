defmodule BlogWeb.Api.BlinkControllerTest do
  use BlogWeb.ConnCase, async: true

  @token Application.compile_env(:blog, :blinks_api_token)

  defp authed(conn), do: put_req_header(conn, "x-blinks-token", @token)

  describe "POST /api/blinks" do
    test "rejects requests without a token", %{conn: conn} do
      conn = post(conn, ~p"/api/blinks", %{"url" => "https://example.com"})
      assert json_response(conn, 401)
    end

    test "saves a link with normalized tags", %{conn: conn} do
      conn =
        conn
        |> authed()
        |> post(~p"/api/blinks", %{
          "url" => "https://example.com/a",
          "title" => "Example",
          "tags" => ["Elixir", " web ", "elixir", ""]
        })

      assert %{"status" => "ok", "blink" => blink} = json_response(conn, 200)
      assert blink["url"] == "https://example.com/a"
      assert blink["tags"] == ["elixir", "web"]
    end

    test "merges tags when the same url is saved again", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://example.com/b", "tags" => ["one"]})

      conn =
        post(authed(conn), ~p"/api/blinks", %{
          "url" => "https://example.com/b",
          "tags" => ["two"]
        })

      assert %{"blink" => %{"tags" => ["one", "two"]}} = json_response(conn, 200)
    end

    test "rejects a missing url", %{conn: conn} do
      conn = post(authed(conn), ~p"/api/blinks", %{"tags" => ["x"]})
      assert %{"errors" => %{"url" => _}} = json_response(conn, 422)
    end
  end

  describe "GET /api/blinks/tags" do
    test "returns tag counts sorted by usage", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://t.co/1", "tags" => ["a", "b"]})
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://t.co/2", "tags" => ["a"]})

      conn = get(authed(conn), ~p"/api/blinks/tags")

      assert %{"tags" => [%{"name" => "a", "count" => 2}, %{"name" => "b", "count" => 1}]} =
               json_response(conn, 200)
    end
  end

  describe "descriptions and search" do
    test "saves a description and finds it via full-text search", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://example.com/ft",
        "title" => "Some page",
        "description" => "long treatise about woodworking joints",
        "tags" => ["crafts"]
      })

      conn1 = get(authed(conn), ~p"/api/blinks", q: "woodworking")

      assert %{"blinks" => [%{"url" => "https://example.com/ft", "description" => desc}]} =
               json_response(conn1, 200)

      assert desc =~ "woodworking"
    end

    test "re-saving keeps the old description unless a new one is given", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://example.com/keep",
        "description" => "original notes"
      })

      conn1 = post(authed(conn), ~p"/api/blinks", %{"url" => "https://example.com/keep"})
      assert %{"blink" => %{"description" => "original notes"}} = json_response(conn1, 200)

      conn2 =
        post(authed(conn), ~p"/api/blinks", %{
          "url" => "https://example.com/keep",
          "description" => "better notes"
        })

      assert %{"blink" => %{"description" => "better notes"}} = json_response(conn2, 200)
    end

    test "filters by multiple tags as a union (OR)", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://m.co/1", "tags" => ["a"]})
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://m.co/2", "tags" => ["b"]})
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://m.co/3", "tags" => ["c"]})

      conn1 = get(authed(conn), ~p"/api/blinks", tags: "a,b")
      assert %{"blinks" => blinks} = json_response(conn1, 200)
      assert Enum.map(blinks, & &1["url"]) |> Enum.sort() == ["https://m.co/1", "https://m.co/2"]
    end
  end

  describe "lookup, export, rss" do
    test "lookup returns the blink for a saved url, null otherwise", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{"url" => "https://look.me/up", "tags" => ["x"]})

      conn1 = get(authed(conn), ~p"/api/blinks/lookup", url: "https://look.me/up")
      assert %{"blink" => %{"tags" => ["x"]}} = json_response(conn1, 200)

      conn2 = get(authed(conn), ~p"/api/blinks/lookup", url: "https://never.seen")
      assert %{"blink" => nil} = json_response(conn2, 200)
    end

    test "export produces json and netscape html, and accepts ?token=", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://exp.ort/1",
        "title" => "Exported",
        "description" => "notes here",
        "tags" => ["keep"]
      })

      conn1 = get(conn, ~p"/api/blinks/export", token: @token)
      assert %{"blinks" => [%{"url" => "https://exp.ort/1"}]} = json_response(conn1, 200)

      conn2 = get(conn, ~p"/api/blinks/export", format: "html", token: @token)
      body = response(conn2, 200)
      assert body =~ "NETSCAPE-Bookmark-file-1"
      assert body =~ ~s(HREF="https://exp.ort/1")
      assert body =~ ~s(TAGS="keep")
      assert body =~ "<DD>notes here"
    end

    test "rss feed is public and filters by tag", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://feed.me/a",
        "title" => "Feed item",
        "tags" => ["radar"]
      })

      post(authed(conn), ~p"/api/blinks", %{"url" => "https://feed.me/b", "tags" => ["other"]})

      body = conn |> get("/blinks.rss?tags=radar") |> response(200)
      assert body =~ "<rss"
      assert body =~ "https://feed.me/a"
      refute body =~ "https://feed.me/b"
    end
  end

  describe "similar" do
    test "falls back to tag overlap + trigram without embeddings", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://sim.co/base",
        "title" => "Elixir deployment guide",
        "tags" => ["elixir", "deploy"]
      })

      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://sim.co/close",
        "title" => "Elixir deployment tips",
        "tags" => ["elixir"]
      })

      post(authed(conn), ~p"/api/blinks", %{"url" => "https://sim.co/far", "title" => "Cooking"})

      base = Blog.Blinks.get_by_url("https://sim.co/base")
      [first | _] = Blog.Blinks.list_similar(base, 5)
      assert first.url == "https://sim.co/close"
    end
  end

  describe "GET /api/blinks" do
    test "lists and filters by tag and query", %{conn: conn} do
      post(authed(conn), ~p"/api/blinks", %{
        "url" => "https://elixir-lang.org",
        "title" => "Elixir",
        "tags" => ["lang"]
      })

      post(authed(conn), ~p"/api/blinks", %{"url" => "https://rust-lang.org", "tags" => ["rust"]})

      conn1 = get(authed(conn), ~p"/api/blinks", tag: "rust")
      assert %{"blinks" => [%{"url" => "https://rust-lang.org"}]} = json_response(conn1, 200)

      conn2 = get(authed(conn), ~p"/api/blinks", q: "elixir")
      assert %{"blinks" => [%{"url" => "https://elixir-lang.org"}]} = json_response(conn2, 200)
    end
  end
end
