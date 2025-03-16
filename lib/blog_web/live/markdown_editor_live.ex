defmodule BlogWeb.MarkdownEditorLive do
  use BlogWeb, :live_view
  require Logger
  import Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{
      markdown: "",
      html: "",
      cursor_position: 0,
      selection_start: 0,
      selection_end: 0,
      selected_text: ""
    })}
  end

  @impl true
  def handle_event("update_markdown", %{"markdown" => markdown}, socket) do
    # Parse the markdown to HTML using Earmark
    {:ok, html, _warnings} = Earmark.as_html(markdown, %Earmark.Options{code_class_prefix: "language-"})

    {:noreply, assign(socket, %{markdown: markdown, html: html})}
  rescue
    error ->
      Logger.error("Markdown parsing error: #{inspect(error)}")
      # Still update the markdown but keep the previous HTML if there's an error
      {:noreply, assign(socket, %{markdown: markdown})}
  end

  @impl true
  def handle_event("save_selection_info", %{"position" => position, "selection_start" => selection_start,
                                           "selection_end" => selection_end, "selected_text" => selected_text}, socket) do
    {position, _} = Integer.parse(position)
    {selection_start, _} = Integer.parse(selection_start)
    {selection_end, _} = Integer.parse(selection_end)

    {:noreply, assign(socket, %{
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
      case format do
        "bold" ->
          if has_selection do
            {
              "#{before_text}**#{selected_text}**#{after_text}",
              selection_start,
              selection_end + 4
            }
          else
            {
              "#{before_text}**bold text**#{after_text}",
              selection_start + 2,
              selection_start + 10
            }
          end
        "italic" ->
          if has_selection do
            {
              "#{before_text}*#{selected_text}*#{after_text}",
              selection_start,
              selection_end + 2
            }
          else
            {
              "#{before_text}*italic text*#{after_text}",
              selection_start + 1,
              selection_start + 12
            }
          end
        "strikethrough" ->
          if has_selection do
            {
              "#{before_text}~~#{selected_text}~~#{after_text}",
              selection_start,
              selection_end + 4
            }
          else
            {
              "#{before_text}~~strikethrough~~#{after_text}",
              selection_start + 2,
              selection_start + 16
            }
          end
        "code" ->
          if has_selection do
            {
              "#{before_text}`#{selected_text}`#{after_text}",
              selection_start,
              selection_end + 2
            }
          else
            {
              "#{before_text}`code`#{after_text}",
              selection_start + 1,
              selection_start + 5
            }
          end
        "code_block" ->
          if has_selection do
            {
              "#{before_text}```\n#{selected_text}\n```#{after_text}",
              selection_start,
              selection_end + 8
            }
          else
            {
              "#{before_text}```\ncode block\n```#{after_text}",
              selection_start + 4,
              selection_start + 14
            }
          end
        "h1" ->
          if has_selection do
            {
              "#{before_text}# #{selected_text}#{after_text}",
              selection_start,
              selection_end + 2
            }
          else
            {
              "#{before_text}# Heading 1#{after_text}",
              selection_start + 2,
              selection_start + 11
            }
          end
        "h2" ->
          if has_selection do
            {
              "#{before_text}## #{selected_text}#{after_text}",
              selection_start,
              selection_end + 3
            }
          else
            {
              "#{before_text}## Heading 2#{after_text}",
              selection_start + 3,
              selection_start + 12
            }
          end
        "h3" ->
          if has_selection do
            {
              "#{before_text}### #{selected_text}#{after_text}",
              selection_start,
              selection_end + 4
            }
          else
            {
              "#{before_text}### Heading 3#{after_text}",
              selection_start + 4,
              selection_start + 13
            }
          end
        "quote" ->
          if has_selection do
            {
              "#{before_text}> #{selected_text}#{after_text}",
              selection_start,
              selection_end + 2
            }
          else
            {
              "#{before_text}> Blockquote#{after_text}",
              selection_start + 2,
              selection_start + 12
            }
          end
        "link" ->
          if has_selection do
            {
              "#{before_text}[#{selected_text}](https://example.com)#{after_text}",
              selection_start,
              selection_end + 21
            }
          else
            {
              "#{before_text}[link text](https://example.com)#{after_text}",
              selection_start + 1,
              selection_start + 10
            }
          end
        "bullet_list" ->
          if has_selection do
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
          else
            {
              "#{before_text}\n- List item 1\n- List item 2\n- List item 3#{after_text}",
              selection_start + 3,
              selection_start + 14
            }
          end
        "numbered_list" ->
          if has_selection do
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
          else
            {
              "#{before_text}\n1. List item 1\n2. List item 2\n3. List item 3#{after_text}",
              selection_start + 3,
              selection_start + 14
            }
          end
        _ ->
          {text, selection_start, selection_end}
      end

    # Parse the new markdown to update the preview
    {:ok, html, _warnings} = Earmark.as_html(new_text, %Earmark.Options{code_class_prefix: "language-"})

    # Update the socket assigns with the new text and HTML
    socket = assign(socket, %{
      markdown: new_text,
      html: html,
      selection_start: new_selection_start,
      selection_end: new_selection_end
    })

    # Push the updated markdown content to the client
    # This ensures the textarea is updated with the new text
    socket = push_event(socket, "update_markdown_content", %{
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

  @impl true
  def render(assigns) do
    ~H"""
    <div class="markdown-editor" phx-hook="MarkdownEditor" id="markdown-editor">
      <div class="container mx-auto p-4">
        <h1 class="text-2xl font-bold mb-4">Markdown Editor</h1>

        <div class="flex flex-col md:flex-row gap-6">
          <!-- Editor Section -->
          <div class="w-full md:w-1/2">
            <div class="bg-gray-50 border border-gray-300 rounded-md overflow-hidden">
              <div class="toolbar bg-gray-100 p-2 border-b border-gray-300 flex flex-wrap gap-1">
                <button
                  phx-click="insert_format"
                  phx-value-format="h1"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Heading 1"
                >
                  H1
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="h2"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Heading 2"
                >
                  H2
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="h3"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Heading 3"
                >
                  H3
                </button>
                <span class="mx-1 text-gray-300">|</span>
                <button
                  phx-click="insert_format"
                  phx-value-format="bold"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200 font-bold"
                  title="Bold"
                >
                  B
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="italic"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200 italic"
                  title="Italic"
                >
                  I
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="strikethrough"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200 line-through"
                  title="Strikethrough"
                >
                  S
                </button>
                <span class="mx-1 text-gray-300">|</span>
                <button
                  phx-click="insert_format"
                  phx-value-format="code"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200 font-mono"
                  title="Inline Code"
                >
                  `code`
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="code_block"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200 font-mono"
                  title="Code Block"
                >
                  ```
                </button>
                <span class="mx-1 text-gray-300">|</span>
                <button
                  phx-click="insert_format"
                  phx-value-format="quote"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Blockquote"
                >
                  Quote
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="link"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Link"
                >
                  Link
                </button>
                <span class="mx-1 text-gray-300">|</span>
                <button
                  phx-click="insert_format"
                  phx-value-format="bullet_list"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Bullet List"
                >
                  • List
                </button>
                <button
                  phx-click="insert_format"
                  phx-value-format="numbered_list"
                  class="toolbar-btn p-1 rounded hover:bg-gray-200"
                  title="Numbered List"
                >
                  1. List
                </button>
              </div>

              <div class="p-4">
                <form phx-change="update_markdown" phx-submit="update_markdown" class="mb-0">
                  <textarea
                    name="markdown"
                    id="markdown-input"
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
                  <p class="pl-2 font-mono">```<br>code block<br>```</p>

                  <p class="font-medium mt-2">Lists:</p>
                  <p class="pl-2 font-mono">- Item 1<br>- Item 2</p>
                  <p class="pl-2 font-mono">1. Item 1<br>2. Item 2</p>

                  <p class="font-medium mt-2">Links:</p>
                  <p class="pl-2 font-mono">[Link text](URL)</p>

                  <p class="font-medium mt-2">Blockquotes:</p>
                  <p class="pl-2 font-mono">> This is a quote</p>

                  <p class="font-medium mt-2">Keyboard Shortcuts:</p>
                  <p class="pl-2">Ctrl+B = Bold</p>
                  <p class="pl-2">Ctrl+I = Italic</p>
                  <p class="pl-2">Ctrl+K = Link</p>
                  <p class="pl-2 font-semibold text-blue-600 mt-2">Tip: Select text first, then apply formatting!</p>
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
              <div id="markdown-preview" class="markdown-preview prose prose-sm md:prose max-w-none p-6 overflow-auto min-h-[30rem]">
                <%= if @html == "" do %>
                  <div class="text-gray-400 italic flex items-center justify-center h-full">
                    <p>Preview will appear here...</p>
                  </div>
                <% else %>
                  <%= raw(@html) %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
