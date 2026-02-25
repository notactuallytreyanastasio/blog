defmodule BlogWeb.CursorTrackerLive do
  @moduledoc """
  A multi-user collaborative cursor tracking and drawing canvas.

  Users can see each other's cursor positions in real-time and click
  to place colored dots on a shared visualization area. Points are
  stored in ETS via `Blog.CursorPoints` and auto-cleared hourly.
  """

  use BlogWeb, :live_view

  alias Blog.CursorPoints
  alias BlogWeb.Presence

  @topic "cursor_tracker"
  @clear_interval_seconds 60 * 60
  @tick_interval_ms 1_000

  # -- Mount ------------------------------------------------------------------

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        x_pos: 0,
        y_pos: 0,
        relative_x: 0,
        relative_y: 0,
        in_visualization: false,
        favorite_points: [],
        other_users: %{},
        user_id: nil,
        user_color: nil,
        next_clear: calculate_next_clear(),
        page_title: "Cursor Tracker",
        meta_attrs: meta_attrs()
      )

    if connected?(socket) do
      {:ok, mount_connected(socket)}
    else
      {:ok, socket}
    end
  end

  defp mount_connected(socket) do
    user_id = generate_user_id()
    user_color = generate_user_color(user_id)

    Phoenix.PubSub.subscribe(Blog.PubSub, @topic)
    Phoenix.PubSub.subscribe(Blog.PubSub, "presence:" <> @topic)

    {:ok, _} =
      Presence.track(self(), @topic, user_id, %{
        color: user_color,
        joined_at: DateTime.utc_now(),
        cursor: %{x: 0, y: 0, in_viz: false}
      })

    Process.send_after(self(), :tick, @tick_interval_ms)

    assign(socket,
      user_id: user_id,
      user_color: user_color,
      other_users: list_present_users(user_id),
      favorite_points: CursorPoints.get_points()
    )
  end

  # -- Events -----------------------------------------------------------------

  def handle_event("mousemove", %{"x" => x, "y" => y} = params, socket) do
    relative_x = Map.get(params, "relativeX", 0)
    relative_y = Map.get(params, "relativeY", 0)
    in_visualization = Map.get(params, "inVisualization", false)

    if socket.assigns.user_id do
      cursor = %{
        x: x,
        y: y,
        relative_x: relative_x,
        relative_y: relative_y,
        in_viz: in_visualization
      }

      Presence.update(self(), @topic, socket.assigns.user_id, fn meta ->
        Map.put(meta, :cursor, cursor)
      end)

      broadcast(:cursor_moved, %{
        user_id: socket.assigns.user_id,
        color: socket.assigns.user_color,
        cursor: cursor
      })
    end

    {:noreply,
     assign(socket,
       x_pos: x,
       y_pos: y,
       relative_x: relative_x,
       relative_y: relative_y,
       in_visualization: in_visualization
     )}
  end

  def handle_event("save_point", _params, socket) do
    if socket.assigns.in_visualization do
      point = build_point(socket.assigns)

      CursorPoints.add_point(point)
      broadcast(:new_point, point)

      {:noreply, assign(socket, favorite_points: [point | socket.assigns.favorite_points])}
    else
      {:noreply, socket}
    end
  end

  def handle_event("clear_points", _params, socket) do
    if socket.assigns.user_id do
      CursorPoints.clear_points()
      broadcast(:clear_points, %{user_id: socket.assigns.user_id})

      {:noreply, assign(socket, favorite_points: [])}
    else
      {:noreply, socket}
    end
  end

  # -- Info handlers ----------------------------------------------------------

  def handle_info({:cursor_moved, %{user_id: user_id, color: color, cursor: cursor}}, socket) do
    if user_id != socket.assigns.user_id do
      other_users =
        Map.put(socket.assigns.other_users, user_id, %{
          color: color,
          x: cursor.x,
          y: cursor.y,
          relative_x: cursor.relative_x,
          relative_y: cursor.relative_y,
          in_viz: cursor.in_viz
        })

      {:noreply, assign(socket, other_users: other_users)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:new_point, %{user_id: user_id} = point}, socket) do
    if user_id != socket.assigns.user_id do
      {:noreply, assign(socket, favorite_points: [point | socket.assigns.favorite_points])}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:clear_points, %{user_id: user_id}}, socket) do
    if user_id != socket.assigns.user_id do
      {:noreply, assign(socket, favorite_points: [])}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, other_users: list_present_users(socket.assigns.user_id))}
  end

  def handle_info(:tick, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, @tick_interval_ms)
    end

    {:noreply, assign(socket, next_clear: calculate_next_clear())}
  end

  # -- Pure functions (public for testability) --------------------------------

  @doc "Generate a deterministic RGB color string from a user ID."
  def generate_user_color(user_id) when is_binary(user_id) do
    <<r, g, b, _rest::binary>> = :crypto.hash(:md5, user_id)

    r = min(255, r + 100)
    g = min(255, g + 100)
    b = min(255, b + 100)

    "rgb(#{r}, #{g}, #{b})"
  end

  @doc "Calculate time remaining until the next scheduled point clear."
  def calculate_next_clear do
    now = DateTime.utc_now() |> DateTime.to_unix()
    remaining = @clear_interval_seconds - rem(now, @clear_interval_seconds)

    %{
      hours: div(remaining, 3600),
      minutes: div(rem(remaining, 3600), 60),
      seconds: rem(remaining, 60),
      total_seconds: remaining
    }
  end

  @doc "Build a point map from the current socket assigns."
  def build_point(assigns) do
    %{
      x: assigns.relative_x,
      y: assigns.relative_y,
      color: assigns.user_color,
      user_id: assigns.user_id,
      timestamp: DateTime.utc_now()
    }
  end

  @doc "Format a time component as a zero-padded two-digit string."
  def format_time_component(n) when is_integer(n) do
    n |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  @doc "Return the display label for a point's author."
  def point_author_label(point_user_id, current_user_id)
      when is_binary(point_user_id) and is_binary(current_user_id) do
    if point_user_id == current_user_id do
      "you"
    else
      String.slice(point_user_id, 0, 6)
    end
  end

  def point_author_label(nil, _current_user_id), do: ""
  def point_author_label(_point_user_id, nil), do: ""

  # -- Private helpers --------------------------------------------------------

  defp generate_user_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp list_present_users(current_user_id) do
    Presence.list(@topic)
    |> Enum.reject(fn {user_id, _} -> user_id == current_user_id end)
    |> Map.new(fn {user_id, %{metas: [meta | _]}} ->
      cursor = Map.get(meta, :cursor, %{x: 0, y: 0, in_viz: false})

      {user_id,
       %{
         color: meta.color,
         x: Map.get(cursor, :x, 0),
         y: Map.get(cursor, :y, 0),
         relative_x: Map.get(cursor, :relative_x, 0),
         relative_y: Map.get(cursor, :relative_y, 0),
         in_viz: Map.get(cursor, :in_viz, false)
       }}
    end)
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {event, payload})
  end

  defp meta_attrs do
    [
      %{name: "description", content: "Track cursor positions, draw points on a canvas"},
      %{property: "og:title", content: "Cursor Tracker - Live Shared and here to draw"},
      %{property: "og:description", content: "Track cursor positions, draw points on a canvas"},
      %{property: "og:type", content: "website"}
    ]
  end

  # -- Render -----------------------------------------------------------------

  def render(assigns) do
    ~H"""
    <div class="os-desktop-win95">
      <div class="os-window os-window-win95" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">Cursor Tracker - Multi-User Drawing</span>
          <div class="os-titlebar-buttons">
            <span class="os-btn">_</span>
            <span class="os-btn">&#9633;</span>
            <a href="/" class="os-btn">&times;</a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>View</span>
          <span>Users ({map_size(@other_users) + 1})</span>
          <span>Help</span>
        </div>
        <div class="os-content" style="height: calc(100% - 80px); overflow-y: auto; background: #000; color: #00ff00;">
          <div
            class="font-mono p-4"
            phx-hook="CursorTracker"
            id="cursor-tracker"
          >
            <div class="max-w-4xl mx-auto">
              <%= if flash = Phoenix.Flash.get(@flash, :info) do %>
                <div class="mb-4 border border-green-500 bg-green-900 bg-opacity-30 p-3 text-green-300">
                  {flash}
                </div>
              <% end %>

              <.header_section other_users={@other_users} x_pos={@x_pos} y_pos={@y_pos} user_color={@user_color} />

              <.visualization_section
                in_visualization={@in_visualization}
                relative_x={@relative_x}
                relative_y={@relative_y}
                other_users={@other_users}
                favorite_points={@favorite_points}
                next_clear={@next_clear}
              />

              <.system_log
                x_pos={@x_pos}
                y_pos={@y_pos}
                in_visualization={@in_visualization}
                relative_x={@relative_x}
                relative_y={@relative_y}
                favorite_points={@favorite_points}
                user_id={@user_id}
                other_users={@other_users}
                next_clear={@next_clear}
              />
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <div class="os-statusbar-section">Points: {length(@favorite_points)}</div>
          <div class="os-statusbar-section">X: {@x_pos} Y: {@y_pos}</div>
          <div class="os-statusbar-section" style="flex: 1;">{map_size(@other_users) + 1} user(s) online</div>
        </div>
      </div>
    </div>
    """
  end

  # -- Function components ----------------------------------------------------

  defp header_section(assigns) do
    ~H"""
    <div class="mb-8 border border-green-500 p-4">
      <h1 class="text-3xl mb-2 glitch-text">CURSOR POSITION TRACKER</h1>
      <div class="text-2xl glitch-text mb-2">
        <h1>// ACTIVE USERS: {map_size(@other_users) + 1}</h1>
      </div>
      <div class="text-2xl glitch-text mb-2">
        <h1>Click to draw a point</h1>
      </div>
      <div class="grid grid-cols-2 gap-4 mb-8">
        <div class="border border-green-500 p-4">
          <div class="text-xs mb-1 opacity-70">X-COORDINATE</div>
          <div id="x-coord" class="text-2xl font-bold tracking-wider">{@x_pos}</div>
        </div>
        <div class="border border-green-500 p-4">
          <div class="text-xs mb-1 opacity-70">Y-COORDINATE</div>
          <div id="y-coord" class="text-2xl font-bold tracking-wider">{@y_pos}</div>
        </div>
      </div>

      <div class="border-t border-green-500 pt-4">
        <div class="flex flex-wrap gap-2">
          <div class="flex items-center">
            <div
              class="w-4 h-4 rounded-full mr-1"
              style={"background-color: #{@user_color || "rgb(100, 255, 100)"}"}
            >
            </div>
            <span class="text-xs">YOU</span>
          </div>

          <div :for={{user_id, user} <- @other_users} class="flex items-center">
            <div class="w-4 h-4 rounded-full mr-1" style={"background-color: #{user.color}"}>
            </div>
            <span class="text-xs">{String.slice(user_id, 0, 6)}</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp visualization_section(assigns) do
    ~H"""
    <div class="border border-green-500 p-4 mb-8">
      <div class="flex justify-between items-center mb-2">
        <div class="text-xs opacity-70">// CURSOR VISUALIZATION</div>
        <div class="flex items-center gap-4">
          <div class="text-xs opacity-70">
            AUTO-CLEAR IN:
            <span class="font-mono">
              {format_time_component(@next_clear.hours)}:{format_time_component(@next_clear.minutes)}:{format_time_component(@next_clear.seconds)}
            </span>
          </div>
          <button
            phx-click="clear_points"
            class="text-xs border border-green-500 px-2 py-1 hover:bg-green-900 transition-colors"
          >
            CLEAR POINTS
          </button>
        </div>
      </div>

      <div
        id="visualization-area"
        class="relative h-64 border border-green-500 overflow-hidden cursor-crosshair"
        phx-click="save_point"
      >
        <%= if @in_visualization do %>
          <div
            class="absolute w-4 h-4 opacity-70"
            style={"left: calc(#{@relative_x}px - 8px); top: calc(#{@relative_y}px - 8px);"}
          >
            <div class="w-full h-full border border-green-500 animate-pulse"></div>
          </div>
          <div
            class="absolute w-1 h-full bg-green-500 opacity-20"
            style={"left: #{@relative_x}px;"}
          >
          </div>
          <div
            class="absolute w-full h-1 bg-green-500 opacity-20"
            style={"top: #{@relative_y}px;"}
          >
          </div>

          <div
            class="absolute text-xs opacity-70"
            style={"left: calc(#{@relative_x}px + 12px); top: calc(#{@relative_y}px - 12px);"}
          >
            X: {@relative_x |> trunc()}, Y: {@relative_y |> trunc()}
          </div>
        <% else %>
          <div class="flex items-center justify-center h-full text-sm opacity-50">
            Move cursor here to visualize position
          </div>
        <% end %>

        <.other_user_cursor :for={{user_id, user} <- @other_users} user_id={user_id} user={user} />

        <div
          :for={point <- @favorite_points}
          class="absolute w-3 h-3 rounded-full transform -translate-x-1/2 -translate-y-1/2"
          style={"background-color: #{point.color}; left: #{point.x}px; top: #{point.y}px;"}
          title={"Point by #{String.slice(point.user_id || "", 0, 6)} at X: #{trunc(point.x)}, Y: #{trunc(point.y)}"}
        >
        </div>
      </div>

      <div class="mt-2 text-xs opacity-70 text-center">
        Click anywhere in the visualization area to save a point
      </div>
    </div>
    """
  end

  defp other_user_cursor(assigns) do
    ~H"""
    <%= if @user.in_viz do %>
      <div
        class="absolute w-4 h-4 opacity-50"
        style={"left: calc(#{@user.relative_x}px - 8px); top: calc(#{@user.relative_y}px - 8px);"}
      >
        <div class="w-full h-full border-2" style={"border-color: #{@user.color}"}></div>
      </div>
      <div
        class="absolute text-xs opacity-50"
        style={"color: #{@user.color}; left: calc(#{@user.relative_x}px + 12px); top: calc(#{@user.relative_y}px - 12px);"}
      >
        {String.slice(@user_id, 0, 6)}
      </div>
    <% end %>
    """
  end

  defp system_log(assigns) do
    ~H"""
    <div class="border border-green-500 p-4">
      <div class="text-xs mb-2 opacity-70">// SYSTEM LOG</div>
      <div id="system-log" class="h-32 overflow-y-auto font-mono text-xs leading-relaxed">
        <div>> Current position: X:{@x_pos} Y:{@y_pos}</div>
        <%= if @in_visualization do %>
          <div>
            > Cursor in visualization area: X:{@relative_x |> trunc()} Y:{@relative_y |> trunc()}
          </div>
        <% end %>
        <%= if length(@favorite_points) > 0 do %>
          <div>> Saved points: {length(@favorite_points)}</div>
          <div :for={{point, index} <- Enum.with_index(Enum.take(@favorite_points, 5))}>
            > Point {index + 1}: X:{point.x |> trunc()} Y:{point.y |> trunc()} by {point_author_label(point.user_id, @user_id)}
          </div>
          <%= if length(@favorite_points) > 5 do %>
            <div>> ... and {length(@favorite_points) - 5} more points</div>
          <% end %>
        <% end %>
        <%= if map_size(@other_users) > 0 do %>
          <div>> Other users online: {map_size(@other_users)}</div>
        <% end %>
        <div>
          > Auto-clear scheduled in {@next_clear.hours}h {@next_clear.minutes}m {@next_clear.seconds}s
        </div>
      </div>
    </div>
    """
  end
end
