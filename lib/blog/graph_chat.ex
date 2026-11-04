defmodule Blog.GraphChat do
  @moduledoc """
  Persistent chat history for the decision-graph explorers (/lolly,
  /rooted_in_good, /ziggy).

  Chats are shared: everyone who gets past the page gate sees the same
  conversations and can continue any of them. History is stored per
  `{graph, conversation_id}`.

  `visitor_id` is still recorded on each message as provenance — it says which
  browser session wrote a turn — but it is not part of any read path. Nothing
  here is private between people.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.GraphChat.Message

  # How much of one conversation to rehydrate into the page when it opens.
  @ui_limit 60

  # How much of it to actually send to the model. Every turn resends the whole
  # window, so this is a direct multiplier on tokens per message — keep it well
  # under the UI limit.
  @context_limit 20

  # How many past conversations the browser lists.
  @conversation_limit 50

  # Longest derived title before it gets an ellipsis.
  @title_length 70

  def ui_limit, do: @ui_limit
  def context_limit, do: @context_limit

  @roles ~w(user assistant)

  defp valid?(graph) when is_binary(graph), do: graph != ""
  defp valid?(_graph), do: false

  @doc "A fresh conversation id. Callers hold onto this for the life of the chat."
  def new_conversation_id, do: Ecto.UUID.generate()

  @doc """
  The stored conversation, oldest first, as the plain
  `%{"role" => _, "content" => _}` maps the LiveViews and OpenAI both expect.
  """
  def history(graph, conversation_id, limit \\ @ui_limit)

  def history(graph, conversation_id, limit) when is_binary(conversation_id) do
    if valid?(graph) and conversation_id != "" do
      # newest-first with a limit, then reverse: "the last N" without loading all
      Message
      |> where([m], m.graph == ^graph and m.conversation_id == ^conversation_id)
      |> order_by([m], desc: m.id)
      |> limit(^limit)
      |> select([m], %{role: m.role, content: m.content})
      |> Repo.all()
      |> Enum.reverse()
      |> Enum.map(&%{"role" => &1.role, "content" => &1.content})
    else
      []
    end
  end

  def history(_graph, _conversation_id, _limit), do: []

  @doc """
  The tail of a conversation to send to the model.

  Errors and rate-limit notices are never written to the database, so anything
  in here is real dialogue — the visitor's turns and the assistant's own
  answers.
  """
  def context_window(history, limit \\ @context_limit) when is_list(history) do
    Enum.take(history, -limit)
  end

  @doc """
  Every conversation on one graph, most recently active first.

  Each entry carries a title derived from its opening question (there is no
  stored title — nothing in the UI names a chat), the message count, and when
  it was last touched.
  """
  def list_conversations(graph, limit \\ @conversation_limit)

  def list_conversations(graph, limit) do
    if valid?(graph) do
      summaries =
        Message
        |> where([m], m.graph == ^graph)
        |> group_by([m], m.conversation_id)
        |> order_by([m], desc: max(m.id))
        |> limit(^limit)
        |> select([m], %{
          id: m.conversation_id,
          count: count(m.id),
          last_id: max(m.id),
          last_at: max(m.inserted_at)
        })
        |> Repo.all()

      titles = first_user_messages(graph, Enum.map(summaries, & &1.id))

      Enum.map(summaries, fn s ->
        Map.put(s, :title, titles |> Map.get(s.id) |> to_title())
      end)
    else
      []
    end
  end

  # One extra query rather than N: pull the opening user message of every
  # listed conversation at once.
  defp first_user_messages(_graph, []), do: %{}

  defp first_user_messages(graph, conversation_ids) do
    firsts =
      Message
      |> where(
        [m],
        m.graph == ^graph and m.conversation_id in ^conversation_ids and m.role == "user"
      )
      |> group_by([m], m.conversation_id)
      |> select([m], %{id: m.conversation_id, first_id: min(m.id)})
      |> Repo.all()

    ids = Enum.map(firsts, & &1.first_id)

    Message
    |> where([m], m.id in ^ids)
    |> select([m], {m.conversation_id, m.content})
    |> Repo.all()
    |> Map.new()
  end

  defp to_title(nil), do: "Untitled chat"

  defp to_title(content) do
    content
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> case do
      "" -> "Untitled chat"
      t when byte_size(t) <= @title_length -> t
      t -> String.slice(t, 0, @title_length) <> "…"
    end
  end

  @doc "The conversation most recently written to on this graph, or nil."
  def latest_conversation_id(graph) do
    if valid?(graph) do
      Message
      |> where([m], m.graph == ^graph)
      |> order_by([m], desc: m.id)
      |> limit(1)
      |> select([m], m.conversation_id)
      |> Repo.one()
    end
  end

  @doc "Append one message. Returns :ok even if it can't be stored — chat must not break on a write failure."
  def append(graph, visitor_id, conversation_id, role, content)

  def append(graph, visitor_id, conversation_id, role, content)
      when is_binary(conversation_id) and role in @roles and is_binary(content) do
    if valid?(graph) and is_binary(visitor_id) and visitor_id != "" and conversation_id != "" do
      %Message{}
      |> Message.changeset(%{
        graph: graph,
        visitor_id: visitor_id,
        conversation_id: conversation_id,
        role: role,
        content: content
      })
      |> Repo.insert()
    end

    :ok
  rescue
    # a chat that 500s because the history table is unreachable is worse than a
    # chat that forgets
    _ -> :ok
  end

  def append(_graph, _visitor_id, _conversation_id, _role, _content), do: :ok

  @doc "Delete one conversation."
  def delete_conversation(graph, conversation_id) when is_binary(conversation_id) do
    if valid?(graph) and conversation_id != "" do
      Message
      |> where([m], m.graph == ^graph and m.conversation_id == ^conversation_id)
      |> Repo.delete_all()
    end

    :ok
  rescue
    _ -> :ok
  end

  def delete_conversation(_graph, _conversation_id), do: :ok

  @doc "Forget every conversation on one graph."
  def clear(graph) do
    if valid?(graph) do
      Message
      |> where([m], m.graph == ^graph)
      |> Repo.delete_all()
    end

    :ok
  rescue
    _ -> :ok
  end

  @doc """
  Word-scored search across every conversation on one graph.

  Backs a `recall_conversations` tool: the model can find what it already
  said to earlier visitors instead of repeating itself. Only the exchange
  text is searched; the hit says who said it and when.
  """
  def search(graph, query, limit \\ 8) do
    terms =
      (query || "")
      |> String.downcase()
      |> String.split(~r/[^a-z0-9']+/, trim: true)
      |> Enum.reject(&(String.length(&1) < 3))

    if terms == [] or not valid?(graph) do
      []
    else
      Message
      |> where([m], m.graph == ^graph)
      |> order_by([m], desc: m.id)
      |> limit(400)
      |> select([m], %{role: m.role, content: m.content, at: m.inserted_at})
      |> Repo.all()
      |> Enum.map(fn m ->
        text = String.downcase(m.content || "")
        {m, Enum.count(terms, &String.contains?(text, &1))}
      end)
      |> Enum.filter(fn {_m, n} -> n > 0 end)
      |> Enum.sort_by(fn {_m, n} -> -n end)
      |> Enum.take(limit)
      |> Enum.map(fn {m, _n} ->
        %{who: m.role, said: String.slice(m.content, 0, 600), at: m.at}
      end)
    end
  rescue
    _ -> []
  end

  @doc "How many messages are stored on this graph."
  def count(graph) do
    if valid?(graph) do
      Message
      |> where([m], m.graph == ^graph)
      |> Repo.aggregate(:count, :id)
    else
      0
    end
  rescue
    _ -> 0
  end
end
