# Where a Temper module's top-level `let` and `var` can live so that a
# module function, a lambda and a class's instance method can all reach
# them. Run: ruby -w 09_module_state.rb
def show(label, value) = puts("#{label.ljust(44)} #{value.inspect}")

module Lib
  local = "local"           # a local in the module body
  _ = local
  GREETING = "constant"     # a constant
  @calls = 0                # the module's own instance variable
  @@count = 0               # a class variable

  def self.sees_local
    local
  rescue NameError
    "NameError"
  end
  def self.sees_constant = GREETING
  def self.sees_ivar = @calls
  def self.sees_class_var = @@count

  class Point
    def sees_constant = GREETING
    def sees_ivar = @calls          # @calls of the Point, not of Lib
    def sees_class_var
      @@count
    rescue NameError
      "NameError"
    end
    def sees_ivar_via_lib = Lib.calls
  end

  class << self
    attr_accessor :calls
  end

  LAMBDA = -> { [GREETING, @calls] }   # self here is Lib
end

show "def self.f sees a module-body local", Lib.sees_local
show "def self.f sees a constant", Lib.sees_constant
show "def self.f sees @ivar", Lib.sees_ivar
show "def self.f sees @@class_var", Lib.sees_class_var
show "class method sees the constant", Lib::Point.new.sees_constant
show "class method's @calls is", Lib::Point.new.sees_ivar
show "class method sees Lib's @@count", Lib::Point.new.sees_class_var
show "class method via Lib.calls accessor", Lib::Point.new.sees_ivar_via_lib
show "lambda made in module body", Lib::LAMBDA.()

# A constant reassigned: allowed, with a warning.
module Lib; GREETING = "again"; end
show "constant after reassignment", Lib::GREETING
