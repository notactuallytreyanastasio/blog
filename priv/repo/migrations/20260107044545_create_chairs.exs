defmodule Blog.Repo.Migrations.CreateChairs do
  use Ecto.Migration

  def change do
    create table(:chairs) do
      add :legs, :integer

      timestamps()
    end
  end
end
