# The data pages: Role Call, the census map, phangraphs, the Camera Browser and its sweep, Stumble's ingest, the work log's poll

    let { sql, SqlBuilder, SqlFragment, SqlSource } = import("../alloy");

A tag gets its string raw: in `sql"... \"id\" ..."` the backslashes reach
Postgres. Statements with a double quote in them (Ecto's `r0."id"`,
`collate "C"`, `to_char`'s `"T"`) are written between backticks instead,
where `"` needs no escape.

Values that may be missing cross from Blimp as `String?`. A `List<String>`
of parameters cannot carry a null, so a missing value is `NULL` in the text
where the parameter would have been: `NULL::varchar` where the Blimp version
sent `$3::varchar` with a null for $3. Postgres reads both the same.

    let data_value(v: String?): SqlFragment {
      if (v == null) { sql"NULL" } else { sql"${v}" }
    }

    let data_join(parts: List<SqlFragment>, sep: String): SqlFragment {
      let b = new SqlBuilder();
      for (var i = 0; i < parts.length; ++i) {
        if (i > 0) { b.appendSafe(sep); }
        b.appendFragment(parts[i]);
      }
      b.accumulated
    }

A column name the site writes, checked (db_id), as SQL text.

    let data_col(name: String): SqlFragment {
      sql"${new SqlSource(db_id(name).sqlValue)}"
    }

## Role Call

The SQL is Ecto's, what Blog.RoleCall's queries compile to, whole, inside a
materialized CTE and turned into JSON by json_agg (src/99_role_call.blimp
says why every column stays: with fewer, Postgres plans differently and
tied rows come out in another order). Only the `$n` are Alloy's now.

    let rc_ecto(ecto: SqlFragment, json: SqlFragment): SqlFragment {
      sql"with q as materialized (${ecto}) select coalesce(json_agg(${json}), '[]')::text as body from q"
    }

    let rc_show_json(): SqlFragment {
      sql"json_build_object('id', q.id, 'title', q.title, 'year', coalesce(q.year_start, 0), 'rating', coalesce(q.imdb_rating, -1), 'image_url', q.image_url)"
    }

    let rc_shows_columns(): SqlFragment {
      sql`r0."id", r0."title", r0."year_start", r0."year_end", r0."imdb_rating", r0."genres", r0."description", r0."image_url", r0."scraped_at", r0."inserted_at", r0."updated_at"`
    }

    let rc_people_columns(): SqlFragment {
      sql`r1."id" AS pid, r1."name", r1."image_url", r1."scraped_at", r1."inserted_at", r1."updated_at"`
    }

search_shows/2. `pattern` is `%q%`; id lists are comma-joined, '' the
empty one.

    export let rc_search_q(pattern: String, hidden: String): List<String> {
      db_q(rc_ecto(sql`SELECT ${rc_shows_columns()} FROM "rc_shows" AS r0 WHERE (r0."title" ILIKE ${pattern}) AND (NOT (r0."id" = ANY(string_to_array(${hidden}, ',')))) ORDER BY r0."imdb_rating" DESC LIMIT 15`, rc_show_json()))
    }

get_random_shows/1

    export let rc_picks_q(exclude: String): List<String> {
      db_q(rc_ecto(sql`SELECT ${rc_shows_columns()} FROM "rc_shows" AS r0 WHERE (NOT (r0."id" = ANY(string_to_array(${exclude}, ',')))) AND ((r0."imdb_rating" >= 7.5) OR (r0."imdb_rating" IS NULL)) AND (NOT (r0."scraped_at" IS NULL)) ORDER BY RANDOM() LIMIT 20`, rc_show_json()))
    }

get_recommendations/2: the writers of the liked shows, then the shows they
wrote, most of those writers first.

    export let rc_writer_ids_q(liked: String): List<String> {
      db_q(sql`SELECT DISTINCT r0."person_id" FROM "rc_credits" AS r0 WHERE (r0."show_id" = ANY(string_to_array(${liked}, ','))) AND (r0."role" IN ('creator','writer'))`)
    }

    export let rc_recs_q(writers: String, exclude: String, liked: String): List<String> {
      db_q(rc_ecto(sql`SELECT ${rc_shows_columns()} FROM "rc_shows" AS r0 INNER JOIN "rc_credits" AS r1 ON r1."show_id" = r0."id" WHERE (r1."person_id" = ANY(string_to_array(${writers}, ','))) AND (r1."role" IN ('creator','writer')) AND (NOT (r0."id" = ANY(string_to_array(${exclude}, ',')))) AND (NOT (r0."id" = ANY(string_to_array(${liked}, ',')))) AND (NOT (r0."scraped_at" IS NULL)) GROUP BY r0."id" ORDER BY count(r1."person_id") DESC, r0."imdb_rating" DESC LIMIT 20`, rc_show_json()))
    }

preload_writers/1, for a list of shows.

    export let rc_writers_q(ids: String): List<String> {
      db_q(rc_ecto(sql`SELECT r0."id", r0."role", r0."details", r0."show_id", r0."person_id", ${rc_people_columns()} FROM "rc_credits" AS r0 INNER JOIN "rc_people" AS r1 ON r1."id" = r0."person_id" WHERE (r0."show_id" = ANY(string_to_array(${ids}, ','))) AND (r0."role" IN ('creator','writer')) ORDER BY CASE r0."role" WHEN 'creator' THEN 1 WHEN 'writer' THEN 2 END`, sql`json_build_array(q.show_id, q.name)`))
    }

get_show_with_credits/1: the show, and its credits in
credits_with_people_query/0's order, of which the modal shows the creators
and writers.

    export let rc_show_q(id: String): List<String> {
      db_q(sql"select json_build_object('id', s.id, 'title', s.title, 'year', coalesce(s.year_start, 0), 'year_end', coalesce(s.year_end, 0), 'rating', coalesce(s.imdb_rating, -1), 'description', s.description, 'image_url', s.image_url)::text as body FROM rc_shows AS s WHERE (s.id = ${id})")
    }

    export let rc_credits_q(id: String): List<String> {
      db_q(sql`with q as materialized (SELECT r0."id", r0."role", r0."details", r0."show_id", r0."person_id", ${rc_people_columns()}, r0."show_id" AS sid FROM "rc_credits" AS r0 INNER JOIN "rc_people" AS r1 ON r1."id" = r0."person_id" WHERE (r0."show_id" = ${id}) ORDER BY r0."show_id", CASE r0."role" WHEN 'creator' THEN 1 WHEN 'writer' THEN 2 WHEN 'director' THEN 3 WHEN 'actor' THEN 4 END) select coalesce(json_agg(json_build_object('id', q.person_id, 'name', q.name, 'role', q.role)) filter (where q.role in ('creator', 'writer')), '[]')::text as body from q`)
    }

get_person_with_shows/1: every credit, best-rated show first (nulls first,
as desc puts them).

    export let rc_person_q(id: String): List<String> {
      db_q(sql"select json_build_object('id', p.id, 'name', p.name)::text as body FROM rc_people AS p WHERE (p.id = ${id})")
    }

    export let rc_person_credits_q(id: String): List<String> {
      db_q(rc_ecto(sql`SELECT r0."id" AS cid, r0."role", r0."details", r0."show_id", r0."person_id", r1."id", r1."title", r1."year_start", r1."year_end", r1."imdb_rating", r1."genres", r1."description", r1."image_url", r1."scraped_at", r1."inserted_at", r1."updated_at", r0."person_id" AS pid FROM "rc_credits" AS r0 INNER JOIN "rc_shows" AS r1 ON r1."id" = r0."show_id" WHERE (r0."person_id" = ${id}) ORDER BY r0."person_id", r1."imdb_rating" DESC`, sql`json_build_object('id', q.id, 'title', q.title, 'year', coalesce(q.year_start, 0), 'rating', coalesce(q.imdb_rating, -1))`))
    }

get_show/1, for each liked id; and count_shows/0.

    export let rc_titles_q(ids: String): List<String> {
      db_q(sql"select coalesce(json_agg(json_build_array(id, title)), '[]')::text as body from rc_shows where id = any(string_to_array(${ids}, ','))")
    }

    export let rc_count_q(): List<String> {
      db_q(sql"select json_build_object('count', count(*))::text as body from rc_shows")
    }

## How many people live here

Every tract once, and every tract's 2020 population: one JSON body.

    export let nyc_tracts_q(): List<String> {
      db_q(sql"select json_build_object('tracts', (select coalesce(json_object_agg(bct2020, json_build_array(lat, lng, units)), '{}') from (select bct2020, avg(latitude) as lat, avg(longitude) as lng, coalesce(sum(units_res), 0) as units from lots where bct2020 is not null and bct2020 <> '' and latitude is not null and longitude is not null group by bct2020) t), 'pops', (select coalesce(json_object_agg(geoid, population), '{}') from census_tracts))::text as body")
    }

Every lot in a box, as arrays, or a null body when there are more than
`max`. The coordinates are text the caller has checked are numbers; the
limit is used twice, so it is two parameters.

    export let nyc_lots_q(min_lat: String, max_lat: String, min_lng: String, max_lng: String, max: Int): List<String> {
      db_q(sql"with b as (select latitude, longitude, coalesce(units_res, 0) as units, coalesce(bct2020, '') as tract, coalesce(address, '') as address, coalesce(bbl, '') as bbl, coalesce(bldg_class, '') as bldg_class, coalesce(num_floors, 0) as floors, coalesce(year_built, 0) as year from lots where latitude >= ${min_lat}::float8 and latitude <= ${max_lat}::float8 and longitude >= ${min_lng}::float8 and longitude <= ${max_lng}::float8 limit ${max}::int + 1) select count(*)::int as n, case when count(*) > ${max}::int then null else coalesce(json_agg(json_build_array(latitude, longitude, units, tract, address, bbl, bldg_class, floors, year)), '[]')::text end as body from b")
    }

## phangraphs

`year` is four digits or "all" (phish_year). The Blimp version sent it once
and wrote `($1 = 'all' or extract(year ...)::int = $1::int)`. With a
parameter per use that stops working: `$2::int` makes Postgres type $2 as
an integer, and "all" is refused before the query runs
(`invalid input syntax for type integer: "all"`). So the year condition is
there or not, as Stumble's language filter is.

    let phish_year_is(year: String): SqlFragment {
      sql"extract(year from show_date)::int = ${year}::int"
    }

    export let phish_songs_q(year: String): List<String> {
      let where_year = if (year == "all") { sql"" } else { sql" where ${phish_year_is(year)}" };
      db_q(sql"select song_name, count(id)::int as times_played, sum(case when is_jamchart then 1 else 0 end)::int as jamchart_count, round(100.0 * sum(case when is_jamchart then 1 else 0 end) / count(*)::numeric, 1)::text as jamchart_pct from phish_tracks${where_year} group by song_name order by sum(case when is_jamchart then 1 else 0 end) desc, count(id) desc, song_name")
    }

    export let phish_years_q(): List<String> {
      db_q(sql"select distinct extract(year from show_date)::int as year from phish_tracks order by 1")
    }

    export let phish_history_q(song: String, year: String): List<String> {
      let and_year = if (year == "all") { sql"" } else { sql" and ${phish_year_is(year)}" };
      db_q(sql"select song_name, to_char(show_date, 'YYYY-MM-DD') as show_date, set_name, position, coalesce(duration_ms, 0) as duration_ms, coalesce(likes, 0) as likes, case when is_jamchart then 1 else 0 end as is_jamchart, coalesce(jam_notes, '') as jam_notes, venue, location, coalesce(jam_url, '') as jam_url from phish_tracks where song_name = ${song}${and_year} order by show_date, id")
    }

## The Camera Browser

A row as the table and the facets need it. A missing string is "", a
missing number -1.

    let cam_row_fields(): SqlFragment {
      sql"'id', q.id, 'title', q.title, 'price', coalesce(q.price_cents, -1), 'area', q.area, 'sub', coalesce(q.subarea, ''), 'loc', coalesce(q.location, ''), 'hood', coalesce(q.neighborhood, ''), 'tags', q.tags, 'score', q.score, 'n_img', cardinality(q.image_ids), 'img', coalesce(q.image_ids[1], ''), 'cond', coalesce(q.attrs->>'condition', ''), 'make', coalesce(q.attrs->>'make / manufacturer', q.attrs->>'make', ''), 'body', coalesce(q.body, ''), 'renewed', coalesce(extract(epoch from q.renewed_at)::bigint, -1), 'posted', coalesce(extract(epoch from q.posted_at)::bigint, -1), 'closed', coalesce(extract(epoch from q.closed_at)::bigint, -1), 'closed_reason', coalesce(q.closed_reason, ''), 'starred', q.starred_at is not null, 'hidden', q.hidden_at is not null, 'note', coalesce(q.note, ''), 'analyzed', q.analysis is not null, 'pt', coalesce(q.analysis->>'price_take', ''), 'pn', coalesce(q.analysis->>'price_note', ''), 'rarity', coalesce((q.analysis->>'rarity')::int, -1), 'contact', q.contact <> '{}'::jsonb"
    }

visible/1: "digital" anywhere disqualifies a post.

    let cam_visible(): SqlFragment {
      let digital = "%digital%";
      sql`(NOT (c0."title" ILIKE ${digital}) AND ((c0."body" IS NULL) OR NOT (c0."body" ILIKE ${digital})))`
    }

    let cam_order_by(sort: String): SqlFragment {
      if (sort == "newest") {
        sql`c0."renewed_at" DESC NULLS LAST, c0."id" DESC`
      } else if (sort == "price_asc") {
        sql`c0."price_cents" ASC NULLS LAST, c0."score" DESC`
      } else if (sort == "price_desc") {
        sql`c0."price_cents" DESC NULLS LAST, c0."score" DESC`
      } else {
        sql`c0."score" DESC, c0."renewed_at" DESC NULLS LAST`
      }
    }

list_listings/1, each clause the one Ecto wrote, in the order the pipeline
adds them. `city` "" is no city filter; with an `area` (a tab) the area is
filtered, otherwise the subarea. `pattern` is "" for no search, else
`%text%`. A price of -1 is no bound.

    export let cam_list_q(status: String, city: String, area: String, pattern: String, min: Int, max: Int, hidden: Boolean, starred: Boolean, sort: String): List<String> {
      let b = new SqlBuilder();
      b.appendFragment(sql`SELECT c0.* FROM "camera_listings" AS c0 WHERE ${cam_visible()}`);
      if (status == "open") {
        b.appendFragment(sql` AND (c0."closed_at" IS NULL)`);
      } else if (status == "closed") {
        b.appendFragment(sql` AND (NOT (c0."closed_at" IS NULL))`);
      }
      if (!city.isEmpty) {
        if (area.isEmpty) {
          b.appendFragment(sql` AND (c0."subarea" = ${city})`);
        } else {
          b.appendFragment(sql` AND (c0."area" = ${area})`);
        }
      }
      if (!pattern.isEmpty) {
        b.appendFragment(sql` AND ((c0."title" ILIKE ${pattern}) OR (c0."body" ILIKE ${pattern}))`);
      }
      if (min >= 0) {
        b.appendFragment(sql` AND (c0."price_cents" >= ${min})`);
      }
      if (max >= 0) {
        b.appendFragment(sql` AND (c0."price_cents" <= ${max})`);
      }
      if (!hidden) {
        b.appendFragment(sql` AND (c0."hidden_at" IS NULL)`);
      }
      if (starred) {
        b.appendFragment(sql` AND (NOT (c0."starred_at" IS NULL))`);
      }
      db_q(sql"with q as materialized (${b.accumulated} ORDER BY ${cam_order_by(sort)} LIMIT 500) select coalesce(json_agg(json_build_object(${cam_row_fields()})), '[]')::text as body from q")
    }

stats/0, over the visible listings; last_seen over all of them.

    export let cam_stats_q(): List<String> {
      db_q(sql"select json_build_object('open', count(*) filter (where c0.closed_at is null and c0.hidden_at is null), 'closed', count(*) filter (where c0.closed_at is not null), 'starred', count(*) filter (where c0.starred_at is not null), 'last_seen', (select coalesce(extract(epoch from max(last_seen_at))::bigint, -1) from camera_listings))::text as body from camera_listings c0 where ${cam_visible()}")
    }

get_listing/1, all of it. attrs and contact as [key, value] pairs in the
order an Elixir map of them iterates (sorted keys), which jsonb does not
keep.

    export let cam_one_q(id: Int): List<String> {
      db_q(sql`select json_build_object(${cam_row_fields()}, 'url', q.url, 'reply_url', coalesce(q.reply_url, ''), 'lat', coalesce(q.lat::text, ''), 'lng', coalesce(q.lng::text, ''), 'attrs', (select coalesce(json_agg(json_build_array(key, value) order by key collate "C"), '[]') from jsonb_each_text(q.attrs)), 'contact_list', (select coalesce(json_agg(json_build_array(key, value) order by key collate "C"), '[]') from jsonb_each(q.contact)), 'queries', q.queries, 'first_seen', coalesce(extract(epoch from q.first_seen_at)::bigint, -1), 'last_seen', coalesce(extract(epoch from q.last_seen_at)::bigint, -1), 'posting_id', q.posting_id::text, 'analysis', q.analysis, 'image_ids', q.image_ids, 'mirrored', q.mirrored_images)::text as body from camera_listings q where q.id = ${id}`)
    }

toggle_star/1, toggle_hidden/1 and set_note/2, with the updated_at
Repo.update! wrote. A null note clears it.

    export let cam_star_q(id: Int): List<String> {
      db_q(sql"update camera_listings set starred_at = case when starred_at is null then date_trunc('second', now() at time zone 'utc') else null end, updated_at = date_trunc('second', now() at time zone 'utc') where id = ${id} returning id")
    }

    export let cam_hide_q(id: Int): List<String> {
      db_q(sql"update camera_listings set hidden_at = case when hidden_at is null then date_trunc('second', now() at time zone 'utc') else null end, updated_at = date_trunc('second', now() at time zone 'utc') where id = ${id} returning id")
    }

    export let cam_note_q(id: Int, note: String?): List<String> {
      db_q(sql"update camera_listings set note = ${data_value(note)}, updated_at = date_trunc('second', now() at time zone 'utc') where id = ${id} returning id")
    }

Whether a sweep has finished: the newest last_seen_at.

    export let cam_last_seen_q(): List<String> {
      db_q(sql"select coalesce(extract(epoch from max(last_seen_at))::bigint, -1) as t from camera_listings")
    }

## The sweep

upsert_from_search/3 looks a listing up by its posting id first.

    export let cs_find_q(posting_id: String?): List<String> {
      db_q(sql"select id, title, body, attrs, to_jsonb(image_ids) as image_ids, to_jsonb(queries) as queries from camera_listings where posting_id = ${data_value(posting_id)}")
    }

The posts to fetch, to analyze, and the ones this sweep did not see (since
`started`, Unix seconds).

    export let cs_detail_q(cap: Int): List<String> {
      db_q(sql`select id, posting_id, url, title, to_jsonb(image_ids) as image_ids, to_jsonb(queries) as queries, to_char(posted_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as posted_at, lat::text as lat, lng::text as lng from camera_listings where detail_fetched_at is null and closed_at is null order by score desc, renewed_at desc limit ${cap}`)
    }

    export let cs_ai_q(cap: Int): List<String> {
      db_q(sql"select id, posting_id, area, subarea, neighborhood, title, price_cents, attrs, cardinality(image_ids) as photos, coalesce(extract(epoch from posted_at)::bigint, -1) as posted_at, body from camera_listings where analyzed_at is null and detail_fetched_at is not null and closed_at is null order by (analysis_error is not null) asc, score desc, id desc limit ${cap}")
    }

    export let cs_unseen_q(started: Int, cap: Int): List<String> {
      db_q(sql"select id, posting_id, url from camera_listings where closed_at is null and last_seen_at < ${cs_ts(sql"${started}")} order by last_seen_at asc limit ${cap}")
    }

A column's value is one of a few shapes. `kind` names it; the value is the
text the Blimp version sent as that parameter (JSON for a list or a map),
or null. `null_timestamp` and `null_varchar` take no value.

    let cs_ts(v: SqlFragment): SqlFragment {
      sql"(to_timestamp(${v}::float8) at time zone 'utc')"
    }

    let cs_value(kind: String, value: String?): SqlFragment {
      let v = data_value(value);
      if (kind == "varchar") {
        sql"${v}::varchar"
      } else if (kind == "text") {
        sql"${v}::text"
      } else if (kind == "integer") {
        sql"${v}::integer"
      } else if (kind == "bigint") {
        sql"${v}::bigint"
      } else if (kind == "float8") {
        sql"${v}::float8"
      } else if (kind == "jsonb") {
        sql"${v}::jsonb"
      } else if (kind == "ts") {
        cs_ts(v)
      } else if (kind == "iso_ts") {
        sql"(${v}::timestamptz at time zone 'utc')"
      } else if (kind == "array") {
        sql"array(select jsonb_array_elements_text(${v}::jsonb))::varchar[]"
      } else if (kind == "null_timestamp") {
        sql"null::timestamp"
      } else if (kind == "null_varchar") {
        sql"null::varchar"
      } else {
        panic()
      }
    }

Repo.update! of a changeset: set the columns, and updated_at only when one
of them changes (a changeset without changes is not written at all).

    export let cs_update_q(id: Int, names: List<String>, kinds: List<String>, values: List<String?>, now_s: Int): List<String> {
      let v_cols = new ListBuilder<SqlFragment>();
      let assign = new ListBuilder<SqlFragment>();
      let old = new ListBuilder<SqlFragment>();
      let fresh = new ListBuilder<SqlFragment>();
      for (var i = 0; i < names.length; ++i) {
        let n = data_col(names[i]);
        v_cols.add(sql"${cs_value(kinds[i], values[i])} as ${n}");
        assign.add(sql"${n} = v.${n}");
        old.add(sql"c.${n}");
        fresh.add(sql"v.${n}");
      }
      db_q(sql"with v as (select ${data_join(v_cols.toList(), ", ")}) update camera_listings c set ${data_join(assign.toList(), ", ")}, updated_at = case when row(${data_join(old.toList(), ", ")}) is distinct from row(${data_join(fresh.toList(), ", ")}) then ${cs_ts(sql"${now_s}")} else c.updated_at end from v where c.id = ${id}")
    }

    export let cs_insert_q(names: List<String>, kinds: List<String>, values: List<String?>, now_s: Int): List<String> {
      let cols = new ListBuilder<SqlFragment>();
      let exprs = new ListBuilder<SqlFragment>();
      for (var i = 0; i < names.length; ++i) {
        cols.add(data_col(names[i]));
        exprs.add(cs_value(kinds[i], values[i]));
      }
      db_q(sql"insert into camera_listings (${data_join(cols.toList(), ", ")}, inserted_at, updated_at) values (${data_join(exprs.toList(), ", ")}, ${cs_ts(sql"${now_s}")}, ${cs_ts(sql"${now_s}")})")
    }

## Stumble's ingest

Links.store_link for a batch: one INSERT, twelve values a row, each the
text the Blimp version sent (langs as a JSON array) or null. ON CONFLICT DO
NOTHING is Ecto's on_conflict: :nothing.

    export let sti_insert_q(rows: List<List<String?>>): List<String> {
      let tuples = new ListBuilder<SqlFragment>();
      for (var i = 0; i < rows.length; ++i) {
        let r = rows[i];
        tuples.add(sql"(${data_value(r[0])}::text, ${data_value(r[1])}::text, ${data_value(r[2])}::text, ${data_value(r[3])}::text, ${data_value(r[4])}::timestamp, ${data_value(r[5])}::text, ${data_value(r[6])}::text, ${data_value(r[7])}::text, ${data_value(r[8])}::int, ${data_value(r[9])}::int, ${data_value(r[10])}::text, array(select x from json_array_elements_text(${data_value(r[11])}::json) with ordinality as l(x, n) order by n)::varchar[], now() at time zone 'utc', now() at time zone 'utc')");
      }
      db_q(sql"insert into pa_links (url, url_hash, post_uri, post_text, post_created_at, author_did, author_handle, author_display_name, author_followers_count, score, domain, langs, inserted_at, updated_at) values ${data_join(tuples.toList(), ", ")} on conflict do nothing returning id")
    }

## The work log's poll

upsert_from_compare/4, one commit; a sha already there is no row.

    export let wl_insert_q(event_id: String, repo: String, branch: String, sha: String, message: String, additions: Int, deletions: Int, now_s: Int): List<String> {
      let at = sql"(to_timestamp(${now_s}::float8) at time zone 'utc')";
      db_q(sql"insert into work_log_commits (event_id, repo, branch, sha, message, additions, deletions, committed_at, inserted_at, updated_at) values (${event_id}, ${repo}, ${branch}, ${sha}, ${message}, ${additions}, ${deletions}, ${at}, ${at}, ${at}) on conflict (sha) do nothing returning id")
    }
