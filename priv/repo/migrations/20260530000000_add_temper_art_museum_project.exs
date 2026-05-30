defmodule Blog.Repo.Migrations.AddTemperArtMuseumProject do
  use Ecto.Migration

  def up do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    execute("""
    INSERT INTO museum_projects
      (slug, title, tagline, description, category, tech_stack, github_repos,
       internal_path, external_url, pixel_art_path, emoji, color, sort_order, visible,
       inserted_at, updated_at)
    VALUES
      ('temper-art',
       'Temper Art',
       'Generative art engine written in Temper, compiled to JavaScript',
       'A generative art engine written in Temper — a memory-safe language that compiles to JS, Python, Java, C#, Lua, and Rust. The engine runs three algorithms (Bauhaus grid, flow-field particles, Mondrian subdivision) driven by a splitmix32 PRNG, so every seed produces the same piece deterministically on any backend. In the browser it renders to Canvas with a history navigator and PNG export.',
       'creative',
       ARRAY['Temper', 'JavaScript', 'Phoenix LiveView'],
       ARRAY[]::jsonb[],
       '/art',
       NULL,
       NULL,
       '🎨',
       '#7c6fcd',
       50,
       true,
       '#{now}',
       '#{now}')
    """)
  end

  def down do
    execute("DELETE FROM museum_projects WHERE slug = 'temper-art'")
  end
end
