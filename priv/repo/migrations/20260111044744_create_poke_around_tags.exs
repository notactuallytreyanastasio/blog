defmodule Blog.Repo.Migrations.CreatePokeAroundTags do
  use Ecto.Migration

  def change do
    # Normalized tags table
    create table(:pa_tags) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :usage_count, :integer, default: 0

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pa_tags, [:slug])
    create index(:pa_tags, [:usage_count])

    # Join table for links <-> tags (many-to-many)
    create table(:pa_link_tags, primary_key: false) do
      add :link_id, references(:pa_links, on_delete: :delete_all), null: false
      add :tag_id, references(:pa_tags, on_delete: :delete_all), null: false
      add :source, :string, default: "axon"  # "axon", "ollama", "user", "firehose"
      add :confidence, :float  # Model confidence if available

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pa_link_tags, [:link_id, :tag_id])
    create index(:pa_link_tags, [:tag_id])
  end
end
