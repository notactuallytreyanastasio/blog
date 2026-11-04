module M
  def self.plain(map, key) = map[key]
  def self.bounded(map, key) = map[key]
  def self.by_object(map, key) = map[key]
  def self.fetch_bounded(map, key) = map.fetch(key) { raise "missing" }
  def self.fetch_by_object(map, key) = map.fetch(key) { raise "missing" }
  def self.delete_by_object(map, key) = map.delete(key)
  def self.to_h_by_object(pairs) = pairs.to_h { |k, v| [k, v] }
end
p M.plain({ "a" => 1 }, "a")
module M
  def self.index_bounded(map, key) = map.key?(key) ? map[key] : raise("missing")
  def self.key_p_bounded(map, key) = map.key?(key)
  def self.fetch_default_bounded(map, key, fallback) = map.fetch(key, fallback)
  def self.delete_bounded(map, key) = map.delete(key)
  def self.to_h_bounded(pairs) = pairs.to_h { |k, v| [k, v] }
  def self.store_bounded(map, key, value) = map.store(key, value)
end
module M
  def self.cast_key(map, key)
    k = key #: untyped
    map.fetch(k) { raise "missing" }
  end
  def self.calls_bounded(map, key) = bounded(map, key)
  def self.calls_plain(map, key) = cast_key(map, key)
end
module M
  def self.bounded_calls_plain(map, key) = cast_key(map, key)
end
