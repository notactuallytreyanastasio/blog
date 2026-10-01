defmodule Point do
  defstruct [:x, :y]
end
defmodule Probe do
  @moduledoc false
  def go(a, b) when a > 0 do
    m = %{:x => 1, "k" => 2}
    m2 = %{m | :x => 3}
    p = %Point{x: 1, y: 2}
    p2 = %{p | x: 9}
    f = fn c, d ->
      e = c + d
      e * 2
    end
    r = case {a, b} do
      {1, _} ->
        :one
      {_, y} when y > 1 ->
        z = y + 1
        {:big, z}
      _ ->
        :other
    end
    [h | t] = [1, 2, 3]
    {m2, p2.x, f.(a, b), r, h, t, :erlang.abs(-3), cond do
      false ->
        1
      true ->
        2
    end}
  end
end
IO.inspect(Probe.go(2, 5))
