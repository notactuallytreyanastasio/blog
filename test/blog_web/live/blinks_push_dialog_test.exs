defmodule BlogWeb.BlinksPushDialogTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  @copy "We publish links live. Want to check them out? Allow in the next dialogue."
  @caps "WE NEVER SEND ADS OR PROMOTED OR SPONSORED CONTENT, only organic links"

  defp state(over) do
    Map.merge(
      %{"supported" => true, "ios" => false, "mobile" => true, "standalone" => false,
        "subscribed" => false, "permission" => "default", "promptSeen" => false},
      over
    )
  end

  setup do
    Application.put_env(:blog, :web_push, public_key: "BHTBtest", private_key: "x", subject: "https://bobbby.online")
    on_exit(fn -> Application.delete_env(:blog, :web_push) end)
    :ok
  end

  test "opens by itself on mobile with the exact copy and an allow button", %{conn: conn} do
    {:ok, view, _} = live(conn, "/blinks")
    refute has_element?(view, "#push-dialog")

    html = render_hook(view, "push-state", state(%{}))
    assert html =~ @copy and html =~ @caps
    assert has_element?(view, "#push-dialog [data-push-allow]")
    assert html =~ "Add to Home Screen"
  end

  test "stays quiet on desktop, when already subscribed, denied, or seen before", %{conn: conn} do
    for over <- [%{"mobile" => false}, %{"subscribed" => true}, %{"permission" => "denied"}, %{"promptSeen" => true}] do
      {:ok, view, _} = live(conn, "/blinks")
      render_hook(view, "push-state", state(over))
      refute has_element?(view, "#push-dialog"), "should not open for #{inspect(over)}"
    end
  end

  test "iPhone in Safari gets the pin-to-home-screen step instead of allow", %{conn: conn} do
    {:ok, view, _} = live(conn, "/blinks")
    html = render_hook(view, "push-state", state(%{"ios" => true, "supported" => false}))
    assert html =~ @copy
    assert html =~ "Add to Home Screen"
    refute has_element?(view, "[data-push-allow]")
    assert has_element?(view, "#push-dialog button", "got it")
  end

  test "closing remembers and does not reopen on the next state report", %{conn: conn} do
    {:ok, view, _} = live(conn, "/blinks")
    render_hook(view, "push-state", state(%{}))
    view |> element("#push-dialog button", "not now") |> render_click()
    refute has_element?(view, "#push-dialog")
    render_hook(view, "push-state", state(%{}))
    refute has_element?(view, "#push-dialog")
  end

  test "the masthead link opens it on demand on desktop", %{conn: conn} do
    {:ok, view, _} = live(conn, "/blinks")
    render_hook(view, "push-state", state(%{"mobile" => false}))
    view |> element("#blinks-push a", "notify me") |> render_click()
    assert has_element?(view, "#push-dialog [data-push-allow]")
  end
end
