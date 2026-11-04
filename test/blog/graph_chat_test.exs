defmodule Blog.GraphChatTest do
  use Blog.DataCase, async: false

  alias Blog.GraphChat

  @graph "lolly"
  @visitor "visitor-abc"

  setup do
    %{convo: GraphChat.new_conversation_id()}
  end

  describe "history/4" do
    test "returns turns oldest-first, both sides included", %{convo: c} do
      GraphChat.append(@graph, @visitor, c, "user", "first question")
      GraphChat.append(@graph, @visitor, c, "assistant", "first answer")
      GraphChat.append(@graph, @visitor, c, "user", "second question")

      assert [
               %{"role" => "user", "content" => "first question"},
               %{"role" => "assistant", "content" => "first answer"},
               %{"role" => "user", "content" => "second question"}
             ] = GraphChat.history(@graph, c)
    end

    test "keeps the most recent when limited, not the oldest", %{convo: c} do
      for i <- 1..10, do: GraphChat.append(@graph, @visitor, c, "user", "msg #{i}")

      history = GraphChat.history(@graph, c, 3)

      assert length(history) == 3
      assert Enum.map(history, & &1["content"]) == ["msg 8", "msg 9", "msg 10"]
    end

    test "one conversation never bleeds into another", %{convo: c} do
      other = GraphChat.new_conversation_id()
      GraphChat.append(@graph, @visitor, c, "user", "in first chat")
      GraphChat.append(@graph, @visitor, other, "user", "in second chat")

      assert [%{"content" => "in first chat"}] = GraphChat.history(@graph, c)
      assert [%{"content" => "in second chat"}] = GraphChat.history(@graph, other)
    end

    test "is scoped per graph but shared between people", %{convo: c} do
      GraphChat.append("lolly", "person-a", c, "user", "course")
      GraphChat.append("rooted", "person-a", c, "user", "method")
      GraphChat.append("lolly", "person-b", c, "user", "from someone else")

      # both people's turns are in the same conversation; graphs stay separate
      assert [%{"content" => "course"}, %{"content" => "from someone else"}] =
               GraphChat.history("lolly", c)

      assert [%{"content" => "method"}] = GraphChat.history("rooted", c)
    end

    test "an unknown conversation yields nothing rather than everything", %{convo: c} do
      GraphChat.append(@graph, @visitor, c, "user", "something")

      assert GraphChat.history(@graph, "no-such-conversation") == []
      assert GraphChat.history(@graph, "") == []
    end
  end

  describe "list_conversations/3" do
    test "lists most-recently-active first, titled by the opening question" do
      a = GraphChat.new_conversation_id()
      b = GraphChat.new_conversation_id()

      GraphChat.append(@graph, @visitor, a, "user", "what is the spine?")
      GraphChat.append(@graph, @visitor, a, "assistant", "the spine is...")
      GraphChat.append(@graph, @visitor, b, "user", "how do choice boards work?")

      assert [second, first] = GraphChat.list_conversations(@graph)

      assert second.id == b
      assert second.title == "how do choice boards work?"
      assert second.count == 1

      assert first.id == a
      assert first.title == "what is the spine?"
      assert first.count == 2
    end

    test "a chat opened by the assistant still gets a title", %{convo: c} do
      GraphChat.append(@graph, @visitor, c, "assistant", "no user turn here")

      assert [%{title: "Untitled chat"}] = GraphChat.list_conversations(@graph)
    end

    test "long opening questions are truncated" do
      c = GraphChat.new_conversation_id()
      GraphChat.append(@graph, @visitor, c, "user", String.duplicate("word ", 40))

      [convo] = GraphChat.list_conversations(@graph)
      assert String.ends_with?(convo.title, "…")
      assert String.length(convo.title) <= 71
    end

    test "lists chats started by other people too", %{convo: c} do
      GraphChat.append(@graph, "someone-else", c, "user", "started by someone else")

      assert [%{title: "started by someone else"}] = GraphChat.list_conversations(@graph)
    end
  end

  describe "latest_conversation_id/2" do
    test "is the conversation most recently written to" do
      a = GraphChat.new_conversation_id()
      b = GraphChat.new_conversation_id()
      GraphChat.append(@graph, @visitor, a, "user", "older")
      GraphChat.append(@graph, @visitor, b, "user", "newer")

      assert GraphChat.latest_conversation_id(@graph) == b
    end

    test "is nil for a visitor who has never chatted" do
      assert GraphChat.latest_conversation_id("emptygraph") == nil
    end
  end

  describe "context_window/2" do
    test "sends the tail of the conversation, including assistant turns" do
      history =
        Enum.flat_map(1..15, fn i ->
          [%{"role" => "user", "content" => "q#{i}"}, %{"role" => "assistant", "content" => "a#{i}"}]
        end)

      assert GraphChat.context_window(history, 4) == [
               %{"role" => "user", "content" => "q14"},
               %{"role" => "assistant", "content" => "a14"},
               %{"role" => "user", "content" => "q15"},
               %{"role" => "assistant", "content" => "a15"}
             ]
    end

    test "a short conversation is sent whole" do
      history = [%{"role" => "user", "content" => "only"}]
      assert GraphChat.context_window(history, 20) == history
    end
  end

  describe "append/5" do
    test "rejects roles the model wouldn't accept", %{convo: c} do
      GraphChat.append(@graph, @visitor, c, "system", "injected")
      assert GraphChat.history(@graph, c) == []
    end

    test "never raises, so a storage failure can't break the chat", %{convo: c} do
      assert GraphChat.append(@graph, nil, c, "user", "x") == :ok
      assert GraphChat.append(@graph, @visitor, c, "user", nil) == :ok
      assert GraphChat.append(@graph, @visitor, "", "user", "x") == :ok
    end

    test "still records who wrote each turn, even though reads ignore it" do
      c = GraphChat.new_conversation_id()
      GraphChat.append(@graph, "person-a", c, "user", "mine")

      assert Blog.Repo.one!(Blog.GraphChat.Message).visitor_id == "person-a"
    end
  end

  describe "deletion" do
    test "delete_conversation/3 removes one chat and leaves the rest" do
      a = GraphChat.new_conversation_id()
      b = GraphChat.new_conversation_id()
      GraphChat.append(@graph, @visitor, a, "user", "keep me")
      GraphChat.append(@graph, @visitor, b, "user", "delete me")

      GraphChat.delete_conversation(@graph, b)

      assert [%{id: ^a}] = GraphChat.list_conversations(@graph)
    end

    test "clear/2 forgets one graph without touching the other", %{convo: c} do
      GraphChat.append("lolly", @visitor, c, "user", "course")
      GraphChat.append("rooted", @visitor, c, "user", "method")

      GraphChat.clear("lolly")

      assert GraphChat.history("lolly", c) == []
      assert [%{"content" => "method"}] = GraphChat.history("rooted", c)
    end
  end
end
