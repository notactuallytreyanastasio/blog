defmodule Blog.PokeAround.LinkTag do
  @moduledoc """
  Join table between links and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(link_tag, attrs) do
    link_tag
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:link_id, :tag_id])
  end
end
