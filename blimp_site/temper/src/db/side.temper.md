# The side doors' writes: push subscriptions, the receipt printer, collages, guest posts

The SQL of src/99_blinkspush.blimp, 99_push_devices.blimp,
99_receipts.blimp, 99_collage.blimp and 99_guest_posts.blimp. Each comes
back as `db_q` makes it, [sql, params...], every value a parameter.

    let { from, update, deleteFrom, sql, SqlFragment, SqlSource, SqlString } = import("../alloy");

Ecto's timestamps: UTC, whole seconds, truncated. The blinks side wrote it
one way and the receipt printer, collages and comments another; each keeps
its own spelling.

    let side_blinks_now(): SqlFragment {
      sql"date_trunc('second', now() at time zone 'UTC')"
    }

    let side_now(): SqlFragment {
      sql"date_trunc('second', timezone('UTC', now()))"
    }

A value that may be null: NULL in the text, or a parameter.

    let side_or_null(v: String?): SqlFragment {
      if (v == null) { sql"NULL" } else { sql"${v}" }
    }

## Followed tags

A JSON list parameter (what the pg client sends a Blimp list as) made into
the first 100 of Device.changeset/2's followed_tags: trimmed of what
Elixir's String.trim/1 trims (temper/src/blinks_write says which code
points), lower-cased, blanks and repeats dropped, first of each kept. The
Blimp side had this as blkw_norm_tags(blkw_text_array("$n")) from
src/99_blinkswrite.blimp; it is spelled out again here because a Blimp
string cannot go into a `sql` fragment as SQL text, only as a value.

The characters are the same 25, in the same order, as BLKW_WS, written as
escapes. They are SQL text, not a parameter: this fragment is constant.
A `sql"..."` template is raw, its `\u{85}` four characters and not one,
so the text is an ordinary string handed over as SqlSource.

    let side_ws(): SqlFragment {
      sql"${new SqlSource("'\u{9}\u{a}\u{b}\u{c}\u{d} \u{85}\u{a0}\u{1680}\u{2000}\u{2001}\u{2002}\u{2003}\u{2004}\u{2005}\u{2006}\u{2007}\u{2008}\u{2009}\u{200a}\u{2028}\u{2029}\u{202f}\u{205f}\u{3000}'")}"
    }

    let side_tags(tags_json: String): SqlFragment {
      sql"array(select q.n from unnest(array(select z.n from (select lower(btrim(u.t, ${side_ws()})) as n, min(u.o) as o from unnest(array(select jsonb_array_elements_text(${tags_json}::jsonb))) with ordinality u(t, o) group by 1) z where z.n <> '' order by z.o)) with ordinality q(n, o) order by q.o limit 100)"
    }

## Web push (src/99_blinkspush.blimp)

Every subscription, oldest first.

    export let bkp_subs_q(): List<String> {
      db_q(from(db_id("web_push_subscriptions"))
        .selectExpr([sql"id", sql"endpoint", sql"p256dh", sql"auth", sql"to_json(followed_tags)::text as tags"])
        .orderBy(db_id("id"), true)
        .toSql())
    }

A push that got through.

    export let bkp_touch_q(id: Int): List<String> {
      db_q(update(db_id("web_push_subscriptions"))
        .set(db_id("last_ok_at"), new SqlSource("date_trunc('second', now() at time zone 'UTC')"))
        .where(sql"id = ${id}::bigint")
        .toSql() orelse panic())
    }

    export let bkp_delete_q(endpoint: String): List<String> {
      db_q(deleteFrom(db_id("web_push_subscriptions"))
        .where(sql"endpoint = ${endpoint}::text")
        .toSql() orelse panic())
    }

    export let bkp_get_q(endpoint: String): List<String> {
      db_q(from(db_id("web_push_subscriptions"))
        .select([db_id("id"), db_id("endpoint"), db_id("p256dh"), db_id("auth")])
        .where(sql"endpoint = ${endpoint}::text")
        .toSql())
    }

subscribe_web/2 as Repo.insert/2 with on_conflict writes it: everything
but inserted_at replaced on an endpoint already there. `tags_json` is the
tags as a JSON list; the user agent is cut to 255 characters.

    export let bkp_upsert_q(endpoint: String, p256dh: String, auth: String, tags_json: String, ua: String?): List<String> {
      db_q(sql"insert into web_push_subscriptions (endpoint, p256dh, auth, followed_tags, user_agent, inserted_at, updated_at) select ${endpoint}::text, ${p256dh}::text, ${auth}::text, ${side_tags(tags_json)}, left(${side_or_null(ua)}::text, 255), ${side_blinks_now()}, ${side_blinks_now()} on conflict (endpoint) do update set p256dh = excluded.p256dh, auth = excluded.auth, followed_tags = excluded.followed_tags, user_agent = excluded.user_agent, updated_at = excluded.updated_at")
    }

## iOS devices (src/99_push_devices.blimp)

Push.register_device/3: env, followed_tags and updated_at replaced on a
token already there, inserted_at kept.

    export let psd_upsert_q(token: String, env: String, tags_json: String): List<String> {
      db_q(sql"insert into apns_devices (token, env, followed_tags, inserted_at, updated_at) select ${token}::text, ${env}::text, ${side_tags(tags_json)}, ${side_blinks_now()}, ${side_blinks_now()} on conflict (token) do update set env = excluded.env, followed_tags = excluded.followed_tags, updated_at = excluded.updated_at")
    }

## The receipt printer (src/99_receipts.blimp)

A message as the printer's JSON wants it.

The `"T"` in the formats is SQL text with double quotes in it, which a
raw `sql"..."` template would keep as `\"T\"`: it is SqlSource instead.

    let receipt_cols(): SqlFragment {
      sql"${new SqlSource("id, content, sender_name, sender_ip, status, image_url, to_char(inserted_at, 'YYYY-MM-DD\"T\"HH24:MI:SS') AS created_at, to_char(printed_at, 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS printed_at, coalesce(octet_length(image_data), 0) > 0 AS has_upload")}"
    }

mark_as_printed/1, mark_as_failed/1 and the retry: the new status, and
printed_at as it is to be. updated_at moves only when something changed,
as Ecto's Repo.update does for an empty changeset.

    let receipt_update(id: String, status: String, printed_at: SqlFragment): List<String> {
      db_q(sql"UPDATE receipt_messages SET status = ${status}::text, printed_at = ${printed_at}, updated_at = CASE WHEN status IS DISTINCT FROM ${status}::text OR printed_at IS DISTINCT FROM ${printed_at} THEN ${side_now()} ELSE updated_at END WHERE id = ${id}::bigint RETURNING ${receipt_cols()}")
    }

    export let receipt_printed_q(id: String): List<String> {
      receipt_update(id, "printed", side_now())
    }

    export let receipt_failed_q(id: String): List<String> {
      receipt_update(id, "failed", sql"printed_at")
    }

    export let receipt_retry_q(id: String): List<String> {
      receipt_update(id, "pending", sql"NULL::timestamp")
    }

list_pending_messages/0, oldest first, id breaking a tie in the second.

    export let receipt_pending_q(): List<String> {
      db_q(sql"SELECT ${receipt_cols()} FROM receipt_messages WHERE status = 'pending' ORDER BY inserted_at, id")
    }

The image as hex, and how many bytes.

    export let receipt_image_q(id: String): List<String> {
      db_q(from(db_id("receipt_messages"))
        .selectExpr([sql"image_content_type", sql"encode(image_data, 'hex') AS hex", sql"coalesce(octet_length(image_data), 0) AS n"])
        .where(sql"id = ${id}::bigint")
        .toSql())
    }

The page's message. Without an image, `hex` and `ctype` are null, and the
statement says NULL where they go.

    export let rx_insert_q(content: String, ip: String, hex: String?, ctype: String?): List<String> {
      db_q(sql"INSERT INTO receipt_messages (content, sender_ip, status, image_data, image_content_type, inserted_at, updated_at) VALUES (${content}, ${ip}, 'pending', decode(${side_or_null(hex)}, 'hex'), ${side_or_null(ctype)}, ${side_now()}, ${side_now()}) RETURNING id")
    }

list_recent_messages(10), newest first.

    export let rx_queue_q(): List<String> {
      let q = from(db_id("receipt_messages"))
        .selectExpr([sql"content", sql"coalesce(status, '') AS status", sql"to_char(inserted_at, 'Mon DD, HH12:MI AM') AS at"])
        .orderBy(db_id("inserted_at"), false)
        .orderBy(db_id("id"), false)
        .limit(10) orelse panic();
      db_q(q.toSql())
    }

## Collages (src/99_collage.blimp)

    export let clg_ready_q(id: Int, key: String, size: Int): List<String> {
      db_q(sql"UPDATE collage_maker_collages SET status = 'ready', collage_s3_key = ${key}, collage_file_size = ${size}::integer, updated_at = ${side_now()} WHERE id = ${id}::bigint")
    }

    export let clg_failed_q(id: Int, reason: String): List<String> {
      db_q(update(db_id("collage_maker_collages"))
        .set(db_id("status"), new SqlSource("'failed'"))
        .set(db_id("error_message"), new SqlString(reason))
        .set(db_id("updated_at"), new SqlSource("date_trunc('second', timezone('UTC', now()))"))
        .where(sql"id = ${id}::bigint")
        .toSql() orelse panic())
    }

cleanup_expired/0: the expired rows go, and every object key they and
their images named comes back.

    export let clg_expire_q(): List<String> {
      db_q(sql"WITH gone AS (DELETE FROM collage_maker_collages WHERE expires_at < ${side_now()} RETURNING id, collage_s3_key) SELECT collage_s3_key AS key FROM gone WHERE collage_s3_key IS NOT NULL UNION ALL SELECT i.original_s3_key FROM collage_maker_images i JOIN gone g ON i.collage_id = g.id WHERE i.original_s3_key IS NOT NULL UNION ALL SELECT i.cropped_s3_key FROM collage_maker_images i JOIN gone g ON i.collage_id = g.id WHERE i.cropped_s3_key IS NOT NULL")
    }

A new collage, processing, for 24 hours.

    export let clg_insert_q(columns: Int, cell: Int, count: Int, width: Int, height: Int, who: String, token: String): List<String> {
      db_q(sql"INSERT INTO collage_maker_collages (status, columns, cell_size, image_count, collage_width, collage_height, ip_hash, share_token, expires_at, inserted_at, updated_at) VALUES ('processing', ${columns}::integer, ${cell}::integer, ${count}::integer, ${width}::integer, ${height}::integer, ${who}, ${token}, ${side_now()} + interval '24 hours', ${side_now()}, ${side_now()}) RETURNING id")
    }

    export let clg_row_q(token: String): List<String> {
      db_q(from(db_id("collage_maker_collages"))
        .select([db_id("id"), db_id("status"), db_id("columns"), db_id("cell_size"), db_id("image_count"), db_id("collage_s3_key"), db_id("collage_width"), db_id("collage_height"), db_id("collage_file_size"), db_id("error_message"), db_id("share_token")])
        .where(sql"share_token = ${token}")
        .toSql())
    }

    export let clg_download_q(id: Int): List<String> {
      db_q(from(db_id("collage_maker_collages"))
        .select([db_id("status"), db_id("collage_s3_key")])
        .where(sql"id = ${id}::bigint")
        .toSql())
    }

## Guest posts (src/99_guest_posts.blimp)

A published draft by its slug.

    export let gp_draft_q(slug: String): List<String> {
      db_q(from(db_id("drafts"))
        .selectExpr([sql"coalesce(title, 'Untitled') as title", sql"slug", sql"coalesce(content, '') as content", sql"author_name", sql"to_char(updated_at, 'FMMonth DD, YYYY') as date"])
        .where(sql"slug = ${slug}")
        .where(sql"status = 'published'")
        .toSql())
    }

list_comments/1, oldest first, id breaking a tie in the second.

    export let gp_comments_q(slug: String): List<String> {
      db_q(from(db_id("post_comments"))
        .selectExpr([sql"author_name", sql"content", sql"${new SqlSource("to_char(inserted_at, 'Mon DD, YYYY \"at\" HH12:MI AM') as at")}"])
        .where(sql"post_slug = ${slug}")
        .orderBy(db_id("inserted_at"), true)
        .orderBy(db_id("id"), true)
        .toSql())
    }

    export let gp_insert_q(slug: String, name: String, content: String): List<String> {
      db_q(sql"insert into post_comments (post_slug, author_name, content, inserted_at, updated_at) values (${slug}, ${name}, ${content}, ${side_now()}, ${side_now()})")
    }
