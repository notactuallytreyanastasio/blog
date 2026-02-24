# Load sky profiles from exported JSON into the database.
# Run with: mix run priv/repo/seeds/sky_profiles.exs

import Ecto.Query
alias Blog.Repo

path = "priv/static/data/sky_profiles.json"

IO.puts("Loading profiles from #{path}")
json = File.read!(path)
profiles = Jason.decode!(json)
IO.puts("Parsed #{length(profiles)} profiles")

# Clear existing data
Repo.query!("TRUNCATE sky_profiles RESTART IDENTITY")
IO.puts("Truncated sky_profiles table")

# Bulk insert in batches of 5000
profiles
|> Enum.map(fn p ->
  %{
    handle: p["h"],
    did: p["d"],
    display_name: p["dn"],
    bio: p["b"],
    avatar_url: p["a"],
    followers_count: p["fc"] || 0,
    following_count: p["fgc"] || 0,
    community_index: p["ci"]
  }
end)
|> Enum.chunk_every(5000)
|> Enum.with_index(1)
|> Enum.each(fn {batch, i} ->
  Repo.insert_all("sky_profiles", batch)
  IO.write("\r  Inserted batch #{i} (#{i * 5000} rows)")
end)

count = Repo.one(from p in "sky_profiles", select: count(p.id))
IO.puts("\nDone! #{count} profiles loaded.")
