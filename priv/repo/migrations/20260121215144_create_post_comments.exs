defmodule Blog.Repo.Migrations.CreatePostComments do
  use Ecto.Migration

  def change do
    create table(:post_comments) do
      add :post_slug, :string, null: false
      add :author_name, :string, null: false
      add :content, :text, null: false

      timestamps()
    end

    create index(:post_comments, [:post_slug, :inserted_at])
  end
end
