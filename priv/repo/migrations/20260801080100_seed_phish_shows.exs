defmodule Blog.Repo.Migrations.SeedPhishShows do
  use Ecto.Migration

  def up do
    %{rows: [[count]]} = repo().query!("SELECT COUNT(*) FROM phish_shows")

    if count == 0 do
      json_path = Path.join([:code.priv_dir(:blog), "static", "data", "phish_shows.json"])
      raw = File.read!(json_path)
      shows = Jason.decode!(raw)
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      shows
      |> Enum.map(fn s ->
        %{
          date: Date.from_iso8601!(s["date"]),
          venue: s["venue"] || "",
          location: s["location"] || "",
          city: s["city"] || "",
          state: s["state"] || "",
          country: s["country"] || "",
          latitude: s["latitude"],
          longitude: s["longitude"],
          tour_name: s["tour_name"] || "",
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.chunk_every(500)
      |> Enum.each(fn batch ->
        repo().insert_all("phish_shows", batch)
      end)
    end
  end

  def down do
    execute("DELETE FROM phish_shows")
  end
end
