defmodule Blog.Repo.Migrations.CreateTagIns do
  use Ecto.Migration

  def change do
    create table(:tag_ins, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_name, :string
      add :spotify_link, :string
      add :note, :text # In migrations, :text is often used for potentially long strings
      add :latitude, :float
      add :longitude, :float

      timestamps(type: :utc_datetime)
    end

    # Optional: Add indexes for fields that will be queried often, e.g., coordinates
    # create index(:tag_ins, [:latitude, :longitude])
  end
end
