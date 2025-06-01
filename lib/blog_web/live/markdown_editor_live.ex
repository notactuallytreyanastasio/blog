defmodule BlogWeb.MarkdownEditorLive do
  use BlogWeb, :live_view
  require Logger
  import Phoenix.LiveView.JS
  alias BlogWeb.MarkdownEditorComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       markdown: "",
       html: "",
       page_title: "Markdown Editor"
     })}
  end

  @impl true
  def handle_info({:markdown_updated, %{markdown: markdown, html: html}}, socket) do
    # Update the LiveView state when the component updates the markdown
    {:noreply, assign(socket, markdown: markdown, html: html)}
  end

  @impl true
  def handle_event("update_markdown", %{"markdown" => markdown}, socket) do
    # Parse the markdown to HTML using EarmarkParser
    html = EarmarkParser.as_html!(markdown, code_class_prefix: "language-")

    {:noreply, assign(socket, %{markdown: markdown, html: html})}
  rescue
    error ->
      Logger.error("Markdown parsing error: #{inspect(error)}")
      # Still update the markdown but keep the previous HTML if there's an error
      {:noreply, assign(socket, %{markdown: markdown})}
  end

  @impl true
  def handle_event(
        "save_selection_info",
        %{
          "position" => position,
          "selection_start" => selection_start,
          "selection_end" => selection_end,
          "selected_text" => selected_text
        },
        socket
      ) do
    {position, _} = Integer.parse(position)
    {selection_start, _} = Integer.parse(selection_start)
    {selection_end, _} = Integer.parse(selection_end)

    {:noreply,
     assign(socket, %{
       cursor_position: position,
       selection_start: selection_start,
       selection_end: selection_end,
       selected_text: selected_text
     })}
  end

  @impl true
  def handle_event("save_cursor_position", %{"position" => position}, socket) do
    {position, _} = Integer.parse(position)
    {:noreply, assign(socket, cursor_position: position)}
  end

  @impl true
  def handle_event("insert_format", %{"format" => format}, socket) do
    text = socket.assigns.markdown
    selection_start = socket.assigns.selection_start
    selection_end = socket.assigns.selection_end
    selected_text = socket.assigns.selected_text
    has_selection = selection_start != selection_end

    {before_text, after_text} =
      if has_selection do
        {String.slice(text, 0, selection_start), String.slice(text, selection_end..-1)}
      else
        {String.slice(text, 0, selection_start), String.slice(text, selection_start..-1)}
      end

    {new_text, new_selection_start, new_selection_end} =
      handle_format(
        format,
        before_text,
        after_text,
        selection_start,
        selection_end,
        selected_text,
        has_selection
      )

    # Parse the new markdown to update the preview
    html = EarmarkParser.as_html!(new_text, code_class_prefix: "language-")

    # Update the socket assigns with the new text and HTML
    socket =
      assign(socket, %{
        markdown: new_text,
        html: html,
        selection_start: new_selection_start,
        selection_end: new_selection_end
      })

    # Push the updated markdown content to the client
    # This ensures the textarea is updated with the new text
    socket =
      push_event(socket, "update_markdown_content", %{
        content: new_text,
        selectionStart: new_selection_start,
        selectionEnd: new_selection_end
      })

    {:noreply, socket}
  rescue
    error ->
      Logger.error("Format insertion error: #{inspect(error)}")
      {:noreply, socket}
  end

  # ========== Format handling functions with pattern matching ==========

  # Bold formatting
  defp handle_format(
         "bold",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}**#{selected_text}**#{after_text}",
      selection_start,
      selection_end + 4
    }
  end

  defp handle_format(
         "bold",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}**bold text**#{after_text}",
      selection_start + 2,
      selection_start + 10
    }
  end

  # Italic formatting
  defp handle_format(
         "italic",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}*#{selected_text}*#{after_text}",
      selection_start,
      selection_end + 2
    }
  end

  defp handle_format(
         "italic",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}*italic text*#{after_text}",
      selection_start + 1,
      selection_start + 12
    }
  end

  # Strikethrough formatting
  defp handle_format(
         "strikethrough",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}~~#{selected_text}~~#{after_text}",
      selection_start,
      selection_end + 4
    }
  end

  defp handle_format(
         "strikethrough",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}~~strikethrough~~#{after_text}",
      selection_start + 2,
      selection_start + 16
    }
  end

  # Code formatting
  defp handle_format(
         "code",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}`#{selected_text}`#{after_text}",
      selection_start,
      selection_end + 2
    }
  end

  defp handle_format(
         "code",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}`code`#{after_text}",
      selection_start + 1,
      selection_start + 5
    }
  end

  # Code block formatting
  defp handle_format(
         "code_block",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}```\n#{selected_text}\n```#{after_text}",
      selection_start,
      selection_end + 8
    }
  end

  defp handle_format(
         "code_block",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}```\ncode block\n```#{after_text}",
      selection_start + 4,
      selection_start + 14
    }
  end

  # H1 formatting
  defp handle_format(
         "h1",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}# #{selected_text}#{after_text}",
      selection_start,
      selection_end + 2
    }
  end

  defp handle_format(
         "h1",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}# Heading 1#{after_text}",
      selection_start + 2,
      selection_start + 11
    }
  end

  # H2 formatting
  defp handle_format(
         "h2",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}## #{selected_text}#{after_text}",
      selection_start,
      selection_end + 3
    }
  end

  defp handle_format(
         "h2",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}## Heading 2#{after_text}",
      selection_start + 3,
      selection_start + 12
    }
  end

  # H3 formatting
  defp handle_format(
         "h3",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}### #{selected_text}#{after_text}",
      selection_start,
      selection_end + 4
    }
  end

  defp handle_format(
         "h3",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}### Heading 3#{after_text}",
      selection_start + 4,
      selection_start + 13
    }
  end

  # Quote formatting
  defp handle_format(
         "quote",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}> #{selected_text}#{after_text}",
      selection_start,
      selection_end + 2
    }
  end

  defp handle_format(
         "quote",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}> Blockquote#{after_text}",
      selection_start + 2,
      selection_start + 12
    }
  end

  # Link formatting
  defp handle_format(
         "link",
         before_text,
         after_text,
         selection_start,
         selection_end,
         selected_text,
         true
       ) do
    {
      "#{before_text}[#{selected_text}](https://example.com)#{after_text}",
      selection_start,
      selection_end + 21
    }
  end

  defp handle_format(
         "link",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}[link text](https://example.com)#{after_text}",
      selection_start + 1,
      selection_start + 10
    }
  end

  # Bullet list formatting
  defp handle_format(
         "bullet_list",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         selected_text,
         true
       ) do
    # Split selected text by newlines and add bullet points
    formatted_text =
      selected_text
      |> String.split("\n")
      |> Enum.map_join("\n", fn line -> "- #{line}" end)

    {
      "#{before_text}\n#{formatted_text}\n#{after_text}",
      selection_start,
      selection_start + String.length(formatted_text) + 2
    }
  end

  defp handle_format(
         "bullet_list",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}\n- List item 1\n- List item 2\n- List item 3#{after_text}",
      selection_start + 3,
      selection_start + 14
    }
  end

  # Numbered list formatting
  defp handle_format(
         "numbered_list",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         selected_text,
         true
       ) do
    # Split selected text by newlines and add numbered points
    formatted_text =
      selected_text
      |> String.split("\n")
      |> Enum.with_index(1)
      |> Enum.map_join("\n", fn {line, idx} -> "#{idx}. #{line}" end)

    {
      "#{before_text}\n#{formatted_text}\n#{after_text}",
      selection_start,
      selection_start + String.length(formatted_text) + 2
    }
  end

  defp handle_format(
         "numbered_list",
         before_text,
         after_text,
         selection_start,
         _selection_end,
         _selected_text,
         false
       ) do
    {
      "#{before_text}\n1. List item 1\n2. List item 2\n3. List item 3#{after_text}",
      selection_start + 3,
      selection_start + 14
    }
  end

  # Default case for unknown formats
  defp handle_format(
         _format,
         text,
         _after_text,
         selection_start,
         selection_end,
         _selected_text,
         _has_selection
       ) do
    {text, selection_start, selection_end}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Markdown Editor</h1>

      <.live_component
        module={MarkdownEditorComponent}
        id="markdown-editor"
        markdown={@markdown}
        html={@html}
      />
    </div>
    """
  end
end
