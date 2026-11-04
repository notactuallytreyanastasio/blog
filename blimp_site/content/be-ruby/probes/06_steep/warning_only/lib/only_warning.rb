# frozen_string_literal: true

# Only an undeclared method: a warning, nothing else.
module OnlyWarning
  def self.declared(value) = value
  def self.undeclared(value) = value + 1
end
