defmodule JobProcessor.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :status, :string, null: false, default: "queued"
      add :payload, :binary, null: false
      add :attempts, :integer, default: 0
      add :max_attempts, :integer, default: 3
      add :scheduled_at, :utc_datetime
      add :started_at, :utc_datetime
      add :completed_at, :utc_datetime
      add :error_message, :text

      timestamps()
    end

    create index(:jobs, [:status])
    create index(:jobs, [:scheduled_at])
    create index(:jobs, [:status, :scheduled_at])
  end
end