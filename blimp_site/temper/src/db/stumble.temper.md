# Stumble

    let { update, sql, SqlFragment, SqlSource } = import("../alloy");

What each link comes back as, to the page.

    let st_link_json(): SqlFragment {
      sql"json_build_object('id', q.id, 'url', q.url, 'post_text', coalesce(q.post_text, ''), 'domain', coalesce(q.domain, ''))"
    }

The language filter is either there or not. The Blimp version always sent
one parameter for it, and wrote `$1 = $1` when there was no filter so that
Postgres still had a use for it; a fragment that is not there takes none.

    let st_langs(qualified: Boolean, langs: String): SqlFragment {
      if (langs.isEmpty) {
        sql""
      } else if (qualified) {
        sql" and l.langs && string_to_array(${langs}, ',')::varchar[]"
      } else {
        sql" and langs && string_to_array(${langs}, ',')::varchar[]"
      }
    }

random_links/2: fifty links with a score of at least `min_score`, in a random
order. With `sample`, from `sample_size` random ids rather than the whole
table (an `order by random()` over 2.3M rows took 800 ms).

    export let st_links_q(sample: Boolean, sample_size: Int, min_score: Int, limit: Int, langs: String): List<String> {
      let pick = if (sample) {
        sql"id = any(array(select (1 + floor(random() * (select max(id) from pa_links)))::bigint from generate_series(1, ${sample_size}))) and "
      } else {
        sql""
      };
      db_q(sql"select count(*) as n, coalesce(json_agg(${st_link_json()}), '[]')::text as body from (select id, url, post_text, domain from pa_links where ${pick}score >= ${min_score}${st_langs(false, langs)} order by random() limit ${limit}) q")
    }

links_by_tag/2: the newest fifty with the tag.

    export let st_tag_q(slug: String, langs: String): List<String> {
      db_q(sql"select coalesce(json_agg(${st_link_json()}), '[]')::text as body from (select l.id, l.url, l.post_text, l.domain from pa_links l join pa_link_tags lt on lt.link_id = l.id join pa_tags t on t.id = lt.tag_id where t.slug = ${slug}${st_langs(true, langs)} order by l.inserted_at desc limit 50) q")
    }

Every tag, in list_tags/0's order (usage_count desc, name), with its name as
lower() has it, its age in seconds (inserted_at is UTC), and its place among
the names and among the creation times in Postgres's order: the program
sorts by those, so names sort by the database's collation as they did.

    export let st_tags_q(): List<String> {
      db_q(sql"select coalesce(json_agg(json_build_object('name', t.name, 'lower', lower(t.name), 'slug', t.slug, 'usage', t.usage_count, 'age', extract(epoch from (now() at time zone 'utc') - t.inserted_at)::float8, 'name_rank', t.name_rank, 'created_rank', t.created_rank) order by t.usage_count desc, t.name_rank), '[]')::text as body from (select *, (row_number() over (order by name))::int as name_rank, (dense_rank() over (order by inserted_at))::int as created_rank from pa_tags) t")
    }

    export let st_count_q(): List<String> {
      db_q(sql"select count(*) as n from pa_links")
    }

`open`: a GET counts the stumble and answers the url; a HEAD only looks.
The id is digits by the time it gets here (st_digits_only), and it is a
parameter either way.

    export let st_go_q(id: String, count: Boolean): List<String> {
      if (count) {
        let u = update(db_id("pa_links"))
          .set(db_id("stumble_count"), new SqlSource("stumble_count + 1"))
          .where(sql"id = ${id}::bigint")
          .toSql() orelse panic();
        db_q(sql"${u} returning url")
      } else {
        db_q(sql"select url from pa_links where id = ${id}::bigint")
      }
    }
