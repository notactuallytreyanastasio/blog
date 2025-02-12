defmodule Blog.Repo.Migrations.CreateSparkles do
  use Ecto.Migration

  def change do
    create table(:sparkles) do
      add :content, :text, null: false
      add :author, :string, null: false
      add :sparkle_id, references(:sparkles, on_delete: :delete_all), null: true
      add :root_sparkle_id, references(:sparkles, on_delete: :delete_all), null: true

      timestamps()
    end

    create index(:sparkles, [:sparkle_id])
    create index(:sparkles, [:root_sparkle_id])
    create index(:sparkles, [:author])
  end
end
