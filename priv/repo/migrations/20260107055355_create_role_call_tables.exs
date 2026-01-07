defmodule Blog.Repo.Migrations.CreateRoleCallTables do
  use Ecto.Migration

  def change do
    # TV Shows table
    create table(:rc_shows, primary_key: false) do
      add :id, :string, primary_key: true  # IMDB tt ID (e.g., tt0496424)
      add :title, :string, null: false
      add :year_start, :integer
      add :year_end, :integer
      add :imdb_rating, :float
      add :genres, :string  # JSON array stored as string
      add :description, :text
      add :image_url, :string
      add :scraped_at, :utc_datetime

      timestamps()
    end

    # People table (writers, actors, directors, creators)
    create table(:rc_people, primary_key: false) do
      add :id, :string, primary_key: true  # IMDB nm ID (e.g., nm0000114)
      add :name, :string, null: false
      add :image_url, :string
      add :scraped_at, :utc_datetime

      timestamps()
    end

    # Credits table - links shows to people with roles
    create table(:rc_credits, primary_key: false) do
      add :show_id, references(:rc_shows, type: :string, on_delete: :delete_all), null: false
      add :person_id, references(:rc_people, type: :string, on_delete: :delete_all), null: false
      add :role, :string, null: false  # 'writer', 'actor', 'director', 'creator'
      add :details, :string  # e.g., "38 episodes", character name
    end

    # Composite primary key for credits
    create unique_index(:rc_credits, [:show_id, :person_id, :role])

    # Indexes for fast lookups
    create index(:rc_credits, [:person_id])
    create index(:rc_credits, [:role])
    create index(:rc_shows, [:imdb_rating])
  end
end
