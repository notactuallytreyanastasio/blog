defmodule Blog.Social.Skeet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skeets" do
    field :skeet, :string

    timestamps()
  end

  def changeset(skeet, attrs) do
    skeet
    |> cast(attrs, [:skeet])
    |> validate_required([:skeet])
  end
end
