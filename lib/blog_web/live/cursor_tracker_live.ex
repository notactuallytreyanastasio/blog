defmodule BlogWeb.CursorTrackerLive do
  use BlogWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    socket = assign(socket,
      x_pos: 0,
      y_pos: 0,
      relative_x: 0,
      relative_y: 0,
      in_visualization: false,
      favorite_points: [],
      page_title: "Cursor Tracker",
      meta_attrs: [
        %{name: "description", content: "Retro hacker-style cursor position tracker"},
        %{property: "og:title", content: "Cursor Tracker"},
        %{property: "og:description", content: "Retro hacker-style cursor position tracker"},
        %{property: "og:type", content: "website"}
      ]
    )

    {:ok, socket}
  end

  def handle_event("mousemove", %{"x" => x, "y" => y} = params, socket) do
    # Extract relative coordinates if available
    relative_x = Map.get(params, "relativeX", 0)
    relative_y = Map.get(params, "relativeY", 0)
    in_visualization = Map.get(params, "inVisualization", false)

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
      # Generate a random color for this point
      color = generate_random_color()

      # Create a new favorite point with the current coordinates and the generated color
      new_point = %{
        x: socket.assigns.relative_x,
        y: socket.assigns.relative_y,
        color: color,
        timestamp: DateTime.utc_now()
      }

      # Add the new point to the list of favorite points
      updated_points = [new_point | socket.assigns.favorite_points]

      {:noreply, assign(socket, favorite_points: updated_points)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("clear_points", _params, socket) do
    {:noreply, assign(socket, favorite_points: [])}
  end

  defp generate_random_color do
    # Generate bright, neon-like colors for the retro hacker aesthetic
    hue = :rand.uniform(360)
    "hsl(#{hue}, 100%, 70%)"
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

            <%= for point <- @favorite_points do %>
              <div
                class="absolute w-3 h-3 rounded-full transform -translate-x-1/2 -translate-y-1/2"
                style={"background-color: #{point.color}; left: #{point.x}px; top: #{point.y}px;"}
                title={"Saved point at X: #{trunc(point.x)}, Y: #{trunc(point.y)}"}
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
              <%= for {point, index} <- Enum.with_index(@favorite_points) do %>
                <div>> Point <%= index + 1 %>: X:<%= point.x |> trunc() %> Y:<%= point.y |> trunc() %></div>
              <% end %>
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
