defmodule Mix.Tasks.ImportPluto do
  @moduledoc "Import PLUTO CSV data into the lots table."
  @shortdoc "Import PLUTO CSV into database"

  use Mix.Task

  alias Blog.Pluto.Parser
  alias Blog.Repo

  # 14 columns x 4000 = 56,000 params (under Postgres' 65,535 limit)
  @batch_size 4000

  @impl Mix.Task
  def run(args) do
    path = List.first(args) || "PLUTO.csv"

    unless File.exists?(path) do
      Mix.raise("File not found: #{path}")
    end

    Mix.Task.run("app.start")

    Mix.shell().info("Clearing existing lots...")
    Repo.query!("TRUNCATE lots RESTART IDENTITY")

    Mix.shell().info("Importing #{path}...")

    [header_line | _] = File.stream!(path) |> Enum.take(1)
    headers = parse_csv_line(header_line)

    count =
      path
      |> File.stream!()
      |> Stream.drop(1)
      |> Stream.map(fn line -> line |> parse_csv_line() |> zip_headers(headers) end)
      |> Stream.map(&Parser.parse_row/1)
      |> Stream.reject(&(&1 == :skip))
      |> Stream.chunk_every(@batch_size)
      |> Enum.reduce(0, fn batch, total ->
        Repo.insert_all("lots", batch, on_conflict: :nothing)
        new_total = total + length(batch)

        if rem(new_total, 50_000) == 0 do
          Mix.shell().info("  #{new_total} lots imported...")
        end

        new_total
      end)

    Mix.shell().info("Done! Imported #{count} lots.")
  end

  defp parse_csv_line(line) do
    line
    |> String.trim()
    |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
    |> hd()
  end

  defp zip_headers(values, headers) do
    Enum.zip(headers, values) |> Map.new()
  end
end
