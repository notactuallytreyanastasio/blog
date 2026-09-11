defmodule BlogWeb.Api.PushWebTest do
  use BlogWeb.ConnCase

  alias Blog.Push

  @sub %{
    "endpoint" => "https://web.push.apple.com/QAbc123",
    "keys" => %{
      "p256dh" => "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4",
      "auth" => "BTBZMqHH6r4Tts7J_aSIgg"
    }
  }

  test "subscribe, re-subscribe (upsert) and unsubscribe", %{conn: conn} do
    conn1 = post(conn, "/api/push/web", %{"subscription" => @sub, "tags" => ["Film", " film "]})
    assert json_response(conn1, 200)["status"] == "ok"
    assert [%{followed_tags: ["film"]}] = Push.list_web_subscriptions()

    conn2 = post(conn, "/api/push/web", %{"subscription" => @sub})
    assert json_response(conn2, 200)["status"] == "ok"
    assert length(Push.list_web_subscriptions()) == 1

    conn3 = delete(conn, "/api/push/web", %{"endpoint" => @sub["endpoint"]})
    assert json_response(conn3, 200)["status"] == "ok"
    assert Push.list_web_subscriptions() == []
  end

  test "rejects junk", %{conn: conn} do
    assert json_response(post(conn, "/api/push/web", %{}), 400)
    bad = put_in(@sub, ["endpoint"], "http://not-https")
    assert json_response(post(conn, "/api/push/web", %{"subscription" => bad}), 422)
  end

  test "test push for an unknown endpoint is a 404", %{conn: conn} do
    assert json_response(post(conn, "/api/push/web/test", %{"endpoint" => "https://nope"}), 404)
  end

  test "serves the service worker at the root with a /blinks scope header", %{conn: conn} do
    conn = get(conn, "/blinks-sw.js")
    assert response(conn, 200) =~ "addEventListener(\"push\""
    assert get_resp_header(conn, "content-type") |> List.first() =~ "javascript"
    assert get_resp_header(conn, "service-worker-allowed") == ["/blinks"]
  end

  test "the manifest and icons are reachable", %{conn: conn} do
    assert json_response(get(conn, "/static/blinks-pwa/manifest.json"), 200)["start_url"] == "/blinks"
    assert response(get(conn, "/static/blinks-pwa/icon-180.png"), 200)
  end

  test "blinks page carries the PWA tags and the push hook", %{conn: conn} do
    html = conn |> get("/blinks") |> html_response(200)
    assert html =~ ~s(rel="manifest" href="/static/blinks-pwa/manifest.json")
    assert html =~ ~s(rel="apple-touch-icon" href="/static/blinks-pwa/icon-180.png")
    assert html =~ ~s(apple-mobile-web-app-capable)
    assert html =~ ~s(phx-hook="BlinksPush")
  end
end
