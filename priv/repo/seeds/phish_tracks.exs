alias Blog.Repo

json_path = Path.join([Application.app_dir(:blog, "priv"), "static", "data", "tracks.json"])

IO.puts("Reading tracks from #{json_path}...")
raw = File.read!(json_path)
tracks = Jason.decode!(raw)
IO.puts("Parsed #{length(tracks)} tracks")

# Check if already seeded
existing = Repo.aggregate(Blog.Phish.Track, :count)

if existing > 0 do
  IO.puts("Already have #{existing} tracks in DB, skipping seed.")
else
  now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  rows =
    Enum.map(tracks, fn t ->
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

  # Insert in batches of 1000
  rows
  |> Enum.chunk_every(1000)
  |> Enum.with_index(1)
  |> Enum.each(fn {batch, i} ->
    Repo.insert_all(Blog.Phish.Track, batch)
    IO.puts("  Inserted batch #{i} (#{length(batch)} rows)")
  end)

  total = Repo.aggregate(Blog.Phish.Track, :count)
  IO.puts("Done! #{total} tracks in database.")
end
