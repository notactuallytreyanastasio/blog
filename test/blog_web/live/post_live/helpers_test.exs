defmodule BlogWeb.PostLive.HelpersTest do
  use ExUnit.Case, async: true
  alias BlogWeb.PostLive.Helpers

  describe "remove_tags_line/1" do
    test "removes a line starting with tags:" do
      content = "# Title\ntags: elixir, phoenix\nSome body text"
      assert Helpers.remove_tags_line(content) == "# Title\nSome body text"
    end

    test "removes tags line with leading whitespace" do
      content = "Hello\n  tags: foo\nWorld"
      assert Helpers.remove_tags_line(content) == "Hello\nWorld"
    end

    test "preserves content with no tags line" do
      content = "# Title\nBody text here"
      assert Helpers.remove_tags_line(content) == content
    end

    test "handles empty string" do
      assert Helpers.remove_tags_line("") == ""
    end

    test "does not remove lines that merely mention tags" do
      content = "We added new tags to the system"
      assert Helpers.remove_tags_line(content) == content
    end
  end

  describe "tags_line?/1" do
    test "returns true for a tags line" do
      assert Helpers.tags_line?("tags: elixir, phoenix")
    end

    test "returns true with leading whitespace" do
      assert Helpers.tags_line?("  tags: something")
    end

    test "returns false for normal text" do
      refute Helpers.tags_line?("We discussed tags today")
    end

    test "returns false for empty string" do
      refute Helpers.tags_line?("")
    end
  end

  describe "word_count/1" do
    test "counts words in a simple sentence" do
      assert Helpers.word_count("hello world") == 2
    end

    test "handles multiple whitespace types" do
      assert Helpers.word_count("hello\tworld\nfoo  bar") == 4
    end

    test "returns 0 for empty string" do
      assert Helpers.word_count("") == 0
    end

    test "returns 0 for whitespace-only string" do
      assert Helpers.word_count("   \n\t  ") == 0
    end

    test "counts markdown content words" do
      content = "# Title\n\nThis is a **paragraph** with `code`."
      assert Helpers.word_count(content) == 8
    end
  end

  describe "estimated_read_time/1" do
    test "returns less than 1 min for short content" do
      content = String.duplicate("word ", 50)
      assert Helpers.estimated_read_time(content) == "< 1 min read"
    end

    test "returns 1 min for ~250 words" do
      content = String.duplicate("word ", 250)
      assert Helpers.estimated_read_time(content) == "1 min read"
    end

    test "returns 2 min for ~500 words" do
      content = String.duplicate("word ", 500)
      assert Helpers.estimated_read_time(content) == "2 min read"
    end

    test "rounds up partial minutes" do
      # 300 words / 250 wpm = 1.2, ceil = 1.2, trunc = 1
      content = String.duplicate("word ", 300)
      assert Helpers.estimated_read_time(content) == "1 min read"
    end
  end

  describe "truncated_post/2" do
    test "truncates long content and appends ellipsis" do
      content = String.duplicate("a", 300)
      result = Helpers.truncated_post(content)
      assert String.length(result) == 253
      assert String.ends_with?(result, "...")
    end

    test "removes tags line before truncating" do
      content = "tags: elixir\n" <> String.duplicate("a", 100)
      result = Helpers.truncated_post(content)
      refute result =~ "tags:"
    end

    test "accepts custom max_length" do
      content = String.duplicate("a", 100)
      result = Helpers.truncated_post(content, 50)
      assert String.length(result) == 53
    end
  end

  describe "get_preview/2" do
    test "strips markdown formatting" do
      content = "# Title\n\n**Bold** and `code`"
      result = Helpers.get_preview(content)
      refute result =~ "#"
      refute result =~ "*"
      refute result =~ "`"
    end

    test "removes tags line" do
      content = "tags: elixir\nSome preview text"
      result = Helpers.get_preview(content)
      refute result =~ "tags:"
      assert result =~ "Some preview text"
    end

    test "collapses whitespace" do
      content = "hello   world\n\nfoo"
      result = Helpers.get_preview(content)
      assert result =~ "hello world foo"
    end

    test "truncates to max_length" do
      content = String.duplicate("word ", 100)
      result = Helpers.get_preview(content, 50)
      # 50 chars + "..."
      assert String.length(result) == 53
    end
  end

  describe "render_markdown/1" do
    test "converts markdown to HTML" do
      result = Helpers.render_markdown("# Hello\n\nWorld")
      assert result =~ "<h1>"
      assert result =~ "Hello"
      assert result =~ "World"
    end

    test "strips tags line before rendering" do
      result = Helpers.render_markdown("tags: elixir\n# Hello")
      refute result =~ "tags:"
      assert result =~ "Hello"
    end

    test "applies code class prefix" do
      result = Helpers.render_markdown("```elixir\nIO.puts(\"hi\")\n```")
      assert result =~ "language-elixir"
    end
  end

  describe "process_details_in_html/1" do
    test "passes through HTML with no details blocks" do
      html = "<p>Hello world</p>"
      assert Helpers.process_details_in_html(html) == html
    end

    test "wraps details content in a div" do
      html = "<details><summary>Click</summary>Content here</details>"
      result = Helpers.process_details_in_html(html)
      assert result =~ "details-content"
    end
  end

  describe "looks_like_markdown?/1" do
    test "detects headings" do
      assert Helpers.looks_like_markdown?("## Heading")
      assert Helpers.looks_like_markdown?("# Title")
    end

    test "detects horizontal rules" do
      assert Helpers.looks_like_markdown?("---")
    end

    test "detects unordered lists" do
      assert Helpers.looks_like_markdown?("- item one\n- item two")
    end

    test "detects ordered lists" do
      assert Helpers.looks_like_markdown?("1. first\n2. second")
    end

    test "detects code blocks" do
      assert Helpers.looks_like_markdown?("```\ncode\n```")
    end

    test "detects inline code" do
      assert Helpers.looks_like_markdown?("Use `Enum.map/2` here")
    end

    test "detects blockquotes" do
      assert Helpers.looks_like_markdown?("> This is a quote")
    end

    test "returns false for HTML content" do
      refute Helpers.looks_like_markdown?("<h2>Title</h2><p>Content</p>")
    end

    test "returns false for plain text without markdown markers" do
      refute Helpers.looks_like_markdown?("Just some plain text here")
    end
  end
end
