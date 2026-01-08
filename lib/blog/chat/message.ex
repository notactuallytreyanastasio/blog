defmodule Blog.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :content, :string
    field :room, :string, default: "terminal"

    belongs_to :chatter, Blog.Chat.Chatter

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :room, :chatter_id])
    |> validate_required([:content])
    |> validate_length(:content, min: 1, max: 500)
    |> foreign_key_constraint(:chatter_id)
  end
end
