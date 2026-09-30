# /admin/museum and /admin/finder

Every read and write the two admin pages make (src/99_admin.blimp). The
writes put down exactly the rows MuseumAdminLive and FinderAdminLive wrote
through Ecto, timestamps included, so the SQL does in Postgres what Ecto did
around it: the next sort_order, `updated_at` moved only when a value
changed, a list kept in order.

    let { from, update, deleteFrom, sql, SafeIdentifier, SqlFragment, SqlSource, SqlInt32 } = import("../alloy");

Delete, toggle and move are the same statement for the three tables. The
table is a `SafeIdentifier`, and only these three can be one here: any other
name is a bug on the Blimp side, and it stops the program where it is made.

    let adm_table(name: String): SafeIdentifier {
      if (name == "museum_projects" || name == "finder_sections" || name == "finder_items") {
        db_id(name)
      } else {
        panic()
      }
    }

Ecto's timestamps(): NaiveDateTime.utc_now() cut to the second, once per
insert or update, the same value in inserted_at and updated_at. Postgres
rounds a timestamp(0) cast; date_trunc cuts, as NaiveDateTime.truncate does.

    let adm_now_text = "date_trunc('second', timezone('utc', clock_timestamp()))";

    let adm_now(): SqlFragment {
      sql"date_trunc('second', timezone('utc', clock_timestamp()))"
    }

A value the form left empty is NULL. `List<String>` cannot carry a null, so
it is in the text, not a parameter.

    let adm_opt(v: String?): SqlFragment {
      if (v == null) { sql"NULL" } else { sql"${v}" }
    }

A JSON array of strings -> varchar[], and of objects -> jsonb[], in order;
`[]` is `'{}'`, as Ecto writes an empty list. The array arrives as its JSON
text, which is what the site's Postgres client sent for a Blimp list.

    let adm_text_array(json: String): SqlFragment {
      sql"array(select e from jsonb_array_elements_text(${json}::jsonb) with ordinality as a(e, n) order by n)::varchar[]"
    }

    let adm_jsonb_array(json: String): SqlFragment {
      sql"array(select e from jsonb_array_elements(${json}::jsonb) with ordinality as a(e, n) order by n)"
    }

## Reads

list_projects/0, list_sections/0 and the items; ties in sort_order come out
as Postgres has them, as they did there.

    export let adm_projects_q(): List<String> {
      db_q(from(db_id("museum_projects"))
        .selectExpr([
          sql"id", sql"slug", sql"title", sql"tagline", sql"description", sql"category",
          sql"array_to_json(tech_stack) as tech_stack",
          sql"array_to_json(github_repos) as github_repos",
          sql"internal_path", sql"external_url", sql"pixel_art_path", sql"emoji", sql"color",
          sql"sort_order", sql"visible",
          sql"inserted_at::text as inserted_at", sql"updated_at::text as updated_at",
        ])
        .orderBy(db_id("sort_order"), true)
        .toSql())
    }

    export let adm_sections_q(): List<String> {
      db_q(from(db_id("finder_sections"))
        .selectExpr([
          sql"id", sql"name", sql"label", sql"sort_order", sql"joyride_target", sql"visible",
          sql"inserted_at::text as inserted_at", sql"updated_at::text as updated_at",
        ])
        .orderBy(db_id("sort_order"), true)
        .toSql())
    }

    export let adm_items_q(): List<String> {
      db_q(from(db_id("finder_items"))
        .selectExpr([
          sql"id", sql"name", sql"icon", sql"path", sql"sort_order", sql"joyride_target",
          sql"action", sql"description", sql"visible", sql"section_id",
          sql"inserted_at::text as inserted_at", sql"updated_at::text as updated_at",
        ])
        .orderBy(db_id("sort_order"), true)
        .toSql())
    }

save_new_item's get_section!/1: is the section there.

    export let adm_section_exists_q(id: String): List<String> {
      let q = from(db_id("finder_sections"))
        .select([db_id("id")])
        .where(sql"id = ${id}::bigint");
      db_q(q.toSql())
    }

reorder_in_list/3's list: the rows in sort_order. Finder.reorder_item/2
reads only the item's own section, and `orderBy` takes a bare column, so
that one is a fragment.

    export let adm_move_list_q(table: String): List<String> {
      db_q(from(adm_table(table))
        .select([db_id("id"), db_id("sort_order")])
        .orderBy(db_id("sort_order"), true)
        .toSql())
    }

    export let adm_move_items_q(id: String): List<String> {
      db_q(sql"select i.id, i.sort_order from finder_items i where i.section_id = (select section_id from finder_items where id = ${id}::bigint) order by i.sort_order")
    }

## Delete, toggle, move

get_x!/1 then Repo.delete/1; the id comes back when there was a row.

    export let adm_delete_q(table: String, id: String): List<String> {
      let d = deleteFrom(adm_table(table))
        .where(sql"id = ${id}::bigint")
        .toSql() orelse panic();
      db_q(sql"${d} returning id")
    }

update_x(row, %{visible: !row.visible}): always a change, so updated_at
moves.

    export let adm_toggle_q(table: String, id: String): List<String> {
      let u = update(adm_table(table))
        .set(db_id("visible"), new SqlSource("not visible"))
        .set(db_id("updated_at"), new SqlSource(adm_now_text))
        .where(sql"id = ${id}::bigint")
        .toSql() orelse panic();
      db_q(sql"${u} returning id")
    }

One half of a swap: updated_at moves only if the value does.

    export let adm_set_order_q(table: String, id: String, order: Int): List<String> {
      let u = update(adm_table(table))
        .set(db_id("sort_order"), new SqlInt32(order))
        .set(db_id("updated_at"), new SqlSource(adm_now_text))
        .where(sql"id = ${id}::bigint and sort_order is distinct from ${order}::int")
        .toSql() orelse panic();
      db_q(u)
    }

reorder_projects -> bulk_reorder/1: the dragged order, sort_order 0, 1, 2,
... by update_all, which leaves updated_at alone. `ids` is the JSON array of
id strings.

    export let adm_bulk_reorder_q(ids: String): List<String> {
      db_q(sql"update museum_projects p set sort_order = a.n - 1 from jsonb_array_elements_text(${ids}::jsonb) with ordinality as a(id, n) where p.id = a.id::bigint")
    }

## Museum projects

save_new_project: sort_order one past the highest (1 for the first),
visible. `tech_stack` and `github_repos` are JSON arrays.

    export let adm_project_insert_q(slug: String, title: String, tagline: String?, description: String?, category: String, tech_stack: String, github_repos: String, internal_path: String?, external_url: String?): List<String> {
      db_q(sql"with t as (select ${adm_now()} as ts) insert into museum_projects (slug, title, tagline, description, category, tech_stack, github_repos, internal_path, external_url, sort_order, visible, inserted_at, updated_at) select ${slug}, ${title}, ${adm_opt(tagline)}, ${adm_opt(description)}, ${category}, ${adm_text_array(tech_stack)}, ${adm_jsonb_array(github_repos)}, ${adm_opt(internal_path)}, ${adm_opt(external_url)}, (select coalesce(max(sort_order), 0) + 1 from museum_projects), true, t.ts, t.ts from t returning id")
    }

update_project: every field the form has, and updated_at only when one of
them differs, because Ecto writes the changes and there are none when every
value is what the row holds. In an UPDATE the columns on the right are the
row as it was.

    export let adm_project_update_q(id: String, slug: String, title: String, tagline: String?, description: String?, category: String, tech_stack: String, github_repos: String, internal_path: String?, external_url: String?, visible: Boolean): List<String> {
      db_q(sql"with n as (select ${slug}::varchar as slug, ${title}::varchar as title, ${adm_opt(tagline)}::varchar as tagline, ${adm_opt(description)}::text as description, ${category}::varchar as category, ${adm_text_array(tech_stack)} as tech_stack, ${adm_jsonb_array(github_repos)} as github_repos, ${adm_opt(internal_path)}::varchar as internal_path, ${adm_opt(external_url)}::varchar as external_url, ${visible}::boolean as visible, ${adm_now()} as ts) update museum_projects p set slug = n.slug, title = n.title, tagline = n.tagline, description = n.description, category = n.category, tech_stack = n.tech_stack, github_repos = n.github_repos, internal_path = n.internal_path, external_url = n.external_url, visible = n.visible, updated_at = case when (p.slug, p.title, p.tagline, p.description, p.category, p.tech_stack, p.github_repos, p.internal_path, p.external_url, p.visible) is distinct from (n.slug, n.title, n.tagline, n.description, n.category, n.tech_stack, n.github_repos, n.internal_path, n.external_url, n.visible) then n.ts else p.updated_at end from n where p.id = ${id}::bigint returning p.id")
    }

## Finder sections and items

save_new_section: sort_order one past the highest (0 for the first).

    export let adm_section_insert_q(name: String, label: String?): List<String> {
      db_q(sql"with t as (select ${adm_now()} as ts) insert into finder_sections (name, label, sort_order, visible, inserted_at, updated_at) select ${name}, ${adm_opt(label)}, (select coalesce(max(sort_order), -1) + 1 from finder_sections), true, t.ts, t.ts from t returning id")
    }

    export let adm_section_update_q(id: String, name: String, label: String?, joyride_target: String?, visible: Boolean): List<String> {
      db_q(sql"with n as (select ${name}::varchar as name, ${adm_opt(label)}::varchar as label, ${adm_opt(joyride_target)}::varchar as joyride_target, ${visible}::boolean as visible, ${adm_now()} as ts) update finder_sections p set name = n.name, label = n.label, joyride_target = n.joyride_target, visible = n.visible, updated_at = case when (p.name, p.label, p.joyride_target, p.visible) is distinct from (n.name, n.label, n.joyride_target, n.visible) then n.ts else p.updated_at end from n where p.id = ${id}::bigint returning p.id")
    }

save_new_item: sort_order one past the section's highest (0 for its first),
visible by the schema's default, no joyride_target.

    export let adm_item_insert_q(name: String, icon: String, path: String?, action: String?, description: String?, section_id: String): List<String> {
      db_q(sql"with t as (select ${adm_now()} as ts) insert into finder_items (name, icon, path, action, description, sort_order, section_id, visible, inserted_at, updated_at) select ${name}, ${icon}, ${adm_opt(path)}, ${adm_opt(action)}, ${adm_opt(description)}, (select coalesce(max(sort_order), -1) + 1 from finder_items where section_id = ${section_id}::bigint), ${section_id}::bigint, true, t.ts, t.ts from t returning id")
    }

    export let adm_item_update_q(id: String, name: String, icon: String, path: String?, action: String?, description: String?, joyride_target: String?, visible: Boolean): List<String> {
      db_q(sql"with n as (select ${name}::varchar as name, ${icon}::varchar as icon, ${adm_opt(path)}::varchar as path, ${adm_opt(action)}::varchar as action, ${adm_opt(description)}::varchar as description, ${adm_opt(joyride_target)}::varchar as joyride_target, ${visible}::boolean as visible, ${adm_now()} as ts) update finder_items p set name = n.name, icon = n.icon, path = n.path, action = n.action, description = n.description, joyride_target = n.joyride_target, visible = n.visible, updated_at = case when (p.name, p.icon, p.path, p.action, p.description, p.joyride_target, p.visible) is distinct from (n.name, n.icon, n.path, n.action, n.description, n.joyride_target, n.visible) then n.ts else p.updated_at end from n where p.id = ${id}::bigint returning p.id")
    }
