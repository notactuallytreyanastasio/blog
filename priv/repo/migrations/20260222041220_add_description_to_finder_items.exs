defmodule Blog.Repo.Migrations.AddDescriptionToFinderItems do
  use Ecto.Migration

  def change do
    alter table(:finder_items) do
      add :description, :string
    end
  end
end
