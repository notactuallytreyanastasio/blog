defmodule Blog.Chat.Chatter do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          screen_name: String.t() | nil,
          ip_hash: String.t() | nil,
          color: String.t() | nil,
          messages: [struct()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "chatters" do
    field :screen_name, :string
    field :ip_hash, :string
    field :color, :string

    has_many :messages, Blog.Chat.Message

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(chatter, attrs) do
    chatter
    |> cast(attrs, [:screen_name, :ip_hash, :color])
    |> validate_required([:screen_name])
    |> validate_length(:screen_name, min: 1, max: 20)
    |> unique_constraint(:screen_name)
  end

  @doc "Generate a random chat color in HSL format"
  @spec random_color() :: String.t()
  def random_color do
    hue = :rand.uniform(360)
    "hsl(#{hue}, 70%, 40%)"
  end
end
