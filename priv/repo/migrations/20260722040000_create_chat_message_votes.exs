defmodule Blog.Repo.Migrations.CreateChatMessageVotes do
  use Ecto.Migration

  def change do
    create table(:chat_message_votes) do
      add :message_id, references(:chat_messages, on_delete: :delete_all), null: false
      add :chatter_id, references(:chatters, on_delete: :delete_all), null: false
      add :value, :integer, null: false

      timestamps()
    end

    create unique_index(:chat_message_votes, [:message_id, :chatter_id])
    create index(:chat_message_votes, [:message_id])
  end
end
