defmodule BlogWeb.AllowedChatsLive do
  use BlogWeb, :live_view
  require Logger

  alias Blog.Chat.MessageStore
  alias Blog.Chat.Presence

  @impl true
  def mount(_params, session, socket) do
    # Generate a unique user ID for this session if not present
    user_id = Map.get(session, "user_id", generate_user_id())

    # Load the global allowed words from ETS
    allowed_words = MessageStore.get_allowed_words()

    # Load recent messages from ETS
    messages = MessageStore.get_recent_messages()

    # Get initial online users count (safely)
    online_count = get_online_count()

    if connected?(socket) do
      # Subscribe to the chat topic for real-time updates
      Phoenix.PubSub.subscribe(Blog.PubSub, MessageStore.topic())

      # Subscribe to the presence topic for user presence updates
      Phoenix.PubSub.subscribe(Blog.PubSub, Presence.topic())

      # Track this user's presence (safely)
      track_user_presence(user_id)

      # Get an updated count after tracking
      _online_count = get_online_count()
    end

    {:ok,
     socket
     |> assign(:page_title, "Community Allowed Chats")
     |> assign(:meta_attrs, [
       %{name: "title", content: "Community Allowed Chats"},
       %{name: "description", content: "Chat with community-managed allowed words filtering"},
       %{property: "og:title", content: "Community Allowed Chats"},
       %{
         property: "og:description",
         content: "Chat with community-managed allowed words filtering"
       },
       %{property: "og:type", content: "website"}
     ])
     |> assign(:user_id, user_id)
     |> assign(:allowed_words, allowed_words)
     |> assign(:messages, calculate_message_visibility(messages, allowed_words))
     |> assign(:add_word_form, to_form(%{"word" => ""}))
     |> assign(:message_form, to_form(%{"content" => ""}))
     |> assign(:online_count, online_count)}
  end

  @impl true
  def handle_event("add_word", %{"word" => word}, socket) when is_binary(word) and word != "" do
    # Add the word to the global allowed_words set
    word = String.downcase(String.trim(word))
    # Use the new function for global word addition
    MessageStore.add_allowed_word(word)

    # We'll get updated words through the PubSub broadcast
    {:noreply, assign(socket, :add_word_form, to_form(%{"word" => ""}))}
  end

  @impl true
  def handle_event("remove_word", %{"word" => word}, socket) do
    # Remove the word from the global allowed_words set
    MessageStore.remove_allowed_word(word)

    # We'll get updated words through the PubSub broadcast
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"content" => content}, socket)
      when is_binary(content) and content != "" do
    user_id = socket.assigns.user_id

    # Create a new message map (without is_visible - we'll calculate it dynamically)
    new_message = %{
      id: System.unique_integer([:positive]),
      content: content,
      timestamp: DateTime.utc_now(),
      user_id: user_id
    }

    # Store the message in ETS
    MessageStore.store_message(new_message)

    # Updates will come through the PubSub channel
    {:noreply, assign(socket, :message_form, to_form(%{"content" => ""}))}
  end

  @impl true
  def handle_event("validate_add_word", %{"word" => word}, socket) do
    {:noreply, assign(socket, :add_word_form, to_form(%{"word" => word}))}
  end

  @impl true
  def handle_event("validate_message", %{"content" => content}, socket) do
    {:noreply, assign(socket, :message_form, to_form(%{"content" => content}))}
  end

  @impl true
  def handle_info({:new_message, _message}, socket) do
    # When a new message is broadcast, update the messages list
    messages = MessageStore.get_recent_messages()

    # Calculate visibility for each message based on the current allowed words
    messages_with_visibility =
      calculate_message_visibility(messages, socket.assigns.allowed_words)

    {:noreply, assign(socket, :messages, messages_with_visibility)}
  end

  @impl true
  def handle_info({:allowed_words_updated, updated_words}, socket) do
    # With shared words, we update for all users regardless of user_id
    # Recalculate message visibility with the updated allowed words
    messages = calculate_message_visibility(socket.assigns.messages, updated_words)

    {:noreply,
     socket
     |> assign(:allowed_words, updated_words)
     |> assign(:messages, messages)}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    # Update the online count when presence changes
    online_count = get_online_count()
    {:noreply, assign(socket, :online_count, online_count)}
  end

  # Helper function to calculate visibility for a list of messages
  defp calculate_message_visibility(messages, allowed_words) do
    Enum.map(messages, fn message ->
      {is_visible, matching_words} = message_visible_with_words(message.content, allowed_words)

      # Create a new message map with visibility information
      Map.merge(message, %{
        is_visible: is_visible,
        matching_words: matching_words
      })
    end)
  end

  # Enhanced helper function to check if a message is visible based on the allowed words
  # Returns a tuple of {is_visible, matching_words}
  defp message_visible_with_words(content, allowed_words) do
    # Skip the check if there are no allowed words
    if MapSet.size(allowed_words) == 0 do
      {false, []}
    else
      # Split the content into words
      words =
        content
        |> String.downcase()
        |> String.split(~r/\s+/)
        |> Enum.map(&String.trim/1)

      # Find all matching words
      matching_words =
        words
        |> Enum.filter(fn word -> MapSet.member?(allowed_words, word) end)
        |> Enum.uniq()

      {length(matching_words) > 0, matching_words}
    end
  end

  # For backward compatibility with older messages
  defp message_visible?(content, allowed_words) do
    {is_visible, _matching_words} = message_visible_with_words(content, allowed_words)
    is_visible
  end

  # Generate a unique user ID
  defp generate_user_id do
    System.unique_integer([:positive]) |> to_string()
  end

  # Helper functions for presence
  defp track_user_presence(user_id) do
    try do
      Presence.track_user(user_id)
    rescue
      _ ->
        # If tracking fails, log it but continue
        Logger.warning("Failed to track user presence for user: #{user_id}")
        :error
    end
  end

  defp get_online_count do
    try do
      Presence.count_online_users()
    rescue
      _ ->
        # If presence counting fails, return 1 (at least this user)
        1
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-win95">
      <div class="os-window os-window-win95" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">💬 Community Chat - Allowed Words Filter</span>
          <div class="os-titlebar-buttons">
            <span class="os-btn">_</span>
            <span class="os-btn">□</span>
            <a href="/" class="os-btn">×</a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>Edit</span>
          <span>View</span>
          <span>Users ({@online_count} online)</span>
          <span>Help</span>
        </div>
        <div class="os-content" style="height: calc(100% - 80px); overflow-y: auto; background: #c0c0c0;">
          <div class="p-3">
            <div class="text-xs mb-2" style="color: #000080;">Session ID: {@user_id}</div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
              <!-- Left sidebar: Allowed words -->
              <div class="md:col-span-1">
                <div class="bg-white border-2 inset p-3">
                  <h2 class="font-bold mb-2 text-sm">Community Allowed Words</h2>
                  <p class="text-xs text-gray-600 mb-3">
                    These words are shared by all users. Any message containing these words will be visible to everyone.
                  </p>

                  <.form
                    for={@add_word_form}
                    phx-submit="add_word"
                    phx-change="validate_add_word"
                    class="mb-3"
                  >
                    <div class="flex gap-1">
                      <.input field={@add_word_form[:word]} placeholder="Enter a word" class="flex-grow text-sm" />
                      <button
                        type="submit"
                        class="px-3 py-1 border-2 outset bg-[#c0c0c0] text-sm hover:bg-[#d0d0d0] active:border-inset"
                      >
                        Add
                      </button>
                    </div>
                  </.form>

                  <div class="mt-3">
                    <div class="flex flex-wrap gap-1">
                      <%= for word <- @allowed_words do %>
                        <span class="px-2 py-1 bg-[#000080] text-white text-xs">
                          {word}
                          <button
                            phx-click="remove_word"
                            phx-value-word={word}
                            class="ml-1 text-yellow-300 hover:text-red-300 focus:outline-none"
                            aria-label={"Remove #{word}"}
                          >
                            ×
                          </button>
                        </span>
                      <% end %>
                    </div>
                    <%= if Enum.empty?(@allowed_words) do %>
                      <p class="text-gray-500 text-xs italic">
                        No community allowed words yet. Add some!
                      </p>
                    <% end %>
                  </div>
                </div>
              </div>

              <!-- Main content: Messages -->
              <div class="md:col-span-2">
                <div class="bg-white border-2 inset p-3 mb-3">
                  <h2 class="font-bold mb-2 text-sm">Send Message</h2>

                  <.form for={@message_form} phx-submit="send_message" phx-change="validate_message">
                    <div class="flex gap-1">
                      <.input
                        field={@message_form[:content]}
                        placeholder="Type a message..."
                        class="flex-grow text-sm"
                      />
                      <button
                        type="submit"
                        class="px-3 py-1 border-2 outset bg-[#c0c0c0] text-sm hover:bg-[#d0d0d0] active:border-inset"
                      >
                        Send
                      </button>
                    </div>
                  </.form>
                </div>

                <div class="bg-white border-2 inset p-3">
                  <h3 class="font-bold mb-2 text-sm">Chat History</h3>

                  <div class="space-y-2">
                    <%= if Enum.empty?(@messages) do %>
                      <p class="text-gray-500 text-center py-4 text-sm">
                        No messages yet. Start the conversation!
                      </p>
                    <% else %>
                      <%= for message <- @messages do %>
                        <div class={[
                          "p-2 border",
                          if(message.is_visible,
                            do: "bg-green-100 border-green-400",
                            else: "bg-red-100 border-red-400"
                          )
                        ]}>
                          <div class="flex justify-between items-start">
                            <div class="flex-1">
                              <%= if message.is_visible do %>
                                <p class="text-gray-800 text-sm">{message.content}</p>
                                <%= if message[:matching_words] && length(message.matching_words) > 0 do %>
                                  <p class="text-xs text-green-700 mt-1">
                                    Allowed by:
                                    <%= for {word, i} <- Enum.with_index(message.matching_words) do %>
                                      <span class="font-bold">{word}</span>{if i <
                                                                                   length(
                                                                                     message.matching_words
                                                                                   ) - 1,
                                                                                 do: ", "}
                                    <% end %>
                                  </p>
                                <% end %>
                              <% else %>
                                <p class="text-gray-500 italic text-sm">
                                  This message is hidden (no allowed words found)
                                </p>
                              <% end %>
                              <p class="text-xs text-gray-500 mt-1">
                                {Calendar.strftime(message.timestamp, "%B %d, %Y at %I:%M %p")}
                                <%= if Map.get(message, :user_id) == @user_id do %>
                                  <span class="ml-2 text-blue-600 font-bold">(You)</span>
                                <% end %>
                              </p>
                            </div>
                            <span class={[
                              "text-xs px-2 py-1",
                              if(message.is_visible,
                                do: "bg-green-600 text-white",
                                else: "bg-red-600 text-white"
                              )
                            ]}>
                              {if message.is_visible, do: "Visible", else: "Hidden"}
                            </span>
                          </div>
                        </div>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <div class="os-statusbar-section">Messages: {length(@messages)}</div>
          <div class="os-statusbar-section">Words: {MapSet.size(@allowed_words)}</div>
          <div class="os-statusbar-section" style="flex: 1;">{@online_count} user(s) online</div>
        </div>
      </div>
    </div>
    """
  end
end
