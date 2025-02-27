defmodule BlogWeb.RainbowLive do
  use BlogWeb, :live_view
  require Logger

  @rainbow_colors [
    # Red
    "#FF0000",
    # Orange
    "#FF7F00",
    # Yellow
    "#FFFF00",
    # Green
    "#00FF00",
    # Blue
    "#0000FF",
    # Indigo
    "#4B0082",
    # Violet
    "#9400D3"
  ]
  # 50ms between frames
  @frame_interval 50
  @max_radius 300
  @animation_steps 60

  # Add DVD animation configuration
  @dvd_speed 2
  @viewport_width 600
  @viewport_height 400
  @logo_width 100
  @logo_height 50

  # Add these module attributes
  # Number of particles per explosion
  @particle_count 12
  # How long particles live
  @particle_lifetime 80

  # Add new module attributes
  @exhaust_particle_lifetime 40
  # Emit particles every N frames
  @exhaust_emit_interval 2
  @exhaust_drift_speed 1.5

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok,
     assign(socket,
       # List of rainbow states
       rainbows: [],
       # Add letters state back
       letters: [],
       # Add particles state
       particles: [],
       dvd_pos: %{
         x: Enum.random(-300..300),
         y: Enum.random(-200..200),
         dx: @dvd_speed,
         dy: @dvd_speed,
         hue: 0
       },
       meta_attrs: [
         %{name: "title", content: "Type shit and hear sounds and see wild shit or whatever"},
         %{
           name: "description",
           content:
             "Bobby got high and made it so it looks wild when you press keys, theres web audio too but its broken."
         },
         %{
           property: "og:title",
           content: "Type shit and hear sounds and see wild shit or whatever"
         },
         %{
           property: "og:description",
           content:
             "Bobby got high and made it so it looks wild when you press keys, theres web audio too but its broken."
         },
         %{property: "og:type", content: "website"}
       ],
       page_title: "lol start typing and see what happens",
       mouse_pos: %{x: 0, y: 0},
       exhaust_particles: [],
       # For controlling particle emission rate
       frame_count: 0
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
    new_particles =
      for i <- 1..@particle_count do
        angle = i * (2 * :math.pi() / @particle_count)

        %{
          id: System.unique_integer([:positive]),
          frame: 0,
          x: pos_x,
          y: pos_y,
          dx: :math.cos(angle) * 3,
          dy: :math.sin(angle) * 3,
          hue: Enum.random(0..360),
          size: Enum.random(5..15),
          rotation: angle * 180 / :math.pi()
        }
      end

    # Create a new letter with enhanced animation
    new_letter = %{
      id: System.unique_integer([:positive]),
      char: key,
      frame: 0,
      x: pos_x,
      y: pos_y,
      # Bigger initial size
      size: 200,
      rotation_speed: Enum.random(-5..5),
      rotation: 0,
      # Start small and grow
      scale: 0.1
    }

    {:noreply,
     assign(socket,
       rainbows: [new_rainbow | socket.assigns.rainbows],
       letters: [new_letter | socket.assigns.letters],
       particles: new_particles ++ (socket.assigns[:particles] || []),
       mouse_pos: %{x: 0, y: 0},
       exhaust_particles: [],
       frame_count: 0
     )}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  def handle_event("mousemove", %{"offsetX" => x, "offsetY" => y}, socket) do
    # Convert screen coordinates to SVG viewBox coordinates
    svg_x = x / socket.assigns.window_width * 600 - 300
    svg_y = y / socket.assigns.window_height * 400 - 200

    {:noreply, assign(socket, mouse_pos: %{x: svg_x, y: svg_y})}
  end

  def handle_info(:animate, socket) do
    Process.send_after(self(), :animate, @frame_interval)

    # Update DVD position
    dvd_pos = update_dvd_position(socket.assigns.dvd_pos)

    # Update rainbows
    updated_rainbows =
      socket.assigns.rainbows
      |> Enum.map(fn rainbow ->
        %{rainbow | frame: rainbow.frame + 1}
      end)
      |> Enum.reject(fn rainbow ->
        rainbow.frame >= @animation_steps
      end)

    # Update letters with growth and rotation
    updated_letters =
      socket.assigns.letters
      |> Enum.map(fn letter ->
        # Grow to full size
        new_scale = min(1.0, letter.scale + 0.05)

        %{
          letter
          | frame: letter.frame + 1,
            rotation: letter.rotation + letter.rotation_speed,
            scale: new_scale
        }
      end)
      |> Enum.reject(fn letter ->
        letter.frame >= @animation_steps
      end)

    # Update particles
    updated_particles =
      socket.assigns.particles
      |> Enum.map(fn particle ->
        %{
          particle
          | frame: particle.frame + 1,
            x: particle.x + particle.dx,
            y: particle.y + particle.dy,
            rotation: particle.rotation + 5
        }
      end)
      |> Enum.reject(fn particle ->
        particle.frame >= @particle_lifetime
      end)

    # Create new exhaust particles periodically
    {new_exhaust, frame_count} =
      if rem(socket.assigns.frame_count, @exhaust_emit_interval) == 0 do
        new_particles =
          for _i <- 1..3 do
            %{
              x: socket.assigns.mouse_pos.x,
              y: socket.assigns.mouse_pos.y,
              dx: :rand.normal() * @exhaust_drift_speed,
              dy: :rand.normal() * @exhaust_drift_speed,
              size: Enum.random(3..8),
              frame: 0,
              # Blue-ish colors
              hue: Enum.random(200..240)
            }
          end

        {new_particles, socket.assigns.frame_count + 1}
      else
        {[], socket.assigns.frame_count + 1}
      end

    # Update existing exhaust particles
    updated_exhaust =
      (socket.assigns.exhaust_particles ++ new_exhaust)
      |> Enum.map(fn particle ->
        %{
          particle
          | frame: particle.frame + 1,
            x: particle.x + particle.dx,
            y: particle.y + particle.dy,
            # Slowly grow
            size: particle.size * 1.02
        }
      end)
      |> Enum.reject(fn particle ->
        particle.frame >= @exhaust_particle_lifetime
      end)

    {:noreply,
     assign(socket,
       rainbows: updated_rainbows,
       letters: updated_letters,
       particles: updated_particles,
       dvd_pos: dvd_pos,
       exhaust_particles: updated_exhaust,
       frame_count: frame_count
     )}
  end

  # Add DVD position update logic
  defp update_dvd_position(pos) do
    new_x = pos.x + pos.dx
    new_y = pos.y + pos.dy

    {dx, new_hue} =
      if new_x <= -(@viewport_width / 2) + @logo_width or
           new_x >= @viewport_width / 2 - @logo_width do
        {-pos.dx, rem(pos.hue + 60, 360)}
      else
        {pos.dx, pos.hue}
      end

    {dy, final_hue} =
      if new_y <= -(@viewport_height / 2) + @logo_height or
           new_y >= @viewport_height / 2 - @logo_height do
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
      radius = @max_radius - index * 40
      arc_progress = min(1.0, progress * 1.2 - index * 0.1)

      if arc_progress > 0 do
        generate_arc_path(radius, arc_progress, color)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp generate_arc_path(radius, progress, color) do
    end_angle = :math.pi() * progress
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
    <div
      class="flex justify-center items-center min-h-screen bg-gray-900"
      id="rainbow-container"
      phx-window-keydown="keydown"
      phx-mousemove="mousemove"
      phx-hook="WindowSize"
    >
      <svg width="100%" height="100vh" viewBox="-300 -200 600 400">
        <%!-- Exhaust particles --%>
        <%= for particle <- @exhaust_particles do %>
          <circle
            cx={particle.x}
            cy={particle.y}
            r={particle.size}
            fill={"hsla(#{particle.hue}, 70%, 50%, #{calculate_exhaust_opacity(particle.frame)})"}
            filter="url(#blur)"
          />
        <% end %>

        <%!-- Add blur filter for smoother particles --%>
        <defs>
          <filter id="blur">
            <feGaussianBlur stdDeviation="2" />
          </filter>
        </defs>

        <%!-- DVD Logo --%>
        <g transform={"translate(#{@dvd_pos.x}, #{@dvd_pos.y})"}>
          <path
            d="M-50,-25 h100 v50 h-100 z"
            fill={"hsl(#{@dvd_pos.hue}, 100%, 70%)"}
            style="transform-origin: center; transform: scale(0.8);"
          >
            <animate attributeName="opacity" values="0.8;1;0.8" dur="2s" repeatCount="indefinite" />
          </path>
          <text
            x="0"
            y="0"
            text-anchor="middle"
            dominant-baseline="middle"
            fill="white"
            font-family="Arial Black"
            font-size="30"
            style="font-weight: bold;"
          >
            DVD
          </text>
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
              <path d={arc.path} stroke={arc.color} stroke-width={arc.stroke_width} fill="none" />
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
            {letter.char}
          </text>
        <% end %>
      </svg>
    </div>
    """
  end

  defp calculate_letter_opacity(frame) do
    1 - frame / @animation_steps
  end

  defp calculate_particle_opacity(frame) do
    1 - frame / @particle_lifetime
  end

  defp calculate_exhaust_opacity(frame) do
    opacity = 1 - frame / @exhaust_particle_lifetime
    # Make them semi-transparent
    opacity * 0.6
  end
end
