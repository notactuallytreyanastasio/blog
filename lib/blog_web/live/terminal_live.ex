defmodule BlogWeb.TerminalLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Chat
  require Logger

  @presence_topic "terminal_presence"
  @chat_topic "terminal_chat"

  @programs [
    # Main
    %{name: "Blog", icon: "📝", path: "/blog"},
    %{name: "Role Call", icon: "📺", path: "/role-call"},
    %{name: "300+ Yrs Tree Law", icon: "🌳", path: "/trees"},

    # Games
    %{name: "Pong", icon: "🏓", path: "/pong"},
    %{name: "Pong God View", icon: "👁️", path: "/pong/god"},
    %{name: "Wordle", icon: "🔤", path: "/wordle"},
    %{name: "Wordle God", icon: "🎯", path: "/wordle_god"},
    %{name: "Blackjack", icon: "🃏", path: "/blackjack"},
    %{name: "War", icon: "⚔️", path: "/war"},

    # Art
    %{name: "Art", icon: "🎨", path: "/generative-art"},
    %{name: "Bezier", icon: "📐", path: "/bezier-triangles"},
    %{name: "Chaos", icon: "🌈", path: "/gay_chaos"},

    # Social
    %{name: "Emoji Skeets", icon: "😀", path: "/emoji-skeets"},
    %{name: "Bluesky YT", icon: "📺", path: "/reddit-links"},
    %{name: "No Words Chat", icon: "💬", path: "/allowed-chats"},

    # Dev & Productivity
    %{name: "Python", icon: "🐍", path: "/python-demo"},
    %{name: "Markdown", icon: "✍️", path: "/markdown-editor"},
    %{name: "Cursor", icon: "🖱️", path: "/cursor-tracker"},
    %{name: "Typewriter", icon: "⌨️", path: "/typewriter"},
    %{name: "Code Mirror", icon: "🪞", path: "/mirror"},

    # News & Bookmarks
    %{name: "HN", icon: "📡", path: "/hacker-news"},
    %{name: "Bookmarks", icon: "🔖", path: "/bookmarks"},

    # Maps
    %{name: "MTA Map", icon: "🚌", path: "/mta-bus-map"},
    %{name: "MTA Bus", icon: "🗺️", path: "/mta-bus"},

    # Nathan Fielder
    %{name: "Nathan", icon: "😐", path: "/nathan"},
    %{name: "Nathan HP", icon: "📖", path: "/nathan_harpers"},
    %{name: "Nathan TV", icon: "👗", path: "/nathan_teen_vogue"},
    %{name: "Nathan BF", icon: "📋", path: "/nathan_buzzfeed"},
    %{name: "Nathan UN", icon: "💻", path: "/nathan_usenet"},
    %{name: "Nathan CF", icon: "🌾", path: "/nathan_content_farm"},
    %{name: "Nathan Cmp", icon: "⚖️", path: "/nathan_comparison"},
    %{name: "Nathan ASCII", icon: "🔣", path: "/nathan_ascii"},

    # Misc
    %{name: "Receipt", icon: "🧾", path: "/very_direct_message"},
    %{name: "Trash", icon: "🗑️", path: nil}
  ]

  def mount(_params, _session, socket) do
    # Ensure ETS chat store is started
    Chat.ensure_started()

    reader_id =
      if connected?(socket) do
        id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

        # Generate a random color for this visitor
        hue = :rand.uniform(360)
        color = "hsl(#{hue}, 70%, 60%)"

        {:ok, _} =
          Presence.track(self(), @presence_topic, id, %{
            joined_at: DateTime.utc_now(),
            color: color,
            display_name: nil
          })

        # Subscribe to presence and chat topics
        Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
        Phoenix.PubSub.subscribe(Blog.PubSub, @chat_topic)

        id
      else
        nil
      end

    # Get online users from presence
    visitor_list =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    # Get messages for the terminal chat room
    messages = Chat.get_messages("terminal")

    {:ok, assign(socket,
      programs: @programs,
      selected: nil,
      time: format_time(),
      # Chat state
      reader_id: reader_id,
      show_chat: true,
      name_submitted: false,
      name_form: %{"name" => ""},
      chat_messages: messages,
      chat_form: %{"message" => ""},
      visitor_list: visitor_list,
      total_online: map_size(visitor_list),
      # Tree state
      show_tree: false
    )}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 60000)
    {:noreply, assign(socket, time: format_time())}
  end

  defp format_time do
    Calendar.strftime(DateTime.utc_now(), "%I:%M %p")
  end

  def handle_event("select", %{"name" => name}, socket) do
    {:noreply, assign(socket, selected: name)}
  end

  def handle_event("open", %{"path" => path}, socket) do
    {:noreply, push_navigate(socket, to: path)}
  end

  def handle_event("open", _params, socket) do
    {:noreply, socket}
  end

  # Tree event handler
  def handle_event("toggle_tree", _params, socket) do
    {:noreply, assign(socket, show_tree: !socket.assigns.show_tree)}
  end

  # Chat event handlers
  def handle_event("toggle_chat", _params, socket) do
    {:noreply, assign(socket, show_chat: !socket.assigns.show_chat)}
  end

  def handle_event("save_name", %{"name" => name}, socket) do
    reader_id = socket.assigns.reader_id
    trimmed_name = String.trim(name)

    if reader_id && trimmed_name != "" do
      Presence.update(self(), @presence_topic, reader_id, fn meta ->
        Map.put(meta, :display_name, trimmed_name)
      end)
      {:noreply, assign(socket, name_submitted: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name_form: %{"name" => name})}
  end

  def handle_event("skip_name", _params, socket) do
    {:noreply, assign(socket, name_submitted: true)}
  end

  def handle_event("send_chat_message", %{"message" => message}, socket) do
    reader_id = socket.assigns.reader_id
    trimmed_message = String.trim(message)

    if reader_id && trimmed_message != "" do
      # Get display name from presence
      visitor_meta =
        case Presence.get_by_key(@presence_topic, reader_id) do
          %{metas: [meta | _]} -> meta
          _ -> %{display_name: nil, color: "hsl(200, 70%, 60%)"}
        end

      display_name = visitor_meta.display_name || "visitor #{String.slice(reader_id, -4, 4)}"
      color = visitor_meta.color

      new_message = %{
        id: System.os_time(:millisecond),
        sender_id: reader_id,
        sender_name: display_name,
        sender_color: color,
        content: trimmed_message,
        timestamp: DateTime.utc_now(),
        room: "terminal"
      }

      # Save to ETS
      Chat.save_message(new_message)

      # Broadcast to all clients
      Phoenix.PubSub.broadcast!(Blog.PubSub, @chat_topic, {:new_chat_message, new_message})

      # Get updated messages
      updated_messages = Chat.get_messages("terminal")

      {:noreply, assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_chat_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, chat_form: %{"message" => message})}
  end

  # Handle presence updates
  def handle_info(%{event: "presence_diff"}, socket) do
    visitor_list =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    {:noreply, assign(socket, visitor_list: visitor_list, total_online: map_size(visitor_list))}
  end

  # Handle new chat messages
  def handle_info({:new_chat_message, _message}, socket) do
    updated_messages = Chat.get_messages("terminal")
    {:noreply, assign(socket, chat_messages: updated_messages)}
  end

  def render(assigns) do
    ~H"""
    <div class="mac">
      <!-- Menu Bar -->
      <div class="menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">View</span>
          <span class="menu-item">Special</span>
        </div>
        <div class="menu-right">
          <span><%= @time %></span>
        </div>
      </div>

      <!-- Desktop -->
      <div class="desktop">
        <!-- Mac Window -->
        <div class="window">
          <div class="title-bar">
            <div class="close-box"></div>
            <div class="title">bobbby.online</div>
            <div class="resize-box"></div>
          </div>
          <div class="window-content">
            <div class="icon-grid">
              <%= for program <- @programs do %>
                <div
                  class={"icon #{if @selected == program.name, do: "selected"}"}
                  phx-click="select"
                  phx-value-name={program.name}
                  phx-click={if program.path, do: nil}
                >
                  <div
                    class="icon-image"
                    phx-click={if program.path, do: "open"}
                    phx-value-path={program.path}
                  >
                    <%= program.icon %>
                  </div>
                  <div class="icon-label"><%= program.name %></div>
                </div>
              <% end %>
            </div>
          </div>
          <div class="status-bar">
            <span><%= length(@programs) %> items</span>
            <span><%= @total_online %> online</span>
          </div>
        </div>

        <!-- Psychedelic Tree (always visible, transparent background) -->
        <div class="tree-container" id="tree-wrapper" phx-update="ignore">
          <canvas id="psychedelic-tree" phx-hook="PsychedelicTree"></canvas>
        </div>

        <!-- AIM Chat Window (Windows 95 style overlaid on Mac) -->
        <!-- Name Dialog -->
        <%= if @reader_id && !@name_submitted && @show_chat do %>
          <div class="aim-name-dialog" style="top: 80px; right: 40px;">
            <div class="aim-name-dialog-titlebar">
              <span>Enter Screen Name</span>
            </div>
            <div class="aim-name-dialog-content">
              <div class="aim-name-dialog-text">
                Please enter your screen name to join the chat:
              </div>
              <.form for={%{}} phx-submit="save_name" phx-change="validate_name">
                <input
                  type="text"
                  name="name"
                  value={@name_form["name"]}
                  placeholder="Screen Name"
                  maxlength="20"
                  class="aim-name-input"
                  autofocus
                />
                <div class="aim-name-buttons">
                  <button type="submit" class="aim-name-btn primary">OK</button>
                  <button type="button" class="aim-name-btn" phx-click="skip_name">Skip</button>
                </div>
              </.form>
            </div>
          </div>
        <% end %>

        <!-- Chat Toggle Button -->
        <button
          class="aim-toggle-btn"
          phx-click="toggle_chat"
          style={if @show_chat, do: "display: none;", else: "right: 40px;"}
        >
          Chat Room
        </button>

        <!-- AIM Chat Container -->
        <div class={["aim-chat-container", if(@show_chat, do: "open", else: "")]} style="right: 40px; bottom: 40px;">
          <div class="aim-chat-titlebar">
            <span class="aim-chat-title">AIM Chat - Terminal</span>
            <div class="aim-chat-controls">
              <button class="aim-control-btn" phx-click="toggle_chat">×</button>
            </div>
          </div>

          <div class="aim-chat-content">
            <div class="aim-buddy-list-title">Online (<%= @total_online %>)</div>
            <div class="aim-buddy-list">
              <%= for {_id, user} <- @visitor_list do %>
                <div class="aim-buddy">
                  <div class="aim-buddy-status"></div>
                  <span class="aim-buddy-name" style={"color: #{user.color};"}>
                    <%= if Map.get(user, :display_name), do: Map.get(user, :display_name), else: "Anonymous" %>
                  </span>
                </div>
              <% end %>
            </div>

            <div class="aim-messages-area" id="aim-chat-messages" phx-hook="ChatScroll">
              <%= for message <- @chat_messages do %>
                <div class="aim-message">
                  <span class="aim-message-sender" style={"color: #{message.sender_color};"}>
                    <%= message.sender_name %>
                  </span>
                  <span class="aim-message-time">
                    <%= Calendar.strftime(message.timestamp, "%I:%M %p") %>
                  </span>
                  <div class="aim-message-content"><%= message.content %></div>
                </div>
              <% end %>
              <%= if Enum.empty?(@chat_messages) do %>
                <div class="aim-message">
                  <span class="aim-message-sender" style="color: #000080;">ChatBot</span>
                  <div class="aim-message-content">Welcome! Say hello!</div>
                </div>
              <% end %>
            </div>

            <div class="aim-input-area">
              <.form for={%{}} phx-submit="send_chat_message" phx-change="validate_chat_message">
                <textarea
                  name="message"
                  class="aim-input-box"
                  placeholder="Type a message..."
                  maxlength="500"
                  autocomplete="off"
                ><%= @chat_form["message"] %></textarea>
                <button type="submit" class="aim-send-btn">Send</button>
                <div style="clear: both;"></div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>

    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      html, body {
        height: 100%;
        overflow: hidden;
      }

      .mac {
        height: 100vh;
        background: #a8a8a8;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        cursor: default;
        -webkit-font-smoothing: none;
      }

      /* Menu Bar */
      .menu-bar {
        height: 20px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
      }

      .menu-left {
        display: flex;
        gap: 16px;
      }

      .apple-menu {
        font-family: system-ui;
        font-size: 14px;
      }

      .menu-item {
        cursor: default;
      }

      .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .menu-right {
        font-size: 11px;
      }

      /* Desktop */
      .desktop {
        height: calc(100vh - 20px);
        padding: 20px;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
      }

      /* Window */
      .window {
        width: 700px;
        max-width: 95vw;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
      }

      .title-bar {
        height: 20px;
        background: #fff;
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
      }

      .close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
      }

      .close-box:hover {
        background: #000;
      }

      .title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
      }

      .resize-box {
        width: 12px;
        height: 12px;
      }

      .window-content {
        padding: 16px;
        min-height: 450px;
        max-height: 70vh;
        overflow-y: auto;
        background: #fff;
      }

      .icon-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, 72px);
        gap: 16px;
      }

      .icon {
        width: 72px;
        text-align: center;
        padding: 4px;
        cursor: default;
      }

      .icon.selected .icon-label {
        background: #000;
        color: #fff;
      }

      .icon-image {
        font-size: 32px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .icon-label {
        font-size: 10px;
        margin-top: 2px;
        padding: 1px 2px;
        word-wrap: break-word;
      }

      .status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
      }

      /* Double click to open */
      .icon-image {
        cursor: pointer;
      }

      /* Psychedelic tree container */
      .tree-container {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        pointer-events: none;
        z-index: 50;
      }

      .tree-container canvas {
        width: 100%;
        height: 100%;
        display: block;
      }
    </style>
    """
  end
end
