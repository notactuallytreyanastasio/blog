defmodule Blog.Repo.Migrations.DropBlinksEmbedding do
  use Ecto.Migration

  def change do
    alter table(:blinks) do
      remove :embedding, {:array, :float}
    end
  end
end
