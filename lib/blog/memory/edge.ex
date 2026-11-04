defmodule Blog.Memory.Edge do
  @moduledoc "One edge in a visitor's living memory graph."

  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(answers follows about)

  schema "memory_edges" do
    field :graph, :string
    field :visitor_id, :string
    field :from_id, :id
    field :to_id, :id
    field :edge_type, :string

    timestamps(updated_at: false)
  end

  def changeset(edge, attrs) do
    edge
    |> cast(attrs, [:graph, :visitor_id, :from_id, :to_id, :edge_type])
    |> validate_required([:graph, :visitor_id, :from_id, :to_id, :edge_type])
    |> validate_inclusion(:edge_type, @types)
  end
end
