defmodule Blog.Memory do
  @moduledoc """
  A living decision graph of what has actually been discussed.

  Unlike the book graphs — which are exported from deciduous ahead of time and
  read-only at runtime — this one is written as people chat. Every exchange
  becomes a `question` node and an `answer` node joined by an `answers` edge,
  chained to the previous exchange with `follows`. A background pass then
  distils the exchange into `topic` nodes (deduped per graph, so a subject
  discussed five times is one node with five mentions) joined with `about`.

  The result is queryable by the assistant itself, which is the point: it can
  recall what was concluded weeks ago instead of restarting cold every session.

  Memory is shared per graph — everyone past the page gate sees and benefits
  from the same memory. `visitor_id` is still recorded on each node as
  provenance, but is not part of any read path. The assistant can read another
  graph's memory when asked — see `search_across/2` — but never mixes it in
  silently.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.Memory.{Node, Edge}

  @graphs ~w(lolly rooted ziggy)
  @graph_labels %{
    "lolly" => "Say It With Pictures",
    "rooted" => "The RootedInGood Method",
    "ziggy" => "The Ziggy Account"
  }

  def known_graphs, do: @graphs
  def graph_label(graph), do: Map.get(@graph_labels, graph, graph)

  defp valid?(graph) when is_binary(graph), do: graph != ""
  defp valid?(_graph), do: false

  # ==========================================================================
  # Recording
  # ==========================================================================

  @doc """
  Record one exchange. Returns `{:ok, %{question: id, answer: id}}` or `:error`.

  Deterministic and exact — no model involved, so this half of the memory can
  never be wrong about what was said.
  """
  def record_exchange(graph, visitor_id, conversation_id, question, answer)
      when is_binary(question) and is_binary(answer) do
    if valid?(graph) and is_binary(visitor_id) and visitor_id != "" do
      previous_answer = last_answer_id(graph, conversation_id)

      with {:ok, q} <-
             insert_node(graph, visitor_id, "question", title_of(question), question,
               conversation_id: conversation_id
             ),
           {:ok, a} <-
             insert_node(graph, visitor_id, "answer", title_of(answer), answer,
               conversation_id: conversation_id
             ) do
        link(graph, visitor_id, q.id, a.id, "answers")
        if previous_answer, do: link(graph, visitor_id, previous_answer, q.id, "follows")
        {:ok, %{question: q.id, answer: a.id}}
      else
        _ -> :error
      end
    else
      :error
    end
  rescue
    _ -> :error
  end

  def record_exchange(_g, _v, _c, _q, _a), do: :error

  @doc """
  Attach distilled topics to an exchange.

  `topics` is a list of short subject strings. Repeats are folded into the
  existing topic node rather than duplicated, so mention counts show what keeps
  coming up.
  """
  def attach_topics(graph, visitor_id, node_ids, topics) when is_list(topics) do
    if valid?(graph) do
      topics
      |> Enum.map(&clean_topic/1)
      |> Enum.reject(&(&1 in [nil, ""]))
      |> Enum.uniq()
      |> Enum.each(fn topic ->
        case upsert_topic(graph, visitor_id, topic) do
          {:ok, t} ->
            for id <- List.wrap(node_ids), is_integer(id) do
              link(graph, visitor_id, id, t.id, "about")
            end

          _ ->
            :ok
        end
      end)
    end

    :ok
  rescue
    _ -> :ok
  end

  def attach_topics(_g, _v, _n, _t), do: :ok

  defp upsert_topic(graph, visitor_id, topic) do
    # shared across visitors: the same subject is one node however many people
    # raise it, with mentions counting how often
    case Repo.get_by(Node, graph: graph, node_type: "topic", title: topic) do
      nil ->
        insert_node(graph, visitor_id, "topic", topic, nil)

      existing ->
        existing
        |> Ecto.Changeset.change(mentions: existing.mentions + 1)
        |> Repo.update()
    end
  end

  defp insert_node(graph, visitor_id, type, title, body, opts \\ []) do
    %Node{}
    |> Node.changeset(%{
      graph: graph,
      visitor_id: visitor_id,
      node_type: type,
      title: title,
      body: body,
      conversation_id: opts[:conversation_id],
      ref_node_id: opts[:ref_node_id]
    })
    |> Repo.insert()
  end

  defp link(graph, visitor_id, from_id, to_id, type) do
    %Edge{}
    |> Edge.changeset(%{
      graph: graph,
      visitor_id: visitor_id,
      from_id: from_id,
      to_id: to_id,
      edge_type: type
    })
    |> Repo.insert(on_conflict: :nothing)
  end

  defp last_answer_id(graph, conversation_id) do
    Node
    |> where([n], n.graph == ^graph and n.node_type == "answer")
    |> then(fn q ->
      if conversation_id,
        do: where(q, [n], n.conversation_id == ^conversation_id),
        else: q
    end)
    |> order_by([n], desc: n.id)
    |> limit(1)
    |> select([n], n.id)
    |> Repo.one()
  end

  # A node's title is a one-line handle for it; the full text lives in body.
  defp title_of(text) do
    text
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> case do
      "" -> "(empty)"
      t when byte_size(t) <= 110 -> t
      t -> String.slice(t, 0, 110) <> "…"
    end
  end

  defp clean_topic(t) when is_binary(t) do
    t
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.trim_trailing(".")
    |> String.slice(0, 80)
  end

  defp clean_topic(_), do: nil

  # ==========================================================================
  # Querying
  # ==========================================================================

  @doc "Token-scored search over one graph's shared memory."
  def search(graph, query, opts \\ []) do
    terms = terms(query)

    if valid?(graph) do
      Node
      |> where([n], n.graph == ^graph)
      |> maybe_type(opts[:node_type])
      |> order_by([n], desc: n.id)
      |> limit(500)
      |> Repo.all()
      |> score(terms)
      |> Enum.take(opts[:limit] || 15)
      |> Enum.map(&summarize/1)
    else
      []
    end
  end

  @doc """
  Search another book's memory. Kept a separate call rather than folded into
  `search/3` so a Ziggy conversation can never leak into a Lolly answer unless
  the assistant deliberately asks for it.
  """
  def search_across(query, opts \\ []) do
    except = opts[:except]

    @graphs
    |> Enum.reject(&(&1 == except))
    |> Enum.flat_map(fn g ->
      g
      |> search(query, limit: opts[:limit] || 5)
      |> Enum.map(&Map.put(&1, :graph, g))
      |> Enum.map(&Map.put(&1, :graph_label, graph_label(g)))
    end)
  end

  defp maybe_type(q, nil), do: q
  defp maybe_type(q, ""), do: q
  defp maybe_type(q, type), do: where(q, [n], n.node_type == ^type)

  defp terms(query) do
    (query || "")
    |> String.downcase()
    |> String.split(~r/[^a-z0-9]+/, trim: true)
    |> Enum.reject(&(String.length(&1) < 3))
  end

  defp score(nodes, []), do: nodes

  defp score(nodes, terms) do
    nodes
    |> Enum.map(fn n ->
      text = String.downcase("#{n.title} #{n.body}")
      {n, Enum.count(terms, &String.contains?(text, &1))}
    end)
    |> Enum.filter(fn {_n, s} -> s > 0 end)
    |> Enum.sort_by(fn {n, s} -> {-s, -n.id} end)
    |> Enum.map(&elem(&1, 0))
  end

  @doc "The subjects that keep coming up, most-discussed first."
  def topics(graph, limit \\ 40) do
    if valid?(graph) do
      Node
      |> where([n], n.graph == ^graph and n.node_type == "topic")
      |> order_by([n], desc: n.mentions, desc: n.id)
      |> limit(^limit)
      |> Repo.all()
      |> Enum.map(&%{id: &1.id, title: &1.title, mentions: &1.mentions, at: &1.inserted_at})
    else
      []
    end
  end

  @doc "Recent exchanges, newest first, as question/answer pairs."
  def recent_exchanges(graph, limit \\ 20) do
    if valid?(graph) do
      answers =
        Node
        |> where([n], n.graph == ^graph and n.node_type == "answer")
        |> order_by([n], desc: n.id)
        |> limit(^limit)
        |> Repo.all()

      question_ids =
        Edge
        |> where([e], e.to_id in ^Enum.map(answers, & &1.id) and e.edge_type == "answers")
        |> select([e], {e.to_id, e.from_id})
        |> Repo.all()
        |> Map.new()

      questions =
        Node
        |> where([n], n.id in ^Map.values(question_ids))
        |> Repo.all()
        |> Map.new(&{&1.id, &1})

      Enum.map(answers, fn a ->
        q = question_ids |> Map.get(a.id) |> then(&Map.get(questions, &1))

        %{
          answer_id: a.id,
          question: q && q.body,
          answer: a.body,
          at: a.inserted_at,
          conversation_id: a.conversation_id,
          topics: topics_for([a.id, q && q.id])
        }
      end)
    else
      []
    end
  end

  defp topics_for(ids) do
    ids = Enum.reject(ids, &is_nil/1)

    if ids == [] do
      []
    else
      Edge
      |> where([e], e.from_id in ^ids and e.edge_type == "about")
      |> join(:inner, [e], n in Node, on: n.id == e.to_id)
      |> select([_e, n], n.title)
      |> distinct(true)
      |> Repo.all()
    end
  end

  @doc "Everything discussed under one topic."
  def exchanges_for_topic(graph, topic_id) do
    if valid?(graph) do
      Edge
      |> where([e], e.to_id == ^topic_id and e.edge_type == "about")
      |> join(:inner, [e], n in Node, on: n.id == e.from_id)
      |> where([_e, n], n.node_type == "answer")
      |> order_by([_e, n], desc: n.id)
      |> select([_e, n], %{id: n.id, body: n.body, at: n.inserted_at})
      |> limit(25)
      |> Repo.all()
    else
      []
    end
  end

  defp summarize(n) do
    %{
      id: n.id,
      type: n.node_type,
      title: n.title,
      body: n.body,
      mentions: n.mentions,
      at: n.inserted_at
    }
  end

  @doc "Counts for the memory tab header."
  def stats(graph) do
    if valid?(graph) do
      counts =
        Node
        |> where([n], n.graph == ^graph)
        |> group_by([n], n.node_type)
        |> select([n], {n.node_type, count(n.id)})
        |> Repo.all()
        |> Map.new()

      edges =
        Edge
        |> where([e], e.graph == ^graph)
        |> Repo.aggregate(:count, :id)

      %{
        exchanges: Map.get(counts, "answer", 0),
        topics: Map.get(counts, "topic", 0),
        nodes: counts |> Map.values() |> Enum.sum(),
        edges: edges
      }
    else
      %{exchanges: 0, topics: 0, nodes: 0, edges: 0}
    end
  end

  @doc "Forget everything remembered on one graph."
  def forget(graph) do
    if valid?(graph) do
      # edges cascade from the node delete
      Node
      |> where([n], n.graph == ^graph)
      |> Repo.delete_all()
    end

    :ok
  rescue
    _ -> :ok
  end
end
