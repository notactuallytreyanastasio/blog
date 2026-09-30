# Pages that read one query each

    let { from, sql, SqlFragment } = import("../alloy");

/sky: one profile by its handle.

    export let sky_profile_q(handle: String): List<String> {
      let q = from(db_id("sky_profiles"))
        .select([db_id("handle"), db_id("did"), db_id("display_name"), db_id("bio"), db_id("avatar_url"), db_id("followers_count"), db_id("following_count"), db_id("community_index")])
        .where(sql"handle = ${handle}")
        .limit(1) orelse panic();
      db_q(q.toSql())
    }

/moon_phish: every show, oldest first.

    export let moon_shows_q(): List<String> {
      db_q(from(db_id("phish_shows"))
        .selectExpr([
          sql"to_char(date, 'YYYY-MM-DD') as date",
          sql"coalesce(venue, '') as venue",
          sql"coalesce(location, '') as location",
          sql"coalesce(tour_name, '') as tour_name",
        ])
        .orderBy(db_id("date"), true)
        .orderBy(db_id("id"), true)
        .toSql())
    }

/work-log: the last hundred commits that changed ten lines or more.

    export let work_log_q(): List<String> {
      let q = from(db_id("work_log_commits"))
        .selectExpr([
          sql"event_id", sql"repo", sql"branch", sql"additions", sql"deletions",
          sql"extract(epoch from committed_at)::bigint as at",
          sql"to_char(committed_at, 'Mon DD HH24:MI') as short_at",
          sql"sha", sql"message",
        ])
        .where(sql"additions >= ${10}")
        .orWhere(sql"deletions >= ${10}")
        .orderBy(db_id("inserted_at"), false)
        .limit(100) orelse panic();
      db_q(q.toSql())
    }

/map: every pin, and a new one. A pin is sent to the page as the JSON
Postgres builds, the same for both.

    let map_tag(): SqlFragment {
      sql"json_build_object('id', id::text, 'name', user_name, 'link', spotify_link, 'note', note, 'lat', latitude, 'lng', longitude)"
    }

    export let map_tags_q(): List<String> {
      db_q(sql"select ${map_tag()} as tag from tag_ins")
    }

An empty note is stored as NULL, as the LiveView stored it.

    export let map_insert_q(id: String, name: String, link: String, note: String, lat: Float64, lng: Float64): List<String> {
      let stored_note = if (note.isEmpty) { sql"NULL" } else { sql"${note}" };
      db_q(sql"insert into tag_ins (id, user_name, spotify_link, note, latitude, longitude, inserted_at, updated_at) values (${id}::uuid, ${name}, ${link}, ${stored_note}, ${lat}, ${lng}, date_trunc('second', now() at time zone 'utc'), date_trunc('second', now() at time zone 'utc')) returning ${map_tag()} as tag")
    }
