defmodule BlogWeb.CameraBrowserLiveTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Blog.CameraBrowser
  alias Blog.CameraBrowser.Listing
  alias Blog.Repo

  @now DateTime.utc_now() |> DateTime.truncate(:second)

  defp listing!(attrs) do
    base = %{
      posting_id: System.unique_integer([:positive]),
      area: "newyork",
      subarea: "brk",
      location: "Brooklyn",
      neighborhood: "Greenpoint",
      title: "Nikon FM2 with 50mm",
      price_cents: 30_000,
      url: "https://www.craigslist.org/view/d/x/abc",
      image_ids: ["00a0a_abc_0CI0qt"],
      body: "Works great, film tested, meter accurate.",
      attrs: %{"condition" => "excellent"},
      queries: ["nikon fm2"],
      tags: ["film", "working", "nikon fm2"],
      score: 100,
      first_seen_at: @now,
      last_seen_at: @now,
      posted_at: @now,
      renewed_at: @now
    }

    %Listing{} |> Listing.changeset(Map.merge(base, attrs)) |> Repo.insert!()
  end

  test "renders the table with Finder chrome, tabs and a row", %{conn: conn} do
    l = listing!(%{})
    {:ok, view, html} = live(conn, "/cameras")

    assert html =~ "Camera Browser"
    assert html =~ "SF / East Bay"
    assert html =~ "Brooklyn"
    assert html =~ "$300"
    assert has_element?(view, "#l-#{l.id}")
  end

  test "filters by city and facets through the URL, with live counts", %{conn: conn} do
    bk = listing!(%{subarea: "brk", title: "Brooklyn Leica M6"})
    mn = listing!(%{subarea: "mnh", title: "Manhattan Nikon F3", tags: ["film", "hopeful"]})

    {:ok, view, _} = live(conn, "/cameras?city=mnh")
    refute has_element?(view, "#l-#{bk.id}")
    assert has_element?(view, "#l-#{mn.id}")

    # pick a tag facet from the rail
    view |> element(".cam-rail a.cam-fv", "hopeful") |> render_click()
    assert_patch(view)
    assert has_element?(view, "#l-#{mn.id}")
    assert has_element?(view, ".cam-rail a.cam-fv.on", "hopeful")

    # facets from the URL, AND across facets
    {:ok, view, _} = live(conn, "/cameras?tags=working&brand=leica")
    assert has_element?(view, "#l-#{bk.id}")
    refute has_element?(view, "#l-#{mn.id}")

    # the brand facet still lists nikon (counted without its own selection)
    assert has_element?(view, ".cam-rail a.cam-fv", "nikon")
  end

  test "Seattle and Portland are tabs that filter by area", %{conn: conn} do
    sea = listing!(%{area: "seattle", subarea: "see", title: "Seattle Mamiya 7"})
    pdx = listing!(%{area: "portland", subarea: "mlt", title: "Portland Contax T2"})
    ny = listing!(%{area: "newyork", subarea: "brk", title: "Brooklyn thing"})

    {:ok, view, html} = live(conn, "/cameras?city=sea")
    assert html =~ "Seattle" and html =~ "Portland"
    assert has_element?(view, "#l-#{sea.id}")
    refute has_element?(view, "#l-#{pdx.id}") or has_element?(view, "#l-#{ny.id}")

    {:ok, view, _} = live(conn, "/cameras?city=clk")
    refute has_element?(view, "#l-#{pdx.id}")
    {:ok, view, html} = live(conn, "/cameras?city=pdx")
    assert has_element?(view, "#l-#{pdx.id}")
    assert html =~ "Vancouver WA"
  end

  test "typing in the search box narrows the table live", %{conn: conn} do
    a = listing!(%{title: "Hasselblad 500cm"})
    b = listing!(%{title: "Pentax K1000"})
    {:ok, view, _} = live(conn, "/cameras")

    view |> form("form.cam-form", %{"q" => "hassel", "status" => "open", "sort" => "best"}) |> render_change()
    assert_patch(view)
    assert has_element?(view, "#l-#{a.id}")
    refute has_element?(view, "#l-#{b.id}")
    assert has_element?(view, ".cam-rail-head", "1 of 1")
  end

  test "opening a row shows the lightbox with body and attributes", %{conn: conn} do
    l = listing!(%{})
    {:ok, view, _} = live(conn, "/cameras")

    view |> element("#l-#{l.id}") |> render_click()
    assert_patch(view, "/cameras?open=#{l.id}")
    html = render(view)
    assert html =~ "film tested"
    assert html =~ "excellent"
    assert html =~ "1200x900.jpg"

    render_keydown(view, "keydown", %{"key" => "Escape"})
    refute has_element?(view, "#lb-#{l.id}")
  end

  # Writes are gated by the blinks API token when one is configured.
  defp admin_qs do
    case Application.get_env(:blog, :blinks_api_token) do
      t when is_binary(t) and t != "" -> "?key=#{t}"
      _ -> "?"
    end
  end

  test "star and hide need the key and then persist", %{conn: conn} do
    l = listing!(%{})

    if Application.get_env(:blog, :blinks_api_token) not in [nil, ""] do
      {:ok, view, _} = live(conn, "/cameras")
      refute has_element?(view, "#l-#{l.id} button[title=star]")
    end

    {:ok, view, _} = live(conn, "/cameras#{admin_qs()}")

    view |> element("#l-#{l.id} button[title=star]") |> render_click()
    assert %{starred_at: %DateTime{}} = CameraBrowser.get_listing!(l.id)

    view |> element("#l-#{l.id} button[title=hide]") |> render_click()
    assert %{hidden_at: %DateTime{}} = CameraBrowser.get_listing!(l.id)

    {:ok, view, _} = live(conn, "/cameras")
    refute has_element?(view, "#l-#{l.id}")
    {:ok, view, _} = live(conn, "/cameras#{admin_qs()}&hidden=1")
    assert has_element?(view, "#l-#{l.id}")
  end

  test "anything mentioning digital is kept off the page", %{conn: conn} do
    t = listing!(%{title: "Canon Digital Rebel"})
    b = listing!(%{title: "Nikon F3", body: "Comes with a digital light meter"})
    ok = listing!(%{title: "Nikon F3", body: "Film only"})
    {:ok, view, _} = live(conn, "/cameras?status=all")
    refute has_element?(view, "#l-#{t.id}")
    refute has_element?(view, "#l-#{b.id}")
    assert has_element?(view, "#l-#{ok.id}")
  end

  test "re-posts with the same title and price collapse into one row", %{conn: conn} do
    a = listing!(%{title: "Rare camera Edixa with50mm lens", price_cents: 20_000})
    b = listing!(%{title: "Rare camera Edixa with50mm lens", price_cents: 20_000})
    c = listing!(%{title: "Rare camera Edixa with50mm lens", price_cents: 20_000})
    {:ok, view, html} = live(conn, "/cameras")
    assert Enum.count([a, b, c], &has_element?(view, "#l-#{&1.id}")) == 1
    assert html =~ "×3"
  end

  test "gone listings only show under status=closed", %{conn: conn} do
    l = listing!(%{closed_at: @now, closed_reason: "deleted"})
    {:ok, view, _} = live(conn, "/cameras")
    refute has_element?(view, "#l-#{l.id}")
    {:ok, view, html} = live(conn, "/cameras?status=closed")
    assert has_element?(view, "#l-#{l.id}")
    assert html =~ "gone (deleted)"
  end

  test "serves an open graph card", %{conn: conn} do
    html = conn |> get("/cameras") |> html_response(200)
    assert html =~ ~s(<title>Camera Browser)
    assert html =~ ~s(property="og:title" content="Camera Browser — film cameras live on craigslist")
    assert html =~ ~s(property="og:image" content="https://www.bobbby.online/images/og-cameras.png?v=2")
    assert html =~ ~s(name="twitter:card" content="summary_large_image")
  end

  test "the open graph image exists at the advertised size" do
    path = Path.join(:code.priv_dir(:blog), "static/images/og-cameras.png")
    assert File.exists?(path)
    assert <<0x89, "PNG", _::binary-12, 1200::32, 630::32, _::binary>> = File.read!(path)
  end

  describe "classifier" do
    test "tags working film cameras and accessories" do
      %{tags: tags, score: score} =
        CameraBrowser.classify("Leica M6 body", "Works perfectly, just CLA'd. Film tested.", %{}, ["leica m6"], ["a", "b", "c", "d"])

      assert "film" in tags and "working" in tags and "leica m6" in tags
      assert score > 90

      %{tags: tags} = CameraBrowser.classify("Nikon camera strap", "", %{}, ["film camera"], ["a"])
      assert "accessory" in tags

      %{tags: tags} = CameraBrowser.classify("Rare camera 35mm Edixa prismat ltl with50mm 1.9 lens", "", %{}, ["35mm camera"], ["a"])
      refute "accessory" in tags

      %{tags: tags} = CameraBrowser.classify("Box of old cameras", "Estate lot, untested, no idea if they work", %{}, ["film camera"], [])
      assert "hopeful" in tags and "lot" in tags
    end
  end

  describe "craigslist decoder" do
    test "reconstructs ids, dates, locations and images from positional items" do
      data = %{
        "items" => [
          [100, 60, 137, 5900, "1:1:2~40.7~-73.9", "0CI0qt", [13, "tok"], [4, "3:00a0a_x_y"], [6, "bk-leica"], [10, "$5,900"], "Leica M-A"]
        ],
        "decode" => %{
          "minPostingId" => 7_000_000_000,
          "minPostedDate" => 1_700_000_000,
          "locations" => [0, [3, "newyork", "brk"]],
          "locationDescriptions" => [0, "Brooklyn"],
          "neighborhoods" => [0, "x", "Greenpoint"]
        }
      }

      [l] = Blog.CameraBrowser.Craigslist.decode_items(data, "newyork")
      assert l.posting_id == 7_000_000_100
      assert l.posted_at == DateTime.from_unix!(1_700_000_060)
      assert l.subarea == "brk" and l.location == "Brooklyn" and l.neighborhood == "Greenpoint"
      assert l.price_cents == 590_000
      assert l.image_ids == ["00a0a_x_y"]
      assert l.url == "https://www.craigslist.org/view/d/bk-leica/tok"
      assert Blog.CameraBrowser.Craigslist.decode_items(%{"items" => [], "decode" => 0}, "newyork") == []
    end
  end
end
