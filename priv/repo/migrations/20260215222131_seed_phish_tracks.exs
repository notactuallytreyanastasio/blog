defmodule Blog.Repo.Migrations.SeedPhishTracks do
  use Ecto.Migration

  def up do
    %{rows: [[count]]} = repo().query!("SELECT COUNT(*) FROM phish_tracks")

    if count == 0 do
      json_path = Path.join([:code.priv_dir(:blog), "static", "data", "tracks.json"])
      raw = File.read!(json_path)
      tracks = Jason.decode!(raw)
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      tracks
      |> Enum.map(fn t ->
        %{
          song_name: t["song_name"],
          show_date: Date.from_iso8601!(t["show_date"]),
          set_name: t["set_name"] || "",
          position: t["position"] || 0,
          duration_ms: t["duration_ms"] || 0,
          likes: t["likes"] || 0,
          is_jamchart: (t["is_jamchart"] || 0) == 1,
          jam_notes: t["jam_notes"] || "",
          venue: t["venue"] || "",
          location: t["location"] || "",
          jam_url: t["jam_url"] || "",
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.chunk_every(1000)
      |> Enum.each(fn batch ->
        repo().insert_all("phish_tracks", batch)
      end)
    end
  end

  def down do
    execute("DELETE FROM phish_tracks")
  end
end
