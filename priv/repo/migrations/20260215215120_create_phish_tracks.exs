defmodule Blog.Repo.Migrations.CreatePhishTracks do
  use Ecto.Migration

  def change do
    create table(:phish_tracks) do
      add :song_name, :string, null: false
      add :show_date, :date, null: false
      add :set_name, :string
      add :position, :integer
      add :duration_ms, :integer, default: 0
      add :likes, :integer, default: 0
      add :is_jamchart, :boolean, default: false
      add :jam_notes, :text, default: ""
      add :venue, :string
      add :location, :string
      add :jam_url, :string, default: ""

      timestamps()
    end

    create index(:phish_tracks, [:song_name])
    create index(:phish_tracks, [:show_date])
    create index(:phish_tracks, [:song_name, :show_date])
  end
end
