defmodule Blog.Repo.Migrations.CreatePokeAroundLinks do
  use Ecto.Migration

  def change do
    create table(:pa_links) do
      # The actual URL
      add :url, :text, null: false

      # Normalized URL for deduplication (lowercase, no trailing slash, etc.)
      add :url_hash, :string, null: false

      # Source post info
      add :post_uri, :string
      add :post_text, :text
      add :post_created_at, :utc_datetime_usec

      # Author info (denormalized for fast reads)
      add :author_did, :string
      add :author_handle, :string
      add :author_display_name, :string
      add :author_followers_count, :integer

      # Quality score (0-100)
      add :score, :integer, default: 0

      # Link metadata (fetched later via unfurl)
      add :title, :text
      add :description, :text
      add :image_url, :text
      add :domain, :string

      # Tags for categorization (legacy array field)
      add :tags, {:array, :string}, default: []

      # Languages
      add :langs, {:array, :string}, default: []

      # State
      add :stumble_count, :integer, default: 0

      # Tagging status
      add :tagged_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    # Unique on normalized URL hash
    create unique_index(:pa_links, [:url_hash])

    # For random stumbling - fetch random links efficiently
    create index(:pa_links, [:score])
    create index(:pa_links, [:inserted_at])
    create index(:pa_links, [:domain])
    create index(:pa_links, [:tagged_at])

    # For filtering by tags and langs
    create index(:pa_links, [:tags], using: "gin")
    create index(:pa_links, [:langs], using: "gin")
  end
end
