defmodule Blog.Repo.Migrations.CreateFinderTables do
  use Ecto.Migration

  def change do
    create table(:finder_sections) do
      add :name, :string, null: false
      add :label, :string
      add :sort_order, :integer, null: false, default: 0
      add :joyride_target, :string
      add :visible, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:finder_sections, [:name])
    create index(:finder_sections, [:sort_order])

    create table(:finder_items) do
      add :name, :string, null: false
      add :icon, :string, null: false
      add :path, :string
      add :sort_order, :integer, null: false, default: 0
      add :joyride_target, :string
      add :action, :string
      add :visible, :boolean, default: true, null: false
      add :section_id, references(:finder_sections, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:finder_items, [:section_id])
    create index(:finder_items, [:section_id, :sort_order])
  end
end
