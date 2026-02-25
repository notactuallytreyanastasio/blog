defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.Chat
  alias Blog.Content
  alias Blog.Content.Post
  alias BlogWeb.Presence

  require Logger

  @presence_topic "blog_presence"
  @chat_topic "blog_chat"
  @default_rooms ["frontpage"]
  @url_regex ~r/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})/i

  @demos [
    # Featured
    %{title: "Role Call", description: "Discover TV shows through writers you love", path: "/role-call", category: "Discovery"},
    %{title: "300+ Years of Tree Law", description: "A timeline and deep dive on tree law", path: "/trees", category: "Art"},

    # Data Viz & Maps
    %{title: "MTA Bus Map", description: "Track Manhattan buses in real-time", path: "/mta-bus-map", category: "Data Visualization"},

    # Games
    %{title: "Wordle", description: "Wordle clone with multiplayer viewing", path: "/wordle", category: "Games"},
    %{title: "Wordle God Mode", description: "Unlimited plays and custom words", path: "/wordle_god", category: "Games"},
    %{title: "AI Pong", description: "Infinite Pong with AI controls", path: "/pong", category: "Games"},
    %{title: "Pong God View", description: "Watch all infinite pong games", path: "/pong/god", category: "Games"},
    %{title: "Blackjack", description: "Classic casino card game", path: "/blackjack", category: "Games"},
    %{title: "War Card Game", description: "Simple card game of War", path: "/war", category: "Games"},

    # Art
    %{title: "Bezier Triangles", description: "Trippy bezier curves animation", path: "/bezier-triangles", category: "Art"},
    %{title: "Generative Art", description: "Dynamic generative art canvas", path: "/generative-art", category: "Art"},
    %{title: "Rainbow Chaos", description: "SSR animations with keyboard", path: "/gay_chaos", category: "Art"},

    # Social
    %{title: "Emoji Skeets", description: "Filter Bluesky firehose by emojis", path: "/emoji-skeets", category: "Social"},
    %{title: "Bluesky YouTube Links", description: "Live YouTube links from Bluesky", path: "/reddit-links", category: "Social"},
    %{title: "No Words Allowed Chat", description: "Chat with word restrictions", path: "/allowed-chats", category: "Social"},

    # Development
    %{title: "Python Playground", description: "Run Python code in browser", path: "/python-demo", category: "Development"},
    %{title: "Markdown Editor", description: "Live markdown editor with preview", path: "/markdown-editor", category: "Productivity"},

    # Interactive
    %{title: "Cursor Tracker", description: "Track cursors and draw spots", path: "/cursor-tracker", category: "Interactive"},
    %{title: "Typewriter", description: "Visualize your keystrokes", path: "/typewriter", category: "Interactive"},
    %{title: "Code Mirror", description: "A code mirror application", path: "/mirror", category: "Development"},

    # News & Productivity
    %{title: "Hacker News Live", description: "Real-time tech news feed", path: "/hacker-news", category: "News"},
    %{title: "Bookmarks", description: "Personal bookmark collection", path: "/bookmarks", category: "Productivity"},

    # Comedy - Nathan Fielder
    %{title: "Nathan Archive", description: "Nathan Fielder content hub", path: "/nathan", category: "Comedy"},
    %{title: "Nathan Harper's", description: "Harper's Magazine style", path: "/nathan_harpers", category: "Comedy"},
    %{title: "Nathan Teen Vogue", description: "Teen Vogue style content", path: "/nathan_teen_vogue", category: "Comedy"},
    %{title: "Nathan BuzzFeed", description: "BuzzFeed style listicles", path: "/nathan_buzzfeed", category: "Comedy"},
    %{title: "Nathan Usenet", description: "Usenet forum discussions", path: "/nathan_usenet", category: "Comedy"},
    %{title: "Nathan Content Farm", description: "Content farm SEO style", path: "/nathan_content_farm", category: "Comedy"},
    %{title: "Nathan Comparison", description: "Compare all styles side by side", path: "/nathan_comparison", category: "Comedy"},
    %{title: "Nathan ASCII", description: "ASCII art representation", path: "/nathan_ascii", category: "Comedy"}
  ]

  # -- Pure functions (testable, no side effects) --

  @doc """
  Parse the "modal" query param into an atom representing the content type.
  Returns nil for unknown values.
  """
  def parse_modal_param(params) do
    case params["modal"] do
      "tech_posts" -> :tech_posts
      "non_tech_posts" -> :non_tech_posts
      "demos" -> :demos
      _ -> nil
    end
  end

  @doc """
  Build a map of {id => meta} from a Presence list.
  """
  def build_visitor_cursors(presence_list) do
    presence_list
    |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
    |> Enum.into(%{})
  end

  @doc """
  Count users in each room from visitor cursor data.
  """
  def count_room_users(visitor_cursors) do
    visitor_cursors
    |> Enum.reduce(
      %{"frontpage" => 0},
      fn {_id, meta}, acc ->
        room = Map.get(meta, :current_room, "general")
        Map.update(acc, room, 1, &(&1 + 1))
      end
    )
  end

  @doc """
  Format message content by converting URLs into clickable HTML links.
  """
  def format_message_with_links(content) when is_binary(content) do
    Regex.replace(@url_regex, content, fn url, _ ->
      href =
        if String.starts_with?(url, ["http://", "https://"]) do
          url
        else
          "https://#{url}"
        end

      "<a href=\"#{href}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-600 hover:underline break-all\">#{url}</a>"
    end)
  end

  @doc """
  Return the static list of interactive demos.
  """
  def demos, do: @demos

  # -- Lifecycle callbacks --

  @impl true
  def mount(_params, _session, socket) do
    Chat.ensure_started()

    reader_id = maybe_track_reader(socket)

    posts = Post.all()
    %{tech: tech_posts, non_tech: non_tech_posts} = Content.categorize_posts(posts)

    visitor_cursors = build_visitor_cursors(Presence.list(@presence_topic))
    total_readers = map_size(visitor_cursors)

    messages = Chat.get_messages("frontpage")

    {:ok,
     assign(socket,
       tech_posts: tech_posts,
       demos: @demos,
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
       room_users: %{"frontpage" => 0},
       show_mod_panel: false,
       banned_word_form: %{"word" => ""},
       mod_password: "letmein",
       show_mobile_modal: false,
       selected_mobile_content: nil,
       selected_category: "All"
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    modal_state = parse_modal_param(params)

    {:noreply,
     assign(socket,
       show_mobile_modal: modal_state != nil,
       selected_mobile_content: modal_state
     )}
  end

  # -- handle_info callbacks --

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    visitor_cursors = build_visitor_cursors(Presence.list(@presence_topic))
    total_readers = map_size(visitor_cursors)
    room_users = count_room_users(visitor_cursors)

    {:noreply,
     assign(socket,
       total_readers: total_readers,
       visitor_cursors: visitor_cursors,
       room_users: room_users
     )}
  end

  @impl true
  def handle_info({:new_chat_message, message}, socket) do
    if message.room == socket.assigns.current_room do
      updated_messages = Chat.get_messages(socket.assigns.current_room)
      {:noreply, assign(socket, chat_messages: updated_messages)}
    else
      {:noreply, socket}
    end
  end

  # -- handle_event callbacks (grouped together to avoid compiler warning) --

  @impl true
  def handle_event("mousemove", %{"x" => x, "y" => y}, socket) do
    cursor_position = %{x: x, y: y}
    socket = assign(socket, cursor_position: cursor_position)

    if socket.assigns.reader_id do
      Presence.update(self(), @presence_topic, socket.assigns.reader_id, fn meta ->
        Map.put(meta, :cursor_position, cursor_position)
      end)
    end

    {:noreply, socket}
  end

  def handle_event("save_name", %{"name" => name}, socket) do
    trimmed_name = String.trim(name)

    if socket.assigns.reader_id && trimmed_name != "" do
      Presence.update(self(), @presence_topic, socket.assigns.reader_id, fn meta ->
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
      Chat.add_banned_word(word)
      {:noreply, assign(socket, banned_word_form: %{"word" => ""})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_banned_word", %{"word" => word}, socket) do
    {:noreply, assign(socket, banned_word_form: %{"word" => word})}
  end

  def handle_event("change_room", %{"room" => room}, socket) when room in @default_rooms do
    if socket.assigns.reader_id do
      Presence.update(self(), @presence_topic, socket.assigns.reader_id, fn meta ->
        Map.put(meta, :current_room, room)
      end)

      messages = Chat.get_messages(room)
      {:noreply, assign(socket, current_room: room, chat_messages: messages)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("send_chat_message", %{"message" => message}, socket) do
    trimmed_message = String.trim(message)

    if socket.assigns.reader_id && trimmed_message != "" do
      send_chat_message(socket, trimmed_message)
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_chat_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, chat_form: %{"message" => message})}
  end

  def handle_event("open_mobile_modal", %{"content" => content}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?modal=#{content}")}
  end

  def handle_event("close_mobile_modal", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/")}
  end

  def handle_event("filter_category", %{"category" => category}, socket) do
    {:noreply, assign(socket, selected_category: category)}
  end

  # -- Render --

  @impl true
  def render(assigns) do
    posts =
      (assigns.tech_posts ++ assigns.non_tech_posts)
      |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})

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
          <a href="/" class="menu-item mac-home-link">Home</a>
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
    """
  end

  # -- Private helpers --

  defp maybe_track_reader(socket) do
    if connected?(socket) do
      id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
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

      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
      Phoenix.PubSub.subscribe(Blog.PubSub, @chat_topic)

      id
    else
      nil
    end
  end

  defp send_chat_message(socket, trimmed_message) do
    reader_id = socket.assigns.reader_id
    current_room = socket.assigns.current_room

    visitor_meta =
      case Presence.get_by_key(@presence_topic, reader_id) do
        %{metas: [meta | _]} -> meta
        _ -> %{display_name: nil, color: "hsl(200, 70%, 60%)"}
      end

    display_name = visitor_meta.display_name || "visitor #{String.slice(reader_id, -4, 4)}"

    new_message = %{
      id: System.os_time(:millisecond),
      sender_id: reader_id,
      sender_name: display_name,
      sender_color: visitor_meta.color,
      content: trimmed_message,
      timestamp: DateTime.utc_now(),
      room: current_room
    }

    Chat.save_message(new_message)

    Phoenix.PubSub.broadcast!(
      Blog.PubSub,
      @chat_topic,
      {:new_chat_message, new_message}
    )

    updated_messages = Chat.get_messages(current_room)
    {:noreply, assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}
  end
end
