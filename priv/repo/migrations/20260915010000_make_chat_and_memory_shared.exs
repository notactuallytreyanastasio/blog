defmodule Blog.Repo.Migrations.MakeChatAndMemoryShared do
  use Ecto.Migration

  @moduledoc """
  Chats and memory are shared by everyone who can get past the page gate, so
  nothing is scoped per visitor any more.

  `visitor_id` stays on both tables as provenance — it still records who wrote
  a turn — but it is no longer part of any read path or uniqueness rule.
  """

  def up do
    # Topics dedupe per graph now, not per graph+visitor. Fold any duplicates
    # that already exist into the lowest id, moving their edges across, so the
    # new unique index can be created.
    execute """
    WITH keep AS (
      SELECT graph, title, MIN(id) AS keep_id
      FROM memory_nodes
      WHERE node_type = 'topic'
      GROUP BY graph, title
    ),
    dupes AS (
      SELECT n.id AS dupe_id, k.keep_id
      FROM memory_nodes n
      JOIN keep k ON k.graph = n.graph AND k.title = n.title
      WHERE n.node_type = 'topic' AND n.id <> k.keep_id
    )
    UPDATE memory_edges e
    SET to_id = d.keep_id
    FROM dupes d
    WHERE e.to_id = d.dupe_id
    """

    execute """
    WITH keep AS (
      SELECT graph, title, MIN(id) AS keep_id
      FROM memory_nodes
      WHERE node_type = 'topic'
      GROUP BY graph, title
    )
    UPDATE memory_nodes n
    SET mentions = sub.total
    FROM (
      SELECT k.keep_id, SUM(m.mentions) AS total
      FROM memory_nodes m
      JOIN keep k ON k.graph = m.graph AND k.title = m.title
      WHERE m.node_type = 'topic'
      GROUP BY k.keep_id
    ) sub
    WHERE n.id = sub.keep_id
    """

    execute """
    DELETE FROM memory_nodes n
    USING (
      SELECT graph, title, MIN(id) AS keep_id
      FROM memory_nodes
      WHERE node_type = 'topic'
      GROUP BY graph, title
    ) k
    WHERE n.node_type = 'topic'
      AND n.graph = k.graph
      AND n.title = k.title
      AND n.id <> k.keep_id
    """

    drop_if_exists index(:memory_nodes, [:graph, :visitor_id, :node_type, :title],
                     name: :memory_nodes_unique_topic
                   )

    create unique_index(:memory_nodes, [:graph, :title],
             where: "node_type = 'topic'",
             name: :memory_nodes_unique_topic
           )

    # reads key off graph (+ type) now that visitor is out of the picture
    create_if_not_exists index(:memory_nodes, [:graph, :node_type, :id])
    create_if_not_exists index(:graph_chat_messages, [:graph, :conversation_id, :id])
  end

  def down do
    drop_if_exists index(:memory_nodes, [:graph, :title], name: :memory_nodes_unique_topic)

    create unique_index(:memory_nodes, [:graph, :visitor_id, :node_type, :title],
             where: "node_type = 'topic'",
             name: :memory_nodes_unique_topic
           )

    drop_if_exists index(:memory_nodes, [:graph, :node_type, :id])
    drop_if_exists index(:graph_chat_messages, [:graph, :conversation_id, :id])
  end
end
