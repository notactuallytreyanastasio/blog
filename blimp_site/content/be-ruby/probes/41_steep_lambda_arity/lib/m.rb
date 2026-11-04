module M
  def self.greet(name, punctuation = nil)
    "hello #{name}#{punctuation || "!"}"
  end
  GREET = lambda do |a, b|
    greet(a, b)
  end
  GREET_DEFAULTED = lambda do |a, b = nil|
    greet(a, b)
  end
  def self.run
    p GREET_DEFAULTED.("you")
    p GREET.("you")
  end
end
M.run
