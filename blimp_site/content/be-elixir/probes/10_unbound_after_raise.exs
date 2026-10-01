# Elixir checks that every variable a function reads is bound, even where the
# read can never run. So `x = raise ...` rewritten to `raise ...` breaks a
# later read of x at compile time, and dropping what follows the raise fixes it.

defmodule Probe do
  def compiles?(source) do
    try do
      Code.compile_string(source)
      :compiles
    rescue
      e in CompileError -> {:compile_error, Exception.message(e)}
    end
  end
end

dropped_binding = """
defmodule A do
  def f() do
    raise "broken"
    if x == 1, do: :one, else: :other
  end
end
"""

kept_binding = """
defmodule B do
  def f() do
    x = raise "broken"
    if x == 1, do: :one, else: :other
  end
end
"""

block_ends_at_raise = """
defmodule C do
  def f() do
    raise "broken"
  end
end
"""

IO.inspect(Probe.compiles?(dropped_binding), label: "binding dropped, read kept")
IO.inspect(Probe.compiles?(kept_binding), label: "binding kept          ")
IO.inspect(Probe.compiles?(block_ends_at_raise), label: "block ends at raise   ")
