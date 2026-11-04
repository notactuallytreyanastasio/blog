defmodule Blog.Repo.Migrations.CreateMemoryGraph do
  use Ecto.Migration

  def change do
    # A decision graph that is written at runtime as people chat, rather than
    # exported from deciduous ahead of time — hence tables rather than a JSON
    # file in priv/.
    create table(:memory_nodes) do
      add :graph, :string, null: false
      add :visitor_id, :string, null: false
      # question | answer | topic
      add :node_type, :string, null: false
      add :title, :text, null: false
      add :body, :text
      # which chat this came out of (null for topics, which span chats)
      add :conversation_id, :string
      # when the node points at a node in the *book* graph, its id there
      add :ref_node_id, :integer
      add :mentions, :integer, null: false, default: 1

      timestamps(updated_at: false)
    end

    create index(:memory_nodes, [:graph, :visitor_id, :id])
    create index(:memory_nodes, [:graph, :visitor_id, :node_type])
    # topics are deduped by title so repeated subjects accumulate mentions
    # instead of piling up duplicate nodes
    create unique_index(:memory_nodes, [:graph, :visitor_id, :node_type, :title],
             where: "node_type = 'topic'",
             name: :memory_nodes_unique_topic
           )

    create table(:memory_edges) do
      add :graph, :string, null: false
      add :visitor_id, :string, null: false
      add :from_id, references(:memory_nodes, on_delete: :delete_all), null: false
      add :to_id, references(:memory_nodes, on_delete: :delete_all), null: false
      # answers | follows | about
      add :edge_type, :string, null: false

      timestamps(updated_at: false)
    end

    create index(:memory_edges, [:graph, :visitor_id])
    create index(:memory_edges, [:from_id])
    create index(:memory_edges, [:to_id])
    create unique_index(:memory_edges, [:from_id, :to_id, :edge_type])
  end
end
