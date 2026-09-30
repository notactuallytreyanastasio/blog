# Bobby's links: the writes

What Phoenix's Blog.Blinks, Blinks.Comments and Chat write, as
src/99_blinkswrite.blimp (token-gated saves and edits),
src/99_blinksanon.blimp (saves, suggestions, comments and reactions from
anyone) and src/99_blinkschat.blimp (the per-link chat rooms) send them.
Each statement is the one those files used to hold as a string, with its
values as parameters. Where a value can be NULL it is either in the text as
`NULL` or a parameter, never both: a `List<String>` has no room for a null.

    let { sql, SqlFragment, SqlSource } = import("../alloy");

Ecto's timestamps: UTC, whole seconds, truncated (a timestamp(0) column
would round .7 up).

    let blkw_now(): SqlFragment {
      sql"date_trunc('second', now() at time zone 'UTC')"
    }

A value that may be missing: `NULL`, or the value as a parameter.

    let blkw_opt(v: String?): SqlFragment {
      if (v == null) { sql"NULL" } else { sql"${v as String}" }
    }

## The row a write answers

The blink as Jason writes it, in the three pieces 99_blinks.blimp's
`blk_one_sql` reads (the fields before the thread, the thread, the fields
after), loaded without list_blinks' two counts. This is a copy of that
text over `w`; the read side keeps its own.

    let blkw_row_from_w(): SqlFragment {
      sql"select (select row_to_json(x) from (select w.id, w.url, w.title, w.description, w.tags, w.quotes) x)::text as pre, w.thread::text as thread, (select row_to_json(y) from (select w.favicon_url, w.image_url, w.site_name, w.inserted_at, null::int as comment_count, null::int as save_count) y)::text as post from w"
    }

## Two constants a `sql` literal cannot hold

A `sql"..."` literal is raw: `\"` and `\u{85}` in it reach Postgres as a
backslash and letters. These two pieces of constant text are written as
ordinary string literals, whose escapes Temper does process, and put in as
SQL text with `SqlSource`. Only these literals are; nothing that arrives
at run time is.

The code points String.trim/1 removes (temper/src/blinks_write has how
they were found), quoted, as the second argument of btrim(). A test checks
the text against BLKW_WS_SQL, the same characters built in Blimp.

    let blkw_ws(): SqlFragment {
      sql"${new SqlSource("'\u{9}\u{a}\u{b}\u{c}\u{d} \u{85}\u{a0}\u{1680}\u{2000}\u{2001}\u{2002}\u{2003}\u{2004}\u{2005}\u{2006}\u{2007}\u{2008}\u{2009}\u{200a}\u{2028}\u{2029}\u{202f}\u{205f}\u{3000}'")}"
    }

Jason sorts a map's keys by their bytes; so does `collate "C"`.

    let blka_collate_c(): SqlFragment {
      sql"${new SqlSource("collate \"C\"")}"
    }

normalize_tags/1 over a text[] expression: trim, downcase, drop "", keep
the first of each. normalize_quotes/1: trim, drop "", the first 2,000
characters, keep the first of each.

    let blkw_norm_tags(arr: SqlFragment): SqlFragment {
      sql"array(select z.n from (select lower(btrim(u.t, ${blkw_ws()})) as n, min(u.o) as o from unnest(${arr}) with ordinality u(t, o) group by 1) z where z.n <> '' order by z.o)"
    }

    let blkw_norm_quotes(arr: SqlFragment): SqlFragment {
      sql"array(select z.n from (select left(btrim(u.t, ${blkw_ws()}), 2000) as n, min(u.o) as o from unnest(${arr}) with ordinality u(t, o) group by 1) z where z.n <> '' order by z.o)"
    }

A JSON list, as text, as a text[]. The Blimp side passes
`json_encode(list)`, which is what its Postgres client sends for a list.

    let blkw_text_array(json: String): SqlFragment {
      sql"array(select jsonb_array_elements_text(${json}::jsonb))"
    }

The title an edit leaves: the old one when `keep` is "1", else the new.

    let blkw_title(keep: String, title: String?): SqlFragment {
      sql"case when ${keep}::text = '1' then b.title else ${blkw_opt(title)}::text end"
    }

## Token-gated writes (99_blinkswrite.blimp)

An UPDATE that Ecto would make: `o` is the row as it is to be, computed
from `b` (the row now); updated_at moves only if something changed, as
Repo.update/1 sends nothing for a changeset without changes. Answers the
row, or nothing when there is no such id.

    let blkw_update(id: Int, title: SqlFragment, description: SqlFragment, tags: SqlFragment, quotes: SqlFragment): List<String> {
      db_q(sql"with o as (select b.id, ${title} as title, ${description} as description, ${tags} as tags, ${quotes} as quotes from blinks b where b.id = ${id}::bigint), w as (update blinks b set title = o.title, description = o.description, tags = o.tags, quotes = o.quotes, updated_at = case when (b.title, b.description, b.tags, b.quotes) is not distinct from (o.title, o.description, o.tags, o.quotes) then b.updated_at else ${blkw_now()} end from o where b.id = o.id returning b.*) ${blkw_row_from_w()}")
    }

save_blink/1, a new url. `tags` and `quotes` are JSON lists.

    export let blkw_insert_q(url: String, title: String?, description: String?, tags: String, quotes: String): List<String> {
      db_q(sql"with w as (insert into blinks (url, title, description, tags, quotes, inserted_at, updated_at) select ${url}::text, ${blkw_opt(title)}::text, ${blkw_opt(description)}::text, ${blkw_norm_tags(blkw_text_array(tags))}, ${blkw_norm_quotes(blkw_text_array(quotes))}, ${blkw_now()}, ${blkw_now()} returning *) ${blkw_row_from_w()}")
    }

    export let blkw_existing_q(url: String): List<String> {
      db_q(sql"select id, title, description from blinks where url = ${url}::text")
    }

save_blink/1, a url already saved: `keep` "1" keeps the title, a null
description keeps it. The lists are the old ones followed by the new,
normalized together.

    export let blkw_merge_q(id: Int, keep: String, title: String?, description: String?, tags: String, quotes: String): List<String> {
      blkw_update(id, blkw_title(keep, title),
        sql"coalesce(${blkw_opt(description)}::text, b.description)",
        blkw_norm_tags(sql"b.tags || ${blkw_text_array(tags)}"),
        blkw_norm_quotes(sql"b.quotes || ${blkw_text_array(quotes)}"))
    }

update_meta/2: the description is already trimmed; null clears it.

    export let blkw_meta_q(id: Int, keep: String, title: String?, description: String?): List<String> {
      blkw_update(id, blkw_title(keep, title), sql"${blkw_opt(description)}::text", sql"b.tags", sql"b.quotes")
    }

add_tags/2: `tags` the new ones as a JSON list.

    export let blkw_add_tags_q(id: Int, tags: String): List<String> {
      blkw_update(id, sql"b.title", sql"b.description", blkw_norm_tags(sql"b.tags || ${blkw_text_array(tags)}"), sql"b.quotes")
    }

remove_tag/2: List.delete/2 takes the first tag equal to `tag` out, then
the list is normalized again. A null tag is equal to none.

    export let blkw_remove_tag_q(id: Int, tag: String?): List<String> {
      blkw_update(id, sql"b.title", sql"b.description",
        blkw_norm_tags(sql"array(select u.t from unnest(b.tags) with ordinality u(t, o) where u.o is distinct from (select min(v.o) from unnest(b.tags) with ordinality v(t, o) where v.t = ${blkw_opt(tag)}::text) order by u.o)"),
        sql"b.quotes")
    }

    export let blkw_exists_q(id: Int): List<String> {
      db_q(sql"select id from blinks where id = ${id}::bigint")
    }

delete_blink/1: the blink (its comments, saves and reactions go by
ON DELETE CASCADE) and every message in its chat room, blink:<id>.

    export let blkw_delete_q(id: Int): List<String> {
      db_q(sql"with d as (delete from blinks where id = ${id}::bigint returning id), m as (delete from chat_messages where room = 'blink:' || (select id from d)) select id from d")
    }

import_candidates/1: `entries` the JSON list. A url that is a string
starting "http" and is not already a blink goes in as pending; one
already queued is skipped by the unique index. Titles are cut to 1,000
characters, folders to 200, urls to 4,096.

    export let blkw_candidates_q(entries: String): List<String> {
      db_q(sql"with i as (insert into bookmark_candidates (url, title, folder, status, inserted_at, updated_at) select left(e.v->>'url', 4096), left(e.v->>'title', 1000), left(e.v->>'folder', 200), 'pending', ${blkw_now()}, ${blkw_now()} from jsonb_array_elements(${entries}::jsonb) with ordinality e(v, o) where jsonb_typeof(e.v->'url') = 'string' and left(e.v->>'url', 4) = 'http' and not exists (select 1 from blinks b where b.url = e.v->>'url') order by e.o on conflict (url) do nothing returning 1) select count(*) as n from i")
    }

## Anyone's writes (99_blinksanon.blimp)

save_for_device/2: whether the blink is there, and the count after the
insert (idempotent). The count reads the table as it was before the
insert (one snapshot), so the inserted row is added.

    export let blka_save_q(id: Int, device: String): List<String> {
      db_q(sql"with b as (select id from blinks where id = ${id}::bigint), i as (insert into blink_saves (blink_id, device_hash, inserted_at, updated_at) select b.id, ${device}::text, ${blkw_now()}, ${blkw_now()} from b on conflict (blink_id, device_hash) do nothing returning 1) select (select count(*) from b) as found, (select count(*) from blink_saves where blink_id = ${id}::bigint) + (select count(*) from i) as n")
    }

unsave_for_device/2: the count after the delete.

    export let blka_unsave_q(id: Int, device: String): List<String> {
      db_q(sql"with d as (delete from blink_saves where blink_id = ${id}::bigint and device_hash = ${device}::text returning 1) select (select count(*) from blink_saves where blink_id = ${id}::bigint) - (select count(*) from d) as n")
    }

import_candidates/1 with one entry: `url` and `title` already cut, and
the url as sent (`whole`) for the is-it-a-blink check.

    export let blka_suggest_q(url: String, title: String?, whole: String): List<String> {
      db_q(sql"with i as (insert into bookmark_candidates (url, title, folder, status, inserted_at, updated_at) select ${url}::text, ${blkw_opt(title)}::text, 'app-suggest', 'pending', ${blkw_now()}, ${blkw_now()} where not exists (select 1 from blinks b where b.url = ${whole}::text) on conflict (url) do nothing returning 1) select count(*) as n from i")
    }

duplicate?/1: the same trimmed body on the same blink in the last ten
minutes.

    export let blka_duplicate_q(id: Int, content: String): List<String> {
      db_q(sql"select count(*) as n from blink_comments where blink_id = ${id}::bigint and content = ${content}::text and inserted_at > (now() at time zone 'UTC') - interval '600 seconds'")
    }

    export let blka_insert_comment_q(id: Int, author: String, content: String, ip_hash: String): List<String> {
      db_q(sql"with w as (insert into blink_comments (blink_id, author_name, content, ip_hash, report_count, inserted_at, updated_at) values (${id}::bigint, ${author}::text, ${content}::text, ${ip_hash}::text, 0, ${blkw_now()}, ${blkw_now()}) returning *) select row_to_json(c)::text as body, c.blink_id from (select w.id, w.blink_id, w.author_name, w.content, w.inserted_at, '{}'::json as reactions from w) c")
    }

report_comment/1: one more report; the one that reaches `hide_at` hides
it. Ecto's update also moves updated_at.

    export let blka_report_q(id: Int, hide_at: Int): List<String> {
      db_q(sql"update blink_comments set report_count = report_count + 1, hidden_at = case when report_count + 1 >= ${hide_at}::int and hidden_at is null then ${blkw_now()} else hidden_at end, updated_at = ${blkw_now()} where id = ${id}::bigint returning id, blink_id, (hidden_at is not null) as hidden")
    }

toggle_reaction/4, as two statements, the write then the count: in one,
the count would read the table from before the write.

    export let blka_react_q(id: Int, emoji: String, device: String): List<String> {
      db_q(sql"with c as (select id, blink_id from blink_comments where id = ${id}::bigint), i as (insert into blink_comment_reactions (comment_id, emoji, device_hash, inserted_at, updated_at) select c.id, ${emoji}::text, ${device}::text, ${blkw_now()}, ${blkw_now()} from c on conflict (comment_id, emoji, device_hash) do nothing returning 1) select c.blink_id from c")
    }

    export let blka_unreact_q(id: Int, emoji: String, device: String): List<String> {
      db_q(sql"with c as (select id, blink_id from blink_comments where id = ${id}::bigint), d as (delete from blink_comment_reactions r using c where r.comment_id = c.id and r.emoji = ${emoji}::text and r.device_hash = ${device}::text returning 1) select c.blink_id from c")
    }

reactions_for/1 of one comment: {"emoji": n}, keys sorted by their bytes
as Jason writes a small map.

    export let blka_reactions_q(id: Int): List<String> {
      db_q(sql"select coalesce((select '{' || string_agg(to_json(r.emoji)::text || ':' || r.n, ',' order by r.emoji ${blka_collate_c()}) || '}' from (select emoji, count(*) as n from blink_comment_reactions where comment_id = ${id}::bigint group by emoji) r), '{}') as body")
    }

delete/2 (admin). Its reactions go by ON DELETE CASCADE.

    export let blka_delete_comment_q(id: Int): List<String> {
      db_q(sql"delete from blink_comments where id = ${id}::bigint returning id, blink_id")
    }

## The chat rooms (99_blinkschat.blimp)

    export let bkc_by_ip_q(ip_hash: String): List<String> {
      db_q(sql"select id, screen_name as name, color from chatters where ip_hash = ${ip_hash} order by id limit 1")
    }

    export let bkc_taken_q(name: String, except: Int): List<String> {
      db_q(sql"select count(*)::int as n from chatters where screen_name = ${name} and id <> ${except}")
    }

    export let bkc_create_q(name: String, ip_hash: String, color: String): List<String> {
      db_q(sql"insert into chatters (screen_name, ip_hash, color, inserted_at, updated_at) values (${name}, ${ip_hash}, ${color}, ${blkw_now()}, ${blkw_now()}) returning id, screen_name as name, color")
    }

    export let bkc_rename_q(name: String, id: Int): List<String> {
      db_q(sql"update chatters set screen_name = ${name}, updated_at = ${blkw_now()} where id = ${id} returning id, screen_name as name, color")
    }

list_messages(room, 100): the newest hundred, oldest first.

    let bkc_last_100(room: String): SqlFragment {
      sql"select id from chat_messages where room = ${room} order by inserted_at desc, id desc limit 100"
    }

    export let bkc_history_q(room: String): List<String> {
      db_q(sql"select coalesce(json_agg(json_build_object('id', x.id, 'reply_to_id', coalesce(x.reply_to_id, 0), 'content', x.content, 'at', to_char(x.inserted_at, 'HH12:MI AM'), 'name', x.name, 'color', x.color) order by x.inserted_at, x.id), '[]')::text as body from (select m.id, m.reply_to_id, m.content, m.inserted_at, c.screen_name as name, c.color from chat_messages m left join chatters c on c.id = m.chatter_id where m.id in (${bkc_last_100(room)})) x")
    }

vote_counts/1 and my_votes/2 over those hundred: {"id": [up, down]},
{"id": v}.

    export let bkc_votes_q(room: String, me: Int): List<String> {
      db_q(sql"select coalesce(json_object_agg(v.message_id, json_build_array(v.up, v.down)), '{}')::text as counts, coalesce(json_object_agg(v.message_id, v.mine) filter (where v.mine <> 0), '{}')::text as mine from (select message_id, count(*) filter (where value > 0) as up, count(*) filter (where value < 0) as down, coalesce(max(value) filter (where chatter_id = ${me}), 0) as mine from chat_message_votes where message_id in (${bkc_last_100(room)}) group by message_id) v")
    }

create_message/4: the reply target, only within the room; a reply to a
reply hangs off its top-level message (threads are one deep).

    export let bkc_reply_to_q(id: Int, room: String): List<String> {
      db_q(sql"select coalesce(reply_to_id, id) as top from chat_messages where id = ${id} and room = ${room}")
    }

    export let bkc_say_q(content: String, room: String, chatter: Int, top: Int): List<String> {
      db_q(sql"insert into chat_messages (content, room, chatter_id, reply_to_id, inserted_at, updated_at) values (${content}, ${room}, ${chatter}, nullif(${top}::bigint, 0), ${blkw_now()}, ${blkw_now()}) returning id, coalesce(reply_to_id, 0) as reply_to_id, to_char(inserted_at, 'HH12:MI AM') as at")
    }

    export let bkc_room_of_q(id: Int): List<String> {
      db_q(sql"select room from chat_messages where id = ${id}")
    }

vote_message/3: none -> insert; the same value -> delete; the other ->
switch. The string version named $1, $2 and $3 more than once; here each
use is its own parameter ($1 to $8). Postgres types the ones in the
insert's select list from the columns they go into, as before.

    export let bkc_vote_q(id: Int, chatter: Int, value: Int): List<String> {
      db_q(sql"with old as (select id, value from chat_message_votes where message_id = ${id} and chatter_id = ${chatter}), gone as (delete from chat_message_votes where id in (select id from old where value = ${value}) returning id), switched as (update chat_message_votes set value = ${value}, updated_at = ${blkw_now()} where id in (select id from old where value <> ${value}) returning id), added as (insert into chat_message_votes (message_id, chatter_id, value, inserted_at, updated_at) select ${id}, ${chatter}, ${value}, ${blkw_now()}, ${blkw_now()} where not exists (select 1 from old) returning id) select (select count(*) from gone)::int + (select count(*) from switched)::int + (select count(*) from added)::int as n")
    }

    export let bkc_counts_q(id: Int, chatter: Int): List<String> {
      db_q(sql"select count(*) filter (where value > 0)::int as up, count(*) filter (where value < 0)::int as down, coalesce(max(value) filter (where chatter_id = ${chatter}), 0)::int as mine from chat_message_votes where message_id = ${id}")
    }
