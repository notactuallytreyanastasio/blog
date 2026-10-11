# frozen_string_literal: true

# Ruby's Regexp (Onigmo) against the regex dialect std/regex formats,
# which is JavaScript's with the u flag.

def show(label, &blk)
  value = begin
    blk.call.inspect
  rescue StandardError, SyntaxError => e
    "#{e.class}: #{e.message.lines.first.chomp}"
  end
  puts format("%-52s %s", label, value)
end

show("/^b/ =~ \"a\\nb\" (JS: no match)") { "a\nb" =~ /^b/ }
show("/a$/ =~ \"a\\nb\" (JS: no match)") { "a\nb" =~ /a$/ }
show("/a$/ =~ \"a\\n\" (JS: no match)") { "a\n" =~ /a$/ }
show("/\\Ab/ =~ \"a\\nb\"") { "a\nb" =~ /\Ab/ }
show("/a\\z/ =~ \"a\\n\"") { "a\n" =~ /a\z/ }
show("/./ =~ \"\\r\" (JS u: no match)") { "\r" =~ /./ }
show("/./ =~ \"\\u2028\" (JS u: no match)") { "\u2028" =~ /./ }
show("/\\s/ =~ \"\\u00a0\" (JS: 0)") { "\u00a0" =~ /\s/ }
show("/\\s/ =~ \"\\ufeff\" (JS: 0)") { "\ufeff" =~ /\s/ }
show("/[[:space:]]/ =~ \"\\u00a0\"") { "\u00a0" =~ /[[:space:]]/ }
show("/\\w/ =~ \"é\" (JS u: no match)") { "é" =~ /\w/ }
show("/\\d/ =~ \"٣\" (JS u: no match)") { "٣" =~ /\d/ }
show("/\\bx/ =~ \"éx\" (JS u: 1)") { "éx" =~ /\bx/ }
show("Regexp.new(\"\\\\u{1F30D}\") =~ \"a🌍\"") { "a🌍" =~ Regexp.new("\\u{1F30D}") }
show("Regexp.new(\"\\\\u{d800}\")") { Regexp.new("\\u{d800}") }
show("Regexp.new(\"\\\\&\") =~ \"a&\"") { "a&" =~ Regexp.new("\\&") }
show("Regexp.new(\"\\\\~\") =~ \"a~\"") { "a~" =~ Regexp.new("\\~") }
show("(?<a>x)(y) groups with a name") { /(?<a>x)(y)/.match("xy").captures }
show("named group unmatched") { /(?<a>x)|(?<b>y)/.match("y")[:a] }
show("names in pattern order") { /(?<z>x)(?<a>y)/.names }
show("match(\"é🌍x\", 2): pos is characters") { /x/.match("é🌍x", 2)&.begin(0) }
show("byteindex(/x/, 6) on \"é🌍x\"") { "é🌍x".byteindex(/x/, 6) }
show("byteoffset(0) after byteindex") { "é🌍x".byteindex(/x/, 0); $~&.byteoffset(0) }
show("\"a,b\".split(/(,)/) keeps captures") { "a,b".split(/(,)/) }
show("\"a,b,\".split(/,/) drops trailing") { "a,b,".split(/,/) }
show("\"a,b,\".split(/,/, -1)") { "a,b,".split(/,/, -1) }
show("\"abc\".split(//, -1) (JS: [a, b, c])") { "abc".split(//, -1) }
show("\"\".split(/,/, -1) (JS: [\"\"])") { "".split(/,/, -1) }
show("gsub(//) {} zero-width") { "ab".gsub(//) { "-" } }
