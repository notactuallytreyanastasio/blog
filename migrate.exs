#!/usr/bin/env elixir

# This script is for running migrations on Gigalixir
# Usage: gigalixir ps:run --app=salmon-unselfish-aphid -- elixir migrate.exs

defmodule Migrate do
  def run do
    IO.puts("Starting migration...")
    
    # Start the app
    Application.load(:blog)
    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:ecto_sql)
    
    # Get repos
    repos = Application.fetch_env!(:blog, :ecto_repos)
    
    # Run migrations for each repo
    Enum.each(repos, fn repo ->
      IO.puts("Running migrations for #{inspect(repo)}")
      
      # Start the repo
      repo.start_link()
      
      # Run migrations
      Ecto.Migrator.run(repo, :up, all: true)
      
      IO.puts("Migrations completed for #{inspect(repo)}")
    end)
    
    IO.puts("All migrations completed!")
  end
end

# Run the migration
Migrate.run()