# The site's SQL, built with Alloy

Every query the Blimp side sends to Postgres from the pages below is built
here, with [Alloy](https://github.com/notactuallytreyanastasio/alloy), the
Temper ORM vendored in `../alloy` (from alloy `8a52073`). What the Blimp
side gets back is a list: the SQL text first, then each parameter, as text,
in order. It sends them as they are, `DB <- :query(head(q), tail(q))`.

The text has `$1`, `$2`, ... where values go, so values are bound by
Postgres, never escaped into the SQL: that is Alloy's `toParameterized`.
A value can only get into a query through a `${...}` in a `sql` fragment or
an Alloy builder method, so there is no way to splice a string into one by
accident. A table or column name the site writes is a `SafeIdentifier`,
checked when it is made.

Alloy's builder is used where the query is its shape: one table, filtered,
ordered, limited, or an update of one table. Where Postgres is doing more
than that (json_agg, window functions, `unnest ... with ordinality`) the
statement is one `sql` fragment. It is still Alloy's: values in it are
parameters all the same.

    let { safeIdentifier, SafeIdentifier, SqlFragment } = import("../alloy");

A name this site writes itself cannot fail the check. If one ever does,
that is a bug here, and it stops the program where it is made.

    export let db_id(name: String): SafeIdentifier {
      safeIdentifier(name) orelse panic()
    }

    export let db_q(f: SqlFragment): List<String> {
      let p = f.toParameterized();
      let out = new ListBuilder<String>();
      out.add(p.text);
      out.addAll(p.params);
      out.toList()
    }
