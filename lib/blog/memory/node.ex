defmodule Blog.Memory.Node do
  @moduledoc "One node in a visitor's living memory graph for a book."

  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(question answer topic)

  schema "memory_nodes" do
    field :graph, :string
    field :visitor_id, :string
    field :node_type, :string
    field :title, :string
    field :body, :string
    field :conversation_id, :string
    field :ref_node_id, :integer
    field :mentions, :integer, default: 1

    timestamps(updated_at: false)
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [
      :graph,
      :visitor_id,
      :node_type,
      :title,
      :body,
      :conversation_id,
      :ref_node_id,
      :mentions
    ])
    |> validate_required([:graph, :visitor_id, :node_type, :title])
    |> validate_inclusion(:node_type, @types)
  end
end
