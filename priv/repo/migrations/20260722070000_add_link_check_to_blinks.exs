defmodule Blog.Repo.Migrations.AddLinkCheckToBlinks do
  use Ecto.Migration

  def change do
    alter table(:blinks) do
      add :dead_at, :naive_datetime
      add :last_checked_at, :naive_datetime
    end
  end
end
