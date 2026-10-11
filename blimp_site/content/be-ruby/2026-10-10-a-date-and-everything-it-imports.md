# 2026-10-10: a date, and everything it imports

Fifty-two of sixty-seven. That is one more test, `TypesDate`, and you
would think a chapter that adds one test about dates would be about dates.
It is partly about dates. Mostly it is about what one line of the test
costs:

```temper
let {Date} = import("std/temporal");
```

Temper's standard library compiles as a single library. Import one name
from `std/temporal`, and the backend has to translate all of `std`:
temporal, but also JSON, networking, regular expressions and the test
framework. The Ruby comes out as one module, `Temper::Std`, 2,361 lines,
and before this chapter the backend could not get through the first
`Promise` in it. So to get a date, I had to do networking and regular
expressions too. The generated `std` passes Steep in strict mode, which
the harness does not check (it checks the test's own library), so I
checked it by hand.

## Ruby's Date is Julian, sometimes

Temper's `Date` is "a {year, month, day} triple representing a day in the
proleptic Gregorian calendar". Ruby has a `Date` class in its standard
library, which is good news, and by default it switches to the Julian
calendar before 15 October 1582, which is the date Italy switched. This is
historically faithful and completely wrong for us:

```
Date.new(12, 11, 10).cwday                           4
Date.new(12, 11, 10, Date::GREGORIAN).cwday          6
Date.new(1500, 2, 29) (Julian leap day)              "1500-02-29"
Date.new(1500, 2, 29, Date::GREGORIAN)               Date::Error: invalid date
Date.new(1582, 10, 10) (in the gap)                  Date::Error: invalid date
```

(`probes/33_dates.rb`.) The functional test checks the weekdays of 1 January
and 1 March in 1700, 1800, 1900, 2000, 2100 and 2400, all after 1582, so a
backend using Ruby's defaults would pass it while giving the wrong weekday
for every date in the first millennium and a half. temper-core makes every
Date with `Date::GREGORIAN`.

Ruby also counts a negative day or month from the end, the way it does
array indices, so `Date.new(2023, 6, -1)` is 30 June. Temper bubbles.
And `Date.iso8601` takes `"15960331"`, the ordinal `"1596-091"`, and
`"96-03-31"`:

```
Date.iso8601("96-03-31")                             "1996-03-31"
```

The functional test has a paragraph warning about exactly this: "when a
year field expects a two-digit year, so you need to adjust by 1900". So
`fromIsoString` is written out in temper-core to the letter of std's own
Temper source: at least four characters, a dash, two, a dash, two, each
part parsed the way `toInt32` parses it. Ruby's `Date#to_s`, on the other
hand, pads exactly as std's Temper does, including `0012`, `12345` and
`-0005`, so `toString` is just `to_s`.

## Three runtimes and a calendar

Then the usual fresh program, about forty lines of calendar edges, on
JavaScript, Python and Ruby, and this time also on Temper's interpreter,
which runs std/temporal's Temper source as written
(`probes/35_fresh_dates/`). JavaScript:

```
new Date(1900, 2, 29): [1900-03-01 weekday 4]
new Date(2023, 6, -1): [2023-05-30 weekday 2]
new Date(2023, 4, 31): [2023-05-01 weekday 1]
new Date(12345, 1, 2): [+012345-01-02 weekday 2]
fromIsoString 96-03-31: [1996-03-31]
fromIsoString ١٥٩٦-03-31: [2001-03-31]
```

There is no 29 February 1900 and no 31 April, and Temper's constructor
bubbles for both. JavaScript's runtime builds the date on a JavaScript
`Date` with `setUTCFullYear`, `setUTCMonth` and `setUTCDate` and never
checks, and `setUTCDate(31)` in a 30-day month rolls into the next one. The
two-digit year the test warns about comes out as 1996. And four
Arabic-Indic digits, which is 1596 to a reader of Arabic, come out as 2001,
which I cannot explain and do not intend to try.

Python bubbles on nearly all of those, correctly, but refuses year 12345
(its `datetime` stops at 9999) and accepts `"15960331"`. Ruby agrees with
the interpreter on twenty-six lines of twenty-seven. The one exception is
those Arabic-Indic digits, which the interpreter's `toInt32` accepts, as
Python's does, and JavaScript's and Ruby's do not. That is entry 9's
question again, where I sided Ruby with JavaScript as the reference
backend. The interpreter is a different kind of reference, and I have not
changed anything yet. I would like a ruling.

## Networking, without async

`std/net` declares a connected `sendRequest` that answers a
`Promise<NetResponse>`. Ruby's `Net::HTTP` blocks, so temper-core makes
the request on a thread of its own. Promises, and anything waiting on one,
should only ever be touched on one thread, so the request's thread does
not settle the promise. It hands the result back through a queue, and the
main thread runs what comes back:

```ruby
def self.in_background(work, finish)
  @outstanding += 1
  Thread.new do
    result = work.()
    @handed_back.push(-> { finish.(result) })
  end
  nil
end
```

The main thread drains the queue at exit until nothing is outstanding.
That is the skeleton of an event loop. Temper's `async` and `await` are
not translated yet, so nothing can wait on that promise from Temper code,
and `TypesNetresponse` still fails. But `std/net` translates, and
temper-core's test makes a real request to a local server and gets
`{"got":[]}` back, and a request to a port where nothing listens breaks its
promise, as std/net says it should.

## Regular expressions in someone else's dialect

std/regex builds a pattern string in JavaScript's dialect, with the `u`
flag, and hands it to the backend to compile. Ruby's regular expressions
look the same and are not:

```
/^b/ =~ "a\nb" (JS: no match)                        2
/a$/ =~ "a\n" (JS: no match)                         0
/./ =~ "\r" (JS u: no match)                         0
/\s/ =~ " " (JS: 0)                             nil
/\bx/ =~ "éx" (JS u: 1)                              nil
"".split(/,/, -1) (JS: [""])                         []
"abc".split(//, -1) (JS: [a, b, c])                  ["a", "b", "c", ""]
```

(`probes/34_regex.rb`.) In Ruby `^` and `$` match at every line break,
which is the kind of difference that lets a validation regex pass
`"ok\n<script>"`. `.` matches a carriage return, `\s` misses the
no-break space, and `\b` thinks `é` is a letter while `\w` does not. So
temper-core rewrites the formatted pattern token by token before Ruby
sees it: `^` is `\A`, `$` is `\z`, `.` is `[^\n\r  ]`, `\s` is
JavaScript's list of spaces, and `\b` is a pair of lookarounds over ASCII
word characters. `split` is JavaScript's algorithm, written out, captures
and trailing empty strings included. Searching from a StringIndex is
`String#byteindex`, since `Regexp#match(text, pos)` counts characters and a
StringIndex is a byte offset.

The regex tests still fail, one step later than before. A pattern literal
in the test's own library refers to names from `std/regex`, and references
across libraries are the next thing to build.

## The guard, refined

Entry 8 made every unmapped connected member stop the build, because the
fallback (call the method by name) had turned Temper's `split` into Ruby's.
That fallback is wrong for a type Ruby represents natively. For a class
that is itself translated from Temper, like std/regex's `RegexFormatter`,
the fallback calls the translated Temper method, which is exactly right.
So there is now a short list of connected members whose Temper body Ruby
uses, each with a comment saying why: the regex formatter's
`regexFormat`, `pushCaptureName` and `adjustCodeSet`, and std/testing's
`Test` methods and test-runner functions. Everything else unmapped still
stops the build.

## Where it stands

Fifty-two of sixty-seven, all typed. temper-core is up to 62 minitest
runs.

**Not done**, fifteen tests: names the translator cannot resolve, mostly
in other libraries (the regex pair, `TypesJsonSyntaxTree`, `ImportsValues`,
`ImportsFunctions` and `FunctionsLocals`), `async` and generators (four), RBS for `Empty` and
`Type` (two), `@test` blocks, a connected function from another library,
and `SemanticsBroken`. The Arabic-Indic digit question is open.
