defmodule Blog.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :blog

  def migrate do
    load_app()
    
    # Ensure SSL is started
    Application.ensure_all_started(:ssl)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed_sky_profiles do
    load_app()
    Application.ensure_all_started(:ssl)

    {:ok, _, _} =
      Ecto.Migrator.with_repo(Blog.Repo, fn repo ->
        import Ecto.Query

        existing = repo.one(from(p in "sky_profiles", select: count(p.id)))

        if existing > 0 do
          IO.puts("sky_profiles already has #{existing} rows, skipping seed.")
        else
          path = Application.app_dir(:blog, "priv/static/data/sky_profiles.json")
          IO.puts("Loading profiles from #{path}")

          json = File.read!(path)
          profiles = Jason.decode!(json)
          IO.puts("Parsed #{length(profiles)} profiles")

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
            repo.insert_all("sky_profiles", batch)
            IO.write("\r  Inserted batch #{i} (#{i * 5000} rows)")
          end)

          count = repo.one(from(p in "sky_profiles", select: count(p.id)))
          IO.puts("\nDone! #{count} profiles loaded.")
        end
      end)
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
