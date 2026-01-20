defmodule Blog.Repo.Migrations.CreateDrafts do
  use Ecto.Migration

  def change do
    create table(:drafts) do
      add :title, :string
      add :slug, :string
      add :content, :text  # markdown with embedded base64 images
      add :status, :string, default: "draft"  # draft, published
      add :author_id, :string  # optional, for multi-user later

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:drafts, [:slug])
    create index(:drafts, [:status])
    create index(:drafts, [:updated_at])
  end
end
