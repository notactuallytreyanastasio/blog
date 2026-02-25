defmodule BlogWeb.PostLive.IndexTest do
  use ExUnit.Case, async: true

  alias BlogWeb.PostLive.Index

  # -- Pure function tests --

  describe "parse_modal_param/1" do
    test "returns :tech_posts for tech_posts param" do
      assert Index.parse_modal_param(%{"modal" => "tech_posts"}) == :tech_posts
    end

    test "returns :non_tech_posts for non_tech_posts param" do
      assert Index.parse_modal_param(%{"modal" => "non_tech_posts"}) == :non_tech_posts
    end

    test "returns :demos for demos param" do
      assert Index.parse_modal_param(%{"modal" => "demos"}) == :demos
    end

    test "returns nil for unknown param" do
      assert Index.parse_modal_param(%{"modal" => "unknown"}) == nil
    end

    test "returns nil when modal param is missing" do
      assert Index.parse_modal_param(%{}) == nil
    end

    test "returns nil for empty params" do
      assert Index.parse_modal_param(%{"other" => "value"}) == nil
    end
  end

  describe "build_visitor_cursors/1" do
    test "builds map from presence list" do
      presence_list = [
        {"user_1", %{metas: [%{color: "red", cursor_position: nil}]}},
        {"user_2", %{metas: [%{color: "blue", cursor_position: %{x: 10, y: 20}}]}}
      ]

      result = Index.build_visitor_cursors(presence_list)

      assert result == %{
               "user_1" => %{color: "red", cursor_position: nil},
               "user_2" => %{color: "blue", cursor_position: %{x: 10, y: 20}}
             }
    end

    test "uses first meta when multiple metas present" do
      presence_list = [
        {"user_1", %{metas: [%{color: "red"}, %{color: "old_red"}]}}
      ]

      result = Index.build_visitor_cursors(presence_list)
      assert result == %{"user_1" => %{color: "red"}}
    end

    test "returns empty map for empty presence list" do
      assert Index.build_visitor_cursors([]) == %{}
    end
  end

  describe "count_room_users/1" do
    test "counts users per room" do
      cursors = %{
        "user_1" => %{current_room: "frontpage"},
        "user_2" => %{current_room: "frontpage"},
        "user_3" => %{current_room: "general"}
      }

      result = Index.count_room_users(cursors)

      assert result["frontpage"] == 2
      assert result["general"] == 1
    end

    test "defaults to general when current_room is missing" do
      cursors = %{
        "user_1" => %{other_field: "value"}
      }

      result = Index.count_room_users(cursors)
      assert result["general"] == 1
    end

    test "always includes frontpage with zero count" do
      result = Index.count_room_users(%{})
      assert result["frontpage"] == 0
    end

    test "handles single user" do
      cursors = %{"user_1" => %{current_room: "frontpage"}}
      result = Index.count_room_users(cursors)
      assert result["frontpage"] == 1
    end
  end

  describe "format_message_with_links/1" do
    test "converts HTTP URLs to clickable links" do
      result = Index.format_message_with_links("check out http://example.com please")

      assert result =~ ~s(href="http://example.com")
      assert result =~ ~s(target="_blank")
      assert result =~ ~s(rel="noopener noreferrer")
    end

    test "converts HTTPS URLs to clickable links" do
      result = Index.format_message_with_links("visit https://example.com/path")

      assert result =~ ~s(href="https://example.com/path")
    end

    test "adds https prefix to www URLs" do
      result = Index.format_message_with_links("go to www.example.com")

      assert result =~ ~s(href="https://www.example.com")
      assert result =~ ~s(>www.example.com</a>)
    end

    test "returns plain text unchanged when no URLs present" do
      text = "hello world, no links here"
      assert Index.format_message_with_links(text) == text
    end

    test "handles multiple URLs in one message" do
      result =
        Index.format_message_with_links(
          "visit http://one.com and http://two.com"
        )

      assert result =~ ~s(href="http://one.com")
      assert result =~ ~s(href="http://two.com")
    end

    test "preserves surrounding text" do
      result = Index.format_message_with_links("before http://example.com after")
      assert result =~ "before "
      assert result =~ " after"
    end
  end

  describe "demos/0" do
    test "returns a non-empty list of demos" do
      demos = Index.demos()
      assert is_list(demos)
      assert length(demos) > 0
    end

    test "each demo has required keys" do
      for demo <- Index.demos() do
        assert Map.has_key?(demo, :title)
        assert Map.has_key?(demo, :description)
        assert Map.has_key?(demo, :path)
        assert Map.has_key?(demo, :category)
      end
    end

    test "all demo paths are strings starting with /" do
      for demo <- Index.demos() do
        assert is_binary(demo.path), "#{demo.title} path should be a string"
        assert String.starts_with?(demo.path, "/"), "#{demo.title} path should start with /"
      end
    end

    test "all demo titles are non-empty strings" do
      for demo <- Index.demos() do
        assert is_binary(demo.title)
        assert String.length(demo.title) > 0
      end
    end

    test "contains expected categories" do
      categories = Index.demos() |> Enum.map(& &1.category) |> Enum.uniq() |> Enum.sort()
      assert "Games" in categories
      assert "Art" in categories
      assert "Comedy" in categories
    end
  end
end
