defmodule BlogWeb.MarkdownEditorComponent do
  use BlogWeb, :live_component
  require Logger
  alias MDEx

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:markdown, fn -> "" end)
      |> assign_new(:html, fn -> "" end)

    {:ok, socket}
  end

  @impl true
  def handle_event("update_markdown", %{"markdown" => markdown}, socket) do
    # Parse the markdown to HTML using EarmarkParser
    html = MDEx.to_html!(markdown)

    # Send the updated content back to the parent LiveView
    send(self(), {:markdown_updated, %{markdown: markdown, html: html}})

    {:noreply, assign(socket, %{markdown: markdown, html: html})}
  rescue
    error ->
      Logger.error("Markdown parsing error: #{inspect(error)}")
      # Still update the markdown but keep the previous HTML if there's an error
      {:noreply, assign(socket, %{markdown: markdown})}
  end

  @impl true
  def handle_event("insert_format", %{"format" => format}, socket) do
    text = socket.assigns.markdown
    selection_start = 0
    selection_end = 0
    selected_text = ""
    has_selection = false

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
    html = MDEx.to_html!(new_text)

    # Send the updated content back to the parent LiveView
    send(self(), {:markdown_updated, %{markdown: new_text, html: html}})

    # Update the component state
    socket =
      assign(socket, %{
        markdown: new_text,
        html: html
      })

    # Push the updated markdown content to the client
    # This ensures the textarea is updated with the new text
    socket =
      push_event(socket, "update_markdown_content", %{
        content: new_text
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
    <div class="markdown-editor" phx-hook="MarkdownEditor" id={@id}>
      <div class="flex flex-col md:flex-row gap-6">
        <!-- Editor Section -->
        <div class="w-full md:w-1/2">
          <div class="bg-gray-50 border border-gray-300 rounded-md overflow-hidden">
            <div class="toolbar bg-gray-100 p-2 border-b border-gray-300 flex flex-wrap gap-1">
              <button
                phx-click="insert_format"
                phx-value-format="h1"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Heading 1"
              >
                H1
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="h2"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Heading 2"
              >
                H2
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="h3"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Heading 3"
              >
                H3
              </button>
              <span class="mx-1 text-gray-300">|</span>
              <button
                phx-click="insert_format"
                phx-value-format="bold"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200 font-bold"
                title="Bold"
              >
                B
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="italic"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200 italic"
                title="Italic"
              >
                I
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="strikethrough"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200 line-through"
                title="Strikethrough"
              >
                S
              </button>
              <span class="mx-1 text-gray-300">|</span>
              <button
                phx-click="insert_format"
                phx-value-format="code"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200 font-mono"
                title="Inline Code"
              >
                `code`
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="code_block"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200 font-mono"
                title="Code Block"
              >
                ```
              </button>
              <span class="mx-1 text-gray-300">|</span>
              <button
                phx-click="insert_format"
                phx-value-format="quote"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Blockquote"
              >
                Quote
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="link"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Link"
              >
                Link
              </button>
              <span class="mx-1 text-gray-300">|</span>
              <button
                phx-click="insert_format"
                phx-value-format="bullet_list"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Bullet List"
              >
                • List
              </button>
              <button
                phx-click="insert_format"
                phx-value-format="numbered_list"
                phx-target={@myself}
                class="toolbar-btn p-1 rounded hover:bg-gray-200"
                title="Numbered List"
              >
                1. List
              </button>
            </div>

            <div class="p-4">
              <form
                phx-change="update_markdown"
                phx-submit="update_markdown"
                phx-target={@myself}
                class="mb-0"
              >
                <textarea
                  name="markdown"
                  id={"#{@id}-input"}
                  rows="20"
                  class="w-full p-3 border border-gray-300 rounded font-mono text-sm focus:ring-blue-500 focus:border-blue-500"
                  phx-debounce="300"
                  spellcheck="false"
                  placeholder="Type your Markdown here..."
                  phx-hook="MarkdownInput"
                ><%= @markdown %></textarea>
              </form>
            </div>
          </div>

          <div class="mt-3 text-sm text-gray-600">
            <details class="cursor-pointer">
              <summary class="mb-2 font-medium text-blue-600">Markdown Cheatsheet</summary>
              <div class="pl-4 mt-2 border-l-2 border-gray-200">
                <p class="font-medium">Headings:</p>
                <p class="pl-2 font-mono"># H1, ## H2, ### H3</p>

                <p class="font-medium mt-2">Emphasis:</p>
                <p class="pl-2 font-mono">**bold**, *italic*, ~~strikethrough~~</p>

                <p class="font-medium mt-2">Code:</p>
                <p class="pl-2 font-mono">`inline code`</p>
                <p class="pl-2 font-mono">```<br />code block<br />```</p>

                <p class="font-medium mt-2">Lists:</p>
                <p class="pl-2 font-mono">- Item 1<br />- Item 2</p>
                <p class="pl-2 font-mono">1. Item 1<br />2. Item 2</p>

                <p class="font-medium mt-2">Links:</p>
                <p class="pl-2 font-mono">[Link text](URL)</p>

                <p class="font-medium mt-2">Blockquotes:</p>
                <p class="pl-2 font-mono">> This is a quote</p>

                <p class="font-medium mt-2">Keyboard Shortcuts:</p>
                <p class="pl-2">Ctrl+B = Bold</p>
                <p class="pl-2">Ctrl+I = Italic</p>
                <p class="pl-2">Ctrl+K = Link</p>
                <p class="pl-2 font-semibold text-blue-600 mt-2">
                  Tip: Select text first, then apply formatting!
                </p>
              </div>
            </details>
          </div>
        </div>

    <!-- Preview Section -->
        <div class="w-full md:w-1/2">
          <div class="bg-white border border-gray-300 rounded-md overflow-hidden h-full">
            <div class="bg-gray-100 p-3 border-b border-gray-300">
              <h2 class="text-lg font-semibold">Preview</h2>
            </div>
            <div
              id={"#{@id}-preview"}
              class="markdown-preview prose prose-sm md:prose max-w-none p-6 overflow-auto min-h-[30rem]"
            >
              <%= if @html == "" do %>
                <div class="text-gray-400 italic flex items-center justify-center h-full">
                  <p>Preview will appear here...</p>
                </div>
              <% else %>
                {raw(@html)}
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
