# Can a module use a struct defined earlier in the same file? And in the same
# module that defines it?
defmodule A.Point do
  defstruct [:x, :y]
  def origin, do: %A.Point{x: 0, y: 0}
  def make(x, y), do: %__MODULE__{x: x, y: y}
end
defmodule B.User do
  def p, do: %A.Point{x: 1, y: 2}
end
IO.inspect(A.Point.origin(), label: "own module")
IO.inspect(A.Point.make(3, 4), label: "__MODULE__")
IO.inspect(B.User.p(), label: "later module, same file")
