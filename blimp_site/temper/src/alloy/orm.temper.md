# Orm

Top-level helpers.

## Imports

All types (SqlFragment, SqlBuilder, TableDef) are available from other
files in the same module without explicit imports.

## deleteSql

Generates `DELETE FROM … WHERE id = ?`.

`appendSafe` is called only with: (a) the string literal `"DELETE FROM "` /
`" WHERE id = "`, and (b) `tableDef.tableName.sqlValue` which is the
`.sqlValue` of a `SafeIdentifier` — validated at `TableDef` construction
time. The `id` is rendered as `SqlInt32` (a bare integer, never quoted).

No raw runtime string ever touches `appendSafe` here.

    export let deleteSql(tableDef: TableDef, id: Int): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("DELETE FROM ");
      b.appendSafe(tableDef.tableName.sqlValue);
      b.appendSafe(" WHERE ");
      b.appendSafe(tableDef.pkName());
      b.appendSafe(" = ");
      b.appendInt32(id);
      b.accumulated
    }
