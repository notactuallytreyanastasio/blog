# frozen_string_literal: true

# Ruby's Hash against Temper's Map and MapBuilder.

def show(label, &blk)
  value = begin
    blk.call.inspect
  rescue StandardError => e
    "#{e.class}: #{e.message}"
  end
  puts format("%-46s %s", label, value)
end

h = { "key" => 1, "other" => 2 }
show("overwrite keeps position") { g = h.dup; g["key"] = 9; g.keys }
show("delete then add goes to end") { g = h.dup; g.delete("key"); g["key"] = 9; g.keys }
show("to_h, duplicate key: first position, last value") { [[1, :a], [2, :b], [1, :c]].to_h }
show("frozen hash []=") { h.freeze; h.dup.freeze["x"] = 1 }
show("dup of frozen is thawed") { h.freeze.dup.frozen? }
show("{a: nil}[:a] vs missing") { [{ a: nil }[:a], {}[:a]] }
show("fetch missing") { {}.fetch(:a) }
show("fetch with fallback, value nil") { { a: nil }.fetch(:a, 1) }
show("delete missing") { {}.delete(:a) }
show("delete key whose value is nil") { { a: nil }.delete(:a) }

two = ->(k, v) { "#{k}=#{v}" }
show("each(&lambda with 2 params)") { r = []; { a: 1 }.each { |k, v| r << two.(k, v) }; r }
show("each(&two) directly") { { a: 1 }.each(&two) }
show("map(&two)") { { a: 1 }.map(&two) }
show("each_pair(&two)") { { a: 1 }.each_pair(&two) }

show("add a key during each") { g = { a: 1 }; g.each { |k, _| g[:"#{k}2"] = 2 }; g }
show("change a value during each") { g = { a: 1, b: 2 }; g.each { |k, _| g[k] = 0 }; g }
show("delete during each") { g = { a: 1, b: 2 }; g.each { |k, _| g.delete(:b) }; g }
show("clear during each") { g = { a: 1, b: 2 }; n = 0; g.each { n += 1; g.clear }; [g, n] }

s = +"ab"
show("unfrozen String key is copied and frozen") { g = {}; g[s] = 1; s << "c"; [g.keys, g.keys[0].frozen?] }
show("1 and 1.0 are different keys") { { 1 => :int, 1.0 => :float }.size }
show("utf-8 vs binary, ascii") { { "a" => 1 }.key?("a".b) }
show("utf-8 vs binary, non-ascii") { { "é" => 1 }.key?("é".b) }
