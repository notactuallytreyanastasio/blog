defmodule Blog.Museum.Project do
  use Ecto.Schema
  import Ecto.Changeset

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
