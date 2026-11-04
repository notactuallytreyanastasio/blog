# frozen_string_literal: true

# `return` inside a lambda returns from the lambda. Steep 2.1 checks it
# against the enclosing method's return type instead. `next` leaves the
# lambda too, and Steep reads it correctly.
module L
  def self.typed(value) = value

  def self.with_return(j)
    fn = ->(i) do
      return typed(i + j)   # Steep: "The method cannot return a value of type ::Integer"
    end
    fn
  end

  def self.with_next(j)
    fn = ->(i) do
      next typed(i + j)
    end
    fn
  end
end

# and at runtime the two are the same
puts L.with_return(1).(2), L.with_next(1).(2)
