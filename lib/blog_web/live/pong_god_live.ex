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
  defp generate_rainbow_paths(games) do
    Enum.map(games, fn game ->
      # Use game ID as seed for randomness to ensure consistent rainbows per game
      seed =
        game.game_id
        |> String.to_charlist()
        |> Enum.sum()

      :rand.seed(:exsss, {seed, seed + 1, seed + 2})

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

      # Random opacity
      opacity = 0.1 + :rand.uniform() * 0.2 # Between 0.1 and 0.3

      %{
        points: points,
        opacity: opacity,
        width: @rainbow_width
      }
    end)
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
    ~H"""
    <div class="p-4 bg-gray-800 min-h-screen relative overflow-hidden">
      <!-- Rainbow background decorations -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <%= for {rainbow, index} <- Enum.with_index(@rainbow_paths) do %>
          <!-- Draw rainbow path segments -->
          <%= for i <- 0..(length(rainbow.points) - 2) do %>
            <%
              start_point = Enum.at(rainbow.points, i)
              end_point = Enum.at(rainbow.points, i + 1)
            %>
            <div
              class="absolute"
              style={"
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                opacity: #{rainbow.opacity};
                overflow: visible;
                z-index: 0;
              "}
            >
              <svg width="100%" height="100%" style="position: absolute; overflow: visible;">
                <line
                  x1={"#{start_point.x}%"}
                  y1={"#{start_point.y}%"}
                  x2={"#{end_point.x}%"}
                  y2={"#{end_point.y}%"}
                  stroke={"#{start_point.color}"}
                  stroke-width={"#{rainbow.width}"}
                  stroke-linecap="round"
                />
              </svg>
            </div>
          <% end %>
        <% end %>

        <!-- Explosions -->
        <%= for explosion <- @explosions do %>
          <%= for particle <- explosion.particles do %>
            <div
              class="absolute rounded-full"
              style={"
                left: #{particle.x}%;
                top: #{particle.y}%;
                width: #{particle.size}px;
                height: #{particle.size}px;
                background-color: #{particle.color};
                box-shadow: 0 0 #{particle.size * 2}px #{particle.color};
                transform: translate(-50%, -50%);
                z-index: 1;
              "}
            >
            </div>
          <% end %>
        <% end %>
      </div>

      <!-- Main content -->
      <div class="max-w-7xl mx-auto relative z-10">
        <h1 class="text-3xl font-bold text-white mb-6">Pong God Mode</h1>
        <div class="mb-4">
          <span class="text-white">Active Games: <%= length(@games) %></span>
          <a href={~p"/pong"} class="text-blue-400 hover:underline ml-4">Play Pong</a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for game <- @games do %>
            <div class="bg-gray-700 rounded-lg overflow-hidden shadow-lg">
              <div class="p-2 bg-gray-600 text-white text-sm flex justify-between">
                <span>Game ID: <%= String.slice(game.game_id || "", 0..8) %>...</span>
                <span>Score: <%= (game.scores || %{}).wall || 0 %></span>
              </div>
              <div class="relative" style="width: 100%; height: 200px;">
                <!-- Mini game board -->
                <div class="absolute w-full h-full bg-gray-900">
                  <!-- Center line -->
                  <div class="absolute left-1/2 top-0 w-0.5 h-full bg-gray-700 border-dashed"></div>

                  <!-- Paddle -->
                  <%= if game.paddle do %>
                    <div
                      class="absolute bg-white rounded-sm"
                      style={"width: 5px; height: 33px; left: 10px; top: #{(game.paddle.y || 0) * 200 / 600}px;"}
                    >
                    </div>
                  <% end %>

                  <!-- Ball -->
                  <%= if game.ball do %>
                    <div
                      class="absolute rounded-full bg-white"
                      style={"width: 6px; height: 6px; left: calc(#{(game.ball.x || 0) * 100 / 800}% - 3px); top: calc(#{(game.ball.y || 0) * 200 / 600}px - 3px);"}
                    >
                    </div>
                  <% end %>

                  <!-- Defeat message -->
                  <%= if game.show_defeat_message do %>
                    <div class="absolute inset-0 flex items-center justify-center z-10">
                      <div
                        class="text-center text-sm font-bold tracking-wider uppercase text-red-500"
                        style="text-shadow: 0 0 5px currentColor;"
                      >
                        DEFEAT
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>

        <%= if @games == [] do %>
          <div class="text-center text-white py-8">
            <p class="text-xl">No active games found</p>
            <p class="mt-2">Open <a href={~p"/pong"} class="text-blue-400 hover:underline">the Pong game</a> in another tab to see it appear here</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
