defmodule BlogWeb.TerminalLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
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
    %{name: "Blog", icon: "📝", path: "/blog"},
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

    # Get blog posts
    blog_posts = Blog.Content.Post.all() |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})

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
      # Blog posts
      blog_posts: blog_posts,
      # Chat state
      reader_id: reader_id,
      visitor_ip: visitor_ip,
      chatter: chatter,
      returning_chatter: returning_chatter,
      show_chat: false,
      name_form: %{"name" => if(returning_chatter, do: returning_chatter.screen_name, else: "")},
      chat_messages: messages,
      chat_form: %{"message" => ""},
      visitor_list: visitor_list,
      total_online: map_size(visitor_list),
      # Phish window state
      show_phish: true,
      # Tree state
      show_tree: false,
      # Tour state - auto-start for first-time visitors (desktop only)
      show_tour: is_nil(returning_chatter),
      tour_steps: build_tour_steps(chatter),
      # Mobile state - which window is active on mobile
      # Options: :finder, :chat, :name_dialog, :blog, :phish
      mobile_window: :finder
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

  # Phish window toggle
  def handle_event("toggle_phish", _params, socket) do
    {:noreply, assign(socket, show_phish: !socket.assigns.show_phish)}
  end

  # Tree event handler
  def handle_event("toggle_tree", _params, socket) do
    {:noreply, assign(socket, show_tree: !socket.assigns.show_tree)}
  end

  # Chat event handlers
  def handle_event("toggle_chat", _params, socket) do
    new_show_chat = !socket.assigns.show_chat
    # When opening chat on mobile, show name dialog if no chatter set
    mobile_window =
      if new_show_chat && is_nil(socket.assigns.chatter) do
        :name_dialog
      else
        socket.assigns.mobile_window
      end
    {:noreply, assign(socket, show_chat: new_show_chat, mobile_window: mobile_window)}
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
            tour_steps: build_tour_steps(chatter),
            mobile_window: :chat
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
        {:noreply, assign(socket,
          chatter: chatter,
          tour_steps: build_tour_steps(chatter),
          mobile_window: :chat
        )}

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

  # Mobile window switching
  def handle_event("switch_mobile_window", %{"window" => window}, socket) do
    window_atom = String.to_existing_atom(window)

    # If switching to chat but user hasn't set name, show name dialog first
    {window_atom, show_chat, show_phish} =
      cond do
        window_atom == :chat ->
          if is_nil(socket.assigns.chatter) do
            {:name_dialog, true, socket.assigns.show_phish}
          else
            {:chat, true, socket.assigns.show_phish}
          end
        window_atom == :phish ->
          {:phish, socket.assigns.show_chat, true}
        true ->
          {window_atom, socket.assigns.show_chat, socket.assigns.show_phish}
      end

    {:noreply, assign(socket, mobile_window: window_atom, show_chat: show_chat, show_phish: show_phish)}
  end

  # Forward phish component events via send_update
  @phish_events ~w(change-year change-song change-sort change-min change-filter-text flip-card change-list-filter toggle-notes play-jam)
  def handle_event(event, params, socket) when event in @phish_events do
    send_update(BlogWeb.PhishComponent, id: "phish-embed", __event__: event, __params__: params)
    {:noreply, socket}
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
        module={LiveJoyride.Component}
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
        <!-- Mac Window (Finder) -->
        <div class={"window mobile-window-finder #{if @mobile_window == :finder, do: "mobile-active"}"} phx-hook="Draggable" id="finder-window">
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

              <%!-- Music --%>
              <div class="icon-section">
                <div class="icon" phx-click="toggle_phish">
                  <div class="icon-image">🐟</div>
                  <div class={"icon-label #{if @show_phish, do: "selected-label"}"}>Phish Stats</div>
                </div>
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

        <!-- Blog Posts Window -->
        <div class={"blog-window mobile-window-blog #{if @mobile_window == :blog, do: "mobile-active"}"} phx-hook="Draggable" id="blog-window">
          <div class="title-bar">
            <div class="close-box"></div>
            <div class="title">Thoughts & Tidbits - Blog</div>
            <div class="resize-box"></div>
          </div>
          <div class="blog-window-content">
            <div class="blog-posts-list">
              <%= for post <- @blog_posts do %>
                <a href={~p"/post/#{post.slug}"} class="blog-post-row">
                  <div class="blog-post-icon">📝</div>
                  <div class="blog-post-info">
                    <div class="blog-post-title"><%= post.title %></div>
                    <div class="blog-post-meta">
                      <%= Calendar.strftime(post.written_on, "%B %d, %Y") %>
                      <%= if length(post.tags) > 0 do %>
                        <span class="blog-post-tags">
                          <%= for tag <- post.tags do %>
                            <span class="blog-tag"><%= tag.name %></span>
                          <% end %>
                        </span>
                      <% end %>
                    </div>
                  </div>
                </a>
              <% end %>
            </div>
          </div>
          <div class="status-bar">
            <span><%= length(@blog_posts) %> posts</span>
            <span><%= @total_online %> <%= if @total_online == 1, do: "reader", else: "readers" %></span>
          </div>
        </div>

        <!-- Phish Jamchart Window -->
        <%= if @show_phish do %>
          <div class={"phish-embed-window mobile-window-phish #{if @mobile_window == :phish, do: "mobile-active"}"} phx-hook="Draggable" id="phish-window">
            <div class="title-bar">
              <div class="close-box" phx-click="toggle_phish"></div>
              <div class="title">Song Deep Dive — Phish 3.0</div>
              <div class="resize-box"></div>
            </div>
            <div class="phish-embed-content">
              <.live_component module={BlogWeb.PhishComponent} id="phish-embed" />
            </div>
            <div class="status-bar">
              <span>phstats</span>
              <span>Phish 3.0 Jamchart Analysis</span>
            </div>
          </div>
        <% end %>

        <!-- Psychedelic Tree (always visible, transparent background) -->
        <div class="tree-container" id="tree-wrapper" phx-update="ignore">
          <canvas id="psychedelic-tree" phx-hook="PsychedelicTree"></canvas>
        </div>

        <!-- AIM Chat Window (Windows 95 style overlaid on Mac) -->
        <!-- Name Dialog - show for new visitors or returning visitors without confirmed chatter -->
        <%= if @reader_id && is_nil(@chatter) && @show_chat do %>
          <div class={"aim-name-dialog mobile-window-name_dialog #{if @mobile_window == :name_dialog, do: "mobile-active"}"} style="top: 80px; right: 40px;" data-joyride="aim-name-dialog" phx-hook="Draggable" id="name-dialog-window">
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
        <div class={["aim-chat-container", "mobile-window-chat", if(@show_chat, do: "open", else: ""), if(@mobile_window == :chat, do: "mobile-active", else: "")]} style="right: 40px; bottom: 40px;" data-joyride="chat-window" phx-hook="Draggable" id="chat-window">
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

        <%!-- Mobile Taskbar - only visible on mobile --%>
        <div class="mobile-taskbar">
          <button
            class={"mobile-taskbar-btn #{if @mobile_window == :finder, do: "active"}"}
            phx-click="switch_mobile_window"
            phx-value-window="finder"
          >
            📁 Apps
          </button>
          <button
            class={"mobile-taskbar-btn #{if @mobile_window == :blog, do: "active"}"}
            phx-click="switch_mobile_window"
            phx-value-window="blog"
          >
            📝 Blog
          </button>
          <%= if is_nil(@chatter) do %>
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :name_dialog, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="name_dialog"
            >
              ✏️ Name
            </button>
          <% end %>
          <button
            class={"mobile-taskbar-btn #{if @mobile_window == :phish, do: "active"}"}
            phx-click="switch_mobile_window"
            phx-value-window="phish"
          >
            🐟 Phish
          </button>
          <button
            class={"mobile-taskbar-btn #{if @mobile_window == :chat, do: "active"}"}
            phx-click="switch_mobile_window"
            phx-value-window="chat"
          >
            💬 Chat
          </button>
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
        display: flex;
        gap: 20px;
        align-items: flex-start;
      }

      /* Window (Icons/Finder) */
      .window {
        width: 260px;
        min-width: 240px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex-shrink: 0;
      }

      /* Blog Window */
      .blog-window {
        flex: 0.5;
        min-width: 300px;
        max-width: 560px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
      }

      /* Hide chat on smaller screens to prioritize main windows */
      @media (max-width: 1200px) {
        .aim-chat-container,
        .aim-name-dialog,
        .aim-toggle-btn {
          display: none !important;
        }
      }

      .blog-window .title-bar {
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

      .blog-window .close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
      }

      .blog-window .title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
      }

      .blog-window-content {
        max-height: calc(100vh - 140px);
        overflow-y: auto;
        background: #fff;
      }

      .blog-posts-list {
        display: flex;
        flex-direction: column;
      }

      .blog-post-row {
        display: flex;
        align-items: center;
        padding: 6px 10px;
        border-bottom: 1px solid #ccc;
        text-decoration: none;
        color: inherit;
        cursor: default;
      }

      .blog-post-row:hover {
        background: #000;
        color: #fff;
      }

      .blog-post-row:hover .blog-tag {
        background: #333;
        color: #fff;
      }

      .blog-post-row:hover .blog-post-meta {
        color: #ccc;
      }

      .blog-post-icon {
        font-size: 20px;
        margin-right: 10px;
        width: 24px;
        text-align: center;
      }

      .blog-post-info {
        flex: 1;
        min-width: 0;
      }

      .blog-post-title {
        font-weight: bold;
        font-size: 12px;
        margin-bottom: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .blog-post-meta {
        font-size: 10px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 6px;
        flex-wrap: wrap;
      }

      .blog-post-tags {
        display: flex;
        gap: 3px;
        flex-wrap: wrap;
      }

      .blog-tag {
        background: #e0e0e0;
        padding: 1px 5px;
        border-radius: 2px;
        font-size: 9px;
      }

      .blog-window .status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
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
        padding: 10px;
        min-height: 300px;
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
        gap: 6px;
        padding: 6px;
        border-radius: 4px;
      }

      .icon-section:hover {
        background: rgba(0, 0, 0, 0.03);
      }

      .icon {
        width: 56px;
        text-align: center;
        padding: 2px;
        cursor: default;
      }

      .icon.selected .icon-label {
        background: #000;
        color: #fff;
      }

      .icon-image {
        font-size: 26px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .icon-label {
        font-size: 9px;
        margin-top: 1px;
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

      /* Phish embed window */
      .phish-embed-window {
        width: 320px;
        min-width: 300px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex-shrink: 0;
        align-self: flex-start;
      }

      .phish-embed-content {
        max-height: calc(100vh - 160px);
        overflow-y: auto;
        background: #fff;
      }

      .phish-embed-window .status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
      }

      .selected-label {
        background: #000;
        color: #fff;
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

      /* Mobile taskbar - hidden on desktop */
      .mobile-taskbar {
        display: none;
      }

      /* ============================================
         MOBILE STYLES (max-width: 768px)
         ============================================ */
      @media (max-width: 768px) {
        /* Hide menu bar items except time on mobile */
        .menu-left .menu-item {
          display: none;
        }

        /* Desktop padding adjustments for mobile */
        .desktop {
          padding: 10px;
          padding-bottom: 70px; /* Room for taskbar */
        }

        /* Finder window - full screen on mobile */
        .window.mobile-window-finder {
          position: fixed;
          top: 20px; /* Below menu bar */
          left: 0;
          right: 0;
          bottom: 60px; /* Above taskbar */
          width: 100% !important;
          max-width: 100% !important;
          z-index: 100;
          display: none; /* Hidden by default */
        }

        .window.mobile-window-finder.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .window.mobile-window-finder .window-content {
          flex: 1;
          max-height: none;
          min-height: auto;
          overflow-y: auto;
        }

        /* Blog window - full screen on mobile */
        .blog-window.mobile-window-blog {
          position: fixed;
          top: 20px;
          left: 0;
          right: 0;
          bottom: 60px;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 100;
          display: none;
        }

        .blog-window.mobile-window-blog.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .blog-window.mobile-window-blog .blog-window-content {
          flex: 1;
          max-height: none;
          overflow-y: auto;
        }

        /* Name dialog - full screen on mobile */
        .aim-name-dialog.mobile-window-name_dialog {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 200;
          display: none; /* Hidden by default */
          box-sizing: border-box;
        }

        .aim-name-dialog.mobile-window-name_dialog.mobile-active {
          display: block;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-dialog-content {
          padding: 20px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-input {
          width: 100%;
          font-size: 16px; /* Prevent zoom on iOS */
          padding: 12px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-buttons {
          flex-direction: column;
          gap: 10px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-btn {
          width: 100%;
          padding: 12px;
          font-size: 16px;
        }

        /* Chat container - full screen on mobile */
        .aim-chat-container.mobile-window-chat {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 150;
          display: none; /* Hidden by default */
          box-sizing: border-box;
        }

        .aim-chat-container.mobile-window-chat.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .aim-chat-container.mobile-window-chat .aim-chat-content {
          flex: 1;
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .aim-chat-container.mobile-window-chat .aim-messages-area {
          flex: 1;
          overflow-y: auto;
        }

        .aim-chat-container.mobile-window-chat .aim-input-box {
          font-size: 16px; /* Prevent zoom on iOS */
        }

        /* Hide the floating chat toggle on mobile */
        .aim-toggle-btn {
          display: none !important;
        }

        /* Hide tree animation on mobile for performance */
        .tree-container {
          display: none;
        }

        /* Mobile taskbar - fixed at bottom */
        .mobile-taskbar {
          display: flex;
          position: fixed;
          bottom: 0;
          left: 0;
          right: 0;
          height: 50px;
          background: linear-gradient(to bottom, #dfdfdf, #c0c0c0);
          border-top: 2px solid #fff;
          box-shadow: 0 -2px 4px rgba(0, 0, 0, 0.2);
          z-index: 1000;
          padding: 5px;
          gap: 5px;
        }

        .mobile-taskbar-btn {
          flex: 1;
          background: linear-gradient(to bottom, #ececec, #d4d4d4);
          border: 1px solid #888;
          border-radius: 4px;
          font-size: 12px;
          font-weight: bold;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 4px;
          box-shadow: 1px 1px 0 #fff inset, -1px -1px 0 #888 inset;
        }

        .mobile-taskbar-btn:active,
        .mobile-taskbar-btn.active {
          background: linear-gradient(to bottom, #c0c0c0, #a8a8a8);
          box-shadow: -1px -1px 0 #fff inset, 1px 1px 0 #888 inset;
        }

        /* Icon grid adjustments for mobile */
        .icon-grid {
          gap: 4px;
        }

        .icon-section {
          gap: 8px;
          padding: 4px;
        }

        .icon {
          width: 60px;
        }

        .icon-image {
          font-size: 28px;
          height: 36px;
        }

        .icon-label {
          font-size: 9px;
        }

        /* Phish window - full screen on mobile */
        .phish-embed-window.mobile-window-phish {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          min-width: 0 !important;
          transform: none !important;
          z-index: 200;
          display: none;
        }

        .phish-embed-window.mobile-window-phish.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .phish-embed-window.mobile-window-phish .phish-embed-content {
          flex: 1;
          max-height: none;
          overflow-y: auto;
        }

        /* Hide joyride tour on mobile - too complex for small screens */
        #site-tour {
          display: none !important;
        }
      }
    </style>
    """
  end
end
