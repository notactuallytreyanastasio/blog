module G
  EMPTY = [].freeze
  def self.empty_list = EMPTY
  def self.reduce(list, f) = list.inject { |a, b| f.(a, b) }
  def self.add(a, b) = a + b
  def self.size(list) = list.length

  def self.empty_plain = size([])                     # 1
  def self.empty_frozen = size([].freeze)             # 2
  def self.empty_generic = size(empty_list)           # 3
  def self.lambda_inline = reduce([1, 2], ->(a, b) do add(a, b) end)  # 4
  ADD = ->(a, b) do add(a, b) end
  def self.lambda_const = reduce([1, 2], ADD)         # 5
  def self.lambda_block = [1, 2].inject(0, &ADD)      # 6
end
p G.empty_plain, G.empty_frozen, G.empty_generic, G.lambda_inline, G.lambda_const, G.lambda_block
