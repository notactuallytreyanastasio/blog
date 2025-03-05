defmodule Blog.Repo.Migrations.CreateTestTable do
  use Ecto.Migration

  def change do
    create table(:test_table) do
      add :name, :string
      add :description, :text

      timestamps()
    end
  end
end
