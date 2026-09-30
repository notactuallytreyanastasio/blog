# The homepage: the museum and the Finder

`load_desk_db` reads these at boot and once a minute. None takes input.

    let { from, sql } = import("../alloy");

    export let desk_museum_q(): List<String> {
      db_q(from(db_id("museum_projects"))
        .selectExpr([
          sql"slug",
          sql"title",
          sql"coalesce(tagline, '') as tagline",
          sql"coalesce(description, '') as description",
          sql"category",
          sql"coalesce(array_to_string(tech_stack, ','), '') as tech",
          sql"coalesce(internal_path, '') as internal_path",
          sql"coalesce(external_url, '') as external_url",
        ])
        .where(sql"visible")
        .orderBy(db_id("sort_order"), true)
        .orderBy(db_id("id"), true)
        .toSql())
    }

A project's repositories are a JSON array in one column, read in order.
`from` takes a table, not `unnest(...) with ordinality`, so this is one
fragment.

    export let desk_repos_q(): List<String> {
      db_q(sql"select p.slug, coalesce(r.repo->>'name', '') as name, coalesce(r.repo->>'full_name', '') as full_name from museum_projects p, unnest(p.github_repos) with ordinality as r(repo, n) where p.visible order by p.sort_order, p.id, r.n")
    }

    export let desk_sections_q(): List<String> {
      db_q(from(db_id("finder_sections"))
        .selectExpr([sql"name", sql"coalesce(label, '') as label"])
        .where(sql"visible")
        .orderBy(db_id("sort_order"), true)
        .orderBy(db_id("id"), true)
        .toSql())
    }

Items are ordered by their section's place, then their own. `orderBy` takes
a bare column, and both tables have `sort_order` and `id`, so this is one
fragment too.

    export let desk_items_q(): List<String> {
      db_q(sql"select s.name as section, i.name, coalesce(i.icon, '') as icon, coalesce(i.path, '') as path, coalesce(i.action, '') as action, coalesce(i.description, '') as description from finder_items i join finder_sections s on s.id = i.section_id where s.visible and i.visible order by s.sort_order, s.id, i.sort_order, i.id")
    }
