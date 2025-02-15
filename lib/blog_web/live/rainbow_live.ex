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

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok,
     assign(socket,
       rainbows: [],  # List of rainbow states
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

    # Update each rainbow's frame and remove completed ones
    updated_rainbows = socket.assigns.rainbows
    |> Enum.map(fn rainbow ->
      %{rainbow | frame: rainbow.frame + 1}
    end)
    |> Enum.reject(fn rainbow ->
      rainbow.frame >= @animation_steps
    end)

    {:noreply, assign(socket, rainbows: updated_rainbows)}
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
