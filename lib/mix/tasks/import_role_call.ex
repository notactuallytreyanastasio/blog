defmodule Mix.Tasks.ImportRoleCall do
  @moduledoc """
  Import Role Call data from SQLite database.

  Usage:
    mix import_role_call [path_to_sqlite_db]

  Defaults to role_call/public/data/role_call.db
  """
  use Mix.Task

  @shortdoc "Import Role Call data from SQLite"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    db_path = case args do
      [path] -> path
      [] -> "role_call/public/data/role_call.db"
    end

    unless File.exists?(db_path) do
      Mix.raise("SQLite database not found at: #{db_path}")
    end

    IO.puts("Importing from: #{db_path}")

    # Open SQLite connection
    {:ok, db} = Exqlite.Sqlite3.open(db_path)

    try do
      import_people(db)
      import_shows(db)
      import_credits(db)
    after
      Exqlite.Sqlite3.close(db)
    end

    IO.puts("\n✓ Import complete!")
    IO.puts("  Shows: #{Blog.RoleCall.count_shows()}")
    IO.puts("  People: #{Blog.RoleCall.count_people()}")
  end

  defp import_people(db) do
    IO.puts("\nImporting people...")

    {:ok, stmt} = Exqlite.Sqlite3.prepare(db, "SELECT id, name, image_url, scraped_at FROM people")

    count = import_rows(db, stmt, fn [id, name, image_url, scraped_at] ->
      Blog.RoleCall.import_person(%{
        id: id,
        name: name,
        image_url: image_url,
        scraped_at: parse_datetime(scraped_at)
      })
    end)

    IO.puts("  Imported #{count} people")
  end

  defp import_shows(db) do
    IO.puts("\nImporting shows...")

    {:ok, stmt} = Exqlite.Sqlite3.prepare(db,
      "SELECT id, title, year_start, year_end, imdb_rating, genres, description, image_url, scraped_at FROM shows"
    )

    count = import_rows(db, stmt, fn [id, title, year_start, year_end, rating, genres, desc, image_url, scraped_at] ->
      Blog.RoleCall.import_show(%{
        id: id,
        title: title,
        year_start: year_start,
        year_end: year_end,
        imdb_rating: rating,
        genres: genres,
        description: desc,
        image_url: image_url,
        scraped_at: parse_datetime(scraped_at)
      })
    end)

    IO.puts("  Imported #{count} shows")
  end

  defp import_credits(db) do
    IO.puts("\nImporting credits...")

    {:ok, stmt} = Exqlite.Sqlite3.prepare(db,
      "SELECT show_id, person_id, role, details FROM credits"
    )

    count = import_rows(db, stmt, fn [show_id, person_id, role, details] ->
      Blog.RoleCall.import_credit(%{
        show_id: show_id,
        person_id: person_id,
        role: role,
        details: details
      })
    end)

    IO.puts("  Imported #{count} credits")
  end

  defp import_rows(db, stmt, process_fn) do
    import_rows_loop(db, stmt, process_fn, 0, 0)
  end

  defp import_rows_loop(db, stmt, process_fn, count, batch) do
    case Exqlite.Sqlite3.step(db, stmt) do
      {:row, row} ->
        process_fn.(row)
        new_count = count + 1
        new_batch = batch + 1

        # Print progress every 1000 records
        if new_batch >= 1000 do
          IO.write("\r  Progress: #{new_count}")
          import_rows_loop(db, stmt, process_fn, new_count, 0)
        else
          import_rows_loop(db, stmt, process_fn, new_count, new_batch)
        end

      :done ->
        IO.write("\r")
        count
    end
  end

  defp parse_datetime(nil), do: nil
  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str <> "Z") do
      {:ok, dt, _} -> dt
      _ ->
        case NaiveDateTime.from_iso8601(str) do
          {:ok, ndt} -> DateTime.from_naive!(ndt, "Etc/UTC")
          _ -> nil
        end
    end
  end
end
