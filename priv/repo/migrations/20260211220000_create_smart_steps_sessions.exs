defmodule Blog.Repo.Migrations.CreateSmartStepsSessions do
  use Ecto.Migration

  def change do
    create table(:smart_steps_sessions) do
      add :session_id, :string, null: false
      add :title, :string
      add :tree_id, :string
      add :level_data, {:array, :map}, default: []
      add :average_metrics, :map, default: %{}
      add :outcome_type, :string
      add :total_levels, :integer
      add :completed, :boolean, default: false

      timestamps()
    end

    create unique_index(:smart_steps_sessions, [:session_id])
  end
end
