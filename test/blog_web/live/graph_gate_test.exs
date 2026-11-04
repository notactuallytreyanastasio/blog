defmodule BlogWeb.GraphGateTest do
  @moduledoc """
  The /lolly and /rooted_in_good explorers are password gated at the page
  level: until the visitor unlocks, the server must not send the graph — not
  the node data, not the counts, not the explorer hook — down the wire.
  """
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  @password "test-gate-password"

  setup do
    prev_lolly = Application.get_env(:blog, :lolly_chat_password)
    prev_rooted = Application.get_env(:blog, :rooted_chat_password)
    Application.put_env(:blog, :lolly_chat_password, @password)
    Application.put_env(:blog, :rooted_chat_password, @password)

    on_exit(fn ->
      Application.put_env(:blog, :lolly_chat_password, prev_lolly)
      Application.put_env(:blog, :rooted_chat_password, prev_rooted)
    end)

    :ok
  end

  for {path, hook, title} <- [
        {"/lolly", "LollyApp", "Say It With Pictures"},
        {"/rooted_in_good", "RootedApp", "RootedInGood"}
      ] do
    describe "#{path} gate" do
      test "locked page shows the prompt and leaks no graph", %{conn: conn} do
        {:ok, _view, html} = live(conn, unquote(path))

        assert html =~ "password protected"
        assert html =~ "unlock_page"
        assert html =~ unquote(title)

        refute html =~ unquote(hook)
        refute html =~ "data-graph=\"{"
        refute html =~ "AI_NOTE"
        refute html =~ "node_type"
      end

      test "wrong password stays locked", %{conn: conn} do
        {:ok, view, _html} = live(conn, unquote(path))

        html =
          view
          |> form("form[phx-submit=unlock_page]", %{"password" => "nope"})
          |> render_submit()

        assert html =~ "Wrong password."
        refute html =~ unquote(hook)
        refute html =~ "data-graph=\"{"
      end

      test "correct password unlocks and mounts the explorer", %{conn: conn} do
        {:ok, view, _html} = live(conn, unquote(path))

        html =
          view
          |> form("form[phx-submit=unlock_page]", %{"password" => @password})
          |> render_submit()

        assert html =~ unquote(hook)
        assert html =~ "data-graph="
        refute html =~ "password protected"
      end
    end
  end
end
