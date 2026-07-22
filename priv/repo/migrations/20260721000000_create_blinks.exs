defmodule Blog.Repo.Migrations.CreateBlinks do
  use Ecto.Migration

  def change do
    create table(:blinks) do
      add :url, :text, null: false
      add :title, :text
      add :tags, {:array, :text}, null: false, default: []

      timestamps()
    end

    create unique_index(:blinks, [:url])
    create index(:blinks, [:tags], using: :gin)
  end
end
