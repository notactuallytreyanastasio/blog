defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_comments" do
    field :post_slug, :string
    field :author_name, :string
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:post_slug, :author_name, :content])
    |> validate_required([:post_slug, :author_name, :content])
    |> validate_length(:author_name, min: 1, max: 100)
    |> validate_length(:content, min: 1, max: 5000)
  end
end
