defmodule BlogWeb.MarkdownEditorLive do
  @moduledoc """
  LiveView for the markdown editor page.

  Renders the WinXP-themed window chrome and delegates editing
  to the MarkdownEditorComponent. Handles cursor/selection tracking
  and format insertion events forwarded from the component.
  """

  use BlogWeb, :live_view

  alias BlogWeb.MarkdownEditor.Formatter
  alias BlogWeb.MarkdownEditorComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       markdown: "",
       html: "",
       page_title: "Markdown Editor",
       cursor_position: 0,
       selection_start: 0,
       selection_end: 0,
       selected_text: ""
     })}
  end

  @impl true
  def handle_info({:markdown_updated, %{markdown: markdown, html: html}}, socket) do
    {:noreply, assign(socket, markdown: markdown, html: html)}
  end

  @impl true
  def handle_event("update_markdown", %{"markdown" => markdown}, socket) do
    case Formatter.to_html(markdown) do
      {:ok, html} ->
        {:noreply, assign(socket, %{markdown: markdown, html: html})}

      {:error, _reason} ->
        {:noreply, assign(socket, %{markdown: markdown})}
    end
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
    %{
      markdown: text,
      selection_start: selection_start,
      selection_end: selection_end,
      selected_text: selected_text
    } = socket.assigns

    has_selection = selection_start != selection_end
    {before_text, after_text} = Formatter.split_text(text, selection_start, selection_end)

    {new_text, new_selection_start, new_selection_end} =
      Formatter.apply_format(
        format,
        before_text,
        after_text,
        selection_start,
        selection_end,
        selected_text,
        has_selection
      )

    case Formatter.to_html(new_text) do
      {:ok, html} ->
        socket =
          socket
          |> assign(%{
            markdown: new_text,
            html: html,
            selection_start: new_selection_start,
            selection_end: new_selection_end
          })
          |> push_event("update_markdown_content", %{
            content: new_text,
            selectionStart: new_selection_start,
            selectionEnd: new_selection_end
          })

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-winxp">
      <div class="os-window os-window-winxp markdown-editor-window">
        <div class="os-titlebar">
          <span class="os-titlebar-title">Markdown Editor - Untitled Document</span>
          <div class="os-titlebar-buttons">
            <div class="os-btn-min"></div>
            <div class="os-btn-max"></div>
            <a href="/" class="os-btn-close"></a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>Edit</span>
          <span>Format</span>
          <span>View</span>
          <span>Help</span>
        </div>
        <div class="os-content markdown-editor-content">
          <div class="p-4">
            <.live_component
              module={MarkdownEditorComponent}
              id="markdown-editor"
              markdown={@markdown}
              html={@html}
            />
          </div>
        </div>
        <div class="os-statusbar">
          <span>Characters: {String.length(@markdown)}</span>
          <span>Markdown Mode</span>
        </div>
      </div>
    </div>
    """
  end
end
