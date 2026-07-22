defmodule Blog.Repo.Migrations.AddMetadataAndEmbeddingToBlinks do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    alter table(:blinks) do
      add :favicon_url, :text
      add :image_url, :text
      add :site_name, :text
      add :embedding, {:array, :float}
      add :enriched_at, :naive_datetime
    end
  end

  def down do
    alter table(:blinks) do
      remove :favicon_url
      remove :image_url
      remove :site_name
      remove :embedding
      remove :enriched_at
    end
  end
end
