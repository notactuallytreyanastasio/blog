defmodule Blog.Editor.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :status, :string, default: "draft"
    field :author_id, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :slug, :content, :status, :author_id])
    |> validate_required([:content])
    |> validate_inclusion(:status, ["draft", "published"])
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        title = get_field(changeset, :title) || "untitled"
        timestamp = DateTime.utc_now() |> DateTime.to_unix()
        slug = slugify(title) <> "-#{timestamp}"
        put_change(changeset, :slug, slug)

      _ ->
        changeset
    end
  end

  defp slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/[\s_-]+/, "-")
    |> String.trim("-")
  end
end
