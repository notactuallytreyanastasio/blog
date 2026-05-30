defmodule Blog.PokeAround.LinkTag do
  @moduledoc """
  Join table between links and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          link_id: integer() | nil,
          link: Ecto.Association.NotLoaded.t() | struct() | nil,
          tag_id: integer() | nil,
          tag: Ecto.Association.NotLoaded.t() | struct() | nil,
          source: String.t() | nil,
          confidence: float() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key false
  schema "pa_link_tags" do
    belongs_to :link, Blog.PokeAround.Link
    belongs_to :tag, Blog.PokeAround.Tag

    field :source, :string, default: "axon"
    field :confidence, :float

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:link_id, :tag_id]
  @optional_fields [:source, :confidence]

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(link_tag, attrs) do
    link_tag
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:link_id, :tag_id])
  end
end
