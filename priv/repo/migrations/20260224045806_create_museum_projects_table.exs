defmodule Blog.Repo.Migrations.CreateMuseumProjectsTable do
  use Ecto.Migration

  def change do
    create table(:museum_projects) do
      add :slug, :string, null: false
      add :title, :string, null: false
      add :tagline, :string
      add :description, :text
      add :category, :string, null: false
      add :tech_stack, {:array, :string}, default: []
      add :github_repos, {:array, :map}, default: []
      add :internal_path, :string
      add :external_url, :string
      add :pixel_art_path, :string
      add :emoji, :string
      add :color, :string
      add :sort_order, :integer, null: false, default: 0
      add :visible, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:museum_projects, [:slug])
    create index(:museum_projects, [:sort_order])
    create index(:museum_projects, [:category])
  end
end
