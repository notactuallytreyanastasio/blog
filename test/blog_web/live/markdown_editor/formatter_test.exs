defmodule BlogWeb.MarkdownEditor.FormatterTest do
  use ExUnit.Case, async: true

  alias BlogWeb.MarkdownEditor.Formatter

  describe "split_text/3" do
    test "splits at selection boundaries when text is selected" do
      assert {"Hello ", " world"} = Formatter.split_text("Hello beautiful world", 6, 15)
    end

    test "splits at cursor position when no selection" do
      assert {"Hello", " world"} = Formatter.split_text("Hello world", 5, 5)
    end

    test "handles empty text" do
      assert {"", ""} = Formatter.split_text("", 0, 0)
    end

    test "handles cursor at beginning" do
      assert {"", "Hello"} = Formatter.split_text("Hello", 0, 0)
    end

    test "handles cursor at end" do
      assert {"Hello", ""} = Formatter.split_text("Hello", 5, 5)
    end
  end

  describe "apply_format/7 with selection" do
    test "bold wraps selected text with **" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("bold", "Hello ", " world", 6, 15, "beautiful", true)

      assert text == "Hello **beautiful** world"
      assert sel_start == 6
      assert sel_end == 19
    end

    test "italic wraps selected text with *" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("italic", "Hello ", " world", 6, 15, "beautiful", true)

      assert text == "Hello *beautiful* world"
      assert sel_start == 6
      assert sel_end == 17
    end

    test "strikethrough wraps selected text with ~~" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("strikethrough", "Hello ", " world", 6, 15, "beautiful", true)

      assert text == "Hello ~~beautiful~~ world"
      assert sel_start == 6
      assert sel_end == 19
    end

    test "code wraps selected text with backtick" do
      {text, _start, _end} =
        Formatter.apply_format("code", "use ", " here", 4, 8, "this", true)

      assert text == "use `this` here"
    end

    test "code_block wraps selected text with triple backticks" do
      {text, _start, _end} =
        Formatter.apply_format("code_block", "before", "after", 6, 10, "code", true)

      assert text == "before```\ncode\n```after"
    end

    test "h1 prepends # to selected text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("h1", "", " rest", 0, 5, "Title", true)

      assert text == "# Title rest"
      assert sel_start == 0
      assert sel_end == 7
    end

    test "h2 prepends ## to selected text" do
      {text, _, _} =
        Formatter.apply_format("h2", "", " rest", 0, 5, "Title", true)

      assert text == "## Title rest"
    end

    test "h3 prepends ### to selected text" do
      {text, _, _} =
        Formatter.apply_format("h3", "", " rest", 0, 5, "Title", true)

      assert text == "### Title rest"
    end

    test "quote prepends > to selected text" do
      {text, _, _} =
        Formatter.apply_format("quote", "", " rest", 0, 4, "text", true)

      assert text == "> text rest"
    end

    test "link wraps selected text as markdown link" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("link", "", " rest", 0, 5, "click", true)

      assert text == "[click](https://example.com) rest"
      assert sel_start == 0
      assert sel_end > 5
    end

    test "bullet_list adds bullet prefix to each line" do
      {text, _, _} =
        Formatter.apply_format("bullet_list", "intro", "outro", 5, 20, "line1\nline2\nline3", true)

      assert text == "intro\n- line1\n- line2\n- line3\noutro"
    end

    test "numbered_list adds number prefix to each line" do
      {text, _, _} =
        Formatter.apply_format("numbered_list", "intro", "outro", 5, 20, "line1\nline2\nline3", true)

      assert text == "intro\n1. line1\n2. line2\n3. line3\noutro"
    end
  end

  describe "apply_format/7 without selection (placeholders)" do
    test "bold inserts placeholder text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("bold", "Hello ", " world", 6, 6, "", false)

      assert text == "Hello **bold text** world"
      assert sel_start == 8
      assert sel_end == 17
    end

    test "italic inserts placeholder text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("italic", "", "", 0, 0, "", false)

      assert text == "*italic text*"
      assert sel_start == 1
      assert sel_end == 12
    end

    test "strikethrough inserts placeholder text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("strikethrough", "", "", 0, 0, "", false)

      assert text == "~~strikethrough~~"
      assert sel_start == 2
      assert sel_end == 15
    end

    test "code inserts placeholder text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("code", "", "", 0, 0, "", false)

      assert text == "`code`"
      assert sel_start == 1
      assert sel_end == 5
    end

    test "code_block inserts placeholder text" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("code_block", "", "", 0, 0, "", false)

      assert text == "```\ncode block\n```"
      assert sel_start == 4
      assert sel_end == 14
    end

    test "h1 inserts placeholder heading" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("h1", "", "", 0, 0, "", false)

      assert text == "# Heading 1"
      assert sel_start == 2
      assert sel_end == 11
    end

    test "h2 inserts placeholder heading" do
      {text, _, _} = Formatter.apply_format("h2", "", "", 0, 0, "", false)
      assert text == "## Heading 2"
    end

    test "h3 inserts placeholder heading" do
      {text, _, _} = Formatter.apply_format("h3", "", "", 0, 0, "", false)
      assert text == "### Heading 3"
    end

    test "quote inserts placeholder blockquote" do
      {text, _, _} = Formatter.apply_format("quote", "", "", 0, 0, "", false)
      assert text == "> Blockquote"
    end

    test "link inserts placeholder link" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("link", "", "", 0, 0, "", false)

      assert text == "[link text](https://example.com)"
      assert sel_start == 1
      assert sel_end == 10
    end

    test "bullet_list inserts placeholder list items" do
      {text, _, _} = Formatter.apply_format("bullet_list", "", "", 0, 0, "", false)
      assert text == "\n- List item 1\n- List item 2\n- List item 3"
    end

    test "numbered_list inserts placeholder list items" do
      {text, _, _} = Formatter.apply_format("numbered_list", "", "", 0, 0, "", false)
      assert text == "\n1. List item 1\n2. List item 2\n3. List item 3"
    end
  end

  describe "apply_format/7 unknown format" do
    test "returns text unchanged for unknown format" do
      {text, sel_start, sel_end} =
        Formatter.apply_format("unknown", "hello", " world", 5, 5, "", false)

      assert text == "hello"
      assert sel_start == 5
      assert sel_end == 5
    end
  end

  describe "to_html/1" do
    test "converts markdown to HTML" do
      assert {:ok, html} = Formatter.to_html("# Hello")
      assert html =~ "<h1>"
      assert html =~ "Hello"
    end

    test "converts bold markdown" do
      assert {:ok, html} = Formatter.to_html("**bold**")
      assert html =~ "<strong>"
    end

    test "handles empty string" do
      assert {:ok, ""} = Formatter.to_html("")
    end
  end

  describe "split_text + apply_format composition" do
    test "full formatting pipeline: split then format with selection" do
      text = "Hello beautiful world"
      selection_start = 6
      selection_end = 15
      selected_text = "beautiful"

      {before, after_text} = Formatter.split_text(text, selection_start, selection_end)

      {new_text, new_start, new_end} =
        Formatter.apply_format(
          "bold",
          before,
          after_text,
          selection_start,
          selection_end,
          selected_text,
          true
        )

      assert new_text == "Hello **beautiful** world"
      assert String.slice(new_text, new_start..(new_end - 1)) == "**beautiful**"
    end

    test "full formatting pipeline: split then format without selection" do
      text = "Hello world"
      cursor = 5

      {before, after_text} = Formatter.split_text(text, cursor, cursor)

      {new_text, new_start, new_end} =
        Formatter.apply_format("bold", before, after_text, cursor, cursor, "", false)

      assert new_text == "Hello**bold text** world"
      # The placeholder text "bold text" should be selected
      assert String.slice(new_text, new_start..(new_end - 1)) == "bold text"
    end
  end
end
