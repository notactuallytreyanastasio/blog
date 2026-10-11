module M
  def self.show(i) = i.to_s
  def self.apply(f, i) = f.(i)
  def self.by_method = apply(method(:show), 1)
  def self.by_lambda = apply(->(i) do show(i) end, 2)
  def self.map_method = [1, 2].map(&method(:show))
end
puts M.by_method, M.by_lambda, M.map_method.inspect
