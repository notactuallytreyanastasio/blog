defmodule Blog.Repo.Migrations.AddUniqueIndexToSkeets do
  use Ecto.Migration

  def change do
    create unique_index(:skeets, [:skeet])
  end
end
