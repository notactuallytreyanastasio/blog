defmodule BlogWeb.EditorLive do
  use BlogWeb, :live_view

  alias Blog.Editor
  alias Blog.Editor.Draft

  @save_debounce_ms 2000

  def mount(%{"id" => id}, _session, socket) do
    case Editor.get_draft(id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/editor")}

      draft ->
        {:ok,
         socket
         |> assign(:draft, draft)
         |> assign(:content, draft.content || "")
         |> assign(:title, draft.title || "")
         |> assign(:preview_html, Editor.render_markdown(draft.content))
         |> assign(:last_saved, draft.updated_at)
         |> assign(:saving, false)
         |> assign(:show_preview, true)}
    end
  end

  def mount(_params, _session, socket) do
    # Create a new draft
    {:ok, draft} = Editor.create_draft(%{content: "", title: "Untitled"})

    {:ok,
     socket
     |> assign(:draft, draft)
     |> assign(:content, "")
     |> assign(:title, "Untitled")
     |> assign(:preview_html, "")
     |> assign(:last_saved, draft.updated_at)
     |> assign(:saving, false)
     |> assign(:show_preview, true)
     |> push_patch(to: ~p"/editor/#{draft.id}")}
  end

  def handle_params(%{"id" => _id}, _uri, socket) do
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  # Handle content changes with debounce for auto-save
  def handle_event("update_content", %{"content" => content}, socket) do
    # Update preview immediately
    preview_html = Editor.render_markdown(content)

    # Schedule save after debounce
    if socket.assigns[:save_timer] do
      Process.cancel_timer(socket.assigns.save_timer)
    end

    timer = Process.send_after(self(), :save_draft, @save_debounce_ms)

    {:noreply,
     socket
     |> assign(:content, content)
     |> assign(:preview_html, preview_html)
     |> assign(:save_timer, timer)
     |> assign(:saving, true)}
  end

  def handle_event("update_title", %{"title" => title}, socket) do
    # Schedule save after debounce
    if socket.assigns[:save_timer] do
      Process.cancel_timer(socket.assigns.save_timer)
    end

    timer = Process.send_after(self(), :save_draft, @save_debounce_ms)

    {:noreply,
     socket
     |> assign(:title, title)
     |> assign(:save_timer, timer)
     |> assign(:saving, true)}
  end

  def handle_event("toggle_preview", _, socket) do
    {:noreply, assign(socket, :show_preview, !socket.assigns.show_preview)}
  end

  def handle_event("insert_image", %{"data" => data_url}, socket) do
    # Insert image at cursor position (JS will handle cursor, we just append for now)
    image_md = "\n![image](#{data_url})\n"
    new_content = socket.assigns.content <> image_md

    preview_html = Editor.render_markdown(new_content)

    # Trigger save
    if socket.assigns[:save_timer] do
      Process.cancel_timer(socket.assigns.save_timer)
    end

    timer = Process.send_after(self(), :save_draft, @save_debounce_ms)

    {:noreply,
     socket
     |> assign(:content, new_content)
     |> assign(:preview_html, preview_html)
     |> assign(:save_timer, timer)
     |> assign(:saving, true)}
  end

  def handle_event("publish", _, socket) do
    case Editor.publish_draft(socket.assigns.draft) do
      {:ok, draft} ->
        {:noreply,
         socket
         |> assign(:draft, draft)
         |> put_flash(:info, "Published!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to publish")}
    end
  end

  def handle_event("new_draft", _, socket) do
    {:ok, draft} = Editor.create_draft(%{content: "", title: "Untitled"})

    {:noreply,
     socket
     |> assign(:draft, draft)
     |> assign(:content, "")
     |> assign(:title, "Untitled")
     |> assign(:preview_html, "")
     |> assign(:last_saved, draft.updated_at)
     |> push_patch(to: ~p"/editor/#{draft.id}")}
  end

  # Handle the debounced save
  def handle_info(:save_draft, socket) do
    case Editor.update_draft(socket.assigns.draft, %{
           content: socket.assigns.content,
           title: socket.assigns.title
         }) do
      {:ok, draft} ->
        {:noreply,
         socket
         |> assign(:draft, draft)
         |> assign(:last_saved, draft.updated_at)
         |> assign(:saving, false)
         |> assign(:save_timer, nil)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:saving, false)
         |> assign(:save_timer, nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mac-editor">
      <!-- Menu Bar -->
      <div class="mac-menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <a href="/" class="menu-item" style="text-decoration: none; color: inherit;">Home</a>
          <span class="menu-item" phx-click="new_draft" style="cursor: pointer;">New</span>
          <span class="menu-item" phx-click="toggle_preview" style="cursor: pointer;">
            <%= if @show_preview, do: "Hide Preview", else: "Show Preview" %>
          </span>
        </div>
        <div class="menu-right">
          <span class="save-status">
            <%= if @saving do %>
              Saving...
            <% else %>
              Saved <%= format_time(@last_saved) %>
            <% end %>
          </span>
        </div>
      </div>

      <!-- Desktop -->
      <div class="editor-desktop">
        <!-- Editor Window -->
        <div class={"editor-window #{if @show_preview, do: "half", else: "full"}"}>
          <div class="mac-title-bar">
            <div class="mac-close-box"></div>
            <div class="mac-title">Editor - <%= @draft.slug %></div>
            <div class="mac-resize-box"></div>
          </div>
          <div class="editor-content">
            <input
              type="text"
              class="title-input"
              value={@title}
              placeholder="Post title..."
              phx-blur="update_title"
              phx-keyup="update_title"
              phx-debounce="500"
              name="title"
            />
            <textarea
              id="markdown-editor"
              class="markdown-textarea"
              phx-hook="MarkdownEditor"
              phx-blur="update_content"
              phx-keyup="update_content"
              phx-debounce="300"
              name="content"
              placeholder="Write your markdown here...

# Headings
**bold** and *italic*

- Lists
- Are easy

```elixir
code_blocks(:work)
```

Embed Bluesky posts:
::bsky[https://bsky.app/profile/user/post/abc]

Paste images directly!"
            ><%= @content %></textarea>
          </div>
          <div class="mac-status-bar">
            <span><%= String.length(@content) %> chars</span>
            <span><%= word_count(@content) %> words</span>
          </div>
        </div>

        <!-- Preview Window -->
        <%= if @show_preview do %>
          <div class="preview-window">
            <div class="mac-title-bar">
              <div class="mac-close-box" phx-click="toggle_preview"></div>
              <div class="mac-title">Preview</div>
              <div class="mac-resize-box"></div>
            </div>
            <div class="preview-content">
              <h1 class="preview-title"><%= @title %></h1>
              <div class="preview-body">
                <%= raw(@preview_html) %>
              </div>
            </div>
            <div class="mac-status-bar">
              <span><%= @draft.status %></span>
              <button class="publish-btn" phx-click="publish">
                <%= if @draft.status == "published", do: "Republish", else: "Publish" %>
              </button>
            </div>
          </div>
        <% end %>
      </div>
    </div>

    <style>
      .mac-editor {
        height: 100vh;
        background: #a8a8a8;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        overflow: hidden;
      }

      .mac-editor .mac-menu-bar {
        height: 20px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
      }

      .mac-editor .menu-left {
        display: flex;
        gap: 16px;
      }

      .mac-editor .apple-menu {
        font-family: system-ui;
        font-size: 14px;
      }

      .mac-editor .menu-item {
        cursor: default;
      }

      .mac-editor .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .mac-editor .menu-right {
        font-size: 11px;
      }

      .save-status {
        color: #666;
      }

      .editor-desktop {
        height: calc(100vh - 20px);
        padding: 20px;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
        display: flex;
        gap: 20px;
      }

      .editor-window {
        background: #fff;
        border: 1px solid #000;
        box-shadow: 2px 2px 0 #000;
        display: flex;
        flex-direction: column;
      }

      .editor-window.half {
        width: 50%;
      }

      .editor-window.full {
        width: 100%;
      }

      .preview-window {
        width: 50%;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 2px 2px 0 #000;
        display: flex;
        flex-direction: column;
      }

      .mac-title-bar {
        height: 20px;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 4px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px,
          #fff 1px,
          #000 1px,
          #000 2px,
          #fff 2px,
          #fff 3px
        );
        flex-shrink: 0;
      }

      .mac-close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
        cursor: pointer;
      }

      .mac-close-box:hover {
        background: #000;
      }

      .mac-title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .mac-resize-box {
        width: 12px;
        height: 12px;
      }

      .editor-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        overflow: hidden;
      }

      .title-input {
        border: none;
        border-bottom: 1px solid #ccc;
        padding: 12px;
        font-size: 18px;
        font-weight: bold;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        outline: none;
      }

      .title-input:focus {
        border-bottom-color: #000;
      }

      .markdown-textarea {
        flex: 1;
        border: none;
        padding: 12px;
        font-family: 'Monaco', 'Courier New', monospace;
        font-size: 14px;
        line-height: 1.6;
        resize: none;
        outline: none;
      }

      .markdown-textarea::placeholder {
        color: #999;
      }

      .mac-status-bar {
        height: 24px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
        flex-shrink: 0;
      }

      .publish-btn {
        background: #000;
        color: #fff;
        border: none;
        padding: 2px 8px;
        font-size: 10px;
        cursor: pointer;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
      }

      .publish-btn:hover {
        background: #333;
      }

      .preview-content {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
      }

      .preview-title {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 1px solid #ccc;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
      }

      .preview-body {
        font-family: 'Charter', 'Georgia', serif;
        font-size: 16px;
        line-height: 1.7;
      }

      .preview-body h1, .preview-body h2, .preview-body h3 {
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        margin: 1.5rem 0 0.75rem 0;
      }

      .preview-body pre {
        background: #1f2937;
        padding: 1rem;
        border-radius: 4px;
        overflow-x: auto;
        border: 1px solid #000;
      }

      .preview-body code {
        font-family: 'Monaco', 'Courier New', monospace;
        font-size: 0.9em;
      }

      .preview-body :not(pre) > code {
        background: #e0e0e0;
        padding: 2px 4px;
        border-radius: 2px;
      }

      .preview-body img {
        max-width: 100%;
        height: auto;
        border: 1px solid #000;
      }

      .preview-body a {
        color: #000;
        text-decoration: underline;
      }

      .preview-body a:hover {
        background: #000;
        color: #fff;
      }

      /* Bluesky embed styles */
      .bsky-embed {
        border: 1px solid #ccc;
        border-radius: 8px;
        padding: 12px;
        margin: 1rem 0;
        background: #f8fafc;
      }

      .bsky-embed-header {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 8px;
      }

      .bsky-icon {
        font-size: 18px;
      }

      .bsky-embed-header a {
        color: #1185fe;
        text-decoration: none;
        font-weight: 500;
      }

      .bsky-embed-loading {
        color: #666;
        font-style: italic;
      }

      @media (max-width: 900px) {
        .editor-desktop {
          flex-direction: column;
          padding: 10px;
        }

        .editor-window.half,
        .editor-window.full,
        .preview-window {
          width: 100%;
          height: 50%;
        }
      }
    </style>
    """
  end

  defp format_time(nil), do: "never"

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end

  defp word_count(nil), do: 0
  defp word_count(""), do: 0

  defp word_count(content) do
    content
    |> String.split(~r/\s+/, trim: true)
    |> length()
  end
end
