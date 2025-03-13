defmodule BlogWeb.PongGodLive do
  use BlogWeb, :live_view
  alias BlogWeb.PongLive

  @refresh_interval 100 # ms
  @cleanup_interval 30_000 # 30 seconds
  @rainbow_segments 12 # Number of segments in each rainbow
  @rainbow_width 3 # Width of rainbow lines in pixels

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval, :refresh)
      :timer.send_interval(@cleanup_interval, :cleanup_stale_games)
    end

    games = PongLive.get_all_games()
    # Sort games by score for better visibility
    sorted_games = Enum.sort_by(games, fn game ->
      -(game.scores || %{}).wall || 0
    end)

    # Generate rainbow paths for each game
    rainbow_paths = generate_rainbow_paths(sorted_games)

    {:ok, assign(socket, games: sorted_games, rainbow_paths: rainbow_paths)}
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

    {:noreply, assign(socket, games: sorted_games, rainbow_paths: rainbow_paths)}
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
