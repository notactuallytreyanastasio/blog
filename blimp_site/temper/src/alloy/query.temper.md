# Query

Composable, immutable SELECT query builder.

## Security model

- `tableName`, `selectedFields`, and `orderBy` fields all require
  `SafeIdentifier` — validated against `[a-zA-Z_][a-zA-Z0-9_]*` before
  they can be passed here. There is no path for a raw user string to reach
  `appendSafe` except through a `SafeIdentifier`.
- `appendSafe` is only ever called with: (a) hardcoded SQL keyword string
  literals, or (b) `safeIdentifier.sqlValue`. Never with runtime arbitrary
  strings.
- User values only enter SQL via `SqlFragment` conditions already built
  with the `sql` tag. The `where()` method takes a `SqlFragment`, not a
  raw `String`.
- `safeToSql(defaultLimit)` is provided as the production-safe variant
  that always applies an upper bound on result set size (CWE-400).
- `orWhere()` follows the same safety model as `where()` — it accepts
  only `SqlFragment` arguments, ensuring user data is always escaped.
- Convenience methods (`whereNull`, `whereNotNull`, `whereIn`, `whereNot`,
  `whereBetween`, `whereLike`, `whereILike`) build SQL fragments internally
  using only `SafeIdentifier` for field names and `SqlPart`/`SqlString`
  for values — no raw strings reach `appendSafe`.

## Imports

All types (SqlFragment, SqlBuilder, sql, SafeIdentifier) are available
from other files in the same module without explicit imports.

## JoinType

Sealed interface for JOIN keywords. Each implementation returns a hardcoded
SQL keyword string — no user input reaches the keyword.

    export sealed interface JoinType {
      public keyword(): String;
    }

    export class InnerJoin() extends JoinType {
      // keyword
      public keyword(): String { "INNER JOIN" }
    }

    export class LeftJoin() extends JoinType {
      // keyword
      public keyword(): String { "LEFT JOIN" }
    }

    export class RightJoin() extends JoinType {
      // keyword
      public keyword(): String { "RIGHT JOIN" }
    }

    export class FullJoin() extends JoinType {
      // keyword
      public keyword(): String { "FULL OUTER JOIN" }
    }

    export class CrossJoin() extends JoinType {
      // keyword
      public keyword(): String { "CROSS JOIN" }
    }

## JoinClause

Associates a join type, target table, and optional ON condition. `onCondition`
is nullable to support CROSS JOIN which has no ON clause.

    export class JoinClause(
      public joinType: JoinType,
      public table: SafeIdentifier,
      public onCondition: SqlFragment?,
    ) {}

## NullsPosition

Controls NULL ordering in ORDER BY. Each implementation returns a hardcoded
SQL clause — no user input reaches the keyword.

    export sealed interface NullsPosition {
      public keyword(): String;
    }

    export class NullsFirst() extends NullsPosition {
      // keyword
      public keyword(): String { " NULLS FIRST" }
    }

    export class NullsLast() extends NullsPosition {
      // keyword
      public keyword(): String { " NULLS LAST" }
    }

## OrderClause

Associates a field with a sort direction and optional nulls position.

    export class OrderClause(
      public field: SafeIdentifier,
      public ascending: Boolean,
      public nullsPos: NullsPosition?,
    ) {}

## LockMode

Row-level locking for SELECT queries. Each implementation returns a hardcoded
SQL clause appended after LIMIT/OFFSET.

    export sealed interface LockMode {
      public keyword(): String;
    }

    export class ForUpdate() extends LockMode {
      // keyword
      public keyword(): String { " FOR UPDATE" }
    }

    export class ForShare() extends LockMode {
      // keyword
      public keyword(): String { " FOR SHARE" }
    }

## WhereClause

Ecto equivalent: `Ecto.Query.where/3` with `:and` / `:or` composition.

Each WHERE condition is tagged as either AND or OR, enabling mixed boolean
logic in the WHERE clause. The first condition is always rendered bare
(without a conjunction keyword); subsequent conditions are prefixed with
their `keyword()` — either `"AND"` or `"OR"`.

The `keyword()` method follows the same pattern as `JoinType.keyword()`:
a sealed interface with hardcoded string returns, ensuring only valid SQL
keywords are emitted. The `condition` getter exposes the underlying
`SqlFragment` for SQL rendering.

    export sealed interface WhereClause {
      public get condition(): SqlFragment;
      public keyword(): String;
    }

    export class AndCondition(private _condition: SqlFragment) extends WhereClause {
      // condition
      public get condition(): SqlFragment { _condition }
      // keyword
      public keyword(): String { "AND" }
    }

    export class OrCondition(private _condition: SqlFragment) extends WhereClause {
      // condition
      public get condition(): SqlFragment { _condition }
      // keyword
      public keyword(): String { "OR" }
    }

## Shared rendering helpers

Extracted to eliminate duplication across Query, countSql, UpdateQuery, and
DeleteQuery. Not exported — internal to the module.

    let renderWhere(b: SqlBuilder, conditions: List<WhereClause>): Void {
      if (!conditions.isEmpty) {
        b.appendSafe(" WHERE ");
        b.appendFragment(conditions[0].condition);
        for (var i = 1; i < conditions.length; ++i) {
          b.appendSafe(" ");
          b.appendSafe(conditions[i].keyword());
          b.appendSafe(" ");
          b.appendFragment(conditions[i].condition);
        }
      }
    }

    let renderJoins(b: SqlBuilder, joinClauses: List<JoinClause>): Void {
      for (let jc of joinClauses) {
        b.appendSafe(" ");
        b.appendSafe(jc.joinType.keyword());
        b.appendSafe(" ");
        b.appendSafe(jc.table.sqlValue);
        let oc = jc.onCondition;
        if (oc != null) {
          b.appendSafe(" ON ");
          b.appendFragment(oc);
        }
      }
    }

    let renderGroupBy(b: SqlBuilder, groupByFields: List<SafeIdentifier>): Void {
      if (!groupByFields.isEmpty) {
        b.appendSafe(" GROUP BY ");
        b.appendSafe(groupByFields.join(", ") { f => f.sqlValue });
      }
    }

    let renderHaving(b: SqlBuilder, havingConditions: List<WhereClause>): Void {
      if (!havingConditions.isEmpty) {
        b.appendSafe(" HAVING ");
        b.appendFragment(havingConditions[0].condition);
        for (var i = 1; i < havingConditions.length; ++i) {
          b.appendSafe(" ");
          b.appendSafe(havingConditions[i].keyword());
          b.appendSafe(" ");
          b.appendFragment(havingConditions[i].condition);
        }
      }
    }

## Query

Immutable query builder. Every mutation method returns a new `Query` instance.
The constructor fields are public to enable inspection, but construction is
typically done through `from()` and the builder methods.

    export class Query(
      public tableName: SafeIdentifier,
      public conditions: List<WhereClause>,
      public selectedFields: List<SafeIdentifier>,
      public orderClauses: List<OrderClause>,
      public limitVal: Int?,
      public offsetVal: Int?,
      public joinClauses: List<JoinClause>,
      public groupByFields: List<SafeIdentifier>,
      public havingConditions: List<WhereClause>,
      public isDistinct: Boolean,
      public selectExprs: List<SqlFragment>,
      public lockMode: LockMode?,
    ) {

      // where: AND condition — Ecto equivalent of `where/3`
      public where(condition: SqlFragment): Query {
        let nb = conditions.toListBuilder();
        nb.add(new AndCondition(condition));
        new Query(tableName, nb.toList(), selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // orWhere: OR condition — Ecto equivalent of `or_where/3`
      public orWhere(condition: SqlFragment): Query {
        let nb = conditions.toListBuilder();
        nb.add(new OrCondition(condition));
        new Query(tableName, nb.toList(), selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // whereNull: field IS NULL — Ecto equivalent of `is_nil/1` in where clause
      public whereNull(field: SafeIdentifier): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" IS NULL");
        this.where(b.accumulated)
      }

      // whereNotNull: field IS NOT NULL
      public whereNotNull(field: SafeIdentifier): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" IS NOT NULL");
        this.where(b.accumulated)
      }

      // whereIn: field IN (values) — empty list yields 1 = 0 (safe degenerate)
      // Ecto equivalent of `where(q, [r], r.field in ^values)`
      public whereIn(field: SafeIdentifier, values: List<SqlPart>): Query {
        if (values.isEmpty) {
          let b = new SqlBuilder();
          b.appendSafe("1 = 0");
          return this.where(b.accumulated);
        }
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" IN (");
        b.appendPart(values[0]);
        for (var i = 1; i < values.length; ++i) {
          b.appendSafe(", ");
          b.appendPart(values[i]);
        }
        b.appendSafe(")");
        this.where(b.accumulated)
      }

      // whereInSubquery: field IN (SELECT ...) for correlated subqueries
      public whereInSubquery(field: SafeIdentifier, sub: Query): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" IN (");
        b.appendFragment(sub.toSql());
        b.appendSafe(")");
        this.where(b.accumulated)
      }

      // whereNot: NOT (condition) — Ecto equivalent of `not/1`
      public whereNot(condition: SqlFragment): Query {
        let b = new SqlBuilder();
        b.appendSafe("NOT (");
        b.appendFragment(condition);
        b.appendSafe(")");
        this.where(b.accumulated)
      }

      // whereBetween: field BETWEEN low AND high
      public whereBetween(field: SafeIdentifier, low: SqlPart, high: SqlPart): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" BETWEEN ");
        b.appendPart(low);
        b.appendSafe(" AND ");
        b.appendPart(high);
        this.where(b.accumulated)
      }

      // whereLike: field LIKE 'pattern' — pattern goes through SqlString escaping
      // Ecto equivalent of `like/2`
      public whereLike(field: SafeIdentifier, pattern: String): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" LIKE ");
        b.appendString(pattern);
        this.where(b.accumulated)
      }

      // whereILike: field ILIKE 'pattern' — case-insensitive LIKE (PostgreSQL)
      // Ecto equivalent of `ilike/2`
      public whereILike(field: SafeIdentifier, pattern: String): Query {
        let b = new SqlBuilder();
        b.appendSafe(field.sqlValue);
        b.appendSafe(" ILIKE ");
        b.appendString(pattern);
        this.where(b.accumulated)
      }

      // select: field names must be SafeIdentifier values
      public select(fields: List<SafeIdentifier>): Query {
        new Query(tableName, conditions, fields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // selectExpr: expression-based SELECT for aggregates and computed columns
      public selectExpr(exprs: List<SqlFragment>): Query {
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, exprs, lockMode)
      }

      // orderBy
      public orderBy(field: SafeIdentifier, ascending: Boolean): Query {
        let nb = orderClauses.toListBuilder();
        nb.add(new OrderClause(field, ascending, null));
        new Query(tableName, conditions, selectedFields, nb.toList(), limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // orderByNulls: ORDER BY with NULLS FIRST/LAST
      public orderByNulls(field: SafeIdentifier, ascending: Boolean, nulls: NullsPosition): Query {
        let nb = orderClauses.toListBuilder();
        nb.add(new OrderClause(field, ascending, nulls));
        new Query(tableName, conditions, selectedFields, nb.toList(), limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // limit: bubbles on negative values
      public limit(n: Int): Query throws Bubble {
        if (n < 0) { bubble() }
        new Query(tableName, conditions, selectedFields, orderClauses, n, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // offset: bubbles on negative values
      public offset(n: Int): Query throws Bubble {
        if (n < 0) { bubble() }
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, n, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // join: generic join method
      public join(joinType: JoinType, table: SafeIdentifier, onCondition: SqlFragment): Query {
        let nb = joinClauses.toListBuilder();
        nb.add(new JoinClause(joinType, table, onCondition));
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, nb.toList(), groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // innerJoin
      public innerJoin(table: SafeIdentifier, onCondition: SqlFragment): Query {
        join(new InnerJoin(), table, onCondition)
      }

      // leftJoin
      public leftJoin(table: SafeIdentifier, onCondition: SqlFragment): Query {
        join(new LeftJoin(), table, onCondition)
      }

      // rightJoin
      public rightJoin(table: SafeIdentifier, onCondition: SqlFragment): Query {
        join(new RightJoin(), table, onCondition)
      }

      // fullJoin
      public fullJoin(table: SafeIdentifier, onCondition: SqlFragment): Query {
        join(new FullJoin(), table, onCondition)
      }

      // crossJoin: CROSS JOIN with no ON condition
      public crossJoin(table: SafeIdentifier): Query {
        let nb = joinClauses.toListBuilder();
        nb.add(new JoinClause(new CrossJoin(), table, null));
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, nb.toList(), groupByFields, havingConditions, isDistinct, selectExprs, lockMode)
      }

      // groupBy: adds a GROUP BY field
      public groupBy(field: SafeIdentifier): Query {
        let nb = groupByFields.toListBuilder();
        nb.add(field);
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, nb.toList(), havingConditions, isDistinct, selectExprs, lockMode)
      }

      // having: AND condition on HAVING clause
      public having(condition: SqlFragment): Query {
        let nb = havingConditions.toListBuilder();
        nb.add(new AndCondition(condition));
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, nb.toList(), isDistinct, selectExprs, lockMode)
      }

      // orHaving: OR condition on HAVING clause
      public orHaving(condition: SqlFragment): Query {
        let nb = havingConditions.toListBuilder();
        nb.add(new OrCondition(condition));
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, nb.toList(), isDistinct, selectExprs, lockMode)
      }

      // distinct: enables SELECT DISTINCT
      public distinct(): Query {
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, true, selectExprs, lockMode)
      }

      // lock: adds row-level locking (FOR UPDATE / FOR SHARE)
      public lock(mode: LockMode): Query {
        new Query(tableName, conditions, selectedFields, orderClauses, limitVal, offsetVal, joinClauses, groupByFields, havingConditions, isDistinct, selectExprs, mode)
      }

      // toSql: assembles the final SqlFragment
      public toSql(): SqlFragment {
        let b = new SqlBuilder();

        if (isDistinct) {
          b.appendSafe("SELECT DISTINCT ");
        } else {
          b.appendSafe("SELECT ");
        }

        if (!selectExprs.isEmpty) {
          b.appendFragment(selectExprs[0]);
          for (var i = 1; i < selectExprs.length; ++i) {
            b.appendSafe(", ");
            b.appendFragment(selectExprs[i]);
          }
        } else if (selectedFields.isEmpty) {
          b.appendSafe("*");
        } else {
          b.appendSafe(selectedFields.join(", ") { f => f.sqlValue });
        }

        b.appendSafe(" FROM ");
        b.appendSafe(tableName.sqlValue);

        renderJoins(b, joinClauses);
        renderWhere(b, conditions);
        renderGroupBy(b, groupByFields);
        renderHaving(b, havingConditions);

        if (!orderClauses.isEmpty) {
          b.appendSafe(" ORDER BY ");
          var first = true;
          for (let orc of orderClauses) {
            if (!first) { b.appendSafe(", "); }
            first = false;
            b.appendSafe(orc.field.sqlValue);
            b.appendSafe(if (orc.ascending) { " ASC" } else { " DESC" });
            let np = orc.nullsPos;
            if (np != null) {
              b.appendSafe(np.keyword());
            }
          }
        }

        let lv = limitVal;
        if (lv != null) {
          b.appendSafe(" LIMIT ");
          b.appendInt32(lv);
        }
        let ov = offsetVal;
        if (ov != null) {
          b.appendSafe(" OFFSET ");
          b.appendInt32(ov);
        }

        let lm = lockMode;
        if (lm != null) {
          b.appendSafe(lm.keyword());
        }

        b.accumulated
      }

      // countSql: SELECT COUNT(*) preserving WHERE, JOIN, GROUP BY, HAVING
      public countSql(): SqlFragment {
        let b = new SqlBuilder();
        b.appendSafe("SELECT COUNT(*) FROM ");
        b.appendSafe(tableName.sqlValue);
        renderJoins(b, joinClauses);
        renderWhere(b, conditions);
        renderGroupBy(b, groupByFields);
        renderHaving(b, havingConditions);
        b.accumulated
      }

      // safeToSql: production-safe variant, applies defaultLimit if none set (CWE-400)
      public safeToSql(defaultLimit: Int): SqlFragment throws Bubble {
        if (defaultLimit < 0) { bubble() }
        if (limitVal != null) { toSql() } else { this.limit(defaultLimit).toSql() }
      }

    }

## from

Entry point. `tableName` must be a `SafeIdentifier`.

    export let from(tableName: SafeIdentifier): Query {
      new Query(tableName, [], [], [], null, null, [], [], [], false, [], null)
    }

## col

Qualified column reference helper. Both `table` and `column` must be
`SafeIdentifier` values, so the result is always safe.

    export let col(table: SafeIdentifier, column: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe(table.sqlValue);
      b.appendSafe(".");
      b.appendSafe(column.sqlValue);
      b.accumulated
    }

## Aggregate Functions

Free functions producing `SqlFragment` values for use with `selectExpr()`
and `having()`. Each uses `appendSafe` exclusively with hardcoded function
names and `SafeIdentifier.sqlValue` for field names.

    export let countAll(): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("COUNT(*)");
      b.accumulated
    }

    export let countCol(field: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("COUNT(");
      b.appendSafe(field.sqlValue);
      b.appendSafe(")");
      b.accumulated
    }

    export let sumCol(field: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("SUM(");
      b.appendSafe(field.sqlValue);
      b.appendSafe(")");
      b.accumulated
    }

    export let avgCol(field: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("AVG(");
      b.appendSafe(field.sqlValue);
      b.appendSafe(")");
      b.accumulated
    }

    export let minCol(field: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("MIN(");
      b.appendSafe(field.sqlValue);
      b.appendSafe(")");
      b.accumulated
    }

    export let maxCol(field: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("MAX(");
      b.appendSafe(field.sqlValue);
      b.appendSafe(")");
      b.accumulated
    }

## Set Operations

Free functions that combine two queries with SQL set operators. Each wraps
both queries in parentheses and joins with a hardcoded keyword. The keyword
is a string literal passed to `appendSafe` — no user input can influence it.

    export let unionSql(a: Query, b: Query): SqlFragment {
      let sb = new SqlBuilder();
      sb.appendSafe("(");
      sb.appendFragment(a.toSql());
      sb.appendSafe(") UNION (");
      sb.appendFragment(b.toSql());
      sb.appendSafe(")");
      sb.accumulated
    }

    export let unionAllSql(a: Query, b: Query): SqlFragment {
      let sb = new SqlBuilder();
      sb.appendSafe("(");
      sb.appendFragment(a.toSql());
      sb.appendSafe(") UNION ALL (");
      sb.appendFragment(b.toSql());
      sb.appendSafe(")");
      sb.accumulated
    }

    export let intersectSql(a: Query, b: Query): SqlFragment {
      let sb = new SqlBuilder();
      sb.appendSafe("(");
      sb.appendFragment(a.toSql());
      sb.appendSafe(") INTERSECT (");
      sb.appendFragment(b.toSql());
      sb.appendSafe(")");
      sb.accumulated
    }

    export let exceptSql(a: Query, b: Query): SqlFragment {
      let sb = new SqlBuilder();
      sb.appendSafe("(");
      sb.appendFragment(a.toSql());
      sb.appendSafe(") EXCEPT (");
      sb.appendFragment(b.toSql());
      sb.appendSafe(")");
      sb.accumulated
    }

## Subqueries

Functions for embedding queries as subexpressions. `subquery` wraps a query
with an alias for use in FROM clauses. `existsSql` wraps a query in EXISTS().
`whereInSubquery` is a Query method that generates `WHERE field IN (SELECT ...)`.

    export let subquery(q: Query, alias: SafeIdentifier): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("(");
      b.appendFragment(q.toSql());
      b.appendSafe(") AS ");
      b.appendSafe(alias.sqlValue);
      b.accumulated
    }

    export let existsSql(q: Query): SqlFragment {
      let b = new SqlBuilder();
      b.appendSafe("EXISTS (");
      b.appendFragment(q.toSql());
      b.appendSafe(")");
      b.accumulated
    }

## SetClause

A single SET assignment for UPDATE queries. Both the field name and value
are type-safe: field is a `SafeIdentifier`, value is an `SqlPart`.

    export class SetClause(
      public field: SafeIdentifier,
      public value: SqlPart,
    ) {}

## UpdateQuery

Immutable batch UPDATE builder. Safety: `toSql()` bubbles if no WHERE
conditions are present, preventing accidental full-table updates.

    export class UpdateQuery(
      public tableName: SafeIdentifier,
      public setClauses: List<SetClause>,
      public conditions: List<WhereClause>,
      public limitVal: Int?,
    ) {

      // set: adds a SET assignment
      public set(field: SafeIdentifier, value: SqlPart): UpdateQuery {
        let nb = setClauses.toListBuilder();
        nb.add(new SetClause(field, value));
        new UpdateQuery(tableName, nb.toList(), conditions, limitVal)
      }

      // where: AND condition
      public where(condition: SqlFragment): UpdateQuery {
        let nb = conditions.toListBuilder();
        nb.add(new AndCondition(condition));
        new UpdateQuery(tableName, setClauses, nb.toList(), limitVal)
      }

      // orWhere: OR condition
      public orWhere(condition: SqlFragment): UpdateQuery {
        let nb = conditions.toListBuilder();
        nb.add(new OrCondition(condition));
        new UpdateQuery(tableName, setClauses, nb.toList(), limitVal)
      }

      // limit
      public limit(n: Int): UpdateQuery throws Bubble {
        if (n < 0) { bubble() }
        new UpdateQuery(tableName, setClauses, conditions, n)
      }

      // toSql: bubbles if no WHERE (prevents accidental full-table update)
      public toSql(): SqlFragment throws Bubble {
        if (conditions.isEmpty) { bubble() }
        if (setClauses.isEmpty) { bubble() }
        let b = new SqlBuilder();
        b.appendSafe("UPDATE ");
        b.appendSafe(tableName.sqlValue);
        b.appendSafe(" SET ");
        b.appendSafe(setClauses[0].field.sqlValue);
        b.appendSafe(" = ");
        b.appendPart(setClauses[0].value);
        for (var i = 1; i < setClauses.length; ++i) {
          b.appendSafe(", ");
          b.appendSafe(setClauses[i].field.sqlValue);
          b.appendSafe(" = ");
          b.appendPart(setClauses[i].value);
        }
        renderWhere(b, conditions);
        let lv = limitVal;
        if (lv != null) {
          b.appendSafe(" LIMIT ");
          b.appendInt32(lv);
        }
        b.accumulated
      }

    }

## DeleteQuery

Immutable batch DELETE builder. Safety: `toSql()` bubbles if no WHERE
conditions are present, preventing accidental full-table deletes.

    export class DeleteQuery(
      public tableName: SafeIdentifier,
      public conditions: List<WhereClause>,
      public limitVal: Int?,
    ) {

      // where: AND condition
      public where(condition: SqlFragment): DeleteQuery {
        let nb = conditions.toListBuilder();
        nb.add(new AndCondition(condition));
        new DeleteQuery(tableName, nb.toList(), limitVal)
      }

      // orWhere: OR condition
      public orWhere(condition: SqlFragment): DeleteQuery {
        let nb = conditions.toListBuilder();
        nb.add(new OrCondition(condition));
        new DeleteQuery(tableName, nb.toList(), limitVal)
      }

      // limit
      public limit(n: Int): DeleteQuery throws Bubble {
        if (n < 0) { bubble() }
        new DeleteQuery(tableName, conditions, n)
      }

      // toSql: bubbles if no WHERE (prevents accidental full-table delete)
      public toSql(): SqlFragment throws Bubble {
        if (conditions.isEmpty) { bubble() }
        let b = new SqlBuilder();
        b.appendSafe("DELETE FROM ");
        b.appendSafe(tableName.sqlValue);
        renderWhere(b, conditions);
        let lv = limitVal;
        if (lv != null) {
          b.appendSafe(" LIMIT ");
          b.appendInt32(lv);
        }
        b.accumulated
      }

    }

## update / deleteFrom

Factory functions for UpdateQuery and DeleteQuery.

    export let update(tableName: SafeIdentifier): UpdateQuery {
      new UpdateQuery(tableName, [], [], null)
    }

    export let deleteFrom(tableName: SafeIdentifier): DeleteQuery {
      new DeleteQuery(tableName, [], null)
    }
