module M
  def self.dot_nil(x) = x.nil?
  def self.nil_eq(x) = nil == x
  def self.case_eq(x) = NilClass === x
  def self.pattern(x) = x in nil
  # does `nil == s` narrow s? (it need not: translated code uses not_null)
  def self.narrowed(s) = nil == s ? 0 : s.length
end
p [M.nil_eq(nil), M.nil_eq(0), M.nil_eq(false), M.pattern(nil), M.pattern(false), M.case_eq(nil)]
