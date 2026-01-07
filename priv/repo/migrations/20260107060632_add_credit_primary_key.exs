defmodule Blog.Repo.Migrations.AddCreditPrimaryKey do
  use Ecto.Migration

  def change do
    alter table(:rc_credits) do
      add :id, :serial, primary_key: true
    end
  end
end
