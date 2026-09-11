defmodule Blog.Repo.Migrations.CreateCameraListings do
  use Ecto.Migration

  def change do
    create table(:camera_listings) do
      add :posting_id, :bigint, null: false
      add :area, :string, null: false
      add :subarea, :string
      add :location, :string
      add :neighborhood, :string
      add :title, :string, null: false
      add :price_cents, :integer
      add :url, :string, null: false
      add :lat, :float
      add :lng, :float
      add :category_id, :integer

      # full post, filled by the detail fetch
      add :body, :text
      add :attrs, :map, null: false, default: %{}
      add :image_ids, {:array, :string}, null: false, default: []
      add :mirrored_images, {:array, :string}, null: false, default: []
      add :reply_url, :string
      add :contact, :map, null: false, default: %{}
      add :posted_at, :utc_datetime
      add :renewed_at, :utc_datetime
      add :cl_updated_at, :utc_datetime
      add :detail_fetched_at, :utc_datetime

      # which of our searches surfaced it, and what we make of it
      add :queries, {:array, :string}, null: false, default: []
      add :tags, {:array, :string}, null: false, default: []
      add :score, :integer, null: false, default: 0

      # lifecycle
      add :first_seen_at, :utc_datetime, null: false
      add :last_seen_at, :utc_datetime, null: false
      add :closed_at, :utc_datetime
      add :closed_reason, :string

      # our own curation
      add :starred_at, :utc_datetime
      add :hidden_at, :utc_datetime
      add :note, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:camera_listings, [:posting_id])
    create index(:camera_listings, [:closed_at])
    create index(:camera_listings, [:area, :subarea])
    create index(:camera_listings, [:posted_at])
    create index(:camera_listings, [:score])
  end
end
