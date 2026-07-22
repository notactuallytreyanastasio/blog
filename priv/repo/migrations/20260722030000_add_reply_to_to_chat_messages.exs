defmodule Blog.Repo.Migrations.AddReplyToToChatMessages do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      add :reply_to_id, references(:chat_messages, on_delete: :nilify_all)
    end

    create index(:chat_messages, [:reply_to_id])
  end
end
