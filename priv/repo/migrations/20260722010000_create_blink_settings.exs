defmodule Blog.Repo.Migrations.CreateBlinkSettings do
  use Ecto.Migration

  def change do
    create table(:blink_settings) do
      add :key, :text, null: false
      add :value, {:array, :text}, null: false, default: []

      timestamps()
    end

    create unique_index(:blink_settings, [:key])
  end
end
