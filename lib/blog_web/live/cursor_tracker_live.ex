defmodule BlogWeb.CursorTrackerLive do
  use BlogWeb, :live_view
  require Logger

  @topic "cursor_tracker"

  def mount(_params, _session, socket) do
    socket = assign(socket,
      x_pos: 0,
      y_pos: 0,
      relative_x: 0,
      relative_y: 0,
      in_visualization: false,
      favorite_points: [],
      other_users: %{},
      user_id: nil,
      user_color: nil,
      page_title: "Cursor Tracker",
      meta_attrs: [
        %{name: "description", content: "Retro hacker-style cursor position tracker"},
        %{property: "og:title", content: "Cursor Tracker"},
        %{property: "og:description", content: "Retro hacker-style cursor position tracker"},
        %{property: "og:type", content: "website"}
      ]
    )

    if connected?(socket) do
      # Generate a unique user ID and color
      user_id = generate_user_id()
      user_color = generate_user_color(user_id)

      # Subscribe to the PubSub topic
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)

      # Subscribe to presence diff events
      Phoenix.PubSub.subscribe(Blog.PubSub, "presence:" <> @topic)

      # Track presence
      {:ok, _} = BlogWeb.Presence.track(
        self(),
        @topic,
        user_id,
        %{
          color: user_color,
          joined_at: DateTime.utc_now(),
          cursor: %{x: 0, y: 0, in_viz: false}
        }
      )

      # Get current users
      other_users = list_present_users(user_id)

      # Broadcast that we've joined
      broadcast_join(user_id, user_color)

      # Load shared points
      shared_points = get_shared_points()

      {:ok, assign(socket,
        user_id: user_id,
        user_color: user_color,
        other_users: other_users,
        favorite_points: shared_points
      )}
    else
      {:ok, socket}
    end
  end

  def handle_event("mousemove", %{"x" => x, "y" => y} = params, socket) do
    # Extract relative coordinates if available
    relative_x = Map.get(params, "relativeX", 0)
    relative_y = Map.get(params, "relativeY", 0)
    in_visualization = Map.get(params, "inVisualization", false)

    # Only broadcast if we have a user_id (connected)
    if socket.assigns.user_id do
      # Update presence with new cursor position
      BlogWeb.Presence.update(
        self(),
        @topic,
        socket.assigns.user_id,
        fn existing_meta ->
          Map.put(existing_meta, :cursor, %{
            x: x,
            y: y,
            relative_x: relative_x,
            relative_y: relative_y,
            in_viz: in_visualization
          })
        end
      )

      # Broadcast cursor position to all users
      broadcast_cursor_position(
        socket.assigns.user_id,
        socket.assigns.user_color,
        x,
        y,
        relative_x,
        relative_y,
        in_visualization
      )
    end

    {:noreply, assign(socket,
      x_pos: x,
      y_pos: y,
      relative_x: relative_x,
      relative_y: relative_y,
      in_visualization: in_visualization
    )}
  end

  def handle_event("save_point", _params, socket) do
    if socket.assigns.in_visualization do
      # Create a new favorite point with the current coordinates and user color
      new_point = %{
        x: socket.assigns.relative_x,
        y: socket.assigns.relative_y,
        color: socket.assigns.user_color,
        user_id: socket.assigns.user_id,
        timestamp: DateTime.utc_now()
      }

      # Add the new point to the list of favorite points
      updated_points = [new_point | socket.assigns.favorite_points]

      # Broadcast the new point to all users
      broadcast_new_point(new_point)

      {:noreply, assign(socket, favorite_points: updated_points)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("clear_points", _params, socket) do
    # Only allow clearing if we have a user_id (connected)
    if socket.assigns.user_id do
      # Broadcast clear points to all users
      broadcast_clear_points(socket.assigns.user_id)

      {:noreply, assign(socket, favorite_points: [])}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:cursor_position, user_id, color, x, y, relative_x, relative_y, in_viz}, socket) do
    # Skip our own cursor updates
    if user_id != socket.assigns.user_id do
      # Update the other user's cursor position
      other_users = Map.put(socket.assigns.other_users, user_id, %{
        color: color,
        x: x,
        y: y,
        relative_x: relative_x,
        relative_y: relative_y,
        in_viz: in_viz
      })

      {:noreply, assign(socket, other_users: other_users)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:new_point, point}, socket) do
    # Add the new point to our list
    updated_points = [point | socket.assigns.favorite_points]

    {:noreply, assign(socket, favorite_points: updated_points)}
  end

  def handle_info({:clear_points, _user_id}, socket) do
    {:noreply, assign(socket, favorite_points: [])}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    # Update the other users list when presence changes
    other_users = list_present_users(socket.assigns.user_id)

    {:noreply, assign(socket, other_users: other_users)}
  end

  def handle_info({:user_joined, user_id, color}, socket) do
    # Skip our own join messages
    if user_id != socket.assigns.user_id do
      # Add the new user to our list of other users
      other_users = Map.put(socket.assigns.other_users, user_id, %{
        color: color,
        x: 0,
        y: 0,
        relative_x: 0,
        relative_y: 0,
        in_viz: false
      })

      {:noreply, assign(socket, other_users: other_users)}
    else
      {:noreply, socket}
    end
  end

  defp generate_user_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp generate_user_color(user_id) do
    # Generate a deterministic color based on the user ID
    <<r, g, b, _rest::binary>> = :crypto.hash(:md5, user_id)

    # Ensure colors are bright enough to see
    r = min(255, r + 100)
    g = min(255, g + 100)
    b = min(255, b + 100)

    "rgb(#{r}, #{g}, #{b})"
  end

  defp generate_random_color do
    # Generate bright, neon-like colors for the retro hacker aesthetic
    hue = :rand.uniform(360)
    "hsl(#{hue}, 100%, 70%)"
  end

  defp list_present_users(current_user_id) do
    BlogWeb.Presence.list(@topic)
    |> Enum.filter(fn {user_id, _} -> user_id != current_user_id end)
    |> Enum.map(fn {user_id, %{metas: [meta | _]}} ->
      cursor = Map.get(meta, :cursor, %{x: 0, y: 0, in_viz: false})

      {user_id, %{
        color: meta.color,
        x: Map.get(cursor, :x, 0),
        y: Map.get(cursor, :y, 0),
        relative_x: Map.get(cursor, :relative_x, 0),
        relative_y: Map.get(cursor, :relative_y, 0),
        in_viz: Map.get(cursor, :in_viz, false)
      }}
    end)
    |> Enum.into(%{})
  end

  defp broadcast_cursor_position(user_id, color, x, y, relative_x, relative_y, in_viz) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:cursor_position, user_id, color, x, y, relative_x, relative_y, in_viz}
    )
  end

  defp broadcast_new_point(point) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:new_point, point}
    )
  end

  defp broadcast_clear_points(user_id) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:clear_points, user_id}
    )
  end

  defp broadcast_join(user_id, color) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:user_joined, user_id, color}
    )
  end

  # This would be replaced with a real persistence mechanism in a production app
  defp get_shared_points do
    # For now, just return an empty list
    []
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-green-500 font-mono p-4" phx-hook="CursorTracker" id="cursor-tracker">
      <div class="max-w-4xl mx-auto">
        <div class="mb-8 border border-green-500 p-4">
          <h1 class="text-3xl mb-2 glitch-text">CURSOR POSITION TRACKER</h1>
          <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="border border-green-500 p-4">
              <div class="text-xs mb-1 opacity-70">X-COORDINATE</div>
              <div class="text-2xl font-bold tracking-wider"><%= @x_pos %></div>
            </div>
            <div class="border border-green-500 p-4">
              <div class="text-xs mb-1 opacity-70">Y-COORDINATE</div>
              <div class="text-2xl font-bold tracking-wider"><%= @y_pos %></div>
            </div>
          </div>

          <div class="border-t border-green-500 pt-4">
            <div class="text-xs opacity-70 mb-2">// ACTIVE USERS: <%= map_size(@other_users) + 1 %></div>
            <div class="flex flex-wrap gap-2">
              <div class="flex items-center">
                <div class="w-4 h-4 rounded-full mr-1" style={"background-color: #{@user_color || 'rgb(100, 255, 100)'}"}></div>
                <span class="text-xs">YOU</span>
              </div>

              <%= for {user_id, user} <- @other_users do %>
                <div class="flex items-center">
                  <div class="w-4 h-4 rounded-full mr-1" style={"background-color: #{user.color}"}></div>
                  <span class="text-xs"><%= String.slice(user_id, 0, 6) %></span>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="border border-green-500 p-4 mb-8">
          <div class="flex justify-between items-center mb-2">
            <div class="text-xs opacity-70">// CURSOR VISUALIZATION</div>
            <div>
              <button
                phx-click="clear_points"
                class="text-xs border border-green-500 px-2 py-1 hover:bg-green-900 transition-colors"
              >
                CLEAR POINTS
              </button>
            </div>
          </div>

          <div
            class="relative h-64 border border-green-500 overflow-hidden cursor-crosshair"
            phx-click="save_point"
          >
            <%= if @in_visualization do %>
              <div class="absolute w-4 h-4 opacity-70" style={"left: calc(#{@relative_x}px - 8px); top: calc(#{@relative_y}px - 8px);"}>
                <div class="w-full h-full border border-green-500 animate-pulse"></div>
              </div>
              <div class="absolute w-1 h-full bg-green-500 opacity-20" style={"left: #{@relative_x}px;"}></div>
              <div class="absolute w-full h-1 bg-green-500 opacity-20" style={"top: #{@relative_y}px;"}></div>

              <div class="absolute text-xs opacity-70" style={"left: calc(#{@relative_x}px + 12px); top: calc(#{@relative_y}px - 12px);"}>
                X: <%= @relative_x |> trunc() %>, Y: <%= @relative_y |> trunc() %>
              </div>
            <% else %>
              <div class="flex items-center justify-center h-full text-sm opacity-50">
                Move cursor here to visualize position
              </div>
            <% end %>

            <%= for {user_id, user} <- @other_users do %>
              <%= if user.in_viz do %>
                <div class="absolute w-4 h-4 opacity-50" style={"left: calc(#{user.relative_x}px - 8px); top: calc(#{user.relative_y}px - 8px);"}>
                  <div class="w-full h-full border-2" style={"border-color: #{user.color}"}></div>
                </div>
                <div class="absolute text-xs opacity-50" style={"color: #{user.color}; left: calc(#{user.relative_x}px + 12px); top: calc(#{user.relative_y}px - 12px);"}>
                  <%= String.slice(user_id, 0, 6) %>
                </div>
              <% end %>
            <% end %>

            <%= for point <- @favorite_points do %>
              <div
                class="absolute w-3 h-3 rounded-full transform -translate-x-1/2 -translate-y-1/2"
                style={"background-color: #{point.color}; left: #{point.x}px; top: #{point.y}px;"}
                title={"Point by #{String.slice(point.user_id || "", 0, 6)} at X: #{trunc(point.x)}, Y: #{trunc(point.y)}"}
              >
              </div>
            <% end %>
          </div>

          <div class="mt-2 text-xs opacity-70 text-center">
            Click anywhere in the visualization area to save a point
          </div>
        </div>

        <div class="border border-green-500 p-4">
          <div class="text-xs mb-2 opacity-70">// SYSTEM LOG</div>
          <div class="h-32 overflow-y-auto font-mono text-xs leading-relaxed">
            <div>> Current position: X:<%= @x_pos %> Y:<%= @y_pos %></div>
            <%= if @in_visualization do %>
              <div>> Cursor in visualization area: X:<%= @relative_x |> trunc() %> Y:<%= @relative_y |> trunc() %></div>
            <% end %>
            <%= if length(@favorite_points) > 0 do %>
              <div>> Saved points: <%= length(@favorite_points) %></div>
              <%= for {point, index} <- Enum.with_index(Enum.take(@favorite_points, 5)) do %>
                <div>> Point <%= index + 1 %>: X:<%= point.x |> trunc() %> Y:<%= point.y |> trunc() %> by <%= if point.user_id == @user_id, do: "you", else: String.slice(point.user_id || "", 0, 6) %></div>
              <% end %>
              <%= if length(@favorite_points) > 5 do %>
                <div>> ... and <%= length(@favorite_points) - 5 %> more points</div>
              <% end %>
            <% end %>
            <%= if map_size(@other_users) > 0 do %>
              <div>> Other users online: <%= map_size(@other_users) %></div>
            <% end %>
          </div>
        </div>
      </div>

      <style>
        .glitch-text {
          text-shadow:
            0.05em 0 0 rgba(255, 0, 0, 0.75),
            -0.025em -0.05em 0 rgba(0, 255, 0, 0.75),
            0.025em 0.05em 0 rgba(0, 0, 255, 0.75);
          animation: glitch 500ms infinite;
        }

        @keyframes glitch {
          0% {
            text-shadow:
              0.05em 0 0 rgba(255, 0, 0, 0.75),
              -0.025em -0.05em 0 rgba(0, 255, 0, 0.75),
              0.025em 0.05em 0 rgba(0, 0, 255, 0.75);
          }
          14% {
            text-shadow:
              0.05em 0 0 rgba(255, 0, 0, 0.75),
              -0.025em -0.05em 0 rgba(0, 255, 0, 0.75),
              0.025em 0.05em 0 rgba(0, 0, 255, 0.75);
          }
          15% {
            text-shadow:
              -0.05em -0.025em 0 rgba(255, 0, 0, 0.75),
              0.025em 0.025em 0 rgba(0, 255, 0, 0.75),
              -0.05em -0.05em 0 rgba(0, 0, 255, 0.75);
          }
          49% {
            text-shadow:
              -0.05em -0.025em 0 rgba(255, 0, 0, 0.75),
              0.025em 0.025em 0 rgba(0, 255, 0, 0.75),
              -0.05em -0.05em 0 rgba(0, 0, 255, 0.75);
          }
          50% {
            text-shadow:
              0.025em 0.05em 0 rgba(255, 0, 0, 0.75),
              0.05em 0 0 rgba(0, 255, 0, 0.75),
              0 -0.05em 0 rgba(0, 0, 255, 0.75);
          }
          99% {
            text-shadow:
              0.025em 0.05em 0 rgba(255, 0, 0, 0.75),
              0.05em 0 0 rgba(0, 255, 0, 0.75),
              0 -0.05em 0 rgba(0, 0, 255, 0.75);
          }
          100% {
            text-shadow:
              -0.025em 0 0 rgba(255, 0, 0, 0.75),
              -0.025em -0.025em 0 rgba(0, 255, 0, 0.75),
              -0.025em -0.05em 0 rgba(0, 0, 255, 0.75);
          }
        }
      </style>
    </div>
    """
  end
end
