defmodule Blog.Repo.Migrations.CreateSkeets do
  use Ecto.Migration

  def change do
    create table(:skeets) do
      add :skeet, :text, null: false

      timestamps()
    end
  end
end 
