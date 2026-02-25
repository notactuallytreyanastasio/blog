defmodule BlogWeb.MarkdownEditorComponent do
  @moduledoc """
  LiveComponent for the markdown editor with toolbar, textarea, and live preview.

  Handles markdown input, toolbar formatting actions, and renders a split-pane
  editor/preview layout. Uses `BlogWeb.MarkdownEditor.Formatter` for all
  text formatting and markdown-to-HTML conversion.
  """

  use BlogWeb, :live_component

  alias BlogWeb.MarkdownEditor.Formatter

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
    case Formatter.to_html(markdown) do
      {:ok, html} ->
        send(self(), {:markdown_updated, %{markdown: markdown, html: html}})
        {:noreply, assign(socket, %{markdown: markdown, html: html})}

      {:error, _reason} ->
        {:noreply, assign(socket, %{markdown: markdown})}
    end
  end

  @impl true
  def handle_event("insert_format", %{"format" => format}, socket) do
    text = socket.assigns.markdown
    selection_start = 0
    selection_end = 0

    {before_text, after_text} = Formatter.split_text(text, selection_start, selection_end)

    {new_text, _new_selection_start, _new_selection_end} =
      Formatter.apply_format(
        format,
        before_text,
        after_text,
        selection_start,
        selection_end,
        "",
        false
      )

    case Formatter.to_html(new_text) do
      {:ok, html} ->
        send(self(), {:markdown_updated, %{markdown: new_text, html: html}})

        socket =
          socket
          |> assign(%{markdown: new_text, html: html})
          |> push_event("update_markdown_content", %{content: new_text})

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="markdown-editor" phx-hook="MarkdownEditor" id={@id}>
      <div class="flex flex-col md:flex-row gap-6">
        <!-- Editor Section -->
        <div class="w-full md:w-1/2">
          <div class="bg-gray-50 border border-gray-300 rounded-md overflow-hidden">
            <.toolbar myself={@myself} />

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
            <.cheatsheet />
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

  defp toolbar(assigns) do
    ~H"""
    <div class="toolbar bg-gray-100 p-2 border-b border-gray-300 flex flex-wrap gap-1">
      <.toolbar_button format="h1" target={@myself} title="Heading 1" label="H1" />
      <.toolbar_button format="h2" target={@myself} title="Heading 2" label="H2" />
      <.toolbar_button format="h3" target={@myself} title="Heading 3" label="H3" />
      <.separator />
      <.toolbar_button format="bold" target={@myself} title="Bold" label="B" class="font-bold" />
      <.toolbar_button
        format="italic"
        target={@myself}
        title="Italic"
        label="I"
        class="italic"
      />
      <.toolbar_button
        format="strikethrough"
        target={@myself}
        title="Strikethrough"
        label="S"
        class="line-through"
      />
      <.separator />
      <.toolbar_button
        format="code"
        target={@myself}
        title="Inline Code"
        label="`code`"
        class="font-mono"
      />
      <.toolbar_button
        format="code_block"
        target={@myself}
        title="Code Block"
        label="```"
        class="font-mono"
      />
      <.separator />
      <.toolbar_button format="quote" target={@myself} title="Blockquote" label="Quote" />
      <.toolbar_button format="link" target={@myself} title="Link" label="Link" />
      <.separator />
      <.toolbar_button format="bullet_list" target={@myself} title="Bullet List" label="* List" />
      <.toolbar_button
        format="numbered_list"
        target={@myself}
        title="Numbered List"
        label="1. List"
      />
    </div>
    """
  end

  attr :format, :string, required: true
  attr :target, :any, required: true
  attr :title, :string, required: true
  attr :label, :string, required: true
  attr :class, :string, default: ""

  defp toolbar_button(assigns) do
    ~H"""
    <button
      phx-click="insert_format"
      phx-value-format={@format}
      phx-target={@target}
      class={"toolbar-btn p-1 rounded hover:bg-gray-200 #{@class}"}
      title={@title}
    >
      {@label}
    </button>
    """
  end

  defp separator(assigns) do
    ~H"""
    <span class="mx-1 text-gray-300">|</span>
    """
  end

  defp cheatsheet(assigns) do
    ~H"""
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
    """
  end
end
