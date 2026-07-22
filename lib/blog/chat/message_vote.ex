defmodule Blog.Chat.MessageVote do
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer() | nil,
          message_id: integer() | nil,
          chatter_id: integer() | nil,
          value: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "chat_message_votes" do
    field :value, :integer

    belongs_to :message, Blog.Chat.Message
    belongs_to :chatter, Blog.Chat.Chatter

    timestamps()
  end
end
