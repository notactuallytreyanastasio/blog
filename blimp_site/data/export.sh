#!/usr/bin/env bash
# Snapshot the homepage's database rows into files Blimp can `split`.
#
# Blimp has no database client and no JSON parser, so the desktop reads
# tab-separated lines: one record per line, NULL as an empty field.
#
#   museum.tsv          visible museum_projects in sort_order:
#                       slug title tagline description category tech_stack
#                       internal_path external_url pixel_art_path emoji color
#                       sort_order
#                       tech_stack is joined with ","; description escapes
#                       \ as \\, newline as \n and tab as \t
#   museum_repos.tsv    slug name full_name, one row per github_repos entry,
#                       in array order
#   finder_sections.tsv visible finder_sections in sort_order: name label
#   finder_items.tsv    visible items of visible sections, by section then
#                       item sort_order: section name icon path action
#                       description
#   icons.txt           the ASCII grids from lib/blog/museum/icons.ex:
#                       "== slug" then the grid rows, trimmed; "== default"
#                       is the fallback
#
# A field that would break a line or a column stops the export instead of
# being written mangled. Run from anywhere: ./data/export.sh [database]
set -euo pipefail
cd "$(dirname "$0")"
DB="${1:-blog_dev}"
ICONS="../../lib/blog/museum/icons.ex"

# PSQL is the client to run. Production's database is only reachable inside
# its container, so a snapshot of the live site is
#
#   PSQL='ssh hetzner docker exec -i blog-db-1 psql -U blog -d blog_prod' ./data/export.sh
#
# The SQL goes in on stdin, with the separator set there, so nothing in it
# has to survive a remote shell's quoting; and every session is read-only.
PSQL="${PSQL:-psql -d $DB}"
q() {
  printf '%s\n' '\set ON_ERROR_STOP on' '\pset format unaligned' '\pset tuples_only on' \
    "\\pset fieldsep '\\t'" 'set default_transaction_read_only = on;' "$1;" | $PSQL -X -q
}

# Every field but description must be free of tabs, newlines, CRs and
# backslashes; tech names also of commas, since they are joined with one.
bad=$(q "select slug from museum_projects where visible and (
  concat_ws('', slug, title, tagline, category, internal_path, external_url,
            pixel_art_path, emoji, color) ~ '[\t\n\r\\\\]'
  or description ~ '\r'
  or exists (select 1 from unnest(tech_stack) t where t ~ '[\t\n\r\\\\,]')
  or exists (select 1 from unnest(github_repos) r
             where concat(r->>'name', r->>'full_name') ~ '[\t\n\r\\\\]'))")
if [ -n "$bad" ]; then echo "museum rows with unexportable fields: $bad" >&2; exit 1; fi

bad=$(q "select s.name || '/' || coalesce(i.name, '') from finder_sections s
  left join finder_items i on i.section_id = s.id
  where concat_ws('', s.name, s.label, i.name, i.icon, i.path, i.action, i.description) ~ '[\t\n\r\\\\]'")
if [ -n "$bad" ]; then echo "finder rows with unexportable fields: $bad" >&2; exit 1; fi

q "select slug, title, tagline,
     replace(replace(replace(coalesce(description, ''), '\\', '\\\\'), E'\n', '\\n'), E'\t', '\\t'),
     category, array_to_string(tech_stack, ','), internal_path, external_url,
     pixel_art_path, emoji, color, sort_order
   from museum_projects where visible order by sort_order, id" > museum.tsv

q "select p.slug, r.repo->>'name', r.repo->>'full_name'
   from museum_projects p, unnest(p.github_repos) with ordinality as r(repo, n)
   where p.visible order by p.sort_order, p.id, r.n" > museum_repos.tsv

q "select name, label from finder_sections where visible order by sort_order, id" > finder_sections.tsv

q "select s.name, i.name, i.icon, i.path, i.action, i.description
   from finder_items i join finder_sections s on s.id = i.section_id
   where s.visible and i.visible order by s.sort_order, s.id, i.sort_order, i.id" > finder_items.tsv

# icons.ex: `defp default do pixels("""` and `"slug" => pixels("""` open a
# grid, `""")` closes it. pixels/1 trims the text and then every row.
awk '
  /defp default do/ { want = "default" }
  /^ *"[^"]+" => pixels\("""/ { match($0, /"[^"]+"/); want = substr($0, RSTART + 1, RLENGTH - 2) }
  /pixels\("""/ { print "== " want; inside = 1; next }
  inside && /^ *"""\)/ { inside = 0; next }
  inside { gsub(/^[ \t]+|[ \t]+$/, ""); if ($0 != "") print }
' "$ICONS" > icons.txt

n_icons=$(grep -c '^== ' icons.txt)
n_src=$(grep -c 'pixels("""' "$ICONS")
if [ "$n_icons" != "$n_src" ]; then echo "icons.txt has $n_icons grids, icons.ex has $n_src" >&2; exit 1; fi
if grep -v '^== ' icons.txt | grep -q '[^.#]'; then echo "icons.txt has a character that is not . or #" >&2; exit 1; fi

wc -l museum.tsv museum_repos.tsv finder_sections.tsv finder_items.tsv
echo "$n_icons icons"
