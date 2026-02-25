defmodule BlogWeb.PostLive.Helpers do
  @moduledoc """
  Pure functions extracted from PostLive for testability.

  Handles markdown processing, content transformations, and text analysis
  that don't depend on LiveView state.
  """

  @earmark_opts [code_class_prefix: "language-", escape: false]

  @doc """
  Removes lines starting with "tags:" from markdown content.
  """
  def remove_tags_line(content) when is_binary(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&tags_line?/1)
    |> Enum.join("\n")
  end

  @doc """
  Returns true if the line is a tags metadata line.
  """
  def tags_line?(line) when is_binary(line) do
    line |> String.trim() |> String.starts_with?("tags:")
  end

  @doc """
  Counts the number of words in a string.
  """
  def word_count(content) when is_binary(content) do
    content
    |> String.split(~r/\s+/, trim: true)
    |> length()
  end

  @doc """
  Estimates reading time based on an average of 250 words per minute.
  """
  def estimated_read_time(content) when is_binary(content) do
    words = word_count(content)
    minutes = Float.ceil(words / 250, 1)

    if minutes < 1.0 do
      "< 1 min read"
    else
      "#{trunc(minutes)} min read"
    end
  end

  @doc """
  Truncates post body for use as a description/preview, removing tags
  and trimming to `max_length` characters.
  """
  def truncated_post(body, max_length \\ 250) when is_binary(body) do
    body
    |> remove_tags_line()
    |> String.slice(0, max_length)
    |> Kernel.<>("...")
  end

  @doc """
  Creates a plain-text preview of markdown content, stripping formatting.
  """
  def get_preview(content, max_length \\ 200) when is_binary(content) do
    content
    |> remove_tags_line()
    |> String.split("\n")
    |> Enum.join(" ")
    |> String.replace(~r/[#*`]/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, max_length)
    |> Kernel.<>("...")
  end

  @doc """
  Renders markdown content to HTML, processing details blocks.
  Returns processed HTML string.
  """
  def render_markdown(content) when is_binary(content) do
    content
    |> remove_tags_line()
    |> Earmark.as_html(@earmark_opts)
    |> case do
      {:ok, html, _} -> process_details_in_html(html)
      {:error, html, _} -> process_details_in_html(html)
    end
  end

  @doc """
  Post-processes rendered HTML to handle `<details>` blocks that may
  contain raw markdown content, rendering them properly.
  """
  def process_details_in_html(html) when is_binary(html) do
    pattern = ~r/<details([^>]*)>\s*<summary([^>]*)>(.*?)<\/summary>\s*(.*?)<\/details>/s

    Regex.scan(pattern, html)
    |> Enum.reduce(html, fn [full_match, details_attrs, summary_attrs, summary_content, details_content], acc ->
      processed_block =
        process_single_details_block(details_attrs, summary_attrs, summary_content, details_content)

      String.replace(acc, full_match, processed_block, global: false)
    end)
  end

  @doc """
  Returns true if the content looks like raw markdown rather than HTML.
  Used to decide whether to re-render content inside details blocks.
  """
  def looks_like_markdown?(content) when is_binary(content) do
    has_markdown_features?(content) and not has_html_tags?(content)
  end

  defp has_markdown_features?(content) do
    Enum.any?(markdown_indicators(), fn check -> check.(content) end)
  end

  defp markdown_indicators do
    [
      &String.contains?(&1, "##"),
      &String.contains?(&1, "# "),
      &String.contains?(&1, "---"),
      &String.contains?(&1, "```"),
      &Regex.match?(~r/^\s*[-*+]\s+/m, &1),
      &Regex.match?(~r/^\s*\d+\.\s+/m, &1),
      &Regex.match?(~r/`[^`]+`/, &1),
      &Regex.match?(~r/^\s*>\s+/m, &1),
      &(String.contains?(&1, "*") and not String.contains?(&1, "<strong>")),
      &(String.contains?(&1, "_") and not String.contains?(&1, "<em>"))
    ]
  end

  defp has_html_tags?(content) do
    String.contains?(content, "<h") or
      String.contains?(content, "<p>") or
      String.contains?(content, "<ul>")
  end

  defp process_single_details_block(details_attrs, summary_attrs, summary_content, details_content) do
    trimmed = String.trim(details_content)

    inner_html =
      if looks_like_markdown?(trimmed) do
        case Earmark.as_html(trimmed, @earmark_opts) do
          {:ok, processed, _} -> processed
          {:error, _, _} -> trimmed
        end
      else
        trimmed
      end

    "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary>" <>
      "<div class=\"details-content\">#{inner_html}</div></details>"
  end
end
