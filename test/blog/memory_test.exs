defmodule Blog.MemoryTest do
  use Blog.DataCase, async: false

  alias Blog.Memory

  @graph "lolly"
  @visitor "v-1"
  @convo "c-1"

  describe "record_exchange/5" do
    test "stores both sides and joins them" do
      assert {:ok, %{question: q, answer: a}} =
               Memory.record_exchange(@graph, @visitor, @convo, "what is the spine?", "it is ...")

      assert is_integer(q) and is_integer(a)

      [exchange] = Memory.recent_exchanges(@graph)
      assert exchange.question == "what is the spine?"
      assert exchange.answer == "it is ..."
    end

    test "chains exchanges in a conversation so the order is recoverable" do
      {:ok, _} = Memory.record_exchange(@graph, @visitor, @convo, "first q", "first a")
      {:ok, second} = Memory.record_exchange(@graph, @visitor, @convo, "second q", "second a")

      follows =
        Blog.Repo.all(
          from e in Blog.Memory.Edge, where: e.edge_type == "follows", select: e.to_id
        )

      # the second question follows the first answer
      assert length(follows) == 1
      assert Blog.Repo.get!(Blog.Memory.Node, hd(follows)).body == "second q"
      assert is_integer(second.answer)
    end

    test "still requires a writer so provenance is never lost" do
      assert Memory.record_exchange(@graph, "", @convo, "q", "a") == :error
      assert Memory.record_exchange(@graph, nil, @convo, "q", "a") == :error
      assert Memory.stats(@graph).nodes == 0
    end
  end

  describe "attach_topics/4" do
    test "folds the same subject raised by different people into one node" do
      {:ok, one} = Memory.record_exchange(@graph, @visitor, @convo, "q1", "a1")
      {:ok, two} = Memory.record_exchange(@graph, @visitor, @convo, "q2", "a2")

      Memory.attach_topics(@graph, "person-a", [one.question, one.answer], ["choice boards"])
      Memory.attach_topics(@graph, "person-b", [two.question, two.answer], ["choice boards", "prompting"])

      topics = Memory.topics(@graph)

      assert [%{title: "choice boards", mentions: 2}, %{title: "prompting", mentions: 1}] = topics
    end

    test "normalises sloppy topic strings" do
      {:ok, ids} = Memory.record_exchange(@graph, @visitor, @convo, "q", "a")
      Memory.attach_topics(@graph, @visitor, [ids.answer], ["  co-regulation.  ", "", nil])

      assert [%{title: "co-regulation", mentions: 1}] = Memory.topics(@graph)
    end

    test "a topic links back to the exchanges that raised it" do
      {:ok, ids} = Memory.record_exchange(@graph, @visitor, @convo, "about repair", "repair means")
      Memory.attach_topics(@graph, @visitor, [ids.question, ids.answer], ["repair"])

      [topic] = Memory.topics(@graph)
      [found] = Memory.exchanges_for_topic(@graph, topic.id)

      assert found.body == "repair means"
    end
  end

  describe "search/4" do
    setup do
      {:ok, ids} =
        Memory.record_exchange(@graph, @visitor, @convo, "how do choice boards work?",
          "a choice board offers two options the child can point at")

      Memory.attach_topics(@graph, @visitor, [ids.question, ids.answer], ["choice boards"])
      :ok
    end

    test "finds past questions and answers by word" do
      hits = Memory.search(@graph, "choice board")
      assert Enum.any?(hits, &(&1.type == "question"))
      assert Enum.any?(hits, &(&1.type == "answer"))
    end

    test "can restrict to one node type" do
      hits = Memory.search(@graph, "choice", node_type: "topic")
      assert [%{type: "topic", title: "choice boards"}] = hits
    end

    test "returns memory recorded by other people on the same graph" do
      {:ok, ids} =
        Memory.record_exchange(@graph, "someone-else", @convo, "their choice board question",
          "their answer about choice boards")

      Memory.attach_topics(@graph, "someone-else", [ids.answer], ["choice boards"])

      hits = Memory.search(@graph, "choice board")
      assert Enum.any?(hits, &(&1.title =~ "their choice board question"))
    end

    test "does not return another graph's memory" do
      assert Memory.search("rooted", "choice board") == []
    end
  end

  describe "search_across/3" do
    test "reaches the other books but excludes the current one, and says which is which" do
      {:ok, _} = Memory.record_exchange("lolly", @visitor, @convo, "lolly q", "about choice boards")
      {:ok, _} = Memory.record_exchange("rooted", @visitor, @convo, "rooted q", "about choice boards too")

      hits = Memory.search_across("choice boards", except: "lolly")

      assert hits != []
      assert Enum.all?(hits, &(&1.graph == "rooted"))
      assert Enum.all?(hits, &(&1.graph_label == "The RootedInGood Method"))
    end
  end

  describe "stats/2 and forget/2" do
    test "counts nodes and edges, then clears one graph only" do
      {:ok, ids} = Memory.record_exchange(@graph, @visitor, @convo, "q", "a")
      Memory.attach_topics(@graph, @visitor, [ids.answer], ["a topic"])
      {:ok, _} = Memory.record_exchange("rooted", @visitor, @convo, "other q", "other a")

      stats = Memory.stats(@graph)
      assert stats.exchanges == 1
      assert stats.topics == 1
      assert stats.edges >= 2

      Memory.forget(@graph)

      assert Memory.stats(@graph).nodes == 0
      assert Memory.stats("rooted").exchanges == 1
    end
  end
end
