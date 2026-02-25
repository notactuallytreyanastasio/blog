defmodule Blog.Repo.Migrations.CreateWorkLogCommits do
  use Ecto.Migration

  def change do
    create table(:work_log_commits) do
      add :event_id, :string, null: false
      add :repo, :string, null: false
      add :branch, :string, null: false
      add :sha, :string, null: false
      add :message, :text
      add :additions, :integer, null: false, default: 0
      add :deletions, :integer, null: false, default: 0
      add :committed_at, :utc_datetime

      timestamps()
    end

    create unique_index(:work_log_commits, [:sha])
    create index(:work_log_commits, [:committed_at])
  end
end
