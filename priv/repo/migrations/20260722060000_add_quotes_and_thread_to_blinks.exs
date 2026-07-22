defmodule Blog.Repo.Migrations.AddQuotesAndThreadToBlinks do
  use Ecto.Migration

  def up do
    alter table(:blinks) do
      add :quotes, {:array, :text}, null: false, default: []
      add :thread, :map
    end

    # rebuild the FTS column so quotes are searchable too
    execute "ALTER TABLE blinks DROP COLUMN search_vector"
    execute "DROP FUNCTION blinks_search_text(text, text, text[], text)"

    execute """
    CREATE FUNCTION blinks_search_text(title text, description text, tags text[], quotes text[], url text)
    RETURNS text LANGUAGE sql IMMUTABLE AS
    'SELECT coalesce(title, '''') || '' '' || coalesce(description, '''') || '' '' ||
            coalesce(array_to_string(tags, '' ''), '''') || '' '' ||
            coalesce(array_to_string(quotes, '' ''), '''') || '' '' || coalesce(url, '''')'
    """

    execute """
    ALTER TABLE blinks ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english', blinks_search_text(title, description, tags, quotes, url))
    ) STORED
    """

    create index(:blinks, [:search_vector], using: :gin)
  end

  def down do
    execute "ALTER TABLE blinks DROP COLUMN search_vector"
    execute "DROP FUNCTION blinks_search_text(text, text, text[], text[], text)"

    execute """
    CREATE FUNCTION blinks_search_text(title text, description text, tags text[], url text)
    RETURNS text LANGUAGE sql IMMUTABLE AS
    'SELECT coalesce(title, '''') || '' '' || coalesce(description, '''') || '' '' ||
            coalesce(array_to_string(tags, '' ''), '''') || '' '' || coalesce(url, '''')'
    """

    execute """
    ALTER TABLE blinks ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english', blinks_search_text(title, description, tags, url))
    ) STORED
    """

    create index(:blinks, [:search_vector], using: :gin)

    alter table(:blinks) do
      remove :quotes
      remove :thread
    end
  end
end
