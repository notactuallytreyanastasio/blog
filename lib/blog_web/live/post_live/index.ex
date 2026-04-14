defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Content
  alias Blog.Chat
  require Logger

  @presence_topic "blog_presence"
  @chat_topic "blog_chat"
  @default_rooms ["frontpage"]
  @url_regex ~r/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})/i

  # TODO add meta tags
  def mount(params, _session, socket) do
    # Ensure ETS chat store is started
    Chat.ensure_started()

    demos = [
      # Featured
      %{title: "Role Call", description: "Discover TV shows through writers you love", path: ~p"/role-call", category: "Discovery"},
      %{title: "300+ Years of Tree Law", description: "A timeline and deep dive on tree law", path: ~p"/trees", category: "Art"},

      # Data Viz & Maps
      %{title: "MTA Bus Map", description: "Track Manhattan buses in real-time", path: ~p"/mta-bus-map", category: "Data Visualization"},

      # Games
      %{title: "Wordle", description: "Wordle clone with multiplayer viewing", path: ~p"/wordle", category: "Games"},
      %{title: "Wordle God Mode", description: "Unlimited plays and custom words", path: ~p"/wordle_god", category: "Games"},
      %{title: "AI Pong", description: "Infinite Pong with AI controls", path: ~p"/pong", category: "Games"},
      %{title: "Pong God View", description: "Watch all infinite pong games", path: ~p"/pong/god", category: "Games"},
      %{title: "Blackjack", description: "Classic casino card game", path: ~p"/blackjack", category: "Games"},

      # Social
      %{title: "Emoji Skeets", description: "Filter Bluesky firehose by emojis", path: ~p"/emoji-skeets", category: "Social"},
      %{title: "Bluesky YouTube Links", description: "Live YouTube links from Bluesky", path: ~p"/reddit-links", category: "Social"},
      %{title: "No Words Allowed Chat", description: "Chat with word restrictions", path: ~p"/allowed-chats", category: "Social"},

      # Development
      %{title: "Python Playground", description: "Run Python code in browser", path: ~p"/python-demo", category: "Development"},
      %{title: "Markdown Editor", description: "Live markdown editor with preview", path: ~p"/markdown-editor", category: "Productivity"},

      # Interactive
      %{title: "Cursor Tracker", description: "Track cursors and draw spots", path: ~p"/cursor-tracker", category: "Interactive"},
      %{title: "Typewriter", description: "Visualize your keystrokes", path: ~p"/typewriter", category: "Interactive"},
      %{title: "Code Mirror", description: "A code mirror application", path: ~p"/mirror", category: "Development"},

      # News & Productivity
      %{title: "Hacker News Live", description: "Real-time tech news feed", path: ~p"/hacker-news", category: "News"},
      %{title: "Bookmarks", description: "Personal bookmark collection", path: ~p"/bookmarks", category: "Productivity"},

      # Comedy - Nathan Fielder
      %{title: "Nathan Archive", description: "Nathan Fielder content hub", path: ~p"/nathan", category: "Comedy"},

    ]

    reader_id =
      if connected?(socket) do
        id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

        # Generate a random color for this visitor
        hue = :rand.uniform(360)
        color = "hsl(#{hue}, 70%, 60%)"

        {:ok, _} =
          Presence.track(self(), @presence_topic, id, %{
            page: "index",
            joined_at: DateTime.utc_now(),
            cursor_position: nil,
            color: color,
            display_name: nil,
            current_room: "frontpage"
          })

        # Subscribe to presence and chat topics
        Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
        Phoenix.PubSub.subscribe(Blog.PubSub, @chat_topic)

        Logger.debug(
          "User #{id} mounted and subscribed to topics: #{@presence_topic}, #{@chat_topic}"
        )

        id
      else
        nil
      end

    posts = Blog.Content.Post.all()
    %{tech: tech_posts, non_tech: non_tech_posts} = Content.categorize_posts(posts)

    # Get all current visitors from presence
    visitor_cursors =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    total_readers = map_size(visitor_cursors)

    # Get messages for the frontpage chat - always fetch from ETS
    messages = Chat.get_messages("frontpage")
    Logger.debug("Loaded #{length(messages)} messages for frontpage room during mount")

    modal_state =
      case params["modal"] do
        "tech_posts" -> :tech_posts
        "non_tech_posts" -> :non_tech_posts
        "demos" -> :demos
        _ -> nil
      end

    {:ok,
     assign(socket,
       tech_posts: tech_posts,
       demos: demos,
       non_tech_posts: non_tech_posts,
       total_readers: total_readers,
       page_title: "Thoughts & Tidbits",
       cursor_position: nil,
       reader_id: reader_id,
       visitor_cursors: visitor_cursors,
       name_form: %{"name" => ""},
       name_submitted: false,
       show_chat: false,
       chat_messages: messages,
       chat_form: %{"message" => ""},
       current_room: "frontpage",
       chat_rooms: @default_rooms,
       room_users: %{
         "frontpage" => 0
       },
       show_mod_panel: false,
       banned_word_form: %{"word" => ""},
       # This is a simple example - in a real app you'd use proper auth
       mod_password: "letmein",
       show_mobile_modal: modal_state != nil,
       selected_mobile_content: modal_state,
       selected_category: "All"
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    modal_state =
      case params["modal"] do
        "tech_posts" -> :tech_posts
        "non_tech_posts" -> :non_tech_posts
        "demos" -> :demos
        _ -> nil
      end

    {:noreply,
     assign(socket,
       show_mobile_modal: modal_state != nil,
       selected_mobile_content: modal_state
     )}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    visitor_cursors =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    total_readers = map_size(visitor_cursors)

    # Count users in each room
    room_users =
      visitor_cursors
      |> Enum.reduce(
        %{
          "frontpage" => 0
        },
        fn {_id, meta}, acc ->
          room = Map.get(meta, :current_room, "general")
          Map.update(acc, room, 1, &(&1 + 1))
        end
      )

    {:noreply,
     assign(socket,
       total_readers: total_readers,
       visitor_cursors: visitor_cursors,
       room_users: room_users
     )}
  end

  def handle_info({:new_chat_message, message}, socket) do
    Logger.debug(
      "Received new chat message: #{inspect(message.id)} in room #{message.room} from #{message.sender_name}"
    )

    # Only update messages if we're in the same room as the message
    if message.room == socket.assigns.current_room do
      # Get all messages from ETS to ensure we have the latest data
      updated_messages = Chat.get_messages(socket.assigns.current_room)

      Logger.debug(
        "Updated chat messages for room #{socket.assigns.current_room}, now have #{length(updated_messages)} messages"
      )

      {:noreply, assign(socket, chat_messages: updated_messages)}
    else
      Logger.debug(
        "Ignoring message for room #{message.room} since user is in room #{socket.assigns.current_room}"
      )

      {:noreply, socket}
    end
  end

  def handle_event("mousemove", %{"x" => x, "y" => y}, socket) do
    reader_id = socket.assigns.reader_id

    # Update local cursor position
    cursor_position = %{x: x, y: y}
    socket = assign(socket, cursor_position: cursor_position)

    if reader_id do
      # Update the presence with the new cursor position
      Presence.update(self(), @presence_topic, reader_id, fn meta ->
        Map.put(meta, :cursor_position, cursor_position)
      end)
    end

    {:noreply, socket}
  end

  def handle_event("save_name", %{"name" => name}, socket) do
    reader_id = socket.assigns.reader_id
    trimmed_name = String.trim(name)

    if reader_id && trimmed_name != "" do
      # Update the presence with the display name
      Presence.update(self(), @presence_topic, reader_id, fn meta ->
        Map.put(meta, :display_name, trimmed_name)
      end)

      {:noreply, assign(socket, name_submitted: true, show_chat: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name_form: %{"name" => name})}
  end

  def handle_event("skip_name", _params, socket) do
    {:noreply, assign(socket, name_submitted: true, show_chat: true)}
  end

  def handle_event("toggle_chat", _params, socket) do
    {:noreply, assign(socket, show_chat: !socket.assigns.show_chat)}
  end

  def handle_event("toggle_mod_panel", _params, socket) do
    {:noreply, assign(socket, show_mod_panel: !socket.assigns.show_mod_panel)}
  end

  def handle_event("add_banned_word", %{"word" => word, "password" => password}, socket) do
    if password == socket.assigns.mod_password do
      case Chat.add_banned_word(word) do
        {:ok, _} ->
          {:noreply, assign(socket, banned_word_form: %{"word" => ""})}

        {:error, _} ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_banned_word", %{"word" => word}, socket) do
    {:noreply, assign(socket, banned_word_form: %{"word" => word})}
  end

  def handle_event("change_room", %{"room" => room}, socket) when room in @default_rooms do
    reader_id = socket.assigns.reader_id

    if reader_id do
      # Update the presence with the new room
      Presence.update(self(), @presence_topic, reader_id, fn meta ->
        Map.put(meta, :current_room, room)
      end)

      # Get messages for the new room
      messages = Chat.get_messages(room)
      Logger.debug("Changed room to #{room}, loaded #{length(messages)} messages")

      {:noreply, assign(socket, current_room: room, chat_messages: messages)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("send_chat_message", %{"message" => message}, socket) do
    reader_id = socket.assigns.reader_id
    current_room = socket.assigns.current_room
    trimmed_message = String.trim(message)

    Logger.debug("Handling send_chat_message event for #{reader_id} in room #{current_room}")

    if reader_id && trimmed_message != "" do
      # Check for banned words
      case Chat.check_for_banned_words(trimmed_message) do
        {:ok, _} ->
          # Message is clean, proceed with sending
          # Get display name from presence
          visitor_meta =
            case Presence.get_by_key(@presence_topic, reader_id) do
              %{metas: [meta | _]} -> meta
              _ -> %{display_name: nil, color: "hsl(200, 70%, 60%)"}
            end

          display_name = visitor_meta.display_name || "visitor #{String.slice(reader_id, -4, 4)}"
          color = visitor_meta.color

          # Create the message
          new_message = %{
            id: System.os_time(:millisecond),
            sender_id: reader_id,
            sender_name: display_name,
            sender_color: color,
            content: trimmed_message,
            timestamp: DateTime.utc_now(),
            room: current_room
          }

          # Save message to ETS
          saved_message = Chat.save_message(new_message)
          Logger.debug("Saved new message to ETS with ID: #{inspect(saved_message.id)}")

          # Broadcast the message to all clients - use broadcast! to raise errors
          Phoenix.PubSub.broadcast!(
            Blog.PubSub,
            @chat_topic,
            {:new_chat_message, saved_message}
          )

          Logger.debug("Broadcast message to topic #{@chat_topic} succeeded")

          # Get updated messages from ETS to ensure consistency
          updated_messages = Chat.get_messages(current_room)

          Logger.debug(
            "After sending: room #{current_room} has #{length(updated_messages)} messages"
          )

          {:noreply,
           assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}

        {:error, :contains_banned_words} ->
          # Message contains banned words, reject it
          system_message = %{
            id: System.os_time(:millisecond),
            sender_id: "system",
            sender_name: "ChatBot",
            sender_color: "hsl(0, 100%, 50%)",
            content: "Your message was not sent because it contains prohibited words.",
            timestamp: DateTime.utc_now(),
            room: current_room
          }

          # Only show the warning to the sender
          updated_messages = [system_message | socket.assigns.chat_messages] |> Enum.take(50)

          {:noreply,
           assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_chat_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, chat_form: %{"message" => message})}
  end

  # Function to format message text and make URLs clickable
  def format_message_with_links(content) when is_binary(content) do
    Regex.replace(@url_regex, content, fn url, _ ->
      # Ensure URL has http/https prefix for the href attribute
      href =
        if String.starts_with?(url, ["http://", "https://"]) do
          url
        else
          "https://#{url}"
        end

      # Create the anchor tag with appropriate attributes
      # Note: We use target="_blank" and rel="noopener noreferrer" for security
      "<a href=\"#{href}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-600 hover:underline break-all\">#{url}</a>"
    end)
  end

  # Add a debug function to be used for troubleshooting
  def debug_chat_state(socket) do
    Logger.debug("------- CHAT DEBUG -------")
    Logger.debug("Reader ID: #{socket.assigns.reader_id}")
    Logger.debug("Current room: #{socket.assigns.current_room}")
    Logger.debug("Message count: #{length(socket.assigns.chat_messages)}")

    # Dump the contents of the ETS table for this room
    room_messages = Chat.get_messages(socket.assigns.current_room)
    Logger.debug("ETS messages for room: #{length(room_messages)}")

    if length(room_messages) > 0 do
      sample = Enum.take(room_messages, 2)
      Logger.debug("Sample messages: #{inspect(sample)}")
    end

    Logger.debug("-------------------------")
    socket
  end

  # Handle modal open event
  def handle_event("open_mobile_modal", %{"content" => content}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?modal=#{content}")}
  end

  # Handle modal close event
  def handle_event("close_mobile_modal", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/")}
  end


  # Handle category filter event
  def handle_event("filter_category", %{"category" => category}, socket) do
    {:noreply, assign(socket, selected_category: category)}
  end

  def render(assigns) do
    posts = (assigns.tech_posts ++ assigns.non_tech_posts) |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})
    assigns = assign(assigns, :all_posts, posts)

    ~H"""
    <div class="mac-blog">
      <!-- Menu Bar -->
      <div class="mac-menu-bar">
        <div class="menu-left">
          <span class="apple-menu">&#63743;</span>
          <span class="menu-item">File</span>
          <span class="menu-item">Edit</span>
          <span class="menu-item">View</span>
          <a href="/" class="menu-item" style="text-decoration: none; color: inherit;">Home</a>
        </div>
        <div class="menu-right">
          <span><%= @total_readers %> online</span>
        </div>
      </div>

      <!-- Desktop -->
      <div class="mac-desktop">
        <!-- Blog Posts Window -->
        <div class="mac-window">
          <div class="mac-title-bar">
            <div class="mac-close-box"></div>
            <div class="mac-title">Thoughts & Tidbits - Blog</div>
            <div class="mac-resize-box"></div>
          </div>
          <div class="mac-window-content">
            <div class="blog-posts-list">
              <%= for post <- @all_posts do %>
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
          <div class="mac-status-bar">
            <span><%= length(@all_posts) %> posts</span>
            <span><%= @total_readers %> <%= if @total_readers == 1, do: "reader", else: "readers" %></span>
          </div>
        </div>
      </div>
    </div>

    <style>
      .mac-blog {
        height: 100vh;
        background: #a8a8a8;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 12px;
        cursor: default;
        -webkit-font-smoothing: none;
        overflow: hidden;
      }

      .mac-menu-bar {
        height: 20px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
      }

      .mac-blog .menu-left {
        display: flex;
        gap: 16px;
      }

      .mac-blog .apple-menu {
        font-family: system-ui;
        font-size: 14px;
      }

      .mac-blog .menu-item {
        cursor: default;
      }

      .mac-blog .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .mac-blog .menu-right {
        font-size: 11px;
      }

      .mac-desktop {
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
        justify-content: center;
        align-items: flex-start;
      }

      .mac-window {
        width: 600px;
        max-width: 95vw;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        margin-top: 20px;
      }

      .mac-title-bar {
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
      }

      .mac-resize-box {
        width: 12px;
        height: 12px;
      }

      .mac-window-content {
        padding: 0;
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
        padding: 8px 12px;
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

      .blog-post-icon {
        font-size: 24px;
        margin-right: 12px;
        width: 32px;
        text-align: center;
      }

      .blog-post-info {
        flex: 1;
      }

      .blog-post-title {
        font-weight: bold;
        font-size: 13px;
        margin-bottom: 2px;
      }

      .blog-post-meta {
        font-size: 10px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
      }

      .blog-post-row:hover .blog-post-meta {
        color: #ccc;
      }

      .blog-post-tags {
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
      }

      .blog-tag {
        background: #e0e0e0;
        padding: 1px 6px;
        border-radius: 3px;
        font-size: 9px;
      }

      .mac-status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
      }

      @media (max-width: 768px) {
        .mac-desktop {
          padding: 10px;
        }

        .mac-window {
          width: 100%;
          margin-top: 10px;
        }

        .mac-blog .menu-item {
          display: none;
        }

        .mac-blog .menu-item:last-child {
          display: inline;
        }

        .blog-post-icon {
          font-size: 20px;
          margin-right: 8px;
          width: 24px;
        }

        .blog-post-title {
          font-size: 12px;
        }
      }
    </style>
    """
  end


end
