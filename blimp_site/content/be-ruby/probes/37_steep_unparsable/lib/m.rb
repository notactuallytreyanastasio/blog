module M
  BEGIN = 1

  # a type error Steep would report in a file it could parse
  def self.twice(n) = "not an Integer"
end
