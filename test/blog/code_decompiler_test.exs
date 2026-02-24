defmodule Blog.CodeDecompilerTest do
  use ExUnit.Case, async: true

  alias Blog.CodeDecompiler

  describe "decompile_to_string/1" do
    test "decompiles a known project module to a string" do
      # Blog.Mirror.SourceProcessor is a simple project module
      result = CodeDecompiler.decompile_to_string(Blog.Mirror.SourceProcessor)

      assert is_binary(result)
      assert result =~ "SourceProcessor"
    end

    test "decompiled output contains function definitions" do
      result = CodeDecompiler.decompile_to_string(Blog.Mirror.SourceProcessor)

      assert is_binary(result)
      assert result =~ "def"
    end

    test "returns error for non-loadable module" do
      # A module atom that doesn't exist - :code.which returns :non_existing
      result = CodeDecompiler.decompile_to_string(NonExistentModuleThatDoesNotExist)

      assert {:error, _reason} = result
    end

    test "returns a string, not an error tuple, for valid modules" do
      result = CodeDecompiler.decompile_to_string(Blog.Mirror.SourceProcessor)

      refute match?({:error, _}, result)
      assert is_binary(result)
    end
  end
end
