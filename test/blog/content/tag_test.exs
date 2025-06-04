defmodule Blog.Content.TagTest do
  use ExUnit.Case, async: true
  alias Blog.Content.Tag

  describe "Tag struct" do
    test "creates tag with name" do
      tag = %Tag{name: "elixir"}
      assert tag.name == "elixir"
    end

    test "can be created with nil name" do
      tag = %Tag{name: nil}
      assert tag.name == nil
    end

    test "supports pattern matching" do
      tag = %Tag{name: "phoenix"}

      case tag do
        %Tag{name: "phoenix"} -> :ok
        _ -> flunk("Pattern matching failed")
      end
    end

    test "implements struct protocol" do
      tag = %Tag{name: "test"}
      assert tag.__struct__ == Tag
    end
  end
end
