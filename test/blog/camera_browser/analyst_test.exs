defmodule Blog.CameraBrowser.AnalystTest do
  use Blog.DataCase, async: false

  alias Blog.CameraBrowser.{Analyst, Listing}
  alias Blog.Repo

  @now DateTime.utc_now() |> DateTime.truncate(:second)

  setup do
    Application.put_env(:blog, :camera_analyst,
      api_key: "test",
      model: "gpt-test-mini",
      req_options: [plug: {Req.Test, Analyst}, retry: false]
    )

    on_exit(fn -> Application.delete_env(:blog, :camera_analyst) end)
    :ok
  end

  defp listing!(over) do
    %Listing{}
    |> Listing.changeset(
      Map.merge(
        %{
          posting_id: System.unique_integer([:positive]),
          area: "newyork",
          subarea: "brk",
          title: "Leica M6 TTL",
          price_cents: 330_000,
          url: "https://www.craigslist.org/view/d/x/y",
          body: "CLA by YYE, works perfectly",
          attrs: %{"condition" => "excellent"},
          image_ids: ["a"],
          first_seen_at: @now,
          last_seen_at: @now,
          detail_fetched_at: @now
        },
        over
      )
    )
    |> Repo.insert!()
  end

  test "stores a normalized analysis from a structured-output reply" do
    Req.Test.stub(Analyst, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      req = Jason.decode!(body)
      assert req["model"] == "gpt-test-mini"
      assert req["response_format"]["json_schema"]["strict"] == true
      assert hd(tl(req["messages"]))["content"] =~ "Leica M6 TTL"

      Req.Test.json(conn, %{
        "model" => "gpt-test-mini-2026",
        "choices" => [
          %{
            "message" => %{
              "content" =>
                Jason.encode!(%{
                  "quick_take" => " A serviced M6, worth a look. ",
                  "rarity" => 7,
                  "price_take" => "high",
                  "price_note" => "M6 TTLs go for $2.5-3k",
                  "commentary" => "Ask for CLA paperwork.",
                  "fun_features" => ["TTL flash metering", ""],
                  "facts" => ["Made 1998-2002"]
                })
            }
          }
        ]
      })
    end)

    l = listing!(%{})
    assert {:ok, %Listing{analysis: a, analyzed_at: %DateTime{}}} = Analyst.analyze(l)
    assert a["quick_take"] == "A serviced M6, worth a look."
    assert a["rarity"] == 5
    assert a["price_take"] == "high"
    assert a["fun_features"] == ["TTL flash metering"]
    assert a["model"] == "gpt-test-mini-2026"
    assert Analyst.stars(a) == "★★★★★"
  end

  test "analyze_missing only touches fetched, unanalyzed, open listings and records errors" do
    Req.Test.stub(Analyst, fn conn -> conn |> Plug.Conn.put_status(500) |> Req.Test.json(%{"error" => "boom"}) end)

    todo = listing!(%{})
    _no_body = listing!(%{detail_fetched_at: nil})
    _done = listing!(%{analyzed_at: @now, analysis: %{"rarity" => 2}})
    _closed = listing!(%{closed_at: @now})

    assert Analyst.analyze_missing(10) == 0
    assert %{analysis_error: err, analyzed_at: nil} = Repo.get!(Listing, todo.id)
    assert err =~ "500"
  end

  test "is a no-op when not configured" do
    Application.delete_env(:blog, :camera_analyst)
    listing!(%{})
    assert Analyst.analyze_missing(10) == 0
  end
end
