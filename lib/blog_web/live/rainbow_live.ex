defmodule BlogWeb.RainbowLive do
  use BlogWeb, :live_view
  require Logger

  @rainbow_colors [
    "#FF0000", # Red
    "#FF7F00", # Orange
    "#FFFF00", # Yellow
    "#00FF00", # Green
    "#0000FF", # Blue
    "#4B0082", # Indigo
    "#9400D3"  # Violet
  ]
  @frame_interval 50 # 50ms between frames
  @max_radius 300
  @animation_steps 60

  # Add DVD animation configuration
  @dvd_speed 2
  @viewport_width 600
  @viewport_height 400
  @logo_width 100
  @logo_height 50

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok,
     assign(socket,
       rainbows: [],  # List of rainbow states
       dvd_pos: %{  # Add DVD position state
         x: Enum.random(-300..300),  # Use integers instead of float division
         y: Enum.random(-200..200),  # Match the SVG viewBox dimensions
         dx: @dvd_speed,
         dy: @dvd_speed,
         hue: 0
       },
       meta_attrs: [
         %{name: "title", content: "Type shit and hear sounds and see wild shit or whatever"},
         %{name: "description", content: "Bobby got high and made it so it looks wild when you press keys, theres web audio too but its broken."},
         %{property: "og:title", content: "Type shit and hear sounds and see wild shit or whatever"},
         %{property: "og:description", content: "Bobby got high and made it so it looks wild when you press keys, theres web audio too but its broken."},
         %{property: "og:type", content: "website"}
       ],
       page_title: "lol start typing and see what happens"
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) when byte_size(key) == 1 do
    # Create a new rainbow with random position
    new_rainbow = %{
      id: System.unique_integer([:positive]),
      frame: 0,
      x: Enum.random(-100..100),  # Random x position
      y: Enum.random(-50..50)     # Random y position
    }

    {:noreply, assign(socket, rainbows: [new_rainbow | socket.assigns.rainbows])}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  def handle_info(:animate, socket) do
    Process.send_after(self(), :animate, @frame_interval)

    # Update DVD position and handle bouncing
    dvd_pos = update_dvd_position(socket.assigns.dvd_pos)

    # Update rainbows (keep existing rainbow update logic)
    updated_rainbows = socket.assigns.rainbows
    |> Enum.map(fn rainbow ->
      %{rainbow | frame: rainbow.frame + 1}
    end)
    |> Enum.reject(fn rainbow ->
      rainbow.frame >= @animation_steps
    end)

    {:noreply, assign(socket,
      rainbows: updated_rainbows,
      dvd_pos: dvd_pos
    )}
  end

  # Add DVD position update logic
  defp update_dvd_position(pos) do
    new_x = pos.x + pos.dx
    new_y = pos.y + pos.dy

    {dx, new_hue} = if new_x <= -(@viewport_width/2) + @logo_width or new_x >= (@viewport_width/2) - @logo_width do
      {-pos.dx, rem(pos.hue + 60, 360)}
    else
      {pos.dx, pos.hue}
    end

    {dy, final_hue} = if new_y <= -(@viewport_height/2) + @logo_height or new_y >= (@viewport_height/2) - @logo_height do
      {-pos.dy, rem(new_hue + 60, 360)}
    else
      {pos.dy, new_hue}
    end

    %{
      x: new_x,
      y: new_y,
      dx: dx,
      dy: dy,
      hue: final_hue
    }
  end

  defp calculate_arcs(frame) do
    progress = frame / @animation_steps

    @rainbow_colors
    |> Enum.with_index()
    |> Enum.map(fn {color, index} ->
      radius = @max_radius - (index * 40)
      arc_progress = min(1.0, progress * 1.2 - (index * 0.1))

      if arc_progress > 0 do
        generate_arc_path(radius, arc_progress, color)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp generate_arc_path(radius, progress, color) do
    end_angle = :math.pi * progress
    end_x = radius * :math.cos(end_angle)
    end_y = radius * :math.sin(end_angle)

    path = "M #{radius} 0 A #{radius} #{radius} 0 0 1 #{end_x} #{end_y}"

    %{
      path: path,
      color: color,
      stroke_width: 20
    }
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen bg-gray-900" phx-window-keydown="keydown">
      <svg width="100%" height="100vh" viewBox="-300 -200 600 400">
        <%!-- DVD Logo --%>
        <g transform={"translate(#{@dvd_pos.x}, #{@dvd_pos.y})"}>
          <path
            d="M-50,-25 h100 v50 h-100 z M-30,-15 L-10,15 H10 L30,-15 H-30 Z M-20,0 h40 M-25,-10 h50"
            fill={"hsl(#{@dvd_pos.hue}, 100%, 70%)"}
            style="transform-origin: center; transform: scale(0.8);"
          >
            <animate
              attributeName="opacity"
              values="0.8;1;0.8"
              dur="2s"
              repeatCount="indefinite"
            />
          </path>
          <text
            x="0"
            y="5"
            text-anchor="middle"
            fill="white"
            font-family="Arial Black"
            font-size="20"
          >DVD</text>
        </g>

        <%!-- Keep existing rainbow rendering --%>
        <%= for rainbow <- @rainbows do %>
          <g transform={"translate(#{rainbow.x}, #{rainbow.y})"}>
            <%= for arc <- calculate_arcs(rainbow.frame) do %>
              <path
                d={arc.path}
                stroke={arc.color}
                stroke-width={arc.stroke_width}
                fill="none"
              />
            <% end %>
          </g>
        <% end %>
      </svg>
    </div>
    """
  end
end
