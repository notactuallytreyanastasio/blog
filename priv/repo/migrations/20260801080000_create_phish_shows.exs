defmodule Blog.Repo.Migrations.CreatePhishShows do
  use Ecto.Migration

  def change do
    create table(:phish_shows) do
      add :date, :date, null: false
      add :venue, :string, null: false
      add :location, :string, default: ""
      add :city, :string, default: ""
      add :state, :string, default: ""
      add :country, :string, default: ""
      add :latitude, :float
      add :longitude, :float
      add :tour_name, :string, default: ""

      timestamps()
    end

    create unique_index(:phish_shows, [:date])
  end
end
