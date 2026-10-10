# Every rendering RubyGrammarTest pins, evaluated with real bindings and
# compared with the value the tree means. Run: ruby 04_grammar_samples.rb
$failures = 0
def check(src, expected)
  got = eval(src, $scope)
  ok = expected.is_a?(Float) && expected.nan? ? got.nan? : got == expected
  ok &&= (expected.is_a?(Float) ? 1.0 / got == 1.0 / expected || got.nan? : true) if expected == 0.0
  $failures += 1 unless ok
  puts "#{ok ? "ok  " : "FAIL"} #{src.ljust(36)} #{got.inspect}"
rescue SyntaxError, StandardError => e
  if expected == e.class
    puts "ok   #{src.ljust(36)} raises #{e.class}"
    return
  end
  $failures += 1
  puts "FAIL #{src.ljust(36)} #{e.class}: #{e.message.lines.first}"
end

x = 3; a = true; b = false; c = true; n = 10; i = 4; xs = [10, 20, 30]
f = ->(v) { v * 2 }
module Temper; module Core; def self.int32(v) = [v].pack("l").unpack1("l"); end; end
Point = Data.define(:x, :y)
$scope = binding

check '(-2) ** 2', 4
check '(-2.5) ** 2', 6.25
check '2 ** (-1)', Rational(1, 2)          # an Integer to a negative power is a Rational
check '-x ** 2', -9
check '(-x) ** 2', 9
check '-(-x)', 3
check '2 ** 3 ** 2', 512
check '(2 ** 3) ** 2', 64
check '6 & 3 == 2', true
check '6 & (3 == 2)', TypeError           # it parsed as written: Integer & false
check '1 | 2 & 3', 3
check '(1 | 2) & 3', 3
check '1 < 2 == true', true
check '!(a == b)', true
check 'n - (i - x)', 9
check 'n - i - x', 3
check '!a && b || c', true
check 'a && (b || c)', true
check '(-2).abs()', 2
check '(x + n).to_s()', "13"
check 'Temper::Core.int32(2147483647 + 1)', -2147483648
check 'xs[i - 3]', 20
check 'Point.new(x: 1, y: 2)', Point.new(1, 2)
check 'xs.map(&f)', [20, 40, 60]
check 'a ? 1 : b ? 2 : 3', 1
check 'b ? 1 : a ? 2 : 3', 2
check '(a ? b : c) ? 1 : 2', 2
check '"a\#{b}\#@c\#$d \#e"', 'a#{b}#@c#$d #e'
check '"q\"\\\\\n\t\u{0}\u{7f}"', "q\"\\\n\t\u0000\u007f"
check '1.0E10', 10_000_000_000.0
check '-0.0', -0.0
check 'Float::NAN', Float::NAN
check '(-Float::INFINITY).abs()', Float::INFINITY
check ':"with space"', "with space".to_sym
check ':empty?', :empty?
check '[1, [], { "a" => 1, :b => nil }, {}]', [1, [], { "a" => 1, b: nil }, {}]
check <<~RUBY, 3
  add = ->(a, b) do
    return a + b
  end
  add.(1, 2)
RUBY
check <<~RUBY, [0, 1, 3, 4, 5]
  out = []
  i = 0
  while i < 10
    if i == 2
      i += 1
      next
    elsif i > 5
      break
    else
      out << i
      i += 1
    end
  end
  out
RUBY
check <<~RUBY, %w[bubbled done]
  log = []
  module Temper::Core; class Bubble < StandardError; end; end
  begin
    raise Temper::Core::Bubble
  rescue Temper::Core::Bubble => e
    log << "bubbled"
  ensure
    log << "done"
  end
  log
RUBY
puts "#{$failures} failures"
exit($failures.zero? ? 0 : 1)
