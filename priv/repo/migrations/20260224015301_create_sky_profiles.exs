defmodule Blog.Repo.Migrations.CreateSkyProfiles do
  use Ecto.Migration

  def change do
    create table(:sky_profiles) do
      add :handle, :string
      add :did, :string
      add :display_name, :string
      add :bio, :text
      add :avatar_url, :string
      add :followers_count, :integer, default: 0
      add :following_count, :integer, default: 0
      add :community_index, :integer
    end

    create index(:sky_profiles, [:handle])
    create index(:sky_profiles, [:community_index])
  end
end
