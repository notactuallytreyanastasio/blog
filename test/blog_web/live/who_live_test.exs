defmodule BlogWeb.WhoLiveTest do
  @moduledoc """
  /who is gated at the page level: until the visitor unlocks, the server
  sends no Doctors, no stories and no stats. After, the browse side renders
  from the graph and events behave.
  """
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  @password "test-who-password"

  setup do
    prev = Application.get_env(:blog, :who_chat_password)
    Application.put_env(:blog, :who_chat_password, @password)
    on_exit(fn -> Application.put_env(:blog, :who_chat_password, prev) end)
    :ok
  end

  defp unlock(conn) do
    {:ok, view, _html} = live(conn, "/who")
    html = view |> form("form[phx-submit=unlock_page]", %{"password" => @password}) |> render_submit()
    {view, html}
  end

  test "locked page shows the prompt and leaks no graph", %{conn: conn} do
    {:ok, view, html} = live(conn, "/who")

    assert html =~ "password protected"
    refute html =~ "Tennant"
    refute html =~ ~s(class="who-doctor)
    refute html =~ "nodes ·"

    # events below the gate are ignored, not served
    refute render_click(view, "pick_doctor", %{"id" => "17"}) =~ "Blink"
  end

  test "wrong password stays locked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/who")
    html = view |> form("form[phx-submit=unlock_page]", %{"password" => "nope"}) |> render_submit()
    assert html =~ "Wrong password."
    refute html =~ "Tennant"
  end

  test "no password configured means locked, not open", %{conn: conn} do
    Application.put_env(:blog, :who_chat_password, nil)
    {:ok, _view, html} = live(conn, "/who")
    assert html =~ "no password is configured"
    refute html =~ "unlock_page"
  end

  test "unlocking renders the Doctors and the stats", %{conn: conn} do
    {_view, html} = unlock(conn)
    assert html =~ "2731 nodes"
    assert html =~ "David Tennant"
    assert html =~ "Jo Martin"
    assert html =~ "Ask the TARDIS"
  end

  test "picking a Doctor lists their stories; inspecting one shows its edges", %{conn: conn} do
    {view, _html} = unlock(conn)

    html = render_click(view, "pick_doctor", %{"id" => "17"})
    assert html =~ "stories filed under the Tenth Doctor"
    assert html =~ "Blink - Sally Sparrow"

    html = render_click(view, "inspect", %{"id" => "182"})
    assert html =~ "who-node-182"
    assert html =~ "→ Doctor"

    html = render_click(view, "pick_doctor", %{"id" => "17"})
    refute html =~ "stories filed under"
  end

  test "search lists matches and an empty query clears them", %{conn: conn} do
    {view, _html} = unlock(conn)

    html = render_change(view, "search", %{"q" => "Gallifrey"})
    assert html =~ "Gallifrey"
    assert html =~ "observation"

    html = render_change(view, "search", %{"q" => ""})
    refute html =~ "Nothing in the graph"
  end

  test "an empty message is not sent to the model", %{conn: conn} do
    {view, _html} = unlock(conn)
    html = render_submit(view, "send", %{"message" => "   "})
    refute html =~ "reading the graph"
  end
end
