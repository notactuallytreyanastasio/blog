defmodule Blog.Mirror.SourceProcessorTest do
  use ExUnit.Case, async: true

  alias Blog.Mirror.SourceProcessor

  describe "process/1" do
    test "splits source into lines of character data" do
      result = SourceProcessor.process("ab\ncd")

      assert length(result) == 2
      assert length(Enum.at(result, 0)) == 2
      assert length(Enum.at(result, 1)) == 2
    end

    test "each character has required animation keys" do
      [[char_data | _] | _] = SourceProcessor.process("x")

      assert Map.has_key?(char_data, :char)
      assert Map.has_key?(char_data, :duration)
      assert Map.has_key?(char_data, :delay)
      assert Map.has_key?(char_data, :direction)
    end

    test "preserves the original characters" do
      [[a, b] | _] = SourceProcessor.process("hi")

      assert a.char == "h"
      assert b.char == "i"
    end

    test "handles empty string" do
      result = SourceProcessor.process("")

      assert result == [[]]
    end

    test "handles multiline code" do
      source = """
      defmodule Foo do
        def bar, do: :ok
      end
      """

      result = SourceProcessor.process(source)

      # Should have multiple lines
      assert length(result) > 1

      # First line should start with 'd' for 'defmodule'
      first_char = result |> Enum.at(0) |> Enum.at(0)
      assert first_char.char == "d"
    end

    test "handles error tuple by returning fallback" do
      result = SourceProcessor.process({:error, :some_reason})

      assert is_list(result)
      assert length(result) > 0
    end

    test "handles non-string input by returning fallback" do
      result = SourceProcessor.process(42)

      assert is_list(result)
      assert length(result) > 0
    end
  end

  describe "process_line/1" do
    test "converts a line into character data list" do
      result = SourceProcessor.process_line("abc")

      assert length(result) == 3
      assert Enum.at(result, 0).char == "a"
      assert Enum.at(result, 1).char == "b"
      assert Enum.at(result, 2).char == "c"
    end

    test "handles empty line" do
      assert SourceProcessor.process_line("") == []
    end

    test "handles unicode characters" do
      result = SourceProcessor.process_line("héllo")

      chars = Enum.map(result, & &1.char)
      assert chars == ["h", "é", "l", "l", "o"]
    end
  end

  describe "build_char_data/1" do
    test "returns map with correct char" do
      result = SourceProcessor.build_char_data("x")

      assert result.char == "x"
    end

    test "duration is between 6 and 15" do
      for _ <- 1..100 do
        result = SourceProcessor.build_char_data("a")
        assert result.duration >= 6 and result.duration <= 15
      end
    end

    test "delay is between 1 and 5000" do
      for _ <- 1..100 do
        result = SourceProcessor.build_char_data("a")
        assert result.delay >= 1 and result.delay <= 5000
      end
    end

    test "direction is either 1 or -1" do
      for _ <- 1..100 do
        result = SourceProcessor.build_char_data("a")
        assert result.direction in [1, -1]
      end
    end
  end

  describe "fallback_source/0" do
    test "returns a non-empty string" do
      result = SourceProcessor.fallback_source()

      assert is_binary(result)
      assert byte_size(result) > 0
    end

    test "contains expected module name" do
      result = SourceProcessor.fallback_source()

      assert result =~ "BlogWeb.MirrorLive"
    end

    test "is valid enough to be processed" do
      result =
        SourceProcessor.fallback_source()
        |> SourceProcessor.process()

      assert is_list(result)
      assert length(result) > 1
    end
  end
end
