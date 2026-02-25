defmodule BlogWeb.MarkdownEditor.Formatter do
  @moduledoc """
  Pure functions for markdown formatting operations.

  Handles text wrapping and insertion for all supported markdown format types.
  All functions are pure -- they take text, selection positions, and format type,
  and return the transformed text with updated cursor positions.
  """

  @type format_result :: {text :: String.t(), selection_start :: non_neg_integer(), selection_end :: non_neg_integer()}

  @doc """
  Splits text into before/after segments based on selection boundaries.

  When there is a selection (start != end), splits at selection_start and selection_end.
  When there is no selection (start == end), splits at the cursor position.
  """
  @spec split_text(String.t(), non_neg_integer(), non_neg_integer()) ::
          {before :: String.t(), after_text :: String.t()}
  def split_text(text, selection_start, selection_end) when selection_start != selection_end do
    {String.slice(text, 0, selection_start), String.slice(text, selection_end..-1//1)}
  end

  def split_text(text, selection_start, _selection_end) do
    {String.slice(text, 0, selection_start), String.slice(text, selection_start..-1//1)}
  end

  @doc """
  Applies the given markdown format to text at the specified selection.

  Returns `{new_text, new_selection_start, new_selection_end}`.

  ## Parameters

    - `format` - The format type string (e.g., "bold", "italic", "h1")
    - `before_text` - Text before the selection/cursor
    - `after_text` - Text after the selection/cursor
    - `selection_start` - Starting position of the selection
    - `selection_end` - Ending position of the selection
    - `selected_text` - The currently selected text
    - `has_selection` - Whether text is selected

  """
  @spec apply_format(String.t(), String.t(), String.t(), non_neg_integer(), non_neg_integer(), String.t(), boolean()) ::
          format_result()

  # -- Wrap formats: bold, italic, strikethrough, code --

  def apply_format("bold", before, after_text, start, end_pos, selected, true) do
    wrap(before, after_text, start, end_pos, selected, "**", "**")
  end

  def apply_format("bold", before, after_text, start, _end_pos, _selected, false) do
    placeholder(before, after_text, start, "**", "bold text", "**")
  end

  def apply_format("italic", before, after_text, start, end_pos, selected, true) do
    wrap(before, after_text, start, end_pos, selected, "*", "*")
  end

  def apply_format("italic", before, after_text, start, _end_pos, _selected, false) do
    placeholder(before, after_text, start, "*", "italic text", "*")
  end

  def apply_format("strikethrough", before, after_text, start, end_pos, selected, true) do
    wrap(before, after_text, start, end_pos, selected, "~~", "~~")
  end

  def apply_format("strikethrough", before, after_text, start, _end_pos, _selected, false) do
    placeholder(before, after_text, start, "~~", "strikethrough", "~~")
  end

  def apply_format("code", before, after_text, start, end_pos, selected, true) do
    wrap(before, after_text, start, end_pos, selected, "`", "`")
  end

  def apply_format("code", before, after_text, start, _end_pos, _selected, false) do
    placeholder(before, after_text, start, "`", "code", "`")
  end

  # -- Block formats: code_block --

  def apply_format("code_block", before, after_text, start, end_pos, selected, true) do
    wrap(before, after_text, start, end_pos, selected, "```\n", "\n```")
  end

  def apply_format("code_block", before, after_text, start, _end_pos, _selected, false) do
    placeholder(before, after_text, start, "```\n", "code block", "\n```")
  end

  # -- Prefix formats: headings, quote --

  def apply_format("h1", before, after_text, start, end_pos, selected, true) do
    prefix(before, after_text, start, end_pos, selected, "# ")
  end

  def apply_format("h1", before, after_text, start, _end_pos, _selected, false) do
    placeholder_prefix(before, after_text, start, "# ", "Heading 1")
  end

  def apply_format("h2", before, after_text, start, end_pos, selected, true) do
    prefix(before, after_text, start, end_pos, selected, "## ")
  end

  def apply_format("h2", before, after_text, start, _end_pos, _selected, false) do
    placeholder_prefix(before, after_text, start, "## ", "Heading 2")
  end

  def apply_format("h3", before, after_text, start, end_pos, selected, true) do
    prefix(before, after_text, start, end_pos, selected, "### ")
  end

  def apply_format("h3", before, after_text, start, _end_pos, _selected, false) do
    placeholder_prefix(before, after_text, start, "### ", "Heading 3")
  end

  def apply_format("quote", before, after_text, start, end_pos, selected, true) do
    prefix(before, after_text, start, end_pos, selected, "> ")
  end

  def apply_format("quote", before, after_text, start, _end_pos, _selected, false) do
    placeholder_prefix(before, after_text, start, "> ", "Blockquote")
  end

  # -- Link format --

  def apply_format("link", before, after_text, start, end_pos, selected, true) do
    url_suffix = "](https://example.com)"
    text = "#{before}[#{selected}#{url_suffix}#{after_text}"
    {text, start, end_pos + 1 + String.length(url_suffix)}
  end

  def apply_format("link", before, after_text, start, _end_pos, _selected, false) do
    link_text = "link text"
    text = "#{before}[#{link_text}](https://example.com)#{after_text}"
    {text, start + 1, start + 1 + String.length(link_text)}
  end

  # -- List formats --

  def apply_format("bullet_list", before, after_text, start, _end_pos, selected, true) do
    formatted = format_as_list(selected, fn _idx, line -> "- #{line}" end)

    {
      "#{before}\n#{formatted}\n#{after_text}",
      start,
      start + String.length(formatted) + 2
    }
  end

  def apply_format("bullet_list", before, after_text, start, _end_pos, _selected, false) do
    {
      "#{before}\n- List item 1\n- List item 2\n- List item 3#{after_text}",
      start + 3,
      start + 14
    }
  end

  def apply_format("numbered_list", before, after_text, start, _end_pos, selected, true) do
    formatted = format_as_list(selected, fn idx, line -> "#{idx}. #{line}" end)

    {
      "#{before}\n#{formatted}\n#{after_text}",
      start,
      start + String.length(formatted) + 2
    }
  end

  def apply_format("numbered_list", before, after_text, start, _end_pos, _selected, false) do
    {
      "#{before}\n1. List item 1\n2. List item 2\n3. List item 3#{after_text}",
      start + 3,
      start + 14
    }
  end

  # -- Unknown format (no-op) --

  def apply_format(_format, before, _after_text, start, end_pos, _selected, _has_selection) do
    {before, start, end_pos}
  end

  @doc """
  Parses markdown text to HTML using MDEx.

  Returns `{:ok, html}` on success or `{:error, reason}` on failure.
  """
  @spec to_html(String.t()) :: {:ok, String.t()} | {:error, term()}
  def to_html(markdown) when is_binary(markdown) do
    {:ok, MDEx.to_html!(markdown)}
  rescue
    error -> {:error, error}
  end

  # -- Private helpers --

  defp wrap(before, after_text, start, end_pos, selected, open, close) do
    text = "#{before}#{open}#{selected}#{close}#{after_text}"
    marker_len = String.length(open) + String.length(close)
    {text, start, end_pos + marker_len}
  end

  defp placeholder(before, after_text, start, open, placeholder_text, close) do
    text = "#{before}#{open}#{placeholder_text}#{close}#{after_text}"
    open_len = String.length(open)
    {text, start + open_len, start + open_len + String.length(placeholder_text)}
  end

  defp prefix(before, after_text, start, end_pos, selected, prefix_str) do
    text = "#{before}#{prefix_str}#{selected}#{after_text}"
    {text, start, end_pos + String.length(prefix_str)}
  end

  defp placeholder_prefix(before, after_text, start, prefix_str, placeholder_text) do
    text = "#{before}#{prefix_str}#{placeholder_text}#{after_text}"
    prefix_len = String.length(prefix_str)
    {text, start + prefix_len, start + prefix_len + String.length(placeholder_text)}
  end

  defp format_as_list(selected_text, formatter) do
    selected_text
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.map_join("\n", fn {line, idx} -> formatter.(idx, line) end)
  end
end
