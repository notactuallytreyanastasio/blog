defmodule Blog.Museum.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          slug: String.t() | nil,
          title: String.t() | nil,
          tagline: String.t() | nil,
          description: String.t() | nil,
          category: String.t() | nil,
          tech_stack: [String.t()],
          github_repos: [map()],
          internal_path: String.t() | nil,
          external_url: String.t() | nil,
          pixel_art_path: String.t() | nil,
          emoji: String.t() | nil,
          color: String.t() | nil,
          sort_order: integer() | nil,
          visible: boolean() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "museum_projects" do
    field :slug, :string
    field :title, :string
    field :tagline, :string
    field :description, :string
    field :category, :string
    field :tech_stack, {:array, :string}, default: []
    field :github_repos, {:array, :map}, default: []
    field :internal_path, :string
    field :external_url, :string
    field :pixel_art_path, :string
    field :emoji, :string
    field :color, :string
    field :sort_order, :integer, default: 0
    field :visible, :boolean, default: true

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :slug, :title, :tagline, :description, :category,
      :tech_stack, :github_repos, :internal_path, :external_url,
      :pixel_art_path, :emoji, :color, :sort_order, :visible
    ])
    |> validate_required([:slug, :title, :category, :sort_order])
    |> unique_constraint(:slug)
  end
end
