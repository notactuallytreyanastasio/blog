defmodule Blog.Repo.Migrations.AddAuthorToDrafts do
  use Ecto.Migration

  def change do
    alter table(:drafts) do
      add :author_name, :string
      add :author_email, :string
    end

    create index(:drafts, [:author_email])
  end
end
