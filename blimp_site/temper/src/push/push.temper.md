# Push registration, the decisions

What `POST /api/push/devices` (`Api.PushController.register/2` and
`Push.Device.changeset/2`) and the router's `plug :accepts, ["json"]`
decide about the values a request carries, before Postgres sees anything.
The routes, the casting of JSON values and the SQL are
`src/99_push_devices.blimp`'s. Tags are trimmed, lower-cased and
de-duplicated in Postgres, as the other blinks writes do it
(`blinks_write.temper.md` says why: Temper's `String` has no case mapping).

No classes; every name starts `ps_`.

## A device token

`validate_format(:token, ~r/^[0-9a-fA-F]{16,200}$/)`. The regex has no
`m` flag, and in PCRE `$` without it matches at the very end *or before a
newline that ends the string*. So `"7777777777777777\n"` is a valid token
and is stored with its newline (checked against Phoenix: 200, and the row's
token ends in `\n`); two newlines are not. Ecto casts a blank string to
`nil` before this runs, and `validate_required` refuses that; the regex
refuses `""` and `"   "` anyway.

    export let ps_valid_token(t: String): Boolean {
      ps_hex_run(t, String.begin, 0)
    }

The count stops the walk at 201, so a megabyte of hex is 201 steps.

    let ps_hex_run(t: String, i: StringIndex, n: Int): Boolean {
      if (n > 200) {
        false
      } else if (i >= t.end) {
        n >= 16
      } else {
        let c = t[i];
        if (ps_is_hex(c)) {
          ps_hex_run(t, t.next(i), n + 1)
        } else if (c == 10 && t.next(i) >= t.end) {
          n >= 16
        } else {
          false
        }
      }
    }

    let ps_is_hex(c: Int): Boolean {
      (c >= 48 && c <= 57) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102)
    }

## The APNs environment

`params["env"] || "prod"`, then `cast/3` and
`validate_inclusion(:env, ["dev", "prod"])`. The caller hands this the
string that is left after casting, `""` for nil, false or a blank string:
Ecto 3.12 casts an empty value to the field's *default*, so `"env": ""`
and `"env": "  "` register a `prod` device (Phoenix answers 200 to both),
not a NOT NULL violation. Anything else must be `dev` or `prod` exactly;
`"DEV"` is a 422. The answer is the env to store, or `""` for a 422.
A value that is not a string at all never gets here: it is a 422 at the cast.

    export let ps_env(env: String): String {
      if (env == "") {
        "prod"
      } else if (env == "dev" || env == "prod") {
        env
      } else {
        ""
      }
    }

## Accept

`plug :accepts, ["json"]` runs before the controller and answers 406 to a
client that says it cannot take JSON. Phoenix takes the *first* Accept
header, splits it on commas, and parses each entry with
`Plug.Conn.Utils.media_type/1`; an entry that does not parse is skipped.
Any entry that names JSON wins, whatever its q (q only orders the
entries, and `Enum.find_value` walks all of them): `*/*`, `application/*`
or `application/json`. An Accept header that is present and empty has no
entries, and is a 406 (the caller treats a missing header as `*/*`).

    export let ps_accepts_json(h: String): Boolean {
      ps_entries(h, String.begin)
    }

    let ps_entries(h: String, i: StringIndex): Boolean {
      if (i >= h.end) {
        false
      } else {
        let e = ps_comma(h, i);
        if (ps_entry_json(h.slice(i, e))) {
          true
        } else if (e >= h.end) {
          false
        } else {
          ps_entries(h, h.next(e))
        }
      }
    }

    let ps_comma(h: String, i: StringIndex): StringIndex {
      if (i >= h.end || h[i] == 44) { i } else { ps_comma(h, h.next(i)) }
    }

One entry, as `media_type/1` reads it: spaces and tabs (and CRLF) off the
front, then either `*/*`, or a type of letters, digits and `-`, a `/`, and
a subtype that is `*` or letters, digits and `.+-_`, both compared without
case. Whatever follows must be blank or start a `;` parameter list, or the
entry does not parse.

    let ps_entry_json(s: String): Boolean {
      let i = ps_spaces(s, String.begin);
      if (ps_at(s, i, 42) && ps_at(s, ps_step(s, i), 47) && ps_at(s, ps_step(s, ps_step(s, i)), 42)) {
        ps_rest_ok(s, ps_step(s, ps_step(s, ps_step(s, i))))
      } else {
        let t = ps_run(s, i, true);
        if (t == i || !ps_at(s, t, 47)) {
          false
        } else {
          let j = s.next(t);
          if (ps_at(s, j, 42)) {
            ps_ieq(s.slice(i, t), "application") && ps_rest_ok(s, s.next(j))
          } else {
            let u = ps_run(s, j, false);
            ps_ieq(s.slice(i, t), "application") && ps_ieq(s.slice(j, u), "json") && ps_rest_ok(s, u)
          }
        }
      }
    }

    let ps_at(s: String, i: StringIndex, c: Int): Boolean {
      i < s.end && s[i] == c
    }

    let ps_step(s: String, i: StringIndex): StringIndex {
      if (i < s.end) { s.next(i) } else { i }
    }

    let ps_spaces(s: String, i: StringIndex): StringIndex {
      if (ps_at(s, i, 32) || ps_at(s, i, 9)) {
        ps_spaces(s, s.next(i))
      } else if (ps_at(s, i, 13) && ps_at(s, s.next(i), 10)) {
        ps_spaces(s, s.next(s.next(i)))
      } else {
        i
      }
    }

    let ps_rest_ok(s: String, i: StringIndex): Boolean {
      let j = ps_spaces(s, i);
      j >= s.end || s[j] == 59
    }

A run of type characters (`first`) or subtype characters.

    let ps_run(s: String, i: StringIndex, first: Boolean): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        let alnum = (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57) || c == 45;
        let other = c == 46 || c == 43 || c == 95;
        if (alnum || (!first && other)) { ps_run(s, s.next(i), first) } else { i }
      }
    }

ASCII case folding, which is all `media_type/1` does.

    let ps_ieq(a: String, b: String): Boolean {
      ps_ieq_from(a, String.begin, b, String.begin)
    }

    let ps_ieq_from(a: String, i: StringIndex, b: String, j: StringIndex): Boolean {
      if (i >= a.end || j >= b.end) {
        i >= a.end && j >= b.end
      } else if (ps_fold(a[i]) == ps_fold(b[j])) {
        ps_ieq_from(a, a.next(i), b, b.next(j))
      } else {
        false
      }
    }

    let ps_fold(c: Int): Int {
      if (c >= 65 && c <= 90) { c + 32 } else { c }
    }
