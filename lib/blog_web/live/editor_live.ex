defmodule BlogWeb.EditorLive do
  use BlogWeb, :live_view

  alias Blog.Editor
  alias Blog.Editor.Draft

  @save_debounce_ms 2000

  def mount(%{"id" => id}, _session, socket) do
    case Editor.get_draft(id) do
      nil ->
        {:ok,
         socket
         |> assign(:error, nil)
         |> assign(:draft, nil)
         |> push_navigate(to: ~p"/editor")}

      draft ->
        {:ok,
         socket
         |> assign(:draft, draft)
         |> assign(:content, draft.content || "")
         |> assign(:title, draft.title || "")
         |> assign(:author_name, draft.author_name || "")
         |> assign(:author_email, draft.author_email || "")
         |> assign(:preview_html, Editor.render_markdown(draft.content))
         |> assign(:last_saved, draft.updated_at)
         |> assign(:saving, false)
         |> assign(:show_preview, true)
         |> assign(:show_publish_dialog, false)
         |> assign(:publish_error, nil)
         |> assign(:cursor_line, 1)
         |> assign(:cursor_col, 1)
         |> assign(:error, nil)}
    end
  end

  def mount(_params, _session, socket) do
    try do
      case Editor.create_draft(%{content: "", title: "Untitled"}) do
        {:ok, draft} ->
          {:ok,
           socket
           |> assign(:draft, draft)
           |> assign(:content, "")
           |> assign(:title, "Untitled")
           |> assign(:author_name, "")
           |> assign(:author_email, "")
           |> assign(:preview_html, "")
           |> assign(:last_saved, draft.updated_at)
           |> assign(:saving, false)
           |> assign(:show_preview, true)
           |> assign(:show_publish_dialog, false)
           |> assign(:publish_error, nil)
           |> assign(:cursor_line, 1)
           |> assign(:cursor_col, 1)
           |> assign(:error, nil)
           |> push_navigate(to: ~p"/editor/#{draft.id}")}

        {:error, changeset} ->
          require Logger
          error_msg = inspect(changeset.errors)
          Logger.error("Failed to create draft: #{error_msg}")
          {:ok, error_socket(socket, "Failed to create draft: #{error_msg}")}
      end
    rescue
      e ->
        require Logger
        Logger.error("Exception in editor mount: #{Exception.message(e)}")
        {:ok, error_socket(socket, "Exception: #{Exception.message(e)}")}
    end
  end

  defp error_socket(socket, error_msg) do
    socket
    |> assign(:error, error_msg)
    |> assign(:draft, %Draft{status: "draft"})
    |> assign(:content, "")
    |> assign(:title, "")
    |> assign(:author_name, "")
    |> assign(:author_email, "")
    |> assign(:preview_html, "")
    |> assign(:last_saved, nil)
    |> assign(:saving, false)
    |> assign(:show_preview, false)
    |> assign(:show_publish_dialog, false)
    |> assign(:publish_error, nil)
    |> assign(:cursor_line, 1)
    |> assign(:cursor_col, 1)
  end

  def handle_params(%{"id" => _id}, _uri, socket), do: {:noreply, socket}
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def handle_event("update_content", %{"value" => content}, socket) do
    preview_html = Editor.render_markdown(content)

    if socket.assigns[:save_timer], do: Process.cancel_timer(socket.assigns.save_timer)
    timer = Process.send_after(self(), :save_draft, @save_debounce_ms)

    {:noreply,
     socket
     |> assign(:content, content)
     |> assign(:preview_html, preview_html)
     |> assign(:save_timer, timer)
     |> assign(:saving, true)}
  end

  def handle_event("update_title", params, socket) do
    title = params["value"] || params["title"] || ""
    if socket.assigns[:save_timer], do: Process.cancel_timer(socket.assigns.save_timer)
    timer = Process.send_after(self(), :save_draft, @save_debounce_ms)

    {:noreply,
     socket
     |> assign(:title, title)
     |> assign(:save_timer, timer)
     |> assign(:saving, true)}
  end

  def handle_event("update_cursor", %{"line" => line, "col" => col}, socket) do
    {:noreply, assign(socket, cursor_line: line, cursor_col: col)}
  end

  def handle_event("toggle_preview", _, socket) do
    {:noreply, assign(socket, :show_preview, !socket.assigns.show_preview)}
  end

  def handle_event("format", %{"type" => type}, socket) do
    {:noreply, push_event(socket, "apply_format", %{type: type})}
  end

  def handle_event("show_publish_dialog", _, socket) do
    {:noreply, assign(socket, show_publish_dialog: true, publish_error: nil)}
  end

  def handle_event("hide_publish_dialog", _, socket) do
    {:noreply, assign(socket, show_publish_dialog: false)}
  end

  def handle_event("update_author", %{"name" => name, "email" => email}, socket) do
    {:noreply, assign(socket, author_name: name, author_email: email)}
  end

  def handle_event("publish", %{"name" => name, "email" => email}, socket) do
    title = String.trim(socket.assigns.title || "")

    if title == "" or title == "Untitled" do
      {:noreply, assign(socket, publish_error: "Please enter a title for your post")}
    else
      attrs = %{
        title: title,
        content: socket.assigns.content,
        author_name: String.trim(name),
        author_email: String.trim(email)
      }

      case Editor.publish_draft(socket.assigns.draft, attrs) do
      {:ok, draft} ->
        {:noreply,
         socket
         |> assign(:draft, draft)
         |> assign(:author_name, draft.author_name)
         |> assign(:author_email, draft.author_email)
         |> assign(:show_publish_dialog, false)
         |> put_flash(:info, "Published! Your post is now live.")}

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
        error_msg = errors |> Enum.map(fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end) |> Enum.join("; ")
        {:noreply, assign(socket, publish_error: error_msg)}
      end
    end
  end

  def handle_event("new_draft", _, socket) do
    {:ok, draft} = Editor.create_draft(%{content: "", title: "Untitled"})

    {:noreply,
     socket
     |> assign(:draft, draft)
     |> assign(:content, "")
     |> assign(:title, "Untitled")
     |> assign(:author_name, "")
     |> assign(:author_email, "")
     |> assign(:preview_html, "")
     |> assign(:last_saved, draft.updated_at)
     |> push_patch(to: ~p"/editor/#{draft.id}")}
  end

  def handle_info(:save_draft, socket) do
    case Editor.update_draft(socket.assigns.draft, %{
           content: socket.assigns.content,
           title: socket.assigns.title,
           author_name: socket.assigns.author_name,
           author_email: socket.assigns.author_email
         }) do
      {:ok, draft} ->
        {:noreply,
         socket
         |> assign(:draft, draft)
         |> assign(:last_saved, draft.updated_at)
         |> assign(:saving, false)
         |> assign(:save_timer, nil)}

      {:error, _} ->
        {:noreply, assign(socket, saving: false, save_timer: nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <%= if assigns[:error] do %>
      <div style="padding: 40px; max-width: 600px; margin: 0 auto; font-family: monospace;">
        <h1 style="color: red;">Editor Error</h1>
        <pre style="background: #f0f0f0; padding: 20px; overflow: auto;"><%= @error %></pre>
        <a href="/" style="color: blue;">Return to homepage</a>
      </div>
    <% else %>
    <div class="mac-editor-retro">
      <!-- Menu Bar -->
      <div class="menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">Format</span>
          <a href="/" class="menu-item">Home</a>
        </div>
        <div class="menu-right">
          <span class={"save-indicator #{if @saving, do: "saving"}"}>
            <%= if @saving, do: "●", else: "○" %>
          </span>
          <%= format_time(@last_saved) %>
        </div>
      </div>

      <!-- Desktop with windows -->
      <div class="desktop">
        <!-- Editor Window -->
        <div class={"editor-window #{if @show_preview, do: "with-preview"}"}>
          <div class="window-titlebar">
            <div class="window-controls">
              <a href="/" class="control-btn close"></a>
              <span class="control-btn minimize"></span>
              <span class="control-btn zoom" phx-click="toggle_preview"></span>
            </div>
            <div class="window-title"><%= @title || "Untitled" %></div>
          </div>

          <!-- Toolbar -->
          <div class="toolbar">
            <div class="toolbar-group">
              <button class="toolbar-btn" phx-click="format" phx-value-type="bold" title="Bold (⌘B)">
                <span class="toolbar-icon">B</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="italic" title="Italic (⌘I)">
                <span class="toolbar-icon italic">I</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="underline" title="Underline">
                <span class="toolbar-icon underline">U</span>
              </button>
            </div>
            <div class="toolbar-divider"></div>
            <div class="toolbar-group">
              <button class="toolbar-btn" phx-click="format" phx-value-type="h1" title="Heading 1">
                <span class="toolbar-icon">H1</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="h2" title="Heading 2">
                <span class="toolbar-icon">H2</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="h3" title="Heading 3">
                <span class="toolbar-icon">H3</span>
              </button>
            </div>
            <div class="toolbar-divider"></div>
            <div class="toolbar-group">
              <button class="toolbar-btn" phx-click="format" phx-value-type="bullet" title="Bullet List">
                <span class="toolbar-icon">•</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="number" title="Numbered List">
                <span class="toolbar-icon">1.</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="quote" title="Quote">
                <span class="toolbar-icon">"</span>
              </button>
            </div>
            <div class="toolbar-divider"></div>
            <div class="toolbar-group">
              <button class="toolbar-btn" phx-click="format" phx-value-type="code" title="Code">
                <span class="toolbar-icon">&lt;/&gt;</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="link" title="Link (⌘K)">
                <span class="toolbar-icon">🔗</span>
              </button>
              <button class="toolbar-btn" phx-click="format" phx-value-type="image" title="Image">
                <span class="toolbar-icon">🖼</span>
              </button>
            </div>
            <div class="toolbar-spacer"></div>
            <div class="toolbar-group">
              <button class="toolbar-btn preview-btn" phx-click="toggle_preview">
                <%= if @show_preview, do: "Hide Preview", else: "Show Preview" %>
              </button>
            </div>
          </div>

          <!-- Ruler -->
          <div class="ruler">
            <div class="ruler-numbers">
              <%= for i <- 0..11 do %>
                <span class="ruler-mark"><%= i %></span>
              <% end %>
            </div>
          </div>

          <!-- Title input -->
          <div class="title-bar">
            <input
              type="text"
              class="title-input"
              value={@title}
              placeholder="Enter title..."
              phx-blur="update_title"
              phx-keyup="update_title"
              phx-debounce="500"
              name="title"
            />
          </div>

          <!-- Editor area -->
          <div class="editor-container">
            <div class="line-numbers" id="line-numbers"></div>
            <textarea
              id="markdown-editor"
              class="editor-textarea"
              phx-hook="MarkdownEditor"
              phx-blur="update_content"
              phx-keyup="update_content"
              phx-debounce="300"
              name="content"
              placeholder="Start writing...

Tip: Paste images directly into the editor!
Use ::bsky[url] to embed Bluesky posts."
              spellcheck="true"
            ><%= @content %></textarea>
          </div>

          <!-- Status bar -->
          <div class="status-bar">
            <span class="status-item">Ln <%= @cursor_line %>, Col <%= @cursor_col %></span>
            <span class="status-item"><%= word_count(@content) %> words</span>
            <span class="status-item"><%= String.length(@content) %> chars</span>
            <span class="status-spacer"></span>
            <span class={"status-item status-#{@draft.status}"}><%= @draft.status %></span>
          </div>
        </div>

        <!-- Preview Window -->
        <%= if @show_preview do %>
          <div class="preview-window">
            <div class="window-titlebar">
              <div class="window-controls">
                <span class="control-btn close" phx-click="toggle_preview"></span>
                <span class="control-btn minimize"></span>
                <span class="control-btn zoom"></span>
              </div>
              <div class="window-title">Preview</div>
            </div>
            <div class="preview-container">
              <article class="preview-content">
                <h1 class="preview-title"><%= @title %></h1>
                <div class="preview-body">
                  <%= raw(@preview_html) %>
                </div>
              </article>
            </div>
            <div class="preview-footer">
              <button class="publish-btn" phx-click="show_publish_dialog">
                <%= if @draft.status == "published", do: "Update Post", else: "Publish Post" %>
              </button>
              <button class="new-btn" phx-click="new_draft">New Draft</button>
            </div>
          </div>
        <% end %>
      </div>

      <!-- Publish Dialog -->
      <%= if @show_publish_dialog do %>
        <div class="dialog-overlay" phx-click="hide_publish_dialog">
          <div class="publish-dialog" phx-click-away="hide_publish_dialog">
            <div class="dialog-titlebar">
              <span>Publish Your Post</span>
              <button class="dialog-close" phx-click="hide_publish_dialog">×</button>
            </div>
            <div class="dialog-content">
              <p class="dialog-intro">
                Anyone can publish here! Just tell us who you are:
              </p>

              <%= if @publish_error do %>
                <div class="dialog-error"><%= @publish_error %></div>
              <% end %>

              <form phx-submit="publish">
                <div class="form-group">
                  <label>Your Name</label>
                  <input type="text" name="name" value={@author_name} placeholder="Jane Doe" required />
                </div>
                <div class="form-group">
                  <label>Your Email</label>
                  <input type="email" name="email" value={@author_email} placeholder="jane@example.com" required />
                  <span class="form-hint">Won't be displayed publicly, just for attribution</span>
                </div>
                <div class="dialog-buttons">
                  <button type="button" class="btn-cancel" phx-click="hide_publish_dialog">Cancel</button>
                  <button type="submit" class="btn-publish">Publish Now</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    <% end %>

    <style>
      @font-face {
        font-family: 'Chicago';
        src: local('Chicago'), local('ChicagoFLF');
      }

      .mac-editor-retro {
        height: 100vh;
        background: #666699;
        font-family: 'Chicago', 'Geneva', 'Helvetica Neue', sans-serif;
        font-size: 12px;
        overflow: hidden;
        -webkit-font-smoothing: none;
      }

      /* Menu Bar */
      .menu-bar {
        height: 20px;
        background: linear-gradient(to bottom, #fff 0%, #ccc 100%);
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        box-shadow: 0 1px 0 #fff inset;
      }

      .menu-left {
        display: flex;
        gap: 16px;
        align-items: center;
      }

      .apple-menu {
        font-size: 14px;
      }

      .menu-item {
        cursor: default;
        padding: 0 4px;
        text-decoration: none;
        color: #000;
      }

      .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .menu-right {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 11px;
      }

      .save-indicator {
        font-size: 10px;
        color: #090;
      }

      .save-indicator.saving {
        color: #f90;
        animation: pulse 1s infinite;
      }

      @keyframes pulse {
        50% { opacity: 0.5; }
      }

      /* Desktop */
      .desktop {
        height: calc(100vh - 20px);
        padding: 20px;
        display: flex;
        gap: 16px;
        background: linear-gradient(135deg, #666699 0%, #336699 100%);
      }

      /* Editor Window */
      .editor-window {
        flex: 1;
        background: #fff;
        border: 2px solid #000;
        border-radius: 8px 8px 0 0;
        box-shadow: 2px 2px 8px rgba(0,0,0,0.4), inset 0 0 0 1px #fff;
        display: flex;
        flex-direction: column;
        overflow: hidden;
      }

      .editor-window.with-preview {
        flex: 1;
      }

      /* Window titlebar - classic Mac platinum look */
      .window-titlebar {
        height: 22px;
        background: linear-gradient(to bottom, #eee 0%, #ccc 50%, #ddd 100%);
        border-bottom: 1px solid #999;
        display: flex;
        align-items: center;
        padding: 0 8px;
        border-radius: 6px 6px 0 0;
      }

      .window-controls {
        display: flex;
        gap: 6px;
        margin-right: 12px;
      }

      .control-btn {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        border: 1px solid #666;
        cursor: pointer;
      }

      .control-btn.close {
        background: linear-gradient(to bottom, #ff6b6b, #ee5a5a);
        border-color: #c44;
      }

      .control-btn.minimize {
        background: linear-gradient(to bottom, #ffbd44, #f0ad30);
        border-color: #c90;
      }

      .control-btn.zoom {
        background: linear-gradient(to bottom, #00ca4e, #00b542);
        border-color: #090;
      }

      .window-title {
        flex: 1;
        text-align: center;
        font-weight: bold;
        font-size: 12px;
        color: #333;
        text-shadow: 0 1px 0 #fff;
      }

      /* Toolbar */
      .toolbar {
        height: 32px;
        background: linear-gradient(to bottom, #f0f0f0, #d8d8d8);
        border-bottom: 1px solid #999;
        display: flex;
        align-items: center;
        padding: 0 8px;
        gap: 4px;
      }

      .toolbar-group {
        display: flex;
        gap: 2px;
      }

      .toolbar-btn {
        width: 26px;
        height: 22px;
        background: linear-gradient(to bottom, #fff, #e0e0e0);
        border: 1px solid #888;
        border-radius: 3px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: inherit;
        font-size: 11px;
        color: #333;
        box-shadow: 0 1px 0 #fff inset, 0 -1px 0 #bbb inset;
      }

      .toolbar-btn:hover {
        background: linear-gradient(to bottom, #e8e8ff, #d0d0f0);
      }

      .toolbar-btn:active {
        background: linear-gradient(to bottom, #ccc, #ddd);
        box-shadow: 0 1px 2px rgba(0,0,0,0.2) inset;
      }

      .toolbar-icon {
        font-weight: bold;
      }

      .toolbar-icon.italic {
        font-style: italic;
      }

      .toolbar-icon.underline {
        text-decoration: underline;
      }

      .toolbar-divider {
        width: 1px;
        height: 20px;
        background: #999;
        margin: 0 6px;
      }

      .toolbar-spacer {
        flex: 1;
      }

      .preview-btn {
        width: auto;
        padding: 0 8px;
        font-size: 10px;
      }

      /* Ruler */
      .ruler {
        height: 18px;
        background: #fff;
        border-bottom: 1px solid #ccc;
        overflow: hidden;
      }

      .ruler-numbers {
        display: flex;
        padding-left: 50px;
        font-size: 9px;
        color: #666;
      }

      .ruler-mark {
        width: 60px;
        text-align: left;
        border-left: 1px solid #ccc;
        padding-left: 2px;
      }

      /* Title bar */
      .title-bar {
        background: #f8f8f0;
        border-bottom: 1px solid #ccc;
        padding: 8px 12px;
      }

      .title-input {
        width: 100%;
        border: none;
        background: transparent;
        font-size: 18px;
        font-weight: bold;
        font-family: 'Chicago', 'Geneva', sans-serif;
        outline: none;
        color: #333;
      }

      .title-input::placeholder {
        color: #999;
      }

      /* Editor container */
      .editor-container {
        flex: 1;
        display: flex;
        overflow: hidden;
        background: #fffef8;
      }

      .line-numbers {
        width: 40px;
        background: #f0f0e8;
        border-right: 1px solid #ccc;
        padding: 8px 4px;
        font-family: 'Monaco', 'Courier New', monospace;
        font-size: 12px;
        line-height: 1.5;
        color: #999;
        text-align: right;
        user-select: none;
        overflow: hidden;
      }

      .editor-textarea {
        flex: 1;
        border: none;
        padding: 8px 12px;
        font-family: 'Monaco', 'Courier New', monospace;
        font-size: 13px;
        line-height: 1.5;
        resize: none;
        outline: none;
        background: #fffef8;
        color: #333;
      }

      .editor-textarea::placeholder {
        color: #999;
      }

      .editor-textarea::selection {
        background: #b5d5ff;
      }

      /* Status bar */
      .status-bar {
        height: 20px;
        background: linear-gradient(to bottom, #e8e8e8, #d0d0d0);
        border-top: 1px solid #999;
        display: flex;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
        color: #555;
      }

      .status-item {
        padding: 0 8px;
        border-right: 1px solid #bbb;
      }

      .status-spacer {
        flex: 1;
      }

      .status-draft {
        color: #666;
      }

      .status-published {
        color: #090;
        font-weight: bold;
      }

      /* Preview Window */
      .preview-window {
        flex: 1;
        background: #fff;
        border: 2px solid #000;
        border-radius: 8px 8px 0 0;
        box-shadow: 2px 2px 8px rgba(0,0,0,0.4), inset 0 0 0 1px #fff;
        display: flex;
        flex-direction: column;
        overflow: hidden;
      }

      .preview-container {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
        background: #fff;
      }

      .preview-content {
        max-width: 680px;
        margin: 0 auto;
      }

      .preview-title {
        font-size: 28px;
        font-weight: bold;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 2px solid #333;
        font-family: 'Chicago', 'Geneva', sans-serif;
      }

      .preview-body {
        font-family: 'Charter', 'Georgia', serif;
        font-size: 16px;
        line-height: 1.7;
        color: #333;
      }

      .preview-body h1 {
        font-family: 'Chicago', 'Geneva', sans-serif;
        font-size: 2rem;
        font-weight: bold;
        margin: 1.5rem 0 0.75rem 0;
      }

      .preview-body h2 {
        font-family: 'Chicago', 'Geneva', sans-serif;
        font-size: 1.5rem;
        font-weight: bold;
        margin: 1.5rem 0 0.75rem 0;
      }

      .preview-body h3 {
        font-family: 'Chicago', 'Geneva', sans-serif;
        font-size: 1.25rem;
        font-weight: bold;
        margin: 1.5rem 0 0.75rem 0;
      }

      .preview-body pre {
        background: #1a1a2e;
        color: #eee;
        padding: 16px;
        border-radius: 4px;
        overflow-x: auto;
        border: 1px solid #333;
        font-size: 13px;
      }

      .preview-body code {
        font-family: 'Monaco', 'Courier New', monospace;
      }

      .preview-body :not(pre) > code {
        background: #f0f0e8;
        padding: 2px 6px;
        border-radius: 3px;
        font-size: 0.9em;
      }

      .preview-body img {
        max-width: 100%;
        border: 1px solid #ccc;
        border-radius: 4px;
      }

      .preview-body blockquote {
        border-left: 4px solid #666;
        padding-left: 16px;
        margin: 1rem 0;
        color: #555;
        font-style: italic;
      }

      .preview-footer {
        height: 40px;
        background: linear-gradient(to bottom, #e8e8e8, #d0d0d0);
        border-top: 1px solid #999;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        padding: 0 12px;
        gap: 8px;
      }

      .publish-btn, .new-btn {
        padding: 4px 16px;
        background: linear-gradient(to bottom, #fff, #e0e0e0);
        border: 1px solid #666;
        border-radius: 4px;
        font-family: inherit;
        font-size: 11px;
        cursor: pointer;
        box-shadow: 0 1px 0 #fff inset;
      }

      .publish-btn {
        background: linear-gradient(to bottom, #4a9eff, #3080e0);
        color: #fff;
        border-color: #2060a0;
      }

      .publish-btn:hover {
        background: linear-gradient(to bottom, #5aaeFF, #4090f0);
      }

      /* Publish Dialog */
      .dialog-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
      }

      .publish-dialog {
        width: 400px;
        background: #e8e8e8;
        border: 2px solid #000;
        border-radius: 8px;
        box-shadow: 4px 4px 16px rgba(0,0,0,0.5);
        overflow: hidden;
      }

      .dialog-titlebar {
        height: 24px;
        background: linear-gradient(to bottom, #eee, #ccc);
        border-bottom: 1px solid #999;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 8px;
        font-weight: bold;
      }

      .dialog-close {
        background: none;
        border: none;
        font-size: 18px;
        cursor: pointer;
        color: #666;
      }

      .dialog-content {
        padding: 20px;
      }

      .dialog-intro {
        margin-bottom: 16px;
        font-size: 13px;
        color: #333;
      }

      .dialog-error {
        background: #ffcccc;
        border: 1px solid #cc0000;
        padding: 8px 12px;
        margin-bottom: 16px;
        border-radius: 4px;
        font-size: 12px;
        color: #990000;
      }

      .form-group {
        margin-bottom: 16px;
      }

      .form-group label {
        display: block;
        margin-bottom: 4px;
        font-weight: bold;
        font-size: 12px;
      }

      .form-group input {
        width: 100%;
        padding: 8px;
        border: 1px solid #999;
        border-radius: 4px;
        font-family: inherit;
        font-size: 13px;
        background: #fff;
      }

      .form-group input:focus {
        outline: none;
        border-color: #4a9eff;
        box-shadow: 0 0 0 2px rgba(74, 158, 255, 0.3);
      }

      .form-hint {
        display: block;
        margin-top: 4px;
        font-size: 10px;
        color: #666;
      }

      .dialog-buttons {
        display: flex;
        justify-content: flex-end;
        gap: 8px;
        margin-top: 20px;
      }

      .btn-cancel, .btn-publish {
        padding: 6px 20px;
        border-radius: 4px;
        font-family: inherit;
        font-size: 12px;
        cursor: pointer;
      }

      .btn-cancel {
        background: linear-gradient(to bottom, #fff, #e0e0e0);
        border: 1px solid #999;
      }

      .btn-publish {
        background: linear-gradient(to bottom, #4a9eff, #3080e0);
        border: 1px solid #2060a0;
        color: #fff;
        font-weight: bold;
      }

      /* Bluesky embeds */
      .bsky-embed {
        border: 1px solid #ccc;
        border-radius: 8px;
        padding: 12px;
        margin: 1rem 0;
        background: #f8fafc;
      }

      /* Responsive */
      @media (max-width: 900px) {
        .desktop {
          flex-direction: column;
          padding: 10px;
        }

        .editor-window, .preview-window {
          flex: none;
          height: 50%;
        }

        .toolbar-btn:not(.preview-btn) {
          display: none;
        }

        .toolbar-group:has(.toolbar-btn:not(.preview-btn)) {
          display: none;
        }

        .toolbar-divider {
          display: none;
        }
      }
    </style>
    """
  end

  defp format_time(nil), do: "never"
  defp format_time(datetime), do: Calendar.strftime(datetime, "%H:%M:%S")

  defp word_count(nil), do: 0
  defp word_count(""), do: 0
  defp word_count(content), do: content |> String.split(~r/\s+/, trim: true) |> length()
end
