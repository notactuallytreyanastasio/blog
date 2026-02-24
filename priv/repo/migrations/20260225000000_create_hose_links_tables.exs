defmodule Blog.Repo.Migrations.CreateHoseLinksTables do
  use Ecto.Migration

  def change do
    create table(:hose_links) do
      add :normalized_url, :string, null: false
      add :observations, :integer, null: false, default: 1
      add :first_seen_at, :utc_datetime, null: false
      add :last_seen_at, :utc_datetime, null: false
      add :sample_raw_urls, {:array, :string}, default: []
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:hose_links, [:normalized_url])
    create index(:hose_links, [:expires_at])
    create index(:hose_links, [:observations])

    create table(:breakthrough_links) do
      add :normalized_url, :string, null: false
      add :observations_at_breakthrough, :integer, null: false
      add :peak_observations, :integer, null: false
      add :first_seen_at, :utc_datetime, null: false
      add :breakthrough_at, :utc_datetime, null: false
      add :sample_raw_urls, {:array, :string}, default: []
      add :domain, :string

      timestamps()
    end

    create unique_index(:breakthrough_links, [:normalized_url])
    create index(:breakthrough_links, [:domain])
    create index(:breakthrough_links, [:breakthrough_at])
  end
end
