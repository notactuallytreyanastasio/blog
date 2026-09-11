defmodule BlogWeb.HomepagePhotoWindowTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  # Blog.Gallery is disabled in test, so its ETS table does not exist. The
  # table is :protected — any process may read it — so the test can create and
  # populate it itself and the LiveView will read it exactly as it would in
  # production.

  @table :gallery_cache

  defp seed(photos) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    end

    :ets.insert(@table, {:photos, photos})
    :ets.insert(@table, {:by_guid, Map.new(photos, &{&1.guid, &1})})
    :ets.insert(@table, {:name, "website_pics"})
    on_exit(fn -> if :ets.whereis(@table) != :undefined, do: :ets.delete_all_objects(@table) end)
  end

  # The desktop only renders after the boot splash is dismissed; without this
  # every assertion below would be made against the splash screen, and the
  # negative ones would pass for the wrong reason.
  defp desktop(conn, path \\ "/") do
    {:ok, live, _} = live(conn, path)
    render_click(live, "skip_splash")
    live
  end

  defp photo(guid, day) do
    %{
      guid: guid,
      thumb: guid <> "-t",
      display: guid <> "-d",
      width: 2254,
      height: 1537,
      caption: nil,
      created_at: DateTime.new!(Date.new!(2026, 9, day), ~T[12:00:00])
    }
  end

  describe "with an album" do
    setup do
      seed([photo("AAA", 3), photo("BBB", 2), photo("CCC", 1)])
      :ok
    end

    test "the photo window is open on arrival", %{conn: conn} do
      html = conn |> desktop() |> render()

      assert html =~ "photo-window"
      assert html =~ ~s(data-embedded="true")
      # The deck is handed to the hook inline, so the first photo can start
      # drifting without a round trip.
      assert html =~ "AAA"
    end

    test "the close box hides it and the desktop icon brings it back", %{conn: conn} do
      live = desktop(conn)
      assert render(live) =~ ~s(class="photo-window")

      refute render_click(live, "toggle_photos") =~ ~s(class="photo-window")
      assert render_click(live, "toggle_photos") =~ ~s(class="photo-window")
    end

    test "?photos=0 lands with it closed", %{conn: conn} do
      html = conn |> desktop("/?photos=0") |> render()

      refute html =~ ~s(class="photo-window")
      # the icon is still there to open it
      assert html =~ "desktop-icon-photos"
    end

    test "new photos reach an open desktop without a reload", %{conn: conn} do
      live = desktop(conn)
      refute render(live) =~ "ZZZ"

      send(live.pid, {:gallery, :updated, [photo("ZZZ", 9) | Blog.Gallery.photos()]})

      assert render(live) =~ "ZZZ"
    end
  end

  test "no album means no window and no desktop icon", %{conn: conn} do
    seed([])
    html = conn |> desktop() |> render()

    # Sanity: we are looking at the desktop, not the boot splash.
    assert html =~ "menu-bar"
    refute html =~ ~s(class="photo-window")
    refute html =~ ~s(class="desktop-icon-photos")
  end
end
