defmodule Blog.Repo.Migrations.AddFailCountToBlinks do
  use Ecto.Migration

  def change do
    alter table(:blinks) do
      add :fail_count, :integer, null: false, default: 0
    end
  end
end
