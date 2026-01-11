defmodule Blog.PokeAround.Tag do
  @moduledoc """
  A tag for categorizing links.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "pa_tags" do
    field :name, :string
    field :slug, :string
    field :usage_count, :integer, default: 0

    many_to_many :links, Blog.PokeAround.Link, join_through: "pa_link_tags"

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:name, :slug]
  @optional_fields [:usage_count]

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug)
  end

  @doc """
  Generate a slug from a tag name.
  Lowercases and replaces spaces with hyphens.
  """
  def slugify(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\-]/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end
