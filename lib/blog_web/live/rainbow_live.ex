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

  # Add these module attributes
  @particle_count 12  # Number of particles per explosion
  @particle_lifetime 80  # How long particles live

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok,
     assign(socket,
       rainbows: [],  # List of rainbow states
       letters: [],   # Add letters state back
       particles: [],  # Add particles state
       dvd_pos: %{
         x: Enum.random(-300..300),
         y: Enum.random(-200..200),
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
    # Create position for all animations
    pos_x = Enum.random(-100..100)
    pos_y = Enum.random(-50..50)

    # Create a new rainbow
    new_rainbow = %{
      id: System.unique_integer([:positive]),
      frame: 0,
      x: pos_x,
      y: pos_y
    }

    # Create particles for spiral explosion
    new_particles = for i <- 1..@particle_count do
      angle = i * (2 * :math.pi / @particle_count)
      %{
        id: System.unique_integer([:positive]),
        frame: 0,
        x: pos_x,
        y: pos_y,
        dx: :math.cos(angle) * 3,
        dy: :math.sin(angle) * 3,
        hue: Enum.random(0..360),
        size: Enum.random(5..15),
        rotation: angle * 180 / :math.pi
      }
    end

    # Create a new letter with enhanced animation
    new_letter = %{
      id: System.unique_integer([:positive]),
      char: key,
      frame: 0,
      x: pos_x,
      y: pos_y,
      size: 200,  # Bigger initial size
      rotation_speed: Enum.random(-5..5),
      rotation: 0,
      scale: 0.1  # Start small and grow
    }

    {:noreply,
     assign(socket,
       rainbows: [new_rainbow | socket.assigns.rainbows],
       letters: [new_letter | socket.assigns.letters],
       particles: new_particles ++ (socket.assigns[:particles] || [])
     )}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  def handle_info(:animate, socket) do
    Process.send_after(self(), :animate, @frame_interval)

    # Update DVD position
    dvd_pos = update_dvd_position(socket.assigns.dvd_pos)

    # Update rainbows
    updated_rainbows = socket.assigns.rainbows
    |> Enum.map(fn rainbow ->
      %{rainbow | frame: rainbow.frame + 1}
    end)
    |> Enum.reject(fn rainbow ->
      rainbow.frame >= @animation_steps
    end)

    # Update letters with growth and rotation
    updated_letters = socket.assigns.letters
    |> Enum.map(fn letter ->
      new_scale = min(1.0, letter.scale + 0.05)  # Grow to full size
      %{letter |
        frame: letter.frame + 1,
        rotation: letter.rotation + letter.rotation_speed,
        scale: new_scale
      }
    end)
    |> Enum.reject(fn letter ->
      letter.frame >= @animation_steps
    end)

    # Update particles
    updated_particles = socket.assigns.particles
    |> Enum.map(fn particle ->
      %{particle |
        frame: particle.frame + 1,
        x: particle.x + particle.dx,
        y: particle.y + particle.dy,
        rotation: particle.rotation + 5
      }
    end)
    |> Enum.reject(fn particle ->
      particle.frame >= @particle_lifetime
    end)

    {:noreply, assign(socket,
      rainbows: updated_rainbows,
      letters: updated_letters,
      particles: updated_particles,
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

        <%!-- Particles --%>
        <%= for particle <- @particles do %>
          <g transform={"translate(#{particle.x}, #{particle.y}) rotate(#{particle.rotation})"}>
            <path
              d="M0,-#{particle.size} L#{particle.size/2},#{particle.size} L-#{particle.size/2},#{particle.size} Z"
              fill={"hsl(#{particle.hue}, 100%, 70%)"}
              opacity={calculate_particle_opacity(particle.frame)}
            />
          </g>
        <% end %>

        <%!-- Rainbows --%>
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

        <%!-- Letters --%>
        <%= for letter <- @letters do %>
          <text
            x={letter.x}
            y={letter.y}
            font-size={letter.size}
            fill="white"
            text-anchor="middle"
            dominant-baseline="middle"
            opacity={calculate_letter_opacity(letter.frame)}
            transform={"rotate(#{letter.rotation}, #{letter.x}, #{letter.y}) scale(#{letter.scale})"}
          >
            <%= letter.char %>
          </text>
        <% end %>
      </svg>
    </div>
    """
  end

  defp calculate_letter_opacity(frame) do
    1 - (frame / @animation_steps)
  end

  defp calculate_particle_opacity(frame) do
    1 - (frame / @particle_lifetime)
  end
end
