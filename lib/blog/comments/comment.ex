defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          post_slug: String.t() | nil,
          author_name: String.t() | nil,
          content: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "post_comments" do
    field :post_slug, :string
    field :author_name, :string
    field :content, :string

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:post_slug, :author_name, :content])
    |> validate_required([:post_slug, :author_name, :content])
    |> validate_length(:author_name, min: 1, max: 100)
    |> validate_length(:content, min: 1, max: 5000)
  end
end
