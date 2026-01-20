defmodule Blog.Editor.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :status, :string, default: "draft"
    field :author_id, :string
    field :author_name, :string
    field :author_email, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :slug, :content, :status, :author_id, :author_name, :author_email])
    # Don't require content for drafts - allow empty drafts
    |> validate_inclusion(:status, ["draft", "published"])
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  @doc "Changeset for publishing - requires author info"
  def publish_changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :slug, :content, :status, :author_name, :author_email])
    |> validate_required([:content, :title, :author_name, :author_email])
    |> validate_format(:author_email, ~r/@/)
    |> validate_length(:author_name, min: 1, max: 100)
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
