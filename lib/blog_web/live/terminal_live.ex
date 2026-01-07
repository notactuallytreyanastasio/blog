defmodule BlogWeb.TerminalLive do
  use BlogWeb, :live_view

  @programs [
    # Main
    %{name: "Blog", icon: "📝", path: "/blog"},
    %{name: "Role Call", icon: "📺", path: "/role-call"},
    %{name: "Museum", icon: "🏛️", path: "/museum"},
    %{name: "Trees", icon: "🌳", path: "/trees"},

    # Games
    %{name: "Pong", icon: "🏓", path: "/pong"},
    %{name: "Pong God", icon: "👁️", path: "/pong/god"},
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
    %{name: "Skeets", icon: "🦋", path: "/skeet-timeline"},
    %{name: "Reddit", icon: "📰", path: "/reddit-links"},
    %{name: "Chat", icon: "💬", path: "/allowed-chats"},

    # Dev & Productivity
    %{name: "Python", icon: "🐍", path: "/python-demo"},
    %{name: "Markdown", icon: "✍️", path: "/markdown-editor"},
    %{name: "Cursor", icon: "🖱️", path: "/cursor-tracker"},
    %{name: "Keylogger", icon: "⌨️", path: "/keylogger"},
    %{name: "Mirror", icon: "🪞", path: "/mirror"},

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
    {:ok, assign(socket,
      programs: @programs,
      selected: nil,
      time: format_time()
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
        <!-- Window -->
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
            <span>64K available</span>
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
    </style>
    """
  end
end
