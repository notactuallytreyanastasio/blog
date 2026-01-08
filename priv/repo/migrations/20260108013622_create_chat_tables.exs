defmodule Blog.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:chatters) do
      add :screen_name, :string, null: false
      add :ip_hash, :string
      add :color, :string

      timestamps()
    end

    create unique_index(:chatters, [:screen_name])
    create index(:chatters, [:ip_hash])

    create table(:chat_messages) do
      add :content, :text, null: false
      add :room, :string, default: "terminal"
      add :chatter_id, references(:chatters, on_delete: :nilify_all)

      timestamps()
    end

    create index(:chat_messages, [:room, :inserted_at])
    create index(:chat_messages, [:chatter_id])
  end
end
