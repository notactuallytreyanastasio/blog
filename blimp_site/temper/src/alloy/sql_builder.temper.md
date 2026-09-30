# SQL Query Builder

## The `sql` tag

This builds a semi-structured *SqlFragment* representation that then can have
values rendered for various DB dialects.

TODO Would it be possible to extract a "prepared statement" form as well? Could
that be recognized and cached instead of rebuilt each time?

    export let sql = SqlBuilder;

    export class SqlBuilder {
      private let buffer: ListBuilder<SqlPart> = new ListBuilder<SqlPart>();

      // appendSafe
      public appendSafe(sqlSource: String): Void {
        buffer.add(new SqlSource(sqlSource));
      }

      // appendSqlFragment: add contents of another SQL fragment
      @overload("append")
      public appendFragment(fragment: SqlFragment): Void {
        buffer.addAll(fragment.parts);
      }

      // appendSqlPart: add a single already qualified SQL part
      @overload("append")
      public appendPart(part: SqlPart): Void {
        buffer.add(part);
      }

      // appendSqlPartList
      @overload("append")
      public appendPartList(values: List<SqlPart>): Void {
        appendList(values) { (x: SqlPart) => appendPart(x) };
      }

      // appendBoolean
      @overload("append")
      public appendBoolean(value: Boolean): Void {
        buffer.add(new SqlBoolean(value));
      }

      // appendBooleanList
      @overload("append")
      public appendBooleanList(values: Listed<Boolean>): Void {
        appendList(values) { (x: Boolean) => appendBoolean(x) };
      }

      // appendDate
      @overload("append")
      public appendDate(value: Date): Void {
        buffer.add(new SqlDate(value));
      }

      // appendDateList
      @overload("append")
      public appendDateList(values: Listed<Date>): Void {
        appendList(values) { (x: Date) => appendDate(x) };
      }

      // appendFloat64
      @overload("append")
      public appendFloat64(value: Float64): Void {
        buffer.add(new SqlFloat64(value));
      }

      // appendFloat64List
      @overload("append")
      public appendFloat64List(values: Listed<Float64>): Void {
        appendList(values) { (x: Float64) => appendFloat64(x) };
      }

      // appendInt32
      @overload("append")
      public appendInt32(value: Int32): Void {
        buffer.add(new SqlInt32(value));
      }

      // appendInt32List
      @overload("append")
      public appendInt32List(values: Listed<Int32>): Void {
        appendList(values) { (x: Int32) => appendInt32(x) };
      }

      // appendInt64
      @overload("append")
      public appendInt64(value: Int64): Void {
        buffer.add(new SqlInt64(value));
      }

      // appendInt64List
      @overload("append")
      public appendInt64List(values: Listed<Int64>): Void {
        appendList(values) { (x: Int64) => appendInt64(x) };
      }

      // appendString
      @overload("append")
      public appendString(value: String): Void {
        buffer.add(new SqlString(value));
      }

      // appendStringList
      @overload("append")
      public appendStringList(values: Listed<String>): Void {
        appendList(values) { (x: String) => appendString(x) };
      }

      // appendList: helper for list append methods
      private appendList<T>(values: Listed<T>, appendValue: Appender<T>): Void {
        for (var i = 0; i < values.length; i++) {
          if (i > 0) {
            appendSafe(", ");
          }
          appendValue(values[i]);
        }
      }

      // accumulated
      public get accumulated(): SqlFragment {
        new SqlFragment(buffer.toList())
      }
    }

## Helper types

    @fun interface Appender<T>(value: T): Void;
