defmodule Blog.Repo.Migrations.CreateGifMakerTables do
  use Ecto.Migration

  def change do
    create table(:gif_maker_jobs) do
      add :youtube_url, :string, null: false
      add :video_id, :string, null: false
      add :title, :string
      add :duration_seconds, :integer
      add :start_time_ms, :integer, null: false
      add :end_time_ms, :integer, null: false
      add :status, :string, null: false, default: "pending"
      add :ip_hash, :string
      add :error_message, :text
      add :frame_count, :integer
      add :expires_at, :utc_datetime

      timestamps()
    end

    create index(:gif_maker_jobs, [:ip_hash])
    create index(:gif_maker_jobs, [:status])
    create index(:gif_maker_jobs, [:expires_at])

    create table(:gif_maker_frames) do
      add :job_id, references(:gif_maker_jobs, on_delete: :delete_all), null: false
      add :frame_number, :integer, null: false
      add :timestamp_ms, :integer, null: false
      add :image_data, :binary, null: false
      add :file_size, :integer

      timestamps()
    end

    create index(:gif_maker_frames, [:job_id])
    create unique_index(:gif_maker_frames, [:job_id, :frame_number])

    create table(:gif_maker_gifs) do
      add :job_id, references(:gif_maker_jobs, on_delete: :delete_all), null: false
      add :hash, :string, null: false
      add :frame_indices, {:array, :integer}, null: false
      add :gif_data, :binary, null: false
      add :frame_count, :integer
      add :duration_ms, :integer
      add :file_size, :integer

      timestamps()
    end

    create unique_index(:gif_maker_gifs, [:hash])
    create index(:gif_maker_gifs, [:job_id])
  end
end
