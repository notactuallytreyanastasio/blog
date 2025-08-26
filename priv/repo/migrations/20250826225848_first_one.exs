defmodule Blog.Repo.Migrations.FirstOne do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string

      timestamps()
    end
  end
end