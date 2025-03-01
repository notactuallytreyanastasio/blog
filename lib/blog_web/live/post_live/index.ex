defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Content

  @presence_topic "blog_presence"
  @chat_topic "blog_chat"

  # TODO add meta tags
  def mount(_params, _session, socket) do
    reader_id = if connected?(socket) do
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
          display_name: nil
        })

      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
      Phoenix.PubSub.subscribe(Blog.PubSub, @chat_topic)
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

    {:ok,
     assign(socket,
       tech_posts: tech_posts,
       non_tech_posts: non_tech_posts,
       total_readers: total_readers,
       page_title: "Thoughts & Tidbits",
       cursor_position: nil,
       reader_id: reader_id,
       visitor_cursors: visitor_cursors,
       name_form: %{"name" => ""},
       name_submitted: false,
       show_chat: false,
       chat_messages: [],
       chat_form: %{"message" => ""}
     )}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    visitor_cursors =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    total_readers = map_size(visitor_cursors)

    {:noreply, assign(socket, total_readers: total_readers, visitor_cursors: visitor_cursors)}
  end

  def handle_info({:new_chat_message, message}, socket) do
    updated_messages = [message | socket.assigns.chat_messages] |> Enum.take(50)
    {:noreply, assign(socket, chat_messages: updated_messages)}
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

      {:noreply, assign(socket, name_submitted: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name_form: %{"name" => name})}
  end

  def handle_event("toggle_chat", _params, socket) do
    {:noreply, assign(socket, show_chat: !socket.assigns.show_chat)}
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

      # Create the message
      new_message = %{
        id: System.os_time(:millisecond),
        sender_id: reader_id,
        sender_name: display_name,
        sender_color: color,
        content: trimmed_message,
        timestamp: DateTime.utc_now()
      }

      # Broadcast the message to all clients
      Phoenix.PubSub.broadcast(Blog.PubSub, @chat_topic, {:new_chat_message, new_message})

      # Clear the input field
      {:noreply, assign(socket, chat_form: %{"message" => ""})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_chat_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, chat_form: %{"message" => message})}
  end

  def render(assigns) do
    ~H"""
    <div
      class="py-12 px-4 sm:px-6 lg:px-8 min-h-screen"
      id="cursor-tracker-container"
      phx-hook="CursorTracker"
    >
      <!-- Name input form if not yet submitted -->
      <%= if @reader_id && !@name_submitted do %>
        <div class="fixed top-4 left-4 z-50">
          <.form for={%{}} phx-submit="save_name" phx-change="validate_name" class="flex items-center space-x-2">
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
                <button type="submit" class="bg-gradient-to-r from-fuchsia-500 to-cyan-500 text-white text-xs font-bold px-3 py-1 rounded-md">
                  SET
                </button>
              </div>
            </div>
          </.form>
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
            <div class="w-3 h-3 rounded-full bg-green-500 mr-2 group-hover:bg-red-500 transition-colors"></div>
            <%= if @show_chat, do: "Close Chat", else: "Join Chat" %>
          </div>
        </button>
      </div>

      <!-- AIM-style Chat Window -->
      <%= if @show_chat do %>
        <div class="fixed bottom-16 right-4 w-80 z-50 shadow-2xl">
          <!-- Chat Window Header -->
          <div class="bg-blue-800 text-white px-3 py-2 flex justify-between items-center rounded-t-md border-2 border-b-0 border-gray-400">
            <div class="font-bold" style="font-family: 'Comic Sans MS', cursive, sans-serif;">
              Blog Chat
            </div>
            <div class="flex space-x-1">
              <div class="w-3 h-3 rounded-full bg-yellow-400 border border-yellow-600"></div>
              <div class="w-3 h-3 rounded-full bg-green-400 border border-green-600"></div>
              <div class="w-3 h-3 rounded-full bg-red-400 border border-red-600 cursor-pointer" phx-click="toggle_chat"></div>
            </div>
          </div>

          <!-- Chat Window Body -->
          <div class="bg-white border-2 border-t-0 border-b-0 border-gray-400 h-64 overflow-y-auto p-2" style="font-family: 'Courier New', monospace;" id="chat-messages">
            <%= for message <- @chat_messages do %>
              <div class="mb-2">
                <span class="font-bold" style={"color: #{message.sender_color};"}>
                  <%= message.sender_name %>:
                </span>
                <span class="text-gray-800 break-words">
                  <%= message.content %>
                </span>
                <div class="text-xs text-gray-500">
                  <%= Calendar.strftime(message.timestamp, "%I:%M %p") %>
                </div>
              </div>
            <% end %>
            <%= if Enum.empty?(@chat_messages) do %>
              <div class="text-center text-gray-500 italic mt-4">
                No messages yet. Be the first to say hello!
              </div>
            <% end %>
          </div>

          <!-- Chat Input Area -->
          <div class="bg-gray-200 border-2 border-t-0 border-gray-400 rounded-b-md p-2">
            <.form for={%{}} phx-submit="send_chat_message" phx-change="validate_chat_message" class="flex">
              <input
                type="text"
                name="message"
                value={@chat_form["message"]}
                placeholder="Type a message..."
                maxlength="200"
                class="flex-1 border border-gray-400 rounded px-2 py-1 text-sm"
                autocomplete="off"
              />
              <button type="submit" class="ml-2 bg-yellow-400 hover:bg-yellow-500 text-blue-900 font-bold px-3 py-1 rounded border border-yellow-600 text-sm">
                Send
              </button>
            </.form>
          </div>
        </div>
      <% end %>

      <%= if @cursor_position do %>
        <div class="fixed top-4 right-4 bg-gradient-to-r from-fuchsia-500 to-cyan-500 text-white px-3 py-1 rounded-lg shadow-md text-sm font-mono z-50">
          x: <%= @cursor_position.x %>, y: <%= @cursor_position.y %>
        </div>

        <!-- Full screen crosshair with gradient and smooth transitions -->
        <div class="fixed inset-0 pointer-events-none z-40">
          <!-- Horizontal line across entire screen with gradient -->
          <div
            class="absolute w-full h-0.5 opacity-40 transition-all duration-200 ease-out"
            style={"top: #{@cursor_position.y}px; background: linear-gradient(to right, #d946ef, #0891b2);"}
          ></div>

          <!-- Vertical line across entire screen with gradient -->
          <div
            class="absolute h-full w-0.5 opacity-40 transition-all duration-200 ease-out"
            style={"left: #{@cursor_position.x}px; background: linear-gradient(to bottom, #d946ef, #0891b2);"}
          ></div>
        </div>
      <% end %>

      <!-- Show all visitor cursors except our own -->
      <%= for {visitor_id, visitor} <- @visitor_cursors do %>
        <%= if visitor_id != @reader_id && visitor.cursor_position do %>
          <div
            class="fixed pointer-events-none z-45 transition-all duration-200 ease-out"
            style={"left: #{visitor.cursor_position.x}px; top: #{visitor.cursor_position.y}px; transform: translate(-50%, -50%);"}
          >
            <!-- Visitor cursor indicator -->
            <div class="flex flex-col items-center">
              <!-- Cursor icon -->
              <svg width="16" height="16" viewBox="0 0 16 16" class="transform -rotate-12" style={"filter: drop-shadow(0 0 1px #000); fill: #{visitor.color};"}>
                <path d="M0 0L5 12L7.5 9.5L14 14L16 0Z" />
              </svg>

              <!-- Visitor label with name if available -->
              <div class="mt-1 px-2 py-0.5 rounded text-xs font-mono text-white shadow-sm whitespace-nowrap" style={"background-color: #{visitor.color}; opacity: 0.85;"}>
                <%= if visitor.display_name, do: visitor.display_name, else: "visitor #{String.slice(visitor_id, -4, 4)}" %>
              </div>
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
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1 text-fuchsia-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <span><%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> browsing</span>
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
                      <%= post.title %>
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-fuchsia-100 to-cyan-100 rounded-full text-xs font-medium text-gray-700">
                          <%= tag.name %>
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
                      <%= post.title %>
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-cyan-100 to-fuchsia-100 rounded-full text-xs font-medium text-gray-700">
                          <%= tag.name %>
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
                Tech Demos
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @non_tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-cyan-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-cyan-600 transition-colors">
                      <%= "Reddit Links Feed" %>
                    </h3>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        </div>

        <!-- Retro footer -->
        <footer class="mt-16 text-center">
          <div class="inline-block px-4 py-2 bg-gradient-to-r from-fuchsia-100 to-cyan-100 rounded-full text-sm text-gray-700">
            <span class="font-mono">/* Crafted with ♥ and Elixir */</span>
          </div>
        </footer>
    </div>
    """
  end

  # Add a debug function to help troubleshoot
  def debug_presence(socket) do
    IO.inspect(socket.assigns.reader_id, label: "Current reader_id")
    IO.inspect(socket.assigns.visitor_cursors, label: "All visitor cursors")
    socket
  end
end
