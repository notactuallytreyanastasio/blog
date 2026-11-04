defmodule Blog.GraphChat.Message do
  @moduledoc "One stored turn of a decision-graph explorer conversation."

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          graph: String.t() | nil,
          visitor_id: String.t() | nil,
          conversation_id: String.t() | nil,
          role: String.t() | nil,
          content: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  @roles ~w(user assistant)

  schema "graph_chat_messages" do
    field :graph, :string
    field :visitor_id, :string
    field :conversation_id, :string
    field :role, :string
    field :content, :string

    timestamps(updated_at: false)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:graph, :visitor_id, :conversation_id, :role, :content])
    |> validate_required([:graph, :visitor_id, :conversation_id, :role, :content])
    |> validate_inclusion(:role, @roles)
  end
end
