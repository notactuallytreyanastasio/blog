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
      %{
        title: "MTA Bus Tracker",
        description: "Track Manhattan buses in real-time",
        path: ~p"/mta-bus-map",
        category: "Data Visualization"
      },
      %{
        title: "Bezier Triangles",
        description: "Trippy animation with bezier curves and spinning triangles",
        path: ~p"/bezier-triangles",
        category: "Art"
      },
      %{
        title: "Wordle",
        description: "Wordle clone with multiplayer viewing",
        path: ~p"/wordle",
        category: "Games"
      },
      %{
        title: "Pong God Mode",
        description: "Watch all infinite pong games",
        path: ~p"/pong/god",
        category: "Games"
      },
      %{
        title: "AI Pong",
        description: "Infinite Pong with AI controls",
        path: ~p"/pong",
        category: "Games"
      },
      %{
        title: "Python Playground",
        description: "Run Python code in your browser",
        path: ~p"/python-demo",
        category: "Development"
      },
      %{
        title: "Cursor Tracker",
        description: "Track cursors and draw favorite spots",
        path: ~p"/cursor-tracker",
        category: "Interactive"
      },
      %{
        title: "Rainbow Chaos",
        description: "SSR animations with keyboard interaction",
        path: ~p"/gay_chaos",
        category: "Art"
      },
      %{
        title: "Reddit Links",
        description: "Live feed of YouTube links from social",
        path: ~p"/reddit-links",
        category: "Social"
      },
      %{
        title: "Emoji Skeets",
        description: "Filter Bluesky firehose by emojis",
        path: ~p"/emoji-skeets",
        category: "Social"
      },
      %{
        title: "Hacker News Live",
        description: "Real-time tech news feed",
        path: ~p"/hacker-news",
        category: "News"
      },
      %{
        title: "Blackjack",
        description: "Classic casino card game",
        path: ~p"/blackjack",
        category: "Games"
      },
      %{
        title: "War Card Game",
        description: "Simple card game of War",
        path: ~p"/war",
        category: "Games"
      },
      %{
        title: "Generative Art",
        description: "Dynamic generative art canvas",
        path: ~p"/generative-art",
        category: "Art"
      },
      %{
        title: "Bubble Game",
        description: "Interactive bubble popping game",
        path: ~p"/bubble-game",
        category: "Games"
      },
      %{
        title: "Markdown Editor",
        description: "Live markdown editor with preview",
        path: ~p"/markdown-editor",
        category: "Productivity"
      },
      %{
        title: "Nathan Fielder Archive",
        description: "Various Nathan Fielder content styles",
        path: ~p"/nathan",
        category: "Comedy"
      },
      %{
        title: "Bookmarks",
        description: "Personal bookmark collection",
        path: ~p"/bookmarks",
        category: "Productivity"
      },
      %{
        title: "Museum",
        description: "Full museum of all projects",
        path: ~p"/museum",
        category: "Meta"
      }
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

  # Helper functions
  defp get_demo_categories(demos) do
    demos
    |> Enum.map(fn demo -> Map.get(demo, :category, "Demo") end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp filter_demos(demos, "All"), do: demos

  defp filter_demos(demos, category) do
    Enum.filter(demos, fn demo -> Map.get(demo, :category, "Demo") == category end)
  end

  def render(assigns) do
    ~H"""
    <!-- AIM Name Dialog -->
    <%= if @reader_id && !@name_submitted do %>
      <div class="aim-name-dialog">
        <div class="aim-name-dialog-titlebar">
          <span>Enter Screen Name</span>
        </div>
        <div class="aim-name-dialog-content">
          <div class="aim-name-dialog-text">
            Please enter your screen name to join the chat room:
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
                OK
              </button>
              <button type="button" class="aim-name-btn" phx-click="skip_name">
                Skip
              </button>
            </div>
          </.form>
        </div>
      </div>
    <% end %>

    <div class="site-header">
      <h1 class="site-title">Thoughts & Tidbits</h1>
      <p class="site-subtitle">
        A collection of thoughts on technology, life, and weird little things I make
      </p>
      <div class="flex items-center justify-center space-x-4">
        <div class="reader-count">
          <div class="reader-dot"></div>
          {@total_readers} {if @total_readers == 1, do: "person", else: "people"} browsing
        </div>
        <a href="/post/whats-my-schtick" class="schtick-link">
          what's my schtick?
        </a>
      </div>
    </div>

    <div class="main-container" phx-hook="PostExpander" id="post-expander">
      <!-- Left Column: Blog Posts -->
      <div class="posts-column">
        <div class="posts-header">
          Recent Posts
        </div>
        <div class="posts-list" id="posts-list">
          <%= for post <- (@tech_posts ++ @non_tech_posts) |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime}) do %>
            <div class="post-card" id={"post-#{post.slug}"}>
              <a href={~p"/post/#{post.slug}"} class="post-link">
                <div class="post-info">
                  <h3 class="post-title">{post.title}</h3>
                  <div class="post-meta">
                    {Calendar.strftime(post.written_on, "%B %d, %Y")}
                  </div>
                  <div class="post-tags">
                    <%= for tag <- post.tags do %>
                      <span class="post-tag">{tag.name}</span>
                    <% end %>
                  </div>
                </div>
              </a>
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- Right Column: Museum/Projects -->
      <div class="museum-column">
        <div class="museum-header">
          🏛️ Project Museum
        </div>
        <div class="museum-content">
          <div class="category-filter">
            <%= for category <- ["All" | get_demo_categories(@demos)] do %>
              <button
                class={["category-btn", if(@selected_category == category, do: "active", else: "")]}
                phx-click="filter_category"
                phx-value-category={category}
              >
                {category}
              </button>
            <% end %>
          </div>

          <div class="projects-grid">
            <%= for demo <- filter_demos(@demos, @selected_category || "All") do %>
              <a href={demo.path} class="project-card">
                <div class="project-title">{demo.title}</div>
                <div class="project-description">{demo.description}</div>
                <div class="project-category">{demo.category || "Demo"}</div>
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </div>

    <!-- AIM Style Chat -->
    <button
      class="aim-toggle-btn"
      phx-click="toggle_chat"
      style={if @show_chat, do: "display: none;", else: ""}
    >
      Chat Room
    </button>

    <div class={["aim-chat-container", if(@show_chat, do: "open", else: "")]}>
      <div class="aim-chat-titlebar">
        <span class="aim-chat-title">General Chat Room</span>
        <div class="aim-chat-controls">
          <button class="aim-control-btn" phx-click="toggle_chat">×</button>
        </div>
      </div>

      <div class="aim-chat-content">
        <div class="aim-buddy-list-title">Online ({@total_readers})</div>
        <div class="aim-buddy-list">
          <%= for {_id, user} <- @visitor_cursors do %>
            <div class="aim-buddy">
              <div class="aim-buddy-status"></div>
              <span class="aim-buddy-name">
                {if Map.get(user, :display_name), do: Map.get(user, :display_name), else: "Anonymous"}
              </span>
            </div>
          <% end %>
        </div>

        <div class="aim-messages-area" id="aim-chat-messages">
          <%= for message <- @chat_messages do %>
            <div class="aim-message">
              <span class="aim-message-sender" style={"color: #{message.sender_color};"}>
                {message.sender_name}
              </span>
              <span class="aim-message-time">
                {Calendar.strftime(message.timestamp, "%I:%M %p")}
              </span>
              <div class="aim-message-content">
                {raw(format_message_with_links(message.content))}
              </div>
            </div>
          <% end %>
          <%= if Enum.empty?(@chat_messages) do %>
            <div class="aim-message">
              <span class="aim-message-sender" style="color: #000080;">ChatBot</span>
              <div class="aim-message-content">Welcome to the chat room! Say hello!</div>
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
            >{@chat_form["message"]}</textarea>
            <button type="submit" class="aim-send-btn">Send</button>
            <div style="clear: both;"></div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  # Check if post is expanded
  defp post_expanded?(assigns, slug) do
    MapSet.member?(assigns.expanded_posts, slug)
  end

  # Desktop view function
  defp render_desktop_view(assigns) do
    ~H"""
    <div
      class="py-12 px-4 sm:px-6 lg:px-8 min-h-screen"
      id="cursor-tracker-container"
      phx-hook="CursorTracker"
    >
      <!-- Name input form if not yet submitted -->
      <%= if @reader_id && !@name_submitted do %>
        <div class="fixed top-4 right-4 z-50">
          <.form
            for={%{}}
            phx-submit="save_name"
            phx-change="validate_name"
            class="flex items-center space-x-2"
          >
            <div class="bg-gradient-to-r from-fuchsia-500 to-cyan-500 p-0.5 rounded-lg shadow-md">
              <div class="bg-white rounded-md px-3 py-2 flex items-center space-x-2">
                <input
                  type="text"
                  name="name"
                  value={@name_form["name"]}
                  placeholder="WHAT'S YOUR NAME?"
                  maxlength="20"
                  class="text-sm font-mono text-gray-800 focus:outline-none"
                />
                <button
                  type="submit"
                  class="bg-gradient-to-r from-fuchsia-500 to-cyan-500 text-white text-xs font-bold px-3 py-1 rounded-md"
                >
                  SET
                </button>
              </div>
            </div>
          </.form>
        </div>
      <% end %>
      
    <!-- Moderator Panel (Hidden from regular users) -->
      <%= if @show_mod_panel do %>
        <div class="fixed top-20 left-4 z-50 bg-gray-900 text-white p-4 rounded-lg shadow-xl border border-red-500 w-80">
          <div class="flex justify-between items-center mb-3">
            <h3 class="font-bold">Moderator Panel</h3>
            <button phx-click="toggle_mod_panel" class="text-red-400 hover:text-red-300">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                  clip-rule="evenodd"
                />
              </svg>
            </button>
          </div>

          <div class="mb-4">
            <h4 class="text-sm font-bold mb-2 text-red-400">Add Word to Ban List</h4>
            <.form for={%{}} phx-submit="add_banned_word" phx-change="validate_banned_word">
              <div class="flex flex-col space-y-2">
                <input
                  type="text"
                  name="word"
                  value={@banned_word_form["word"]}
                  placeholder="Enter word to ban"
                  class="px-2 py-1 bg-gray-800 border border-gray-700 rounded text-sm"
                />
                <input
                  type="password"
                  name="password"
                  placeholder="Moderator password"
                  class="px-2 py-1 bg-gray-800 border border-gray-700 rounded text-sm"
                />
                <button
                  type="submit"
                  class="bg-red-600 hover:bg-red-700 text-white py-1 px-2 rounded text-sm"
                >
                  Add to Ban List
                </button>
              </div>
            </.form>
          </div>

          <div class="text-xs text-gray-400 mt-2">
            This panel is not visible to users. The banned word list is not displayed anywhere.
          </div>
        </div>
      <% end %>
      
    <!-- Join Chat Button -->
      <div class="fixed bottom-4 right-4 z-50">
        <button
          phx-click="toggle_chat"
          class="group bg-gradient-to-r from-yellow-400 to-yellow-500 border-2 border-yellow-600 rounded-md px-4 py-2 font-bold text-blue-900 shadow-lg hover:shadow-xl transition-all duration-300"
          style="font-family: 'Comic Sans MS', cursive, sans-serif; text-shadow: 1px 1px 0 #fff;"
        >
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-green-500 mr-2 group-hover:bg-red-500 transition-colors">
            </div>
            {if @show_chat, do: "Close Chat", else: "Join Chat"}
          </div>
        </button>
      </div>
      
    <!-- Expanded AIM-style Chat Window -->
      <%= if @show_chat do %>
        <div class="fixed bottom-16 right-4 w-[90vw] md:w-[40rem] h-[70vh] z-50 shadow-2xl flex">
          <!-- Room Sidebar -->
          <div class="w-48 bg-gray-100 border-2 border-r-0 border-gray-400 rounded-l-md flex flex-col">
            <!-- Room Header -->
            <div
              class="bg-blue-800 text-white px-3 py-2 font-bold border-b-2 border-gray-400"
              style="font-family: 'Comic Sans MS', cursive, sans-serif;"
            >
              Chat Rooms
            </div>
            
    <!-- Room List -->
            <div class="flex-1 overflow-y-auto p-2">
              <%= for room <- @chat_rooms do %>
                <button
                  phx-click="change_room"
                  phx-value-room={room}
                  class={"w-full text-left mb-2 px-3 py-2 rounded #{if @current_room == room, do: "bg-yellow-100 border border-yellow-300", else: "hover:bg-gray-200"}"}
                >
                  <div class="flex items-center justify-between">
                    <div class="flex items-center">
                      <!-- Room Icon based on room name -->
                      <%= case room do %>
                        <% "general" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="h-4 w-4 mr-2 text-blue-600"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"
                            />
                          </svg>
                        <% "random" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="h-4 w-4 mr-2 text-purple-600"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                          </svg>
                        <% "programming" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="h-4 w-4 mr-2 text-green-600"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
                            />
                          </svg>
                        <% "music" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="h-4 w-4 mr-2 text-red-600"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"
                            />
                          </svg>
                      <% end %>
                      <span style="font-family: 'Tahoma', sans-serif;" class="text-sm">
                        {String.capitalize(room)}
                      </span>
                    </div>
                    <span class="bg-blue-100 text-blue-800 text-xs px-2 py-0.5 rounded-full">
                      {Map.get(@room_users, room, 0)}
                    </span>
                  </div>
                </button>
              <% end %>
            </div>
            
    <!-- Online Users -->
            <div class="p-2 border-t-2 border-gray-400">
              <div class="text-xs text-gray-600 mb-1 font-bold">Online Users</div>
              <div class="max-h-40 overflow-y-auto">
                <%= for {_id, user} <- @visitor_cursors do %>
                  <div class="flex items-center mb-1">
                    <div class="w-2 h-2 rounded-full bg-green-500 mr-1"></div>
                    <span class="text-xs truncate" style={"color: #{user.color};"}>
                      {if Map.get(user, :display_name),
                        do: Map.get(user, :display_name),
                        else: "Anonymous"}
                    </span>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
          
    <!-- Main Chat Area -->
          <div class="flex-1 flex flex-col">
            <!-- Chat Window Header -->
            <div class="bg-blue-800 text-white px-3 py-2 flex justify-between items-center rounded-tr-md border-2 border-b-0 border-l-0 border-gray-400">
              <div
                class="font-bold flex items-center"
                style="font-family: 'Comic Sans MS', cursive, sans-serif;"
              >
                <%= case @current_room do %>
                  <% "general" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5 mr-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>
                    General Chat
                  <% "random" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5 mr-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    Random Chat
                  <% "programming" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5 mr-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
                      />
                    </svg>
                    Programming Chat
                  <% "music" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5 mr-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"
                      />
                    </svg>
                    Music Chat
                <% end %>
              </div>
              <div class="flex space-x-1">
                <div class="w-3 h-3 rounded-full bg-yellow-400 border border-yellow-600"></div>
                <div class="w-3 h-3 rounded-full bg-green-400 border border-green-600"></div>
                <div
                  class="w-3 h-3 rounded-full bg-red-400 border border-red-600 cursor-pointer"
                  phx-click="toggle_chat"
                >
                </div>
              </div>
            </div>
            
    <!-- Chat Window Body -->
            <div
              class="bg-white border-2 border-t-0 border-b-0 border-l-0 border-gray-400 flex-1 overflow-y-auto p-3"
              style="font-family: 'Courier New', monospace;"
              id="chat-messages"
            >
              <%= for message <- @chat_messages do %>
                <div class="mb-3 hover:bg-gray-50 p-2 rounded">
                  <div class="flex items-center mb-1">
                    <span class="font-bold" style={"color: #{message.sender_color};"}>
                      {message.sender_name}
                    </span>
                    <span class="text-xs text-gray-500 ml-2">
                      {Calendar.strftime(message.timestamp, "%I:%M %p")}
                    </span>
                  </div>
                  <div
                    class="text-gray-800 break-words pl-1 border-l-2"
                    style={"border-color: #{message.sender_color};"}
                  >
                    {raw(format_message_with_links(message.content))}
                  </div>
                </div>
              <% end %>
              <%= if Enum.empty?(@chat_messages) do %>
                <div class="text-center text-gray-500 italic mt-8">
                  <div class="mb-2">Welcome to the {String.capitalize(@current_room)} room!</div>
                  <div>No messages yet. Be the first to say hello!</div>
                </div>
              <% end %>
            </div>
            
    <!-- Chat Input Area -->
            <div class="bg-gray-200 border-2 border-t-0 border-l-0 border-gray-400 rounded-br-md p-3">
              <.form
                for={%{}}
                phx-submit="send_chat_message"
                phx-change="validate_chat_message"
                class="flex"
              >
                <input
                  type="text"
                  name="message"
                  value={@chat_form["message"]}
                  placeholder={"Type a message in #{String.capitalize(@current_room)}..."}
                  maxlength="500"
                  class="flex-1 border border-gray-400 rounded px-3 py-2 text-sm"
                  autocomplete="off"
                />
                <button
                  type="submit"
                  class="ml-2 bg-yellow-400 hover:bg-yellow-500 text-blue-900 font-bold px-4 py-2 rounded border border-yellow-600"
                >
                  Send
                </button>
              </.form>
            </div>
          </div>
        </div>
      <% end %>

      <%= if @cursor_position do %>
        <div class="fixed top-4 right-4 bg-gradient-to-r from-fuchsia-500 to-cyan-500 text-white px-3 py-1 rounded-lg shadow-md text-sm font-mono z-50">
          x: {@cursor_position.x}, y: {@cursor_position.y}
        </div>
        
    <!-- Full screen crosshair with gradient and smooth transitions -->
        <div class="fixed inset-0 pointer-events-none z-40">
          <!-- Horizontal line across entire screen with gradient -->
          <div
            class="absolute w-full h-0.5 opacity-40 transition-all duration-200 ease-out"
            style={"top: #{@cursor_position.y}px; background: linear-gradient(to right, #d946ef, #0891b2);"}
          >
          </div>
          
    <!-- Vertical line across entire screen with gradient -->
          <div
            class="absolute h-full w-0.5 opacity-40 transition-all duration-200 ease-out"
            style={"left: #{@cursor_position.x}px; background: linear-gradient(to bottom, #d946ef, #0891b2);"}
          >
          </div>
        </div>
      <% end %>
      
    <!-- Show all visitor cursors except our own -->
      <%= for {id, meta} <- @visitor_cursors do %>
        <%= if id != @reader_id && Map.get(meta, :cursor_position) do %>
          <div
            class="absolute w-4 h-4 pointer-events-none transform -translate-x-2 -translate-y-2 transition-all duration-100"
            style={"left: #{Map.get(meta, :cursor_position, %{})[:x]}px; top: #{Map.get(meta, :cursor_position, %{})[:y]}px;"}
          >
            <div class="relative">
              <div
                class="w-4 h-4 absolute animate-ping rounded-full opacity-20"
                style={"background-color: #{meta.color}"}
              >
              </div>
              <div class="w-4 h-4 rounded-full" style={"background-color: #{meta.color}"}></div>
              <%= if meta.display_name do %>
                <div class="absolute left-5 top-0 px-2 py-1 text-xs rounded bg-gray-800 text-white whitespace-nowrap">
                  {meta.display_name}
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
      <% end %>

      <div class="max-w-7xl mx-auto">
        <!-- Header with retro styling -->
        <header class="mb-12 text-center">
          <div class="inline-block p-1 bg-gradient-to-r from-fuchsia-500 to-cyan-500 rounded-lg shadow-lg mb-6">
            <h1 class="text-4xl md:text-5xl font-bold bg-white px-6 py-3 rounded-md">
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                Thoughts & Tidbits
              </span>
            </h1>
          </div>

          <div class="flex justify-center items-center space-x-2 text-sm text-gray-600 mb-4">
            <div class="inline-flex items-center px-3 py-1 rounded-full bg-gradient-to-r from-fuchsia-100 to-cyan-100 border border-fuchsia-200">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4 mr-1 text-fuchsia-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
              <span>
                {@total_readers} {if @total_readers == 1, do: "person", else: "people"} browsing
              </span>
            </div>
          </div>

          <p class="text-gray-600 max-w-2xl mx-auto">
            A collection of thoughts on technology, life, and weird little things I make.
          </p>
        </header>
        
    <!-- Two column layout for posts -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- Tech Posts Column -->
          <div class="bg-gradient-to-br from-fuchsia-50 to-cyan-50 rounded-xl p-6 shadow-lg border border-fuchsia-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                Tech & Programming
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-fuchsia-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-fuchsia-600 transition-colors">
                      {post.title}
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-fuchsia-100 to-cyan-100 rounded-full text-xs font-medium text-gray-700">
                          {tag.name}
                        </span>
                      <% end %>
                    </div>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Non-Tech Posts Column -->
          <div class="bg-gradient-to-br from-cyan-50 to-fuchsia-50 rounded-xl p-6 shadow-lg border border-cyan-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-600 to-fuchsia-600">
                Life & Everything Else
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @non_tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-cyan-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-cyan-600 transition-colors">
                      {post.title}
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-cyan-100 to-fuchsia-100 rounded-full text-xs font-medium text-gray-700">
                          {tag.name}
                        </span>
                      <% end %>
                    </div>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Tech Demos Column -->
          <div class="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-xl p-6 shadow-lg border border-indigo-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-purple-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-pink-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-purple-600">
                Interactive Demos
              </h2>
            </div>

            <div class="space-y-4">
              <%= for demo <- @demos do %>
                <.link navigate={demo.path} class="block">
                  <div class={"group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-#{demo.color}-400 hover:border-#{demo.color}-500"}>
                    <div class="flex items-center justify-between">
                      <div>
                        <h3 class={"text-xl font-bold text-gray-800 group-hover:text-#{demo.color}-600 transition-colors"}>
                          {demo.title}
                        </h3>
                        <p class="text-sm text-gray-600 mt-1">
                          {demo.description}
                        </p>
                      </div>
                      <span class={"text-#{demo.color}-600 group-hover:translate-x-0.5 transition-transform"}>
                        →
                      </span>
                    </div>
                  </div>
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Retro footer -->
      <footer class="mt-16 text-center">
        <span class="font-mono">/* Crafted with ♥ and Elixir */</span>
        
    <!-- Moderator Button - subtle but visible -->
        <div class="mt-4 flex justify-center">
          <button
            phx-click="toggle_mod_panel"
            class="flex items-center px-3 py-1 text-xs text-gray-500 hover:text-gray-800 border border-gray-200 rounded-md transition-colors duration-200 bg-white hover:bg-gray-50"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-3.5 w-3.5 mr-1"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
              />
            </svg>
            Moderator Access
          </button>
        </div>
      </footer>
    </div>
    """
  end

  # Mobile view with buttons
  defp render_mobile_view(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center min-h-screen space-y-4">
      <button
        phx-click="open_mobile_modal"
        phx-value-content="tech_posts"
        class="px-4 py-2 bg-blue-500 text-white rounded"
      >
        TECH WRITING
      </button>
      <button
        phx-click="open_mobile_modal"
        phx-value-content="non_tech_posts"
        class="px-4 py-2 bg-green-500 text-white rounded"
      >
        OTHER WRITING
      </button>
      <button
        phx-click="open_mobile_modal"
        phx-value-content="demos"
        class="px-4 py-2 bg-purple-500 text-white rounded"
      >
        TOYS
      </button>

      <button phx-click="toggle_chat" class="px-4 py-2 bg-yellow-500 text-white rounded">
        {if @show_chat, do: "Close Chat", else: "Join Chat"}
      </button>

      <%= if @show_chat do %>
        <div class="fixed bottom-0 left-0 right-0 h-1/2 bg-white shadow-lg overflow-auto">
          <%= for message <- @chat_messages do %>
            <div class="p-2 border-b">
              <strong><%= message.sender_name %></strong>:
              <span>{raw(format_message_with_links(message.content))}</span>
              <span class="text-xs text-gray-500 ml-2">
                {Calendar.strftime(message.timestamp, "%I:%M %p")}
              </span>
            </div>
          <% end %>

          <.form
            for={%{}}
            phx-submit="send_chat_message"
            phx-change="validate_chat_message"
            class="p-2"
          >
            <input
              type="text"
              name="message"
              value={@chat_form["message"]}
              placeholder="Type a message..."
              maxlength="500"
              class="w-full border rounded px-3 py-2"
              autocomplete="off"
            />
            <button type="submit" class="mt-2 w-full bg-blue-500 text-white py-2 rounded">
              Send
            </button>
          </.form>
        </div>
      <% end %>
    </div>
    """
  end

  # Mobile modal rendering
  defp render_mobile_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white rounded-lg shadow-lg p-4 w-full max-w-md">
        <button phx-click="close_mobile_modal" class="mb-4 text-red-500">Close</button>
        <%= case @selected_mobile_content do %>
          <% :tech_posts -> %>
            <%= for post <- @tech_posts do %>
              <.link navigate={~p"/post/#{post.slug}"} class="block mb-2 text-blue-600">
                {post.title}
              </.link>
            <% end %>
          <% :non_tech_posts -> %>
            <%= for post <- @non_tech_posts do %>
              <.link navigate={~p"/post/#{post.slug}"} class="block mb-2 text-green-600">
                {post.title}
              </.link>
            <% end %>
          <% :demos -> %>
            <%= for demo <- @demos do %>
              <.link navigate={demo.path} class="block mb-2 text-purple-600">
                {demo.title}
              </.link>
            <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
