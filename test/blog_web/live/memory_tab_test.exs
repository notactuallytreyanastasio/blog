defmodule BlogWeb.MemoryTabTest do
  @moduledoc """
  The Memory tab is the visible half of the living graph: it must stay behind
  the page gate, show what has been recorded, and filter by topic.
  """
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  alias Blog.Memory

  @password "test-gate-password"

  setup do
    prev = %{
      lolly: Application.get_env(:blog, :lolly_chat_password),
      rooted: Application.get_env(:blog, :rooted_chat_password),
      key: Application.get_env(:blog, :openai_api_key)
    }

    Application.put_env(:blog, :lolly_chat_password, @password)
    Application.put_env(:blog, :rooted_chat_password, @password)
    Application.delete_env(:blog, :openai_api_key)

    on_exit(fn ->
      Application.put_env(:blog, :lolly_chat_password, prev.lolly)
      Application.put_env(:blog, :rooted_chat_password, prev.rooted)
      if prev.key, do: Application.put_env(:blog, :openai_api_key, prev.key)
    end)

    :ok
  end

  defp unlock(view) do
    view |> form("form[phx-submit=unlock_page]", %{"password" => @password}) |> render_submit()
    view
  end

  for {path, graph} <- [{"/lolly", "lolly"}, {"/rooted_in_good", "rooted"}] do
    describe "#{path} memory tab" do
      test "is not reachable while the page is locked", %{conn: conn} do
        {:ok, _view, html} = live(conn, unquote(path))
        refute html =~ "Living memory"
        refute html =~ ~s(phx-value-view="memory")
      end

      test "shows an empty state before anything is remembered", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        html = render_click(view, "set_view", %{"view" => "memory"})

        assert html =~ "Living memory"
        assert html =~ "Nothing remembered yet"
      end

      test "renders recorded exchanges and distilled topics", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        # a real exchange for this conn's visitor
        view
        |> form("form[phx-submit=send]", %{"message" => "how does repair work?"})
        |> render_submit()

        {:ok, ids} =
          Memory.record_exchange(unquote(graph), "anyone", "c", "how does repair work?",
            "repair is returning after the rupture")

        Memory.attach_topics(unquote(graph), "anyone", [ids.question, ids.answer], ["repair"])

        html = render_click(view, "set_view", %{"view" => "memory"})

        assert html =~ "how does repair work?"
        assert html =~ "repair is returning after the rupture"
        assert html =~ "repair"
        refute html =~ "Nothing remembered yet"
      end

      test "clicking a topic filters to its exchanges, and toggles back", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)
        view |> form("form[phx-submit=send]", %{"message" => "seed"}) |> render_submit()

        {:ok, a} = Memory.record_exchange(unquote(graph), "anyone", "c", "q about boards", "boards answer")
        {:ok, b} = Memory.record_exchange(unquote(graph), "anyone", "c", "q about routines", "routines answer")
        Memory.attach_topics(unquote(graph), "anyone", [a.question, a.answer], ["boards"])
        Memory.attach_topics(unquote(graph), "anyone", [b.question, b.answer], ["routines"])

        render_click(view, "set_view", %{"view" => "memory"})
        [boards] = Enum.filter(Memory.topics(unquote(graph)), &(&1.title == "boards"))

        filtered = render_click(view, "memory_topic", %{"id" => to_string(boards.id)})
        assert filtered =~ "boards answer"
        refute filtered =~ "routines answer"

        all = render_click(view, "memory_topic", %{"id" => to_string(boards.id)})
        assert all =~ "routines answer"
      end
    end
  end

  test "memory recorded by anyone shows for everyone on that page", %{conn: conn} do
    Memory.record_exchange("lolly", "someone-else", "c", "their question", "their answer")

    conn = get(conn, "/lolly")
    {:ok, view, _html} = live(conn, "/lolly")
    unlock(view)
    html = render_click(view, "set_view", %{"view" => "memory"})

    assert html =~ "their question"
    assert html =~ "their answer"
    refute html =~ "Nothing remembered yet"
  end

  test "one book's memory does not appear on another book's page", %{conn: conn} do
    Memory.record_exchange("rooted", "someone", "c", "a rooted question", "a rooted answer")

    conn = get(conn, "/lolly")
    {:ok, view, _html} = live(conn, "/lolly")
    unlock(view)
    html = render_click(view, "set_view", %{"view" => "memory"})

    refute html =~ "a rooted question"
    assert html =~ "Nothing remembered yet"
  end
end
