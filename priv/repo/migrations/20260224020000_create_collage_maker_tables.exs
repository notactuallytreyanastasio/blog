defmodule Blog.Repo.Migrations.CreateCollageMakerTables do
  use Ecto.Migration

  def change do
    create table(:collage_maker_collages) do
      add :status, :string, null: false, default: "uploading"
      add :columns, :integer, null: false, default: 3
      add :cell_size, :integer
      add :image_count, :integer
      add :collage_s3_key, :string
      add :collage_width, :integer
      add :collage_height, :integer
      add :collage_file_size, :integer
      add :ip_hash, :string
      add :error_message, :text
      add :share_token, :string
      add :expires_at, :utc_datetime

      timestamps()
    end

    create index(:collage_maker_collages, [:ip_hash])
    create index(:collage_maker_collages, [:status])
    create index(:collage_maker_collages, [:expires_at])
    create unique_index(:collage_maker_collages, [:share_token])

    create table(:collage_maker_images) do
      add :collage_id, references(:collage_maker_collages, on_delete: :delete_all), null: false
      add :position, :integer, null: false
      add :original_s3_key, :string, null: false
      add :cropped_s3_key, :string
      add :original_width, :integer
      add :original_height, :integer
      add :content_type, :string
      add :file_size, :integer

      timestamps()
    end

    create index(:collage_maker_images, [:collage_id])
    create unique_index(:collage_maker_images, [:collage_id, :position])
  end
end
