defmodule Mix.Tasks.PokeAround.Migrate do
  @moduledoc """
  Migrates data from the poke_around database to the blog database.

  ## Usage

      mix poke_around.migrate

  ## Options

      --source-db NAME    Source database name (default: poke_around_dev)
      --source-host HOST  Source database host (default: localhost)
      --source-user USER  Source database user (default: postgres)
      --source-pass PASS  Source database password (default: postgres)
      --dry-run           Show what would be migrated without actually migrating

  ## Examples

      # Migrate from default dev database
      mix poke_around.migrate

      # Migrate from production database
      mix poke_around.migrate --source-db poke_around_prod --source-host prod.example.com

      # Preview without migrating
      mix poke_around.migrate --dry-run
  """

  use Mix.Task

  require Logger

  @shortdoc "Migrates data from poke_around database to blog database"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} = OptionParser.parse(args,
      switches: [
        source_db: :string,
        source_host: :string,
        source_user: :string,
        source_pass: :string,
        dry_run: :boolean
      ]
    )

    # Start the applications we need
    Application.ensure_all_started(:postgrex)
    {:ok, _} = Application.ensure_all_started(:blog)

    source_config = [
      hostname: opts[:source_host] || "localhost",
      username: opts[:source_user] || "postgres",
      password: opts[:source_pass] || "postgres",
      database: opts[:source_db] || "poke_around_dev"
    ]

    dry_run = opts[:dry_run] || false

    Mix.shell().info("Connecting to source database: #{source_config[:database]}@#{source_config[:hostname]}")

    case Postgrex.start_link(source_config) do
      {:ok, source_conn} ->
        migrate_data(source_conn, dry_run)
        GenServer.stop(source_conn)
        Mix.shell().info("Migration complete!")

      {:error, reason} ->
        Mix.shell().error("Failed to connect to source database: #{inspect(reason)}")
        exit({:shutdown, 1})
    end
  end

  defp migrate_data(source_conn, dry_run) do
    # Migrate in order: tags first (no dependencies), then links, then link_tags
    migrate_tags(source_conn, dry_run)
    migrate_links(source_conn, dry_run)
    migrate_link_tags(source_conn, dry_run)
  end

  defp migrate_tags(source_conn, dry_run) do
    Mix.shell().info("\n--- Migrating Tags ---")

    {:ok, result} = Postgrex.query(source_conn, "SELECT id, name, slug, usage_count, inserted_at, updated_at FROM tags", [])

    Mix.shell().info("Found #{result.num_rows} tags in source database")

    if dry_run do
      Mix.shell().info("[DRY RUN] Would migrate #{result.num_rows} tags")
    else
      inserted = Enum.reduce(result.rows, 0, fn row, count ->
        [id, name, slug, usage_count, inserted_at, updated_at] = row

        attrs = %{
          name: name,
          slug: slug,
          usage_count: usage_count || 0,
          inserted_at: inserted_at,
          updated_at: updated_at
        }

        case insert_tag(attrs) do
          {:ok, _} -> count + 1
          {:error, :exists} -> count
          {:error, reason} ->
            Mix.shell().error("Failed to insert tag #{name}: #{inspect(reason)}")
            count
        end
      end)

      Mix.shell().info("Inserted #{inserted} new tags")
    end
  end

  defp insert_tag(attrs) do
    # Check if tag already exists
    case Blog.Repo.get_by(Blog.PokeAround.Tag, slug: attrs.slug) do
      nil ->
        %Blog.PokeAround.Tag{}
        |> Ecto.Changeset.change(attrs)
        |> Blog.Repo.insert()

      _existing ->
        {:error, :exists}
    end
  end

  defp migrate_links(source_conn, dry_run) do
    Mix.shell().info("\n--- Migrating Links ---")

    query = """
    SELECT id, url, url_hash, post_uri, post_text, post_created_at,
           author_did, author_handle, author_display_name, author_followers_count,
           score, domain, tags, langs, stumble_count, tagged_at, inserted_at, updated_at
    FROM links
    """

    {:ok, result} = Postgrex.query(source_conn, query, [])

    Mix.shell().info("Found #{result.num_rows} links in source database")

    if dry_run do
      Mix.shell().info("[DRY RUN] Would migrate #{result.num_rows} links")
    else
      inserted = Enum.reduce(result.rows, 0, fn row, count ->
        [id, url, url_hash, post_uri, post_text, post_created_at,
         author_did, author_handle, author_display_name, author_followers_count,
         score, domain, tags, langs, stumble_count, tagged_at, inserted_at, updated_at] = row

        attrs = %{
          url: url,
          url_hash: url_hash,
          post_uri: post_uri,
          post_text: post_text,
          post_created_at: post_created_at,
          author_did: author_did,
          author_handle: author_handle,
          author_display_name: author_display_name,
          author_followers_count: author_followers_count,
          score: score || 0,
          domain: domain,
          tags: tags || [],
          langs: langs || [],
          stumble_count: stumble_count || 0,
          tagged_at: tagged_at,
          inserted_at: inserted_at,
          updated_at: updated_at
        }

        case insert_link(attrs) do
          {:ok, _} -> count + 1
          {:error, :exists} -> count
          {:error, reason} ->
            Mix.shell().error("Failed to insert link #{url}: #{inspect(reason)}")
            count
        end
      end)

      Mix.shell().info("Inserted #{inserted} new links")
    end
  end

  defp insert_link(attrs) do
    # Check if link already exists by url_hash
    case Blog.Repo.get_by(Blog.PokeAround.Link, url_hash: attrs.url_hash) do
      nil ->
        %Blog.PokeAround.Link{}
        |> Ecto.Changeset.change(attrs)
        |> Blog.Repo.insert()

      _existing ->
        {:error, :exists}
    end
  end

  defp migrate_link_tags(source_conn, dry_run) do
    Mix.shell().info("\n--- Migrating Link-Tag Associations ---")

    query = """
    SELECT lt.link_id, lt.tag_id, lt.source, lt.confidence, lt.inserted_at,
           l.url_hash, t.slug
    FROM link_tags lt
    JOIN links l ON l.id = lt.link_id
    JOIN tags t ON t.id = lt.tag_id
    """

    {:ok, result} = Postgrex.query(source_conn, query, [])

    Mix.shell().info("Found #{result.num_rows} link-tag associations in source database")

    if dry_run do
      Mix.shell().info("[DRY RUN] Would migrate #{result.num_rows} link-tag associations")
    else
      inserted = Enum.reduce(result.rows, 0, fn row, count ->
        [_link_id, _tag_id, source, confidence, inserted_at, url_hash, tag_slug] = row

        # Find the corresponding link and tag in the blog database
        with link when not is_nil(link) <- Blog.Repo.get_by(Blog.PokeAround.Link, url_hash: url_hash),
             tag when not is_nil(tag) <- Blog.Repo.get_by(Blog.PokeAround.Tag, slug: tag_slug) do

          attrs = %{
            link_id: link.id,
            tag_id: tag.id,
            source: source || "migration",
            confidence: confidence,
            inserted_at: inserted_at
          }

          case insert_link_tag(attrs) do
            {:ok, _} -> count + 1
            {:error, :exists} -> count
            {:error, reason} ->
              Mix.shell().error("Failed to insert link_tag for #{url_hash} -> #{tag_slug}: #{inspect(reason)}")
              count
          end
        else
          nil ->
            Mix.shell().info("Skipping link_tag - link or tag not found in destination")
            count
        end
      end)

      Mix.shell().info("Inserted #{inserted} new link-tag associations")
    end
  end

  defp insert_link_tag(attrs) do
    import Ecto.Query

    # Check if association already exists
    exists = Blog.Repo.exists?(
      from lt in Blog.PokeAround.LinkTag,
      where: lt.link_id == ^attrs.link_id and lt.tag_id == ^attrs.tag_id
    )

    if exists do
      {:error, :exists}
    else
      %Blog.PokeAround.LinkTag{}
      |> Ecto.Changeset.change(attrs)
      |> Blog.Repo.insert()
    end
  end
end
