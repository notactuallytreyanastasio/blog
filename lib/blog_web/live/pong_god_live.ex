defmodule BlogWeb.PongGodLive do
  use BlogWeb, :live_view
  alias BlogWeb.PongLive

  @refresh_interval 100 # ms
  @cleanup_interval 30_000 # 30 seconds
  @explosion_interval 15 # 15ms (100x more frequent than 1500ms)
  @rainbow_segments 12 # Number of segments in each rainbow
  @rainbow_width 3 # Width of rainbow lines in pixels
  @particles_per_explosion 40 # Doubled from 20 to 40 particles per explosion
  @max_explosions 50 # Cap the number of simultaneous explosions to prevent performance issues

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval, :refresh)
      :timer.send_interval(@cleanup_interval, :cleanup_stale_games)
      :timer.send_interval(@explosion_interval, :create_explosion)
    end

    games = PongLive.get_all_games()
    # Sort games by score for better visibility
    sorted_games = Enum.sort_by(games, fn game ->
      -(game.scores || %{}).wall || 0
    end)

    # Generate rainbow paths for each game
    rainbow_paths = generate_rainbow_paths(sorted_games)

    # Initialize explosions list
    explosions = []

    {:ok, assign(socket, games: sorted_games, rainbow_paths: rainbow_paths, explosions: explosions)}
  end

  def handle_info(:refresh, socket) do
    games = PongLive.get_all_games()
    # Sort games by score for better visibility
    sorted_games = Enum.sort_by(games, fn game ->
      -(game.scores || %{}).wall || 0
    end)

    # Update rainbow paths if games have changed
    rainbow_paths =
      if length(sorted_games) != length(socket.assigns.games) do
        generate_rainbow_paths(sorted_games)
      else
        socket.assigns.rainbow_paths
      end

    # Update explosions - remove any that have expired
    current_time = System.monotonic_time(:millisecond)
    updated_explosions = Enum.filter(socket.assigns.explosions, fn explosion ->
      current_time - explosion.created_at < 800 # Shorter lifespan for better performance
    end)

    {:noreply, assign(socket, games: sorted_games, rainbow_paths: rainbow_paths, explosions: updated_explosions)}
  end

  def handle_info(:create_explosion, socket) do
    # Only create a new explosion if we're under the maximum limit
    updated_explosions =
      if length(socket.assigns.explosions) < @max_explosions do
        # Create a new explosion at a random position
        new_explosion = generate_explosion()
        [new_explosion | socket.assigns.explosions]
      else
        socket.assigns.explosions
      end

    {:noreply, assign(socket, explosions: updated_explosions)}
  end

  def handle_info(:cleanup_stale_games, socket) do
    # With our new ID system (including tab IDs), we don't need to
    # clean up duplicates anymore as each tab should have a unique ID
    # We'll just keep this as a placeholder for future cleanup logic

    # Refresh the games list
    games = PongLive.get_all_games()
    sorted_games = Enum.sort_by(games, fn game ->
      -(game.scores || %{}).wall || 0
    end)

    # Update rainbow paths if games have changed
    rainbow_paths =
      if length(sorted_games) != length(socket.assigns.games) do
        generate_rainbow_paths(sorted_games)
      else
        socket.assigns.rainbow_paths
      end

    {:noreply, assign(socket, games: sorted_games, rainbow_paths: rainbow_paths)}
  end

  # Generate a new explosion with particles
  defp generate_explosion do
    # Random position for the explosion center
    center_x = :rand.uniform(100)
    center_y = :rand.uniform(100)

    # Random explosion size
    explosion_size = 5 + :rand.uniform() * 20

    # Generate particles for the explosion
    particles = Enum.map(1..@particles_per_explosion, fn _ ->
      # Random angle and distance from center
      angle = :rand.uniform() * 2 * :math.pi
      distance = :rand.uniform() * explosion_size

      # Calculate particle position
      x = center_x + distance * :math.cos(angle)
      y = center_y + distance * :math.sin(angle)

      # Random size for the particle
      size = 1 + :rand.uniform() * 5

      # Random color from expanded palette
      color = get_random_vibrant_color()

      # Random opacity
      opacity = 0.7 + :rand.uniform() * 0.3

      %{
        x: x,
        y: y,
        size: size,
        color: color,
        opacity: opacity
      }
    end)

    %{
      center_x: center_x,
      center_y: center_y,
      particles: particles,
      created_at: System.monotonic_time(:millisecond)
    }
  end

  # Get a random vibrant color
  defp get_random_vibrant_color do
    colors = [
      # Pinks
      "rgba(255, 105, 180, %s)", # Hot Pink
      "rgba(255, 20, 147, %s)",  # Deep Pink
      "rgba(219, 112, 147, %s)", # Pale Violet Red

      # Yellows
      "rgba(255, 255, 0, %s)",   # Yellow
      "rgba(255, 215, 0, %s)",   # Gold
      "rgba(255, 165, 0, %s)",   # Orange

      # Blues
      "rgba(0, 191, 255, %s)",   # Deep Sky Blue
      "rgba(30, 144, 255, %s)",  # Dodger Blue
      "rgba(138, 43, 226, %s)",  # Blue Violet

      # Greens
      "rgba(50, 205, 50, %s)",   # Lime Green
      "rgba(0, 250, 154, %s)",   # Medium Spring Green
      "rgba(127, 255, 212, %s)", # Aquamarine

      # Reds
      "rgba(255, 69, 0, %s)",    # Red-Orange
      "rgba(255, 0, 0, %s)",     # Red
      "rgba(220, 20, 60, %s)",   # Crimson

      # Purples
      "rgba(148, 0, 211, %s)",   # Dark Violet
      "rgba(186, 85, 211, %s)",  # Medium Orchid
      "rgba(218, 112, 214, %s)", # Orchid

      # Cyans
      "rgba(0, 255, 255, %s)",   # Cyan
      "rgba(64, 224, 208, %s)"   # Turquoise
    ]

    color_template = Enum.random(colors)
    opacity = 0.7 + :rand.uniform() * 0.3
    opacity_string = :erlang.float_to_binary(opacity, [decimals: 2])
    String.replace(color_template, "%s", opacity_string)
  end

  # Generate random rainbow paths for each game
  defp generate_rainbow_paths(game) when is_map(game) do
    # Generate a single rainbow path for a game
    # Make sure we have a game_id to use as seed
    game_id = Map.get(game, :game_id, "default_#{:rand.uniform(10000)}")

    # Use game ID as seed for randomness to ensure consistent rainbows per game
    seed =
      game_id
      |> to_string()
      |> String.to_charlist()
      |> Enum.sum()

    :rand.seed(:exsss, {seed, seed + 1, seed + 2})

    # Generate multiple paths for this game
    Enum.map(1..3, fn path_index ->
      # Random starting position
      start_x = :rand.uniform(100)
      start_y = :rand.uniform(100)

      # Random direction
      angle = :rand.uniform() * 2 * :math.pi
      length = 30 + :rand.uniform(70) # Random length between 30-100

      # Random curve factor
      curve_factor = (:rand.uniform() * 0.4) - 0.2 # Between -0.2 and 0.2

      # Generate path points
      points = generate_path_points(start_x, start_y, angle, length, curve_factor, @rainbow_segments)

      # Convert points to SVG path
      path_d = points_to_svg_path(points)

      # Get color from the last point (end of rainbow)
      color = List.last(points).color

      %{
        d: path_d,
        color: color
      }
    end)
  end

  # Handle list of games
  defp generate_rainbow_paths(games) when is_list(games) do
    # Generate rainbow paths for each game
    Enum.flat_map(games, &generate_rainbow_paths/1)
  end

  # Fallback for any other type
  defp generate_rainbow_paths(_), do: []

  # Convert points to SVG path string
  defp points_to_svg_path(points) do
    # Start with the first point
    [first | rest] = points

    # Create the path string
    path = "M #{first.x} #{first.y} " <>
      Enum.map_join(rest, " ", fn point -> "L #{point.x} #{point.y}" end)

    path
  end

  # Generate points for a curved path
  defp generate_path_points(start_x, start_y, angle, length, curve_factor, segments) do
    segment_length = length / segments

    Enum.map(0..segments, fn i ->
      # Gradually change angle for curved path
      current_angle = angle + (curve_factor * i)

      # Calculate position
      x = start_x + (i * segment_length * :math.cos(current_angle))
      y = start_y + (i * segment_length * :math.sin(current_angle))

      # Calculate color (rainbow hue)
      hue = rem(i * div(360, segments), 360)

      %{
        x: x,
        y: y,
        color: "hsl(#{hue}, 100%, 70%)"
      }
    end)
  end

  def render(assigns) do
    # Add rainbow_width to assigns so it's accessible in the template
    assigns = assign(assigns, :rainbow_width, @rainbow_width)

    ~H"""
    <div class="w-full min-h-screen bg-gray-900 text-white p-4 relative overflow-hidden">
      <!-- Rainbow background paths -->
      <svg class="absolute inset-0 w-full h-full" style="z-index: 0;">
        <%= for game <- @games do %>
          <% paths = generate_rainbow_paths(game) %>
          <%= for path <- paths do %>
            <path
              d={path.d}
              fill="none"
              stroke={path.color}
              stroke-width={@rainbow_width}
              stroke-linecap="round"
              opacity="0.3"
            />
          <% end %>
        <% end %>
      </svg>

      <!-- Explosion particles -->
      <div class="absolute inset-0 w-full h-full" style="z-index: 1; pointer-events: none;">
        <%= for explosion <- @explosions do %>
          <%= for particle <- explosion.particles do %>
            <div
              class="absolute rounded-full"
              style={"left: #{particle.x}%; top: #{particle.y}%; width: #{particle.size}px; height: #{particle.size}px; background-color: #{particle.color}; opacity: #{particle.opacity};"}
            ></div>
          <% end %>
        <% end %>
      </div>

      <div class="relative z-10">
        <h1 class="text-3xl font-bold mb-6 text-center">Pong God Mode</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for game <- @games do %>
            <div class="border border-gray-700 rounded-lg overflow-hidden">
              <!-- Game header with ID and score -->
              <div class="bg-gray-800 p-3 flex justify-between items-center">
                <div class="text-xs opacity-70 truncate">
                  ID: <%= String.slice(game.game_id || "unknown", 0, 8) %>...
                </div>
                <div class="text-sm font-bold">
                  Score: <%= (game.scores || %{}).wall || 0 %>
                </div>
              </div>

              <!-- Game preview -->
              <div class="relative" style="height: 200px;">
                <!-- Semi-transparent game background -->
                <div class="absolute inset-0 bg-gray-900 bg-opacity-60 rounded-b-lg"></div>

                <!-- Ball -->
                <div
                  class="absolute rounded-full bg-white"
                  style={"width: #{20}px; height: #{20}px; left: #{(game.ball || %{x: 400}).x / 4 - 10}px; top: #{(game.ball || %{y: 300}).y / 3 - 10}px;"}
                ></div>

                <!-- Paddle -->
                <div
                  class="absolute bg-white rounded-sm"
                  style={"width: #{15 / 4}px; height: #{100 / 3}px; left: #{(game.paddle || %{x: 30}).x / 4}px; top: #{(game.paddle || %{y: 250}).y / 3}px;"}
                ></div>

                <!-- Center line -->
                <div class="absolute left-1/2 top-0 w-0.5 h-full bg-gray-700 opacity-50"></div>
              </div>
            </div>
          <% end %>
        </div>

        <div class="mt-8 text-center">
          <a href={~p"/pong"} class="text-blue-400 hover:underline">Play Pong</a>
        </div>
      </div>
    </div>
    """
  end
end
