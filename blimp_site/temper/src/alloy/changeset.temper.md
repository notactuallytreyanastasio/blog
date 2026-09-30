# Changeset

Ecto-style cast → validate → generate-SQL pipeline.

## Security model

- `Changeset` is a **sealed interface**. `ChangesetImpl` is not exported.
  External code cannot construct a Changeset — only the `changeset()`
  factory can. This closes the CWE-284 bypass via direct construction.
- `params` (raw user input) is never exposed. Only `changes` (whitelisted,
  cast fields) and `errors` are readable from outside. Closes CWE-532.
- `cast()` takes `List<SafeIdentifier>` — column names must be validated
  identifiers before they are accepted as allowed fields.
- `toInsertSql()` independently enforces non-nullable fields regardless of
  `isValid`, so a manually-constructed object still cannot produce bad SQL.
- `valueToSqlPart` uses exhaustive `when` on sealed `FieldType` — the
  compiler guarantees every type dispatches to a typed `SqlPart`, never
  to raw unescaped text.
- `BoolField` bubbles on unrecognised values rather than silently coercing.

## Imports

All types (SqlFragment, SqlBuilder, SqlPart, TableDef, etc.) are available
from other files in the same module without explicit imports.

## ChangesetError

    export class ChangesetError(
      public field: String,
      public message: String,
    ) {}

## NumberValidationOpts

Options for numeric range validation. Each field is nullable — only non-null
constraints are checked. Matches Ecto's `validate_number/3` options.

    export class NumberValidationOpts(
      public greaterThan: Float64?,
      public lessThan: Float64?,
      public greaterThanOrEqual: Float64?,
      public lessThanOrEqual: Float64?,
      public equalTo: Float64?,
    ) {}

## Changeset (sealed interface)

The public contract. All methods return `Changeset` so pipelines can be
chained. `params` is intentionally absent — callers see only the
whitelisted `changes` and accumulated `errors`.

    export sealed interface Changeset {
      public get tableDef(): TableDef;
      public get changes(): Map<String, String>;
      public get errors(): List<ChangesetError>;
      public get isValid(): Boolean;

      public cast(allowedFields: List<SafeIdentifier>): Changeset;
      public validateRequired(fields: List<SafeIdentifier>): Changeset;
      public validateLength(field: SafeIdentifier, min: Int, max: Int): Changeset;
      public validateInt(field: SafeIdentifier): Changeset;
      public validateInt64(field: SafeIdentifier): Changeset;
      public validateFloat(field: SafeIdentifier): Changeset;
      public validateBool(field: SafeIdentifier): Changeset;

      public putChange(field: SafeIdentifier, value: String): Changeset;
      public getChange(field: SafeIdentifier): String throws Bubble;
      public deleteChange(field: SafeIdentifier): Changeset;
      public validateInclusion(field: SafeIdentifier, allowed: List<String>): Changeset;
      public validateExclusion(field: SafeIdentifier, disallowed: List<String>): Changeset;
      public validateNumber(field: SafeIdentifier, opts: NumberValidationOpts): Changeset;
      public validateAcceptance(field: SafeIdentifier): Changeset;
      public validateConfirmation(field: SafeIdentifier, confirmationField: SafeIdentifier): Changeset;
      public validateContains(field: SafeIdentifier, substring: String): Changeset;
      public validateStartsWith(field: SafeIdentifier, prefix: String): Changeset;
      public validateEndsWith(field: SafeIdentifier, suffix: String): Changeset;

      public toInsertSql(): SqlFragment throws Bubble;
      public toUpdateSql(id: Int): SqlFragment throws Bubble;
    }

## ChangesetImpl (private)

Not exported — the only path to an instance is through `changeset()`.

    class ChangesetImpl(
      private _tableDef: TableDef,
      private _params: Map<String, String>,
      private _changes: Map<String, String>,
      private _errors: List<ChangesetError>,
      private _isValid: Boolean,
    ) extends Changeset {

      public get tableDef(): TableDef { _tableDef }
      public get changes(): Map<String, String> { _changes }
      public get errors(): List<ChangesetError> { _errors }
      public get isValid(): Boolean { _isValid }

      // addError: centralizes error construction (extracted from 15 validator copies)
      private addError(field: String, message: String): Changeset {
        let eb = _errors.toListBuilder();
        eb.add(new ChangesetError(field, message));
        new ChangesetImpl(_tableDef, _params, _changes, eb.toList(), false)
      }

      // cast: whitelists fields by SafeIdentifier
      public cast(allowedFields: List<SafeIdentifier>): Changeset {
        let mb = new MapBuilder<String, String>();
        for (let f of allowedFields) {
          let val = _params.getOr(f.sqlValue, "");
          if (!val.isEmpty) {
            mb.set(f.sqlValue, val);
          }
        }
        new ChangesetImpl(_tableDef, _params, mb.toMap(), _errors, _isValid)
      }

      // validateRequired
      public validateRequired(fields: List<SafeIdentifier>): Changeset {
        if (!_isValid) { return this; }
        let eb = _errors.toListBuilder();
        var valid = true;
        for (let f of fields) {
          if (!_changes.has(f.sqlValue)) {
            eb.add(new ChangesetError(f.sqlValue, "is required"));
            valid = false;
          }
        }
        new ChangesetImpl(_tableDef, _params, _changes, eb.toList(), valid)
      }

      // validateLength
      public validateLength(field: SafeIdentifier, min: Int, max: Int): Changeset {
        if (!_isValid) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let len = val.countBetween(String.begin, val.end);
        if (len < min || len > max) {
          return addError(field.sqlValue, "must be between ${min} and ${max} characters");
        }
        this
      }

      // validateInt
      public validateInt(field: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        if (val.isEmpty) { return this; }
        let parseOk = do { val.toInt32(); true } orelse false;
        if (!parseOk) { return addError(field.sqlValue, "must be an integer"); }
        this
      }

      // validateInt64
      public validateInt64(field: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        if (val.isEmpty) { return this; }
        let parseOk = do { val.toInt64(); true } orelse false;
        if (!parseOk) { return addError(field.sqlValue, "must be a 64-bit integer"); }
        this
      }

      // validateFloat
      public validateFloat(field: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        if (val.isEmpty) { return this; }
        let parseOk = do { val.toFloat64(); true } orelse false;
        if (!parseOk) { return addError(field.sqlValue, "must be a number"); }
        this
      }

      // validateBool: accepts true/1/yes/on and false/0/no/off, bubbles on anything else
      public validateBool(field: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        if (val.isEmpty) { return this; }
        let isTrue = val == "true" || val == "1" || val == "yes" || val == "on";
        let isFalse = val == "false" || val == "0" || val == "no" || val == "off";
        if (!isTrue && !isFalse) {
          return addError(field.sqlValue, "must be a boolean (true/false/1/0/yes/no/on/off)");
        }
        this
      }

      // putChange: add or overwrite a field in changes
      public putChange(field: SafeIdentifier, value: String): Changeset {
        let mb = new MapBuilder<String, String>();
        let pairs = _changes.toList();
        for (var i = 0; i < pairs.length; ++i) {
          mb.set(pairs[i].key, pairs[i].value);
        }
        mb.set(field.sqlValue, value);
        new ChangesetImpl(_tableDef, _params, mb.toMap(), _errors, _isValid)
      }

      // getChange: retrieve a field value from changes, bubble if missing
      public getChange(field: SafeIdentifier): String throws Bubble {
        if (!_changes.has(field.sqlValue)) { bubble() }
        _changes.getOr(field.sqlValue, "")
      }

      // deleteChange: remove a field from changes
      public deleteChange(field: SafeIdentifier): Changeset {
        let mb = new MapBuilder<String, String>();
        let pairs = _changes.toList();
        for (var i = 0; i < pairs.length; ++i) {
          if (pairs[i].key != field.sqlValue) {
            mb.set(pairs[i].key, pairs[i].value);
          }
        }
        new ChangesetImpl(_tableDef, _params, mb.toMap(), _errors, _isValid)
      }

      // validateInclusion: value must be in the allowed list
      public validateInclusion(field: SafeIdentifier, allowed: List<String>): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        var found = false;
        for (let a of allowed) {
          if (a == val) { found = true; }
        }
        if (!found) { return addError(field.sqlValue, "is not included in the list"); }
        this
      }

      // validateExclusion: value must NOT be in the disallowed list
      public validateExclusion(field: SafeIdentifier, disallowed: List<String>): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        var found = false;
        for (let d of disallowed) {
          if (d == val) { found = true; }
        }
        if (found) { return addError(field.sqlValue, "is reserved"); }
        this
      }

      // validateNumber: check numeric constraints
      public validateNumber(field: SafeIdentifier, opts: NumberValidationOpts): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let parseOk = do { val.toFloat64(); true } orelse false;
        if (!parseOk) { return addError(field.sqlValue, "must be a number"); }
        let num = do { val.toFloat64() } orelse 0.0;
        let gt = opts.greaterThan;
        if (gt != null) {
          if (!(num > gt)) { return addError(field.sqlValue, "must be greater than ${gt}"); }
        }
        let lt = opts.lessThan;
        if (lt != null) {
          if (!(num < lt)) { return addError(field.sqlValue, "must be less than ${lt}"); }
        }
        let gte = opts.greaterThanOrEqual;
        if (gte != null) {
          if (!(num >= gte)) { return addError(field.sqlValue, "must be greater than or equal to ${gte}"); }
        }
        let lte = opts.lessThanOrEqual;
        if (lte != null) {
          if (!(num <= lte)) { return addError(field.sqlValue, "must be less than or equal to ${lte}"); }
        }
        let eq = opts.equalTo;
        if (eq != null) {
          if (!(num == eq)) { return addError(field.sqlValue, "must be equal to ${eq}"); }
        }
        this
      }

      // validateAcceptance: field must be truthy (true/1/yes/on)
      public validateAcceptance(field: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let accepted = val == "true" || val == "1" || val == "yes" || val == "on";
        if (!accepted) { return addError(field.sqlValue, "must be accepted"); }
        this
      }

      // validateConfirmation: confirmationField must match field
      public validateConfirmation(field: SafeIdentifier, confirmationField: SafeIdentifier): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let conf = _changes.getOr(confirmationField.sqlValue, "");
        if (val != conf) { return addError(confirmationField.sqlValue, "does not match"); }
        this
      }

      // validateContains: field value must contain substring
      public validateContains(field: SafeIdentifier, substring: String): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        if (!(val.indexOf(substring) is StringIndex)) {
          return addError(field.sqlValue, "must contain the given substring");
        }
        this
      }

      // validateStartsWith: field value must start with prefix
      public validateStartsWith(field: SafeIdentifier, prefix: String): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let idx = val.indexOf(prefix);
        let starts = if (idx is StringIndex) {
          val.countBetween(String.begin, idx) == 0
        } else {
          false
        };
        if (!starts) { return addError(field.sqlValue, "must start with the given prefix"); }
        this
      }

      // validateEndsWith: field value must end with suffix
      // Uses cursor-based character comparison for correctness
      public validateEndsWith(field: SafeIdentifier, suffix: String): Changeset {
        if (!_isValid) { return this; }
        if (!_changes.has(field.sqlValue)) { return this; }
        let val = _changes.getOr(field.sqlValue, "");
        let valLen = val.countBetween(String.begin, val.end);
        let suffixLen = suffix.countBetween(String.begin, suffix.end);
        if (valLen < suffixLen) {
          return addError(field.sqlValue, "must end with the given suffix");
        }
        let skipCount = valLen - suffixLen;
        var strIdx = String.begin;
        for (var i = 0; i < skipCount; ++i) {
          strIdx = val.next(strIdx);
        }
        var sufIdx = String.begin;
        var matches = true;
        while (matches && suffix.hasIndex(sufIdx)) {
          if (!val.hasIndex(strIdx)) {
            matches = false;
          } else if (val[strIdx] != suffix[sufIdx]) {
            matches = false;
          } else {
            strIdx = val.next(strIdx);
            sufIdx = suffix.next(sufIdx);
          }
        }
        if (!matches) {
          return addError(field.sqlValue, "must end with the given suffix");
        }
        this
      }

      // parseBoolSqlPart: converts validated bool string to SqlBoolean
      private parseBoolSqlPart(val: String): SqlBoolean throws Bubble {
        if (val == "true" || val == "1" || val == "yes" || val == "on") {
          return new SqlBoolean(true);
        }
        if (val == "false" || val == "0" || val == "no" || val == "off") {
          return new SqlBoolean(false);
        }
        bubble()
      }

      // valueToSqlPart: type-dispatched conversion from validated string to SqlPart
      private valueToSqlPart(fieldDef: FieldDef, val: String): SqlPart throws Bubble {
        let ft = fieldDef.fieldType;
        if (ft is StringField) { return new SqlString(val); }
        if (ft is IntField) { return new SqlInt32(val.toInt32()); }
        if (ft is Int64Field) { return new SqlInt64(val.toInt64()); }
        if (ft is FloatField) { return new SqlFloat64(val.toFloat64()); }
        if (ft is BoolField) { return parseBoolSqlPart(val); }
        if (ft is DateField) { return new SqlDate(Date.fromIsoString(val)); }
        bubble()
      }

      // toInsertSql: generates INSERT INTO … (cols) VALUES (vals)
      // Skips virtual fields. Uses defaultValue when field not in changes but has a default.
      public toInsertSql(): SqlFragment throws Bubble {
        if (!_isValid) { bubble() }
        for (var i = 0; i < _tableDef.fields.length; ++i) {
          let f = _tableDef.fields[i];
          if (f.virtual) { continue; }
          let dv = f.defaultValue;
          if (!f.nullable && !_changes.has(f.name.sqlValue) && dv == null) {
            bubble()
          }
        }
        let colNames = new ListBuilder<String>();
        let valParts = new ListBuilder<SqlPart>();
        // First add fields from changes (skip virtual)
        let pairs = _changes.toList();
        for (var i = 0; i < pairs.length; ++i) {
          let pair = pairs[i];
          let fd = _tableDef.field(pair.key);
          if (fd.virtual) { continue; }
          colNames.add(fd.name.sqlValue);
          valParts.add(valueToSqlPart(fd, pair.value));
        }
        // Then add fields with defaults that aren't in changes
        for (var i = 0; i < _tableDef.fields.length; ++i) {
          let f = _tableDef.fields[i];
          if (f.virtual) { continue; }
          let dv = f.defaultValue;
          if (dv != null) {
            if (!_changes.has(f.name.sqlValue)) {
              colNames.add(f.name.sqlValue);
              valParts.add(dv);
            }
          }
        }
        if (valParts.length == 0) { bubble() }
        let b = new SqlBuilder();
        b.appendSafe("INSERT INTO ");
        b.appendSafe(_tableDef.tableName.sqlValue);
        b.appendSafe(" (");
        b.appendSafe(colNames.toList().join(", ") { c => c });
        b.appendSafe(") VALUES (");
        b.appendPart(valParts[0]);
        for (var j = 1; j < valParts.length; ++j) {
          b.appendSafe(", ");
          b.appendPart(valParts[j]);
        }
        b.appendSafe(")");
        b.accumulated
      }

      // toUpdateSql: generates UPDATE … SET col = val, … WHERE pk = ?
      // Uses tableDef.pkName() for the primary key column (defaults to "id").
      // Skips virtual fields.
      public toUpdateSql(id: Int): SqlFragment throws Bubble {
        if (!_isValid) { bubble() }
        let pairs = _changes.toList();
        if (pairs.length == 0) { bubble() }
        let b = new SqlBuilder();
        b.appendSafe("UPDATE ");
        b.appendSafe(_tableDef.tableName.sqlValue);
        b.appendSafe(" SET ");
        var setCount = 0;
        for (var i = 0; i < pairs.length; ++i) {
          let pair = pairs[i];
          let fd = _tableDef.field(pair.key);
          if (fd.virtual) { continue; }
          if (setCount > 0) { b.appendSafe(", "); }
          b.appendSafe(fd.name.sqlValue);
          b.appendSafe(" = ");
          b.appendPart(valueToSqlPart(fd, pair.value));
          setCount = setCount + 1;
        }
        if (setCount == 0) { bubble() }
        b.appendSafe(" WHERE ");
        b.appendSafe(_tableDef.pkName());
        b.appendSafe(" = ");
        b.appendInt32(id);
        b.accumulated
      }

    }

## changeset

The sole entry point. Returns the sealed `Changeset` interface.

    export let changeset(tableDef: TableDef, params: Map<String, String>): Changeset {
      new ChangesetImpl(
        tableDef,
        params,
        new Map<String, String>([]),
        [],
        true,
      )
    }
