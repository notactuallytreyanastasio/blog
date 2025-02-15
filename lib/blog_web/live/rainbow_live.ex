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
  @text_lifetime 40 # How many frames the text stays visible

  # Add DVD animation configuration
  @dvd_speed 2
  @viewport_width 600
  @viewport_height 400
  @logo_width 100
  @logo_height 50

  # Add new animation configs
  @bubble_count 15
  @star_count 5
  @spiral_arms 6

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok,
     assign(socket,
       rainbows: [],  # List of rainbow states
       letters: [],  # List to track letters and their positions/lifetimes
       play_sound: false,  # Add this to track when to play sound
       # Add DVD logo state
       dvd_pos: %{
         x: Enum.random(0..@viewport_width),
         y: Enum.random(0..@viewport_height),
         dx: @dvd_speed,
         dy: @dvd_speed,
         hue: 0
       },
       # Add new animation states
       bubbles: create_bubbles(),
       stars: create_stars(),
       spiral_rotation: 0,
       spiral_arms: @spiral_arms,
       meta_attrs: [
         %{name: "title", content: "Rainbow Animation"},
         %{name: "description", content: "Bobby is doinking around with art and computers. type on the page to see the rainbow animation change."},
         %{property: "og:title", content: "Rainbow Animation shit started this lets see where it goes, it changes when you type on the page"},
         %{property: "og:description", content: "Bobby is doinking around with art and computers. type on the page to see the rainbow animation change."},
         %{property: "og:type", content: "website"}
       ],
       page_title: "Rainbow Animation"
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) when byte_size(key) == 1 do
    # Create a new rainbow
    new_rainbow = %{
      id: System.unique_integer([:positive]),
      frame: 0,
      x: Enum.random(-100..100),
      y: Enum.random(-50..50)
    }

    # Create a new letter with rotation properties
    new_letter = %{
      id: System.unique_integer([:positive]),
      char: key,
      frame: 0,
      x: new_rainbow.x,
      y: new_rainbow.y,
      size: Enum.random(50..150),
      rotation_speed: Enum.random(-10..10),  # Degrees per frame
      rotation: Enum.random(0..360)          # Initial rotation
    }

    {:noreply,
     assign(socket,
       rainbows: [new_rainbow | socket.assigns.rainbows],
       letters: [new_letter | socket.assigns.letters]
     )}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  def handle_info(:animate, socket) do
    Process.send_after(self(), :animate, @frame_interval)

    # Update DVD position and handle bouncing
    dvd_pos = update_dvd_position(socket.assigns.dvd_pos)

    # Track which rainbows are completing this frame
    {completing, continuing} = socket.assigns.rainbows
    |> Enum.map(fn rainbow ->
      %{rainbow | frame: rainbow.frame + 1}
    end)
    |> Enum.split_with(fn rainbow ->
      rainbow.frame >= @animation_steps
    end)

    # Set play_sound if any rainbows completed
    should_play = length(completing) > 0

    # Update letters with rotation
    updated_letters = socket.assigns.letters
    |> Enum.map(fn letter ->
      %{letter |
        frame: letter.frame + 1,
        rotation: letter.rotation + letter.rotation_speed
      }
    end)
    |> Enum.reject(fn letter ->
      letter.frame >= @text_lifetime
    end)

    # Update new animations
    updated_bubbles = update_bubbles(socket.assigns.bubbles)
    updated_stars = update_stars(socket.assigns.stars)
    updated_spiral = rem(socket.assigns.spiral_rotation + 2, 360)

    {:noreply, assign(socket,
      rainbows: continuing,
      letters: updated_letters,
      play_sound: should_play,
      dvd_pos: dvd_pos,
      bubbles: updated_bubbles,
      stars: updated_stars,
      spiral_rotation: updated_spiral
    )}
  end

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

  defp calculate_letter_opacity(frame) do
    1 - (frame / @text_lifetime)
  end

  defp create_bubbles do
    for _i <- 1..@bubble_count do
      %{
        x: Enum.random(-300..300),
        y: Enum.random(-200..200),
        size: Enum.random(10..30),
        speed: Enum.random(1..3),
        hue: Enum.random(0..360),
        offset: Enum.random(0..100)
      }
    end
  end

  defp create_stars do
    for _i <- 1..@star_count do
      %{
        x: -400,
        y: Enum.random(-200..200),
        angle: :math.atan2(Enum.random(-100..100), 400),
        speed: Enum.random(5..10),
        length: Enum.random(30..60),
        hue: Enum.random(0..360),
        active: true
      }
    end
  end

  defp update_bubbles(bubbles) do
    Enum.map(bubbles, fn bubble ->
      new_y = bubble.y - bubble.speed
      y = if new_y < -250, do: 250, else: new_y

      # Add subtle horizontal movement using sine wave
      x_offset = :math.sin((bubble.offset + y) / 50) * 5

      %{bubble |
        y: y,
        x: bubble.x + x_offset
      }
    end)
  end

  defp update_stars(stars) do
    Enum.map(stars, fn star ->
      if star.active do
        new_x = star.x + :math.cos(star.angle) * star.speed
        new_y = star.y + :math.sin(star.angle) * star.speed

        if new_x > 400 do
          # Reset star to start position with new random values
          %{star |
            x: -400,
            y: Enum.random(-200..200),
            angle: :math.atan2(Enum.random(-100..100), 400),
            hue: Enum.random(0..360)
          }
        else
          %{star | x: new_x, y: new_y}
        end
      else
        star
      end
    end)
  end

  defp generate_spiral_path(rotation) do
    points = for t <- 0..50 do
      r = t * 2
      angle = t * 0.5 + rotation * :math.pi / 180
      x = r * :math.cos(angle)
      y = r * :math.sin(angle)
      "#{x},#{y}"
    end

    "M " <> Enum.join(points, " L ")
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen" phx-window-keydown="keydown">
      <%!-- Add SVG filters for noise --%>
      <svg width="0" height="0">
        <defs>
          <filter id="noise">
            <feTurbulence
              type="fractalNoise"
              baseFrequency="0.6"
              numOctaves="3"
              seed="1"
            >
              <animate
                attributeName="seed"
                from="1"
                to="100"
                dur="3s"
                repeatCount="indefinite"
              />
            </feTurbulence>
            <feColorMatrix type="saturate" values="0"/>
            <feBlend mode="multiply" in2="SourceGraphic"/>
          </filter>

          <%!-- Add shine effect for DVD logo --%>
          <filter id="shine">
            <feGaussianBlur in="SourceAlpha" stdDeviation="2" result="blur"/>
            <feSpecularLighting in="blur" surfaceScale="5" specularConstant="1" specularExponent="20" result="spec">
              <fePointLight x="-5000" y="-10000" z="20000"/>
            </feSpecularLighting>
            <feComposite in="SourceGraphic" in2="spec" operator="arithmetic" k1="0" k2="1" k3="1" k4="0"/>
          </filter>
        </defs>
      </svg>

      <%!-- Background with noise --%>
      <div class="absolute inset-0 bg-gray-900 animate-noise">
        <style>
          @keyframes shift {
            from {
              filter: url(#noise) hue-rotate(0deg);
              opacity: 0.3;
            }
            to {
              filter: url(#noise) hue-rotate(360deg);
              opacity: 0.4;
            }
          }
          .animate-noise {
            animation: shift 20s linear infinite;
            background: linear-gradient(
              45deg,
              rgba(20, 20, 30, 0.9),
              rgba(40, 40, 60, 0.9)
            );
          }
        </style>
      </div>

      <%!-- Main content with DVD logo --%>
      <svg width="100%" height="100vh" viewBox="-300 -200 600 400" style="position: relative; z-index: 1;">
        <%!-- DVD Logo --%>
        <g transform={"translate(#{@dvd_pos.x}, #{@dvd_pos.y})"}>
          <path
            d="M-50,-25 h100 v50 h-100 z M-30,-15 L-10,15 H10 L30,-15 H-30 Z M-20,0 h40 M-25,-10 h50"
            fill={"hsl(#{@dvd_pos.hue}, 100%, 70%)"}
            filter="url(#shine)"
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
            filter="url(#shine)"
          >DVD</text>
        </g>

        <%!-- Floating Bubbles --%>
        <%= for bubble <- @bubbles do %>
          <circle
            cx={bubble.x}
            cy={bubble.y}
            r={bubble.size}
            fill={"hsla(#{bubble.hue}, 100%, 70%, 0.6)"}
            filter="url(#shine)"
          >
            <animate
              attributeName="r"
              values={"#{bubble.size};#{bubble.size * 1.2};#{bubble.size}"}
              dur="2s"
              repeatCount="indefinite"
              begin={"#{bubble.offset}ms"}
            />
          </circle>
        <% end %>

        <%!-- Shooting Stars --%>
        <%= for star <- @stars do %>
          <g transform={"translate(#{star.x}, #{star.y})"}>
            <path
              d={"M0,0 L#{star.length},0"}
              stroke={"hsl(#{star.hue}, 100%, 70%)"}
              stroke-width="2"
              transform={"rotate(#{:math.atan2(:math.sin(star.angle), :math.cos(star.angle)) * 180 / :math.pi})"}
            >
              <animate
                attributeName="stroke-width"
                values="2;4;2"
                dur="0.5s"
                repeatCount="indefinite"
              />
            </path>
          </g>
        <% end %>

        <%!-- Pulsing Spiral --%>
        <%= for i <- 0..(@spiral_arms - 1) do %>
          <path
            d={generate_spiral_path(i * 360 / @spiral_arms + @spiral_rotation)}
            stroke={"hsl(#{i * 360 / @spiral_arms}, 100%, 70%)"}
            stroke-width="2"
            fill="none"
            opacity="0.5"
          >
            <animate
              attributeName="stroke-width"
              values="2;4;2"
              dur="1s"
              repeatCount="indefinite"
              begin={"#{i * 150}ms"}
            />
          </path>
        <% end %>

        <%!-- Keep existing rainbows and letters --%>
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
        <%= for letter <- @letters do %>
          <text
            x={letter.x}
            y={letter.y}
            font-size={letter.size}
            fill="white"
            text-anchor="middle"
            dominant-baseline="middle"
            opacity={calculate_letter_opacity(letter.frame)}
            transform={"rotate(#{letter.rotation}, #{letter.x}, #{letter.y})"}
          >
            <%= letter.char %>
          </text>
        <% end %>
      </svg>

      <%!-- Keep existing script and sound trigger --%>
      <script>
        let audioCtx;

        // Initialize audio context on first user interaction
        window.addEventListener('keydown', () => {
          if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
          }
        });

        // Function to play a pleasant chime sound
        function playChime() {
          if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
          }

          const oscillator = audioCtx.createOscillator();
          const gainNode = audioCtx.createGain();

          oscillator.connect(gainNode);
          gainNode.connect(audioCtx.destination);

          oscillator.frequency.setValueAtTime(523.25, audioCtx.currentTime);
          oscillator.type = 'sine';

          gainNode.gain.setValueAtTime(0, audioCtx.currentTime);
          gainNode.gain.linearRampToValueAtTime(0.3, audioCtx.currentTime + 0.01);
          gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);

          oscillator.start();
          oscillator.stop(audioCtx.currentTime + 0.3);
        }

        // Watch for changes to play_sound
        let lastPlaySound = false;
        const observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.type === "attributes" && mutation.attributeName === "data-play-sound") {
              const shouldPlay = mutation.target.getAttribute("data-play-sound") === "true";
              if (shouldPlay && !lastPlaySound) {
                playChime();
              }
              lastPlaySound = shouldPlay;
            }
          });
        });

        // Start observing when the element is available
        document.addEventListener('DOMContentLoaded', () => {
          const trigger = document.getElementById('sound-trigger');
          if (trigger) {
            observer.observe(trigger, {
              attributes: true,
              attributeFilter: ['data-play-sound']
            });
          }
        });
      </script>

      <div id="sound-trigger" data-play-sound={@play_sound} phx-update="ignore"></div>
    </div>
    """
  end
end
