defmodule BlogWeb.PongGodLive do
  use BlogWeb, :live_view
  alias BlogWeb.PongLive
  require Logger

  @refresh_interval 50
  @max_explosions 20
  @explosion_interval 50
  @particles_per_explosion 30
  @explosion_types [:burst, :spiral]
  @rainbow_width 3
  @trail_length 40
  @game_width 800
  @game_height 600
  @paddle_height 100
  @rainbow_colors [
    # Pink
    "#FF1A8C",
    # Magenta
    "#E81CFF",
    # Purple
    "#841CFF",
    # Blue
    "#1C56FF",
    # Cyan
    "#1CD7FF",
    # Green
    "#1CFF78",
    # Yellow
    "#FFE81C",
    # Orange
    "#FF781C"
  ]
  @musical_notes [
    "C4",
    "D4",
    "E4",
    "F4",
    "G4",
    "A4",
    "B4",
    "C5",
    "D5",
    "E5",
    "F5",
    "G5"
  ]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Start the refresh timer
      :timer.send_interval(@refresh_interval, :refresh)
      # Start the explosion timer
      :timer.send_interval(@explosion_interval, :generate_explosion)
    end

    # Initialize the socket with empty games and explosions
    socket =
      socket
      |> assign(:games, [])
      |> assign(:explosions, [])
      |> assign(:rainbow_paths, %{})
      |> assign(:rainbow_width, @rainbow_width)
      |> assign(:rainbow_colors, @rainbow_colors)
      |> assign(:game_width, @game_width)
      |> assign(:game_height, @game_height)
      |> assign(:paddle_height, @paddle_height)
      |> assign(:musical_notes, @musical_notes)
      |> assign(:game_scores, %{})
      |> assign(:play_sound, false)
      |> assign(:sound_note, nil)

    {:ok, socket}
  end

  def handle_info(:refresh, socket) do
    # Get all games from PongLive
    games = PongLive.get_all_games()

    # Update rainbow paths for each game
    rainbow_paths =
      update_rainbow_paths(socket.assigns.rainbow_paths, games, socket.assigns.rainbow_colors)

    # Check for score changes to play sounds
    {play_sound, sound_note, game_scores} =
      check_for_score_changes(games, socket.assigns.game_scores, socket.assigns.musical_notes)

    # Update explosions - remove expired ones
    explosions =
      socket.assigns.explosions
      |> Enum.map(fn explosion ->
        # Reduce life of explosion based on type
        life_reduction =
          case explosion.type do
            :burst -> 2
            :spiral -> 1
            _ -> 2
          end

        %{explosion | life: explosion.life - life_reduction}
      end)
      |> Enum.filter(fn explosion -> explosion.life > 0 end)

    {:noreply,
     assign(socket,
       games: games,
       explosions: explosions,
       rainbow_paths: rainbow_paths,
       play_sound: play_sound,
       sound_note: sound_note,
       game_scores: game_scores
     )}
  end

  def handle_info(:generate_explosion, socket) do
    # Only generate a new explosion if we're under the limit
    if length(socket.assigns.explosions) < @max_explosions do
      new_explosion = generate_explosion(socket.assigns.rainbow_colors)
      {:noreply, assign(socket, explosions: [new_explosion | socket.assigns.explosions])}
    else
      {:noreply, socket}
    end
  end

  # Check for score changes to play sounds
  defp check_for_score_changes(games, previous_scores, musical_notes) do
    {play_sound, sound_note, new_scores} =
      games
      |> Enum.reduce({false, nil, previous_scores}, fn game, {should_play, note, scores_acc} ->
        game_id = Map.get(game, :game_id)
        current_score = get_in(game, [:scores, :wall])
        previous_score = Map.get(scores_acc, game_id, 0)

        if game_id && current_score > previous_score do
          # Score increased, play a sound
          random_note = Enum.random(musical_notes)
          {true, random_note, Map.put(scores_acc, game_id, current_score)}
        else
          # Update the score in our tracking map
          {should_play, note, Map.put(scores_acc, game_id, current_score || 0)}
        end
      end)

    {play_sound, sound_note, new_scores}
  end

  # Generate a random explosion
  defp generate_explosion(rainbow_colors) do
    # Random position within the viewport
    x = :rand.uniform(800)
    y = :rand.uniform(600)

    # Random size
    size = :rand.uniform(5) + 8

    # Random explosion type
    type = Enum.random(@explosion_types)

    # Create the explosion with particles
    %{
      x: x,
      y: y,
      size: size,
      type: type,
      life: :rand.uniform(200) + 600,
      particles: generate_particles(type, x, y, size, rainbow_colors)
    }
  end

  # Generate particles based on explosion type
  defp generate_particles(:burst, x, y, size, rainbow_colors) do
    for i <- 1..@particles_per_explosion do
      angle = :rand.uniform() * 2 * :math.pi()
      distance = :rand.uniform(size * 3)
      particle_x = x + :math.cos(angle) * distance
      particle_y = y + :math.sin(angle) * distance
      particle_size = :rand.uniform(3) + 1

      %{
        x: particle_x,
        y: particle_y,
        size: particle_size,
        color: Enum.random(rainbow_colors)
      }
    end
  end

  defp generate_particles(:spiral, x, y, size, rainbow_colors) do
    for i <- 1..@particles_per_explosion do
      angle = i / @particles_per_explosion * 2 * :math.pi() * 3
      distance = size * (i / @particles_per_explosion) * 2
      particle_x = x + :math.cos(angle) * distance
      particle_y = y + :math.sin(angle) * distance
      particle_size = :rand.uniform(2) + 1

      %{
        x: particle_x,
        y: particle_y,
        size: particle_size,
        color: Enum.at(rainbow_colors, rem(i, length(rainbow_colors)))
      }
    end
  end

  # Update rainbow paths for each game
  defp update_rainbow_paths(existing_paths, games, rainbow_colors) do
    games
    |> Enum.reduce(%{}, fn game, acc ->
      game_id = Map.get(game, :game_id)
      ball = Map.get(game, :ball)

      if game_id && ball do
        # Get existing path or initialize a new one
        existing_path = Map.get(existing_paths, game_id, [])

        # Add new point to the path
        new_point = %{
          x: ball.x,
          y: ball.y,
          color: get_rainbow_color(length(existing_path), rainbow_colors)
        }

        # Keep only the last @trail_length points
        updated_path = [new_point | existing_path] |> Enum.take(@trail_length)

        Map.put(acc, game_id, updated_path)
      else
        acc
      end
    end)
  end

  # Generate a rainbow color based on index
  defp get_rainbow_color(index, rainbow_colors) do
    Enum.at(rainbow_colors, rem(index, length(rainbow_colors)))
  end

  # Generate SVG path for rainbow trail
  defp generate_rainbow_path(points) do
    if length(points) >= 2 do
      points
      |> Enum.map(fn %{x: x, y: y} -> "#{x},#{y}" end)
      |> Enum.join(" ")
    else
      ""
    end
  end

  # Calculate the scaled position for the preview
  defp scale_position(value, dimension, preview_dimension) do
    value / dimension * preview_dimension
  end

  # Get frequency for a musical note
  defp get_note_frequency(note) do
    case note do
      "C4" -> 261.63
      "D4" -> 293.66
      "E4" -> 329.63
      "F4" -> 349.23
      "G4" -> 392.00
      "A4" -> 440.00
      "B4" -> 493.88
      "C5" -> 523.25
      "D5" -> 587.33
      "E5" -> 659.25
      "F5" -> 698.46
      "G5" -> 783.99
      # Default to A4
      _ -> 440.00
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-full bg-gradient-to-br from-gray-900 to-gray-800 p-4 overflow-hidden">
      <div class="text-center mb-4">
        <h1 class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-3xl font-bold">
          Pong God Mode
        </h1>
        <p class="text-gray-300 mt-2">
          Watching {length(@games)} active games
        </p>
      </div>
      
    <!-- Sound player -->
      <%= if @play_sound && @sound_note do %>
        <div id="sound-player" phx-hook="PlaySound" data-frequency={get_note_frequency(@sound_note)}>
        </div>
      <% end %>
      
    <!-- Background particles container with pointer-events: none -->
      <div class="fixed inset-0 pointer-events-none z-10">
        <%= for explosion <- @explosions do %>
          <%= for particle <- explosion.particles do %>
            <div
              class="absolute rounded-full"
              style={"left: #{particle.x}px; top: #{particle.y}px; width: #{particle.size}px; height: #{particle.size}px; background-color: #{particle.color}; opacity: #{explosion.life / 800};"}
            >
            </div>
          <% end %>
        <% end %>
      </div>
      
    <!-- Rainbow trails container -->
      <div class="fixed inset-0 pointer-events-none z-0">
        <svg width="100%" height="100%" class="absolute inset-0">
          <%= for {game_id, points} <- @rainbow_paths do %>
            <%= if length(points) >= 2 do %>
              <polyline
                points={generate_rainbow_path(points)}
                fill="none"
                stroke="url(#rainbow-gradient-#{game_id})"
                stroke-width={@rainbow_width}
                stroke-linecap="round"
                stroke-linejoin="round"
                class="opacity-70"
              />
              
    <!-- Define a unique gradient for each game -->
              <defs>
                <linearGradient id={"rainbow-gradient-#{game_id}"} x1="0%" y1="0%" x2="100%" y2="0%">
                  <%= for {color, index} <- Enum.with_index(@rainbow_colors) do %>
                    <stop
                      offset={to_string(index * 100 / (length(@rainbow_colors) - 1)) <> "%"}
                      stop-color={color}
                    />
                  <% end %>
                </linearGradient>
              </defs>
            <% end %>
          <% end %>
        </svg>
      </div>
      
    <!-- Game previews -->
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 z-20 relative">
        <%= for game <- @games do %>
          <div class={"bg-gray-900 rounded-lg overflow-hidden border transition-colors duration-300 hover:opacity-100 opacity-80 #{if game.game_state == :defeat_message, do: "border-red-500 shadow-lg shadow-red-500/30", else: "border-gray-700 hover:border-fuchsia-500"}"}>
            <div class="p-2 bg-gradient-to-r from-fuchsia-900 to-cyan-900 text-white text-xs">
              <div class="truncate">
                Game ID: {game.game_id}
              </div>
              <div class="flex justify-between mt-1">
                <span>Score: {game.scores.wall}</span>
                <span>{if game.ai_controlled, do: "AI Playing", else: "Player Control"}</span>
              </div>
            </div>

            <div class="relative" style="height: 150px;">
              <!-- Game board -->
              <div class="absolute inset-0 bg-gray-900">
                <!-- Ball -->
                <div
                  class={"absolute rounded-full #{if game.game_state == :defeat_message, do: "animate-pulse"} bg-gradient-to-br from-fuchsia-500 via-purple-500 to-cyan-500"}
                  style={"width: 10px; height: 10px; left: #{game.ball.x / @game_width * 100}%; top: #{game.ball.y / @game_height * 100}%; transform: translate(-50%, -50%); filter: drop-shadow(0 0 4px rgba(217, 70, 239, 0.5));"}
                >
                </div>
                
    <!-- Paddle - correctly positioned and sized -->
                <div
                  class="absolute bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 rounded-sm"
                  style={"width: 4px; height: #{@paddle_height / @game_height * 150}px; left: #{game.paddle.x / @game_width * 100}%; top: #{game.paddle.y / @game_height * 100}%;"}
                >
                </div>
                
    <!-- Center line -->
                <div class="absolute left-1/2 top-0 w-px h-full bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 opacity-30">
                </div>
                
    <!-- Defeat message overlay -->
                <%= if game.game_state == :defeat_message do %>
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-yellow-500 text-lg font-bold animate-pulse">
                      DEFEAT
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>

      <div class="text-center mt-6">
        <a
          href={~p"/pong"}
          class="inline-block px-4 py-2 rounded-md bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-white font-bold hover:shadow-lg transition-shadow"
        >
          Play Pong
        </a>
      </div>
    </div>

    <script>
      // Add a hook for playing sounds
      document.addEventListener("DOMContentLoaded", () => {
        let audioContext;

        // Initialize audio context on user interaction
        document.addEventListener("click", initAudio, { once: true });

        function initAudio() {
          audioContext = new (window.AudioContext || window.webkitAudioContext)();
        }

        // Hook for playing sounds
        window.addEventListener("phx:hook-initialized", () => {
          window.LiveView.registerHook("PlaySound", {
            mounted() {
              if (!audioContext) {
                initAudio();
              }

              const frequency = parseFloat(this.el.dataset.frequency);
              playTone(frequency);
            }
          });
        });

        function playTone(frequency) {
          if (!audioContext) return;

          // Create oscillator
          const oscillator = audioContext.createOscillator();
          const gainNode = audioContext.createGain();

          // Set properties
          oscillator.type = "sine";
          oscillator.frequency.value = frequency;
          gainNode.gain.value = 0.1; // Lower volume

          // Connect nodes
          oscillator.connect(gainNode);
          gainNode.connect(audioContext.destination);

          // Start and stop
          oscillator.start();

          // Fade out
          gainNode.gain.exponentialRampToValueAtTime(0.001, audioContext.currentTime + 1.5);
          oscillator.stop(audioContext.currentTime + 1.5);
        }
      });
    </script>
    """
  end
end
