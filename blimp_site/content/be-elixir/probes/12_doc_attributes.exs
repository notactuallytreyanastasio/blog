# What be-elixir's @doc and @moduledoc rely on (entry 43).
# Run: elixir journal/probes/12_doc_attributes.exs
ExUnit.start(autorun: false)
import ExUnit.CaptureIO

compile = fn src ->
  capture_io(:stderr, fn -> send(self(), {:compiled, Code.compile_string(src)}) end)
end

# a module compiled from a string has no .beam file, so read its Docs chunk
docs = fn ->
  receive do
    {:compiled, [{_, bin}]} ->
      {:ok, {_, [{~c"Docs", chunk}]}} = :beam_lib.chunks(bin, [~c"Docs"])
      :erlang.binary_to_term(chunk)
  end
end

# 1. A @doc on a defp is discarded, with a warning. A private function gets none.
w = compile.(~S'''
defmodule P1 do
  @doc "Adds one."
  defp helper(x), do: x + 1
  def api(x), do: helper(x)
end
''')
receive do {:compiled, _} -> :ok end
IO.puts("doc on defp warns: #{w =~ "@doc attribute is always discarded for private functions"}")

# 2. The closing """'s indentation is stripped from every line, so a doc
#    indented with the module's items reads back as the text as written.
compile.(~S'''
defmodule P2 do
  @moduledoc """
  First line.

  Second paragraph.
  """
end
''')
{:docs_v1, _, _, _, %{"en" => md}, _, _} = docs.()
IO.puts("indent stripped: #{inspect(md)}")

# 3. A line indented less than the closing """ is a warning, not an error.
w = compile.(~s'''
defmodule P3 do
  @moduledoc """
Not indented.
  """
end
''')
receive do {:compiled, _} -> :ok end
IO.puts("outdented line warns: #{w =~ "outdented heredoc line"}")

# 4. `\`, `#{` and `"""` must be escaped, or they mean something.
compile.(~S'''
defmodule P4 do
  @moduledoc """
  Use `\"""` sparingly, and `\\n` and `\#{x}` mean nothing here.
  """
end
''')
{:docs_v1, _, _, _, %{"en" => md}, _, _} = docs.()
IO.puts("escaped: #{inspect(md)}")

# 5. A @doc false function is hidden from docs but still callable.
compile.(~S'''
defmodule P5 do
  @doc false
  def helper(x), do: x + 1
end
''')
{:docs_v1, _, _, _, _, _, [{{:function, :helper, 1}, _, _, doc, _}]} = docs.()
IO.puts("@doc false: #{inspect(doc)}, P5.helper(1) = #{P5.helper(1)}")
