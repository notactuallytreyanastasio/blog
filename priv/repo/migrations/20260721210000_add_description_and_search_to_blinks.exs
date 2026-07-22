defmodule Blog.Repo.Migrations.AddDescriptionAndSearchToBlinks do
  use Ecto.Migration

  def up do
    alter table(:blinks) do
      add :description, :text
    end

    # array_to_string is only STABLE, which Postgres rejects in generated
    # columns; wrapping it in a function we declare IMMUTABLE is the standard
    # workaround (safe here: text-array formatting is deterministic).
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
  end

  def down do
    execute "ALTER TABLE blinks DROP COLUMN search_vector"
    execute "DROP FUNCTION blinks_search_text(text, text, text[], text)"

    alter table(:blinks) do
      remove :description
    end
  end
end
