defmodule BlogWeb.ThinkerStreamLive do
  use BlogWeb, :live_view
  require Logger

  @emoji_options ["❤️", "😂", "👍", "🙏", "😭", "🔥", "😍", "🥺", "✨", "🤔", "😊", "💕", "🥰", "😩", "😤", "💀", "😳", "🙄", "🎉", "✅", "💯", "😌", "😔", "🫶", "👀"]
  @max_skeets 50

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to the general skeet feed
      Phoenix.PubSub.subscribe(Blog.PubSub, "skeet_feed")
    end

    {:ok,
     assign(socket,
       page_title: "Thinker Stream",
       selected_emojis: [],
       emoji_options: @emoji_options,
       skeets: [],
       max_skeets: @max_skeets,
       selected_profile: nil
     )}
  end

  def handle_event("toggle_emoji", %{"emoji" => emoji}, socket) do
    selected_emojis = socket.assigns.selected_emojis

    updated_emojis = if emoji in selected_emojis do
      # Remove emoji if already selected
      List.delete(selected_emojis, emoji)
    else
      # Add emoji to selection
      [emoji | selected_emojis]
    end

    # Reset skeets when changing filters
    {:noreply, assign(socket, selected_emojis: updated_emojis, skeets: [])}
  end

  def handle_event("clear_filters", _params, socket) do
    {:noreply, assign(socket, selected_emojis: [], skeets: [])}
  end

  def handle_event("view_profile", %{"id" => skeet_id}, socket) do
    # Find the skeet with the given ID
    case Enum.find(socket.assigns.skeets, fn skeet -> skeet.id == skeet_id end) do
      nil ->
        {:noreply, socket}

      skeet ->
        # Extract profile information from the skeet
        profile = extract_profile_info(skeet.text)

        {:noreply, assign(socket, selected_profile: profile)}
    end
  end

  def handle_event("close_profile", _params, socket) do
    {:noreply, assign(socket, selected_profile: nil)}
  end

  def handle_info({:new_post, skeet}, socket) do
    selected_emojis = socket.assigns.selected_emojis

    # If no emojis are selected or the skeet doesn't contain any of the selected emojis, do nothing
    if Enum.empty?(selected_emojis) or not contains_any_emoji?(skeet, selected_emojis) do
      {:noreply, socket}
    else
      # Add the new skeet to our collection with a unique ID
      skeet_id = generate_id()

      updated_skeets = [%{
        id: skeet_id,
        text: skeet,
        timestamp: DateTime.utc_now(),
        username: extract_username(skeet),
        matched_emojis: find_matching_emojis(skeet, selected_emojis)
      } | socket.assigns.skeets]
      |> Enum.take(socket.assigns.max_skeets) # Keep only the most recent skeets

      {:noreply, assign(socket, skeets: updated_skeets)}
    end
  end

  defp contains_any_emoji?(text, emojis) do
    Enum.any?(emojis, fn emoji -> String.contains?(text, emoji) end)
  end

  defp find_matching_emojis(text, emojis) do
    Enum.filter(emojis, fn emoji -> String.contains?(text, emoji) end)
  end

  defp generate_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp extract_username(skeet) do
    # Try to extract a username from the skeet text
    case Regex.run(~r/@([a-zA-Z0-9_]+)/, skeet) do
      [_, username] -> username
      _ -> "unknown_user"
    end
  end

  defp extract_profile_info(skeet) do
    # In a real implementation, you would make an API call to Bluesky
    # to get the actual profile information
    username = extract_username(skeet)

    %{
      username: username,
      display_name: String.capitalize(username),
      bio: "This is a mock bio for #{username}. In a real implementation, this would come from the Bluesky API.",
      avatar_url: "https://ui-avatars.com/api/?name=#{username}&background=random",
      follower_count: :rand.uniform(1000),
      following_count: :rand.uniform(500)
    }
  end

  # Helper function to highlight emojis in the text
  defp highlight_emojis(text, emojis) do
    Enum.reduce(emojis, text, fn emoji, acc ->
      String.replace(acc, emoji, "<span class=\"text-2xl\">#{emoji}</span>")
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-white p-4 font-mono">
      <div class="max-w-4xl mx-auto">
        <div class="mb-8 border-b border-gray-800 pb-4">
          <h1 class="text-4xl font-bold mb-2 glitch" data-text="THINKER STREAM">Skeet Vibe Filter</h1>
          <p class="text-gray-400">Select emojis to see matching skeets in real-time</p>
        </div>

        <div class="mb-8">
          <div class="flex flex-wrap gap-4 mb-4">
            <%= for emoji <- @emoji_options do %>
              <button
                phx-click="toggle_emoji"
                phx-value-emoji={emoji}
                class={"text-3xl p-2 rounded-lg transition-all #{if emoji in @selected_emojis, do: "bg-blue-700 scale-110", else: "bg-gray-800 hover:bg-gray-700"}"}
              >
                <%= emoji %>
              </button>
            <% end %>
          </div>

          <div class="flex justify-between items-center">
            <div>
              <%= if Enum.empty?(@selected_emojis) do %>
                <p class="text-gray-400">No filters selected</p>
              <% else %>
                <div class="flex items-center gap-2">
                  <p class="text-gray-400">Showing skeets with:</p>
                  <div class="flex gap-1">
                    <%= for emoji <- @selected_emojis do %>
                      <span class="text-2xl"><%= emoji %></span>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>

            <%= if not Enum.empty?(@selected_emojis) do %>
              <button
                phx-click="clear_filters"
                class="text-sm px-3 py-1 bg-gray-800 hover:bg-gray-700 rounded"
              >
                Clear filters
              </button>
            <% end %>
          </div>
        </div>

        <%= if Enum.empty?(@selected_emojis) do %>
          <div class="flex items-center justify-center h-64 border-2 border-dashed border-gray-700 rounded-lg">
            <p class="text-2xl text-gray-500">Select emojis above to start seeing skeets</p>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= if Enum.empty?(@skeets) do %>
              <div class="flex items-center justify-center h-64 border-2 border-dashed border-gray-700 rounded-lg">
                <p class="text-xl text-gray-500">Waiting for skeets containing your selected emojis...</p>
              </div>
            <% else %>
              <%= for {skeet, index} <- Enum.with_index(@skeets) do %>
                <div
                  id={"skeet-#{index}"}
                  class="border border-gray-800 p-4 rounded-lg hover:border-gray-600 transition-all cursor-pointer"
                  phx-mounted={JS.transition("fade-in-scale", time: 500)}
                  phx-click="view_profile"
                  phx-value-id={skeet.id}
                >
                  <div class="flex justify-between items-start mb-2">
                    <div class="text-blue-400">
                      @<%= skeet.username %>
                    </div>
                    <div class="text-gray-400 text-sm">
                      <%= Calendar.strftime(skeet.timestamp, "%Y-%m-%d %H:%M:%S") %>
                    </div>
                  </div>
                  <p class="whitespace-pre-wrap"><%= raw(highlight_emojis(skeet.text, skeet.matched_emojis)) %></p>

                  <div class="mt-2 flex justify-between items-center">
                    <div class="flex gap-1">
                      <%= for emoji <- skeet.matched_emojis do %>
                        <span class="text-xl"><%= emoji %></span>
                      <% end %>
                    </div>
                    <div class="text-sm text-gray-500">Click to view profile</div>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        <% end %>

        <%= if @selected_profile do %>
          <div class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
            <div class="bg-gray-900 border border-gray-700 rounded-lg max-w-md w-full p-6">
              <div class="flex justify-between items-start mb-4">
                <h2 class="text-2xl font-bold">Profile</h2>
                <button
                  class="text-gray-400 hover:text-white"
                  phx-click="close_profile"
                >
                  <.icon name="hero-x-mark-solid" class="h-6 w-6" />
                </button>
              </div>

              <div class="flex items-center space-x-4 mb-4">
                <img
                  src={@selected_profile.avatar_url}
                  alt={@selected_profile.username}
                  class="w-16 h-16 rounded-full border-2 border-blue-500"
                />
                <div>
                  <div class="font-bold text-xl"><%= @selected_profile.display_name %></div>
                  <div class="text-blue-400">@<%= @selected_profile.username %></div>
                </div>
              </div>

              <div class="mb-4 text-gray-300">
                <%= @selected_profile.bio %>
              </div>

              <div class="flex space-x-4 text-sm text-gray-400">
                <div><span class="font-bold text-white"><%= @selected_profile.following_count %></span> Following</div>
                <div><span class="font-bold text-white"><%= @selected_profile.follower_count %></span> Followers</div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>

    <style>
    .glitch {
      position: relative;
      text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                   0.025em 0.04em 0 #fffc00;
      animation: glitch 725ms infinite;
    }

    @keyframes glitch {
      0% {
        text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                     0.025em 0.04em 0 #fffc00;
      }
      15% {
        text-shadow: 0.05em 0 0 #00fffc, -0.03em -0.04em 0 #fc00ff,
                     0.025em 0.04em 0 #fffc00;
      }
      16% {
        text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.035em 0 #fc00ff,
                     -0.05em -0.05em 0 #fffc00;
      }
      49% {
        text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.035em 0 #fc00ff,
                     -0.05em -0.05em 0 #fffc00;
      }
      50% {
        text-shadow: 0.05em 0.035em 0 #00fffc, 0.03em 0 0 #fc00ff,
                     0 -0.04em 0 #fffc00;
      }
      99% {
        text-shadow: 0.05em 0.035em 0 #00fffc, 0.03em 0 0 #fc00ff,
                     0 -0.04em 0 #fffc00;
      }
      100% {
        text-shadow: -0.05em 0 0 #00fffc, -0.025em -0.04em 0 #fc00ff,
                     -0.04em -0.025em 0 #fffc00;
      }
    }

    .fade-in-scale {
      animation: fadeInScale 0.5s ease-out;
    }

    @keyframes fadeInScale {
      from {
        opacity: 0;
        transform: scale(0.95);
      }
      to {
        opacity: 1;
        transform: scale(1);
      }
    }
    </style>
    """
  end
end
