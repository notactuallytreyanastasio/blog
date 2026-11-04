defmodule Blog.Repo.Migrations.AddConversationToGraphChatMessages do
  use Ecto.Migration

  def up do
    alter table(:graph_chat_messages) do
      add :conversation_id, :string
    end

    # Existing rows were one undifferentiated stream per visitor+graph. Fold
    # each of those streams into a single conversation so nothing is orphaned
    # and old chats still open in the browser.
    execute """
    UPDATE graph_chat_messages m
    SET conversation_id = c.generated
    FROM (
      SELECT graph, visitor_id, md5(graph || ':' || visitor_id) AS generated
      FROM graph_chat_messages
      GROUP BY graph, visitor_id
    ) c
    WHERE m.graph = c.graph
      AND m.visitor_id = c.visitor_id
      AND m.conversation_id IS NULL
    """

    alter table(:graph_chat_messages) do
      modify :conversation_id, :string, null: false
    end

    # listing conversations and reading one both key off this
    create index(:graph_chat_messages, [:graph, :visitor_id, :conversation_id, :id])
  end

  def down do
    drop index(:graph_chat_messages, [:graph, :visitor_id, :conversation_id, :id])

    alter table(:graph_chat_messages) do
      remove :conversation_id
    end
  end
end
