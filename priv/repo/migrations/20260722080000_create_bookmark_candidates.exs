defmodule Blog.Repo.Migrations.CreateBookmarkCandidates do
  use Ecto.Migration

  def change do
    create table(:bookmark_candidates) do
      add :url, :text, null: false
      add :title, :text
      add :folder, :text
      add :status, :text, null: false, default: "pending"

      timestamps()
    end

    create unique_index(:bookmark_candidates, [:url])
    create index(:bookmark_candidates, [:status])
  end
end
