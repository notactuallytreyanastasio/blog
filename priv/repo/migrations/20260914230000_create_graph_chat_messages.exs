defmodule Blog.Repo.Migrations.CreateGraphChatMessages do
  use Ecto.Migration

  def change do
    create table(:graph_chat_messages) do
      # which explorer the message belongs to: "lolly", "rooted", "ziggy"
      add :graph, :string, null: false
      # the session user_id from BlogWeb.Plugs.EnsureUserId
      add :visitor_id, :string, null: false
      add :role, :string, null: false
      add :content, :text, null: false

      timestamps(updated_at: false)
    end

    # the only read path is "the most recent messages for this visitor on this
    # graph", so index exactly that and let id carry the ordering
    create index(:graph_chat_messages, [:graph, :visitor_id, :id])
  end
end
