defmodule BlogWeb.TerminalLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias BlogWeb.JoyrideComponent
  alias Blog.Chat
  require Logger

  @presence_topic "terminal_presence"

  @tour_steps_base [
    %{
      target: "toys-section",
      title: "Fun Toys & Art",
      content: "These are fun toys or art generators.",
      placement: :bottom
    },
    %{
      target: "bluesky-section",
      title: "Bluesky Feeds",
      content: "These are atproto firehose toys.",
      placement: :bottom
    },
    %{
      target: "nathan-section",
      title: "Nathan Fielder",
      content: "Writing experiments with regard to Nathan Fielder.",
      placement: :bottom
    },
    %{
      target: "trees-item",
      title: "Tree Law",
      content: "Tree law, brother.",
      placement: :bottom
    },
    %{
      target: "receipt-item",
      title: "Receipt Printer",
      content: "Send me a very literal DM to my desk.",
      placement: :bottom
    },
    %{
      target: "utilities-section",
      title: "Utilities",
      content: "Silly or helpful little utilities.",
      placement: :bottom
    }
  ]

  @name_dialog_step %{
    target: "aim-name-dialog",
    title: "Pick Your Screen Name",
    content: "Choose a name for the chat - it'll stick around for next time!",
    placement: :left
  }

  @chat_window_step %{
    target: "chat-window",
    title: "Leave a Note!",
    content: "Say hi in the chatroom - messages persist so I'll see them later!",
    placement: :left
  }

  # Build tour steps - include name dialog step only if dialog is visible
  defp build_tour_steps(chatter) do
    if is_nil(chatter) do
      [@name_dialog_step, @chat_window_step | @tour_steps_base]
    else
      [@chat_window_step | @tour_steps_base]
    end
  end

  # Grouped by tour sections
  @toys [
    %{name: "Pong", icon: "🏓", path: "/pong"},
    %{name: "Pong God View", icon: "👁️", path: "/pong/god"},
    %{name: "Wordle", icon: "🔤", path: "/wordle"},
    %{name: "Wordle God", icon: "🎯", path: "/wordle_god"},
    %{name: "Blackjack", icon: "🃏", path: "/blackjack"},
    %{name: "War", icon: "⚔️", path: "/war"},
    %{name: "Art", icon: "🎨", path: "/generative-art"},
    %{name: "Bezier", icon: "📐", path: "/bezier-triangles"},
    %{name: "Chaos", icon: "🌈", path: "/gay_chaos"},
    %{name: "Cursor", icon: "🖱️", path: "/cursor-tracker"},
    %{name: "Typewriter", icon: "⌨️", path: "/typewriter"},
    %{name: "Code Mirror", icon: "🪞", path: "/mirror"},
    %{name: "Role Call", icon: "📺", path: "/role-call"},
    %{name: "Python", icon: "🐍", path: "/python-demo"},
    %{name: "Markdown", icon: "✍️", path: "/markdown-editor"}
  ]

  @bluesky [
    %{name: "Emoji Skeets", icon: "😀", path: "/emoji-skeets"},
    %{name: "Bluesky YT", icon: "📺", path: "/reddit-links"},
    %{name: "No Words Chat", icon: "💬", path: "/allowed-chats"}
  ]

  @nathan [
    %{name: "Nathan", icon: "😐", path: "/nathan"},
    %{name: "Nathan HP", icon: "📖", path: "/nathan_harpers"},
    %{name: "Nathan TV", icon: "👗", path: "/nathan_teen_vogue"},
    %{name: "Nathan BF", icon: "📋", path: "/nathan_buzzfeed"},
    %{name: "Nathan UN", icon: "💻", path: "/nathan_usenet"},
    %{name: "Nathan CF", icon: "🌾", path: "/nathan_content_farm"},
    %{name: "Nathan Cmp", icon: "⚖️", path: "/nathan_comparison"},
    %{name: "Nathan ASCII", icon: "🔣", path: "/nathan_ascii"}
  ]

  @trees [
    %{name: "300+ Yrs Tree Law", icon: "🌳", path: "/trees"}
  ]

  @receipt [
    %{name: "Receipt", icon: "🧾", path: "/very_direct_message"}
  ]

  @utilities [
    %{name: "HN", icon: "📡", path: "/hacker-news"},
    %{name: "Bookmarks", icon: "🔖", path: "/bookmarks"},
    %{name: "MTA Map", icon: "🚌", path: "/mta-bus-map"}
  ]

  @other [
    %{name: "Trash", icon: "🗑️", path: nil}
  ]

  @programs @toys ++ @bluesky ++ @nathan ++ @trees ++ @receipt ++ @utilities ++ @other

  def mount(_params, session, socket) do
    # Get visitor's IP from session (set by RemoteIp plug)
    visitor_ip = Map.get(session, "remote_ip", "unknown")

    # Check for returning chatter by IP hash
    ip_hash = Chat.hash_ip(visitor_ip)
    returning_chatter = if ip_hash, do: Chat.get_chatter_by_ip(ip_hash), else: nil

    # Don't set chatter yet - user needs to confirm their name first via the dialog
    # We track returning_chatter separately to show "Welcome back!" message
    reader_id =
      if connected?(socket) do
        id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

        # If returning chatter exists, use their color; otherwise generate new
        color = if returning_chatter, do: returning_chatter.color, else: Blog.Chat.Chatter.random_color()
        display_name = if returning_chatter, do: returning_chatter.screen_name, else: nil

        {:ok, _} =
          Presence.track(self(), @presence_topic, id, %{
            joined_at: DateTime.utc_now(),
            color: color,
            display_name: display_name
          })

        # Subscribe to presence and chat topics
        Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
        Phoenix.PubSub.subscribe(Blog.PubSub, Chat.topic())

        id
      else
        nil
      end

    # chatter is nil until they confirm via save_name or skip_name
    chatter = nil

    # Get online users from presence
    visitor_list =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    # Get messages from Postgres
    messages = Chat.list_messages("terminal")

    {:ok, assign(socket,
      programs: @programs,
      # Program groups for template
      toys: @toys,
      bluesky: @bluesky,
      nathan: @nathan,
      trees: @trees,
      receipt: @receipt,
      utilities: @utilities,
      other: @other,
      selected: nil,
      time: format_time(),
      # Chat state
      reader_id: reader_id,
      visitor_ip: visitor_ip,
      chatter: chatter,
      returning_chatter: returning_chatter,
      show_chat: true,
      name_form: %{"name" => if(returning_chatter, do: returning_chatter.screen_name, else: "")},
      chat_messages: messages,
      chat_form: %{"message" => ""},
      visitor_list: visitor_list,
      total_online: map_size(visitor_list),
      # Tree state
      show_tree: false,
      # Tour state - auto-start for first-time visitors
      show_tour: is_nil(returning_chatter),
      tour_steps: build_tour_steps(chatter)
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
    visitor_ip = socket.assigns.visitor_ip
    trimmed_name = String.trim(name)

    if reader_id && trimmed_name != "" do
      # Create or update chatter in Postgres
      case Chat.find_or_create_chatter(trimmed_name, visitor_ip) do
        {:ok, chatter} ->
          # Update presence with the chatter's info
          Presence.update(self(), @presence_topic, reader_id, fn meta ->
            meta
            |> Map.put(:display_name, chatter.screen_name)
            |> Map.put(:color, chatter.color)
          end)

          {:noreply, assign(socket,
            chatter: chatter,
            name_form: %{"name" => chatter.screen_name},
            tour_steps: build_tour_steps(chatter)
          )}

        {:error, _changeset} ->
          # Handle error - keep dialog open
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name_form: %{"name" => name})}
  end

  def handle_event("skip_name", _params, socket) do
    # Skip creates an anonymous chatter
    visitor_ip = socket.assigns.visitor_ip
    anonymous_name = "Visitor#{:rand.uniform(9999)}"

    case Chat.find_or_create_chatter(anonymous_name, visitor_ip) do
      {:ok, chatter} ->
        reader_id = socket.assigns.reader_id
        if reader_id do
          Presence.update(self(), @presence_topic, reader_id, fn meta ->
            meta
            |> Map.put(:display_name, chatter.screen_name)
            |> Map.put(:color, chatter.color)
          end)
        end
        {:noreply, assign(socket, chatter: chatter, tour_steps: build_tour_steps(chatter))}

      {:error, _} ->
        {:noreply, assign(socket, chatter: nil)}
    end
  end

  def handle_event("send_chat_message", %{"message" => message}, socket) do
    chatter = socket.assigns.chatter
    trimmed_message = String.trim(message)

    if chatter && trimmed_message != "" do
      # Save to Postgres and broadcast
      case Chat.create_message(chatter, trimmed_message, "terminal") do
        {:ok, _message} ->
          # Get updated messages
          updated_messages = Chat.list_messages("terminal")
          {:noreply, assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}

        {:error, _changeset} ->
          {:noreply, socket}
      end
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
    updated_messages = Chat.list_messages("terminal")
    {:noreply, assign(socket, chat_messages: updated_messages)}
  end

  # Handle Joyride tour completion
  def handle_info({:tour_complete, _id}, socket) do
    {:noreply, assign(socket, show_tour: false)}
  end

  # Tour controls
  def handle_event("start_tour", _params, socket) do
    {:noreply, assign(socket, show_tour: true)}
  end

  # Function component for rendering icon items
  defp icon_item(assigns) do
    # Support optional data-joyride on individual icons
    assigns = assign_new(assigns, :joyride, fn -> nil end)

    ~H"""
    <div
      class={"icon #{if @selected == @program.name, do: "selected"}"}
      phx-click="select"
      phx-value-name={@program.name}
      data-joyride={@joyride}
    >
      <div
        class="icon-image"
        phx-click={if @program.path, do: "open"}
        phx-value-path={@program.path}
      >
        <%= @program.icon %>
      </div>
      <div class="icon-label"><%= @program.name %></div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="mac">
      <%!-- Joyride Tour Component --%>
      <.live_component
        module={JoyrideComponent}
        id="site-tour"
        steps={@tour_steps}
        run={@show_tour}
      />

      <!-- Menu Bar -->
      <div class="menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">View</span>
          <span class="menu-item" phx-click="start_tour" style="cursor: pointer;">Tour</span>
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
              <%!-- Fun Toys & Art Generators --%>
              <div class="icon-section" data-joyride="toys-section">
                <%= for program <- @toys do %>
                  <.icon_item program={program} selected={@selected} />
                <% end %>
              </div>

              <%!-- Bluesky / ATProto --%>
              <div class="icon-section" data-joyride="bluesky-section">
                <%= for program <- @bluesky do %>
                  <.icon_item program={program} selected={@selected} />
                <% end %>
              </div>

              <%!-- Nathan Fielder --%>
              <div class="icon-section" data-joyride="nathan-section">
                <%= for program <- @nathan do %>
                  <.icon_item program={program} selected={@selected} />
                <% end %>
              </div>

              <%!-- Single items with individual joyride targets --%>
              <div class="icon-section">
                <%= for program <- @trees do %>
                  <.icon_item program={program} selected={@selected} joyride="trees-item" />
                <% end %>
                <%= for program <- @receipt do %>
                  <.icon_item program={program} selected={@selected} joyride="receipt-item" />
                <% end %>
              </div>

              <%!-- Utilities: HN, Bookmarks, MTA --%>
              <div class="icon-section" data-joyride="utilities-section">
                <%= for program <- @utilities do %>
                  <.icon_item program={program} selected={@selected} />
                <% end %>
              </div>

              <%!-- Other --%>
              <div class="icon-section">
                <%= for program <- @other do %>
                  <.icon_item program={program} selected={@selected} />
                <% end %>
              </div>
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
        <!-- Name Dialog - show for new visitors or returning visitors without confirmed chatter -->
        <%= if @reader_id && is_nil(@chatter) && @show_chat do %>
          <div class="aim-name-dialog" style="top: 80px; right: 40px;" data-joyride="aim-name-dialog">
            <div class="aim-name-dialog-titlebar">
              <span><%= if @returning_chatter, do: "Welcome Back!", else: "Enter Screen Name" %></span>
            </div>
            <div class="aim-name-dialog-content">
              <div class="aim-name-dialog-text">
                <%= if @returning_chatter do %>
                  Welcome back, <strong><%= @returning_chatter.screen_name %></strong>! Change your name or join as:
                <% else %>
                  Please enter your screen name to join the chat:
                <% end %>
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
                  <button type="submit" class="aim-name-btn primary">
                    <%= if @returning_chatter, do: "Join as #{@returning_chatter.screen_name}", else: "OK" %>
                  </button>
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
        <div class={["aim-chat-container", if(@show_chat, do: "open", else: "")]} style="right: 40px; bottom: 40px;" data-joyride="chat-window">
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
                  <span class="aim-message-sender" style={"color: #{if message.chatter, do: message.chatter.color, else: "#666"};"}>
                    <%= if message.chatter, do: message.chatter.screen_name, else: "Anonymous" %>
                  </span>
                  <span class="aim-message-time">
                    <%= Calendar.strftime(message.inserted_at, "%I:%M %p") %>
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
        display: flex;
        flex-direction: column;
        gap: 8px;
      }

      .icon-section {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        padding: 8px;
        border-radius: 4px;
      }

      .icon-section:hover {
        background: rgba(0, 0, 0, 0.03);
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
