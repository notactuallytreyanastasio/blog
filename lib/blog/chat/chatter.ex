defmodule Blog.Chat.Chatter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chatters" do
    field :screen_name, :string
    field :ip_hash, :string
    field :color, :string

    has_many :messages, Blog.Chat.Message

    timestamps()
  end

  @doc false
  def changeset(chatter, attrs) do
    chatter
    |> cast(attrs, [:screen_name, :ip_hash, :color])
    |> validate_required([:screen_name])
    |> validate_length(:screen_name, min: 1, max: 20)
    |> unique_constraint(:screen_name)
  end

  @doc "Generate a random chat color in HSL format"
  def random_color do
    hue = :rand.uniform(360)
    "hsl(#{hue}, 70%, 40%)"
  end
end
