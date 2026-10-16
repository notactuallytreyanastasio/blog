# frozen_string_literal: true

# Three mistakes, one of each kind Steep reports differently.
module Broken
  # declared to return Integer; returns a String
  def self.wrong_return(value) = value.to_s

  # declared to take Integer; called with a Float
  def self.caller(value) = wrong_return(value.to_f)

  # not declared in sig/ at all
  def self.undeclared(value) = value + 1
end
