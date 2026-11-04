defmodule BlogWeb.ChatPersistenceTest do
  @moduledoc """
  The graph explorer chats are expected to survive a reload: what the visitor
  asked and what the assistant answered both come back, and both are what gets
  resent to the model on the next turn.
  """
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Ecto.Query

  alias Blog.GraphChat

  @password "test-gate-password"

  setup do
    prev = %{
      lolly: Application.get_env(:blog, :lolly_chat_password),
      rooted: Application.get_env(:blog, :rooted_chat_password),
      key: Application.get_env(:blog, :openai_api_key)
    }

    Application.put_env(:blog, :lolly_chat_password, @password)
    Application.put_env(:blog, :rooted_chat_password, @password)
    # No key: OpenAI.ask/1 short-circuits before any HTTP call, so "send"
    # exercises persistence without spending credits or touching the network.
    Application.delete_env(:blog, :openai_api_key)

    on_exit(fn ->
      Application.put_env(:blog, :lolly_chat_password, prev.lolly)
      Application.put_env(:blog, :rooted_chat_password, prev.rooted)
      if prev.key, do: Application.put_env(:blog, :openai_api_key, prev.key)
    end)

    :ok
  end

  defp unlock(view) do
    view
    |> form("form[phx-submit=unlock_page]", %{"password" => @password})
    |> render_submit()

    view
  end

  for {path, graph} <- [{"/lolly", "lolly"}, {"/rooted_in_good", "rooted"}] do
    describe "#{path} chat persistence" do
      test "a sent message is stored against the session visitor", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view
        |> form("form[phx-submit=send]", %{"message" => "does the rhythm actually hold?"})
        |> render_submit()

        stored = Blog.Repo.all(Blog.GraphChat.Message)

        assert [%{graph: unquote(graph), role: "user", content: "does the rhythm actually hold?"}] =
                 stored

        assert hd(stored).visitor_id not in [nil, ""]
      end

      test "history comes back on a fresh mount, assistant turns included", %{conn: conn} do
        # one real request first so the session cookie exists and is recycled
        # into both mounts; otherwise each mount is a different visitor
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view
        |> form("form[phx-submit=send]", %{"message" => "first visit question"})
        |> render_submit()

        visitor = Blog.Repo.one!(Blog.GraphChat.Message).visitor_id
        convo = Blog.Repo.one!(Blog.GraphChat.Message).conversation_id
        GraphChat.append(unquote(graph), visitor, convo, "assistant", "first visit answer")

        # reload: a brand new LiveView process, same session cookie
        {:ok, view2, _html} = live(conn, unquote(path))
        html = unlock(view2) |> render()

        assert html =~ "first visit question"
        assert html =~ "first visit answer"
      end

      test "clearing forgets the conversation", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view
        |> form("form[phx-submit=send]", %{"message" => "forget me"})
        |> render_submit()

        render_click(view, "clear_history")

        assert Blog.Repo.aggregate(Blog.GraphChat.Message, :count, :id) == 0

        {:ok, view2, _html} = live(conn, unquote(path))
        refute unlock(view2) |> render() =~ "forget me"
      end


      test "a new chat starts empty but the old one stays browsable", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view |> form("form[phx-submit=send]", %{"message" => "first chat"}) |> render_submit()
        render_click(view, "new_chat")
        view |> form("form[phx-submit=send]", %{"message" => "second chat"}) |> render_submit()

        # the visible conversation is only the new one
        html = render(view)
        assert html =~ "second chat"
        refute html =~ "first chat"

        # but both are listed in the browser, newest first
        listing = render_click(view, "show_history")
        assert listing =~ "first chat"
        assert listing =~ "second chat"

        assert length(GraphChat.list_conversations(unquote(graph))) == 2
      end

      test "opening an old chat reloads it and new turns append to it", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view |> form("form[phx-submit=send]", %{"message" => "the original question"}) |> render_submit()
        original = Blog.Repo.one!(from m in Blog.GraphChat.Message, limit: 1, select: m.conversation_id)

        render_click(view, "new_chat")
        view |> form("form[phx-submit=send]", %{"message" => "an unrelated question"}) |> render_submit()

        # go back to the first chat and keep going
        html = render_click(view, "open_conversation", %{"id" => original})
        assert html =~ "the original question"
        refute html =~ "an unrelated question"

        view |> form("form[phx-submit=send]", %{"message" => "a follow up"}) |> render_submit()

        contents = GraphChat.history(unquote(graph), original) |> Enum.map(& &1["content"])

        assert contents == ["the original question", "a follow up"]
      end

      test "deleting a chat from the browser removes only that one", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view |> form("form[phx-submit=send]", %{"message" => "keep this"}) |> render_submit()
        keep = Blog.Repo.one!(from m in Blog.GraphChat.Message, limit: 1, select: m.conversation_id)

        render_click(view, "new_chat")
        view |> form("form[phx-submit=send]", %{"message" => "drop this"}) |> render_submit()
        drop =
          Blog.Repo.one!(
            from m in Blog.GraphChat.Message,
              where: m.content == "drop this",
              select: m.conversation_id
          )

        render_click(view, "show_history")
        render_click(view, "delete_conversation", %{"id" => drop})

        assert [%{id: ^keep}] = GraphChat.list_conversations(unquote(graph))
      end

      test "a reload resumes the conversation last used, not a blank one", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)

        view |> form("form[phx-submit=send]", %{"message" => "chat one"}) |> render_submit()
        render_click(view, "new_chat")
        view |> form("form[phx-submit=send]", %{"message" => "chat two"}) |> render_submit()

        {:ok, view2, _html} = live(conn, unquote(path))
        html = unlock(view2) |> render()

        assert html =~ "chat two"
        refute html =~ "chat one"
      end

      test "a second browser sees and can continue the same conversation", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))
        unlock(view)
        view |> form("form[phx-submit=send]", %{"message" => "asked from browser one"}) |> render_submit()

        # a different session entirely — no shared cookie
        {:ok, other, _html} = live(Phoenix.ConnTest.build_conn(), unquote(path))
        html = unlock(other) |> render()

        assert html =~ "asked from browser one"
      end

      test "a locked page stores nothing even if send is fired directly", %{conn: conn} do
        conn = get(conn, unquote(path))
        {:ok, view, _html} = live(conn, unquote(path))

        # the send handler must no-op while locked rather than persisting or
        # spending anything — the gate is not just a template-level hide
        render_click(view, "send", %{"message" => "sneaky"})

        assert Blog.Repo.aggregate(Blog.GraphChat.Message, :count, :id) == 0
      end
    end
  end
end
