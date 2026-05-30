defmodule Blog.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          content: String.t() | nil,
          room: String.t() | nil,
          chatter_id: integer() | nil,
          chatter: struct() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "chat_messages" do
    field :content, :string
    field :room, :string, default: "terminal"

    belongs_to :chatter, Blog.Chat.Chatter

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :room, :chatter_id])
    |> validate_required([:content])
    |> validate_length(:content, min: 1, max: 500)
    |> foreign_key_constraint(:chatter_id)
  end
end
