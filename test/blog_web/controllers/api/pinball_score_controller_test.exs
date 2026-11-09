defmodule BlogWeb.Api.PinballScoreControllerTest do
  use BlogWeb.ConnCase, async: true
  @moduletag :db

  defp post_score(conn, attrs, ip) do
    conn
    |> put_req_header("x-forwarded-for", ip)
    |> put_req_header("content-type", "application/json")
    |> post("/api/pinball/scores", Jason.encode!(attrs))
  end

  @good %{"initials" => "abc", "score" => 120, "stage" => 3, "lines" => 3, "badges" => ["cherry", "bell"]}

  test "a cash-out posts, comes back upper-cased with its id, and tops the board", %{conn: conn} do
    conn = post_score(conn, @good, "10.0.0.1")
    body = json_response(conn, 201)
    assert [%{"initials" => "ABC", "score" => 120, "badges" => ["cherry", "bell"], "id" => id}] = body["scores"]
    assert body["id"] == id
  end

  test "the board is the top 10, highest first", %{conn: conn} do
    for {s, i} <- Enum.with_index([5, 50, 500, 40, 30, 20, 10, 9, 8, 7, 6]) do
      {:ok, _} = Blog.Pinball.submit(%{@good | "score" => s, "initials" => "Z" <> <<?A + i>> <> "Z"})
    end

    scores = json_response(get(conn, "/api/pinball/scores"), 200)["scores"]
    assert length(scores) == 10
    assert Enum.map(scores, & &1["score"]) == [500, 50, 40, 30, 20, 10, 9, 8, 7, 6]
  end

  test "bad shapes are refused with a reason", %{conn: conn} do
    for {bad, why} <- [
          {%{@good | "initials" => "A1"}, "initials"},
          {%{@good | "score" => 0}, "score"},
          {%{@good | "score" => Blog.Pinball.Score.max_score() + 1}, "score"},
          {%{@good | "lines" => 2}, "lines"},
          {%{@good | "badges" => ["unicorn"]}, "badges"},
          {%{@good | "badges" => ["bell", "bell"]}, "badges"}
        ] do
      body = json_response(post_score(conn, bad, "10.1.#{:rand.uniform(250)}.#{:rand.uniform(250)}"), 422)
      assert body["error"] =~ why
    end
  end

  test "one address gets five a minute", %{conn: conn} do
    ip = "10.2.#{:rand.uniform(250)}.#{:rand.uniform(250)}"
    codes = for _ <- 1..6, do: post_score(conn, @good, ip).status
    assert codes == [201, 201, 201, 201, 201, 429]
  end
end
