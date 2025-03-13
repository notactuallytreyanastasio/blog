defmodule BlogWeb.PongLive do
  use BlogWeb, :live_view
  alias Phoenix.LiveView.Socket

  @fps 60
  @tick_rate 1000 / @fps
  @ball_radius 10
  @ball_speed 5
  @board_width 800
  @board_height 600
  @paddle_width 15
  @paddle_height 100
  @paddle_offset 30
  @paddle_speed 10
  @trail_length 30  # Reduced to a more reasonable value
  @sparkle_life 45 # frames
  @defeat_message_duration 90 # frames (1.5 seconds at 60 FPS)
  @jitter_amount 80 # pixels of random jitter in ball position
  @burst_particle_count 50 # number of particles in defeat burst

  def mount(_params, session, socket) do
    # Use the user's session ID + a unique timestamp for this session
    # This ensures each tab gets its own unique game ID
    user_id = session["user_id"] || generate_unique_id()

    # Add a unique component to make sure each tab gets its own game
    tab_id = generate_unique_id()
    game_id = "pong_#{user_id}_tab_#{tab_id}"

    initial_state = %{
      game_id: game_id,
      ball: %{
        x: @board_width / 2,
        y: @board_height / 2,
        dx: @ball_speed,
        dy: @ball_speed
      },
      paddle: %{
        y: @board_height / 2 - @paddle_height / 2,
        x: @paddle_offset
      },
      scores: %{
        wall: 0
      },
      board: %{
        width: @board_width,
        height: @board_height
      },
      trail: [],
      sparkles: [],
      message_timer: 0,
      ball_radius: @ball_radius,
      ball_speed: @ball_speed,
      paddle_width: @paddle_width,
      paddle_height: @paddle_height,
      paddle_offset: @paddle_offset,
      trail_length: @trail_length,
      sparkle_life: @sparkle_life,
      defeat_message_duration: @defeat_message_duration,
      show_defeat_message: false,
      game_state: :playing # :playing, :scored, :defeat_message
    }

    # Always start the tick timer for this LiveView instance
    if connected?(socket) do
      # Always start timer for this LiveView instance
      :timer.send_interval(trunc(@tick_rate), :tick)

      # Check if we should create a new game or use an existing one
      case :ets.lookup(:pong_games, game_id) do
        [] ->
          # New game - store it in ETS
          store_game_state(game_id, initial_state)
          Phoenix.PubSub.subscribe(Blog.PubSub, "pong:#{game_id}")

        [{^game_id, existing_state}] ->
          # Existing game - use its state instead of the initial state
          initial_state = Map.merge(initial_state, %{
            ball: existing_state.ball,
            paddle: existing_state.paddle,
            scores: existing_state.scores,
            game_state: Map.get(existing_state, :game_state, :playing),
            show_defeat_message: Map.get(existing_state, :show_defeat_message, false)
          })
          Phoenix.PubSub.subscribe(Blog.PubSub, "pong:#{game_id}")
      end
    end

    {:ok, assign(socket, initial_state) |> assign(:last_key, nil)}
  end

  def terminate(reason, socket) do
    # Only delete the game if it's a normal termination
    # This helps prevent deleting games on page refreshes or brief disconnects
    if reason == {:shutdown, :closed} do
      # Maybe we should add a timeout before deleting, to allow for reconnects?
      # For now, we'll just delete on full disconnect
      :ets.delete(:pong_games, socket.assigns.game_id)
    end
    :ok
  end

  def handle_event("keydown", %{"key" => key}, socket) when key in ["ArrowUp", "ArrowDown"] do
    {:noreply, assign(socket, :last_key, key)}
  end

  def handle_event("keydown", _params, socket), do: {:noreply, socket}

  def handle_event("keyup", %{"key" => key}, socket) when key in ["ArrowUp", "ArrowDown"] do
    if socket.assigns.last_key == key do
      {:noreply, assign(socket, :last_key, nil)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keyup", _params, socket), do: {:noreply, socket}

  def handle_info(:tick, %{assigns: %{game_state: :defeat_message, message_timer: timer}} = socket) do
    if timer >= @defeat_message_duration do
      # Time to reset ball and continue playing
      socket = reset_ball_with_jitter(socket)

      new_socket = assign(socket, game_state: :playing, show_defeat_message: false)
      # Store updated state in ETS
      store_game_state(new_socket.assigns.game_id, new_socket.assigns)

      {:noreply, new_socket}
    else
      new_socket = assign(socket, message_timer: timer + 1)
      store_game_state(new_socket.assigns.game_id, new_socket.assigns)
      {:noreply, new_socket}
    end
  end

  def handle_info(:tick, %{assigns: %{game_state: :scored}} = socket) do
    # Transition to defeat message state instead of directly resetting
    new_socket = socket |> assign(
      game_state: :defeat_message,
      message_timer: 0,
      show_defeat_message: true
    )

    store_game_state(new_socket.assigns.game_id, new_socket.assigns)
    {:noreply, new_socket}
  end

  def handle_info(:tick, socket) do
    new_state = update_game_state(socket.assigns)
    new_socket = assign(socket, new_state)

    # Store updated state in ETS
    store_game_state(new_socket.assigns.game_id, new_socket.assigns)

    {:noreply, new_socket}
  end

  # Reset ball with random jitter
  defp reset_ball_with_jitter(socket) do
    # Add random jitter to starting position
    x_jitter = :rand.uniform(@jitter_amount) - (@jitter_amount / 2)
    y_jitter = :rand.uniform(@jitter_amount) - (@jitter_amount / 2)

    # Make sure ball stays in bounds despite jitter
    new_x = min(max(@board_width / 2 + x_jitter, @ball_radius * 2), @board_width - @ball_radius * 2)
    new_y = min(max(@board_height / 2 + y_jitter, @ball_radius * 2), @board_height - @ball_radius * 2)

    # Random slight variation in angle
    angle_variation = (:rand.uniform(40) - 20) * :math.pi / 180
    base_speed = @ball_speed

    # Calculate new dx/dy with the angle variation
    # Always move toward the paddle (negative dx)
    dx = -base_speed * :math.cos(angle_variation)
    dy = base_speed * :math.sin(angle_variation)

    assign(socket,
      ball: %{
        x: new_x,
        y: new_y,
        dx: dx,
        dy: dy
      },
      trail: []
    )
  end

  defp update_game_state(assigns) do
    # First, update paddle position based on keyboard input
    new_paddle = update_paddle_position(assigns.paddle, assigns.last_key, assigns.board.height, assigns.paddle_height)

    # Then, update ball position and check for collisions
    {new_ball, new_game_state, new_scores, bounce_position, bounce_type} = update_ball_and_check_scoring(
      assigns.ball,
      assigns.board,
      new_paddle,
      assigns.ball_radius,
      assigns.paddle_width,
      assigns.paddle_height,
      assigns.scores
    )

    # Update trail with new position
    new_trail = update_trail(assigns.trail, new_ball)

    # Update sparkles - add burst if scored against
    new_sparkles =
      if new_game_state == :scored do
        # Create a burst of particles when scored against
        create_defeat_burst(assigns.sparkles, new_ball)
      else
        update_sparkles(assigns.sparkles, bounce_position, bounce_type)
      end

    %{
      ball: new_ball,
      paddle: new_paddle,
      game_state: new_game_state,
      scores: new_scores,
      trail: new_trail,
      sparkles: new_sparkles
    }
  end

  defp create_defeat_burst(existing_sparkles, ball) do
    # Create a large burst of particles around the ball position
    new_particles = for _i <- 1..@burst_particle_count do
      # Random angle and speed for each particle
      angle = :rand.uniform() * 2 * :math.pi
      speed = :rand.uniform(8) + 2

      # Calculate velocity components
      dx = :math.cos(angle) * speed
      dy = :math.sin(angle) * speed

      # Random particle properties
      %{
        x: ball.x,
        y: ball.y,
        dx: dx,
        dy: dy,
        type: :burst,
        life: @sparkle_life + :rand.uniform(30),
        size: :rand.uniform(8) + 2,
        color: "hsl(#{:rand.uniform(60)}, 100%, #{50 + :rand.uniform(40)}%)" # Red/orange hues
      }
    end

    # Combine with existing sparkles and limit to a reasonable number
    (new_particles ++ Enum.map(existing_sparkles, &age_sparkle/1))
    |> Enum.filter(&(&1.life > 0))
    |> Enum.take(200) # Allow more particles for the burst
  end

  defp update_trail(trail, ball) do
    new_position = %{
      x: ball.x,
      y: ball.y,
      color: generate_rainbow_color(length(trail))
    }

    # Keep only the last @trail_length positions
    [new_position | Enum.take(trail, @trail_length - 1)]
  end

  defp generate_rainbow_color(index) do
    # Cycle through the rainbow colors
    hue = rem(index * 12, 360)
    "hsl(#{hue}, 100%, 60%)"
  end

  defp update_sparkles(sparkles, nil, _), do: update_particle_positions(Enum.map(sparkles, &age_sparkle/1)) |> Enum.filter(&(&1.life > 0))

  defp update_sparkles(sparkles, bounce_position, bounce_type) do
    # Add a new sparkle
    new_sparkle = %{
      x: bounce_position.x,
      y: bounce_position.y,
      dx: 0,
      dy: 0,
      type: bounce_type,
      life: @sparkle_life,
      size: :rand.uniform(7) + 3, # Random size between 3 and 10
      color: case bounce_type do
        :paddle -> "hsl(#{:rand.uniform(60) + 180}, 100%, 70%)" # Blues/purples
        :wall -> "hsl(#{:rand.uniform(60)}, 100%, 70%)" # Reds/oranges
        _ -> "hsl(#{:rand.uniform(360)}, 100%, 70%)" # Any color
      end
    }

    # Add the new sparkle and age existing ones
    [new_sparkle | Enum.map(sparkles, &age_sparkle/1)]
    |> update_particle_positions()
    |> Enum.filter(&(&1.life > 0))
    |> Enum.take(50) # Limit to 50 sparkles max
  end

  defp age_sparkle(sparkle) do
    %{sparkle | life: sparkle.life - 1}
  end

  # Update positions for particles with velocity
  defp update_particle_positions(particles) do
    Enum.map(particles, fn particle ->
      if Map.has_key?(particle, :dx) && Map.has_key?(particle, :dy) && particle.dx != 0 && particle.dy != 0 do
        %{particle | x: particle.x + particle.dx, y: particle.y + particle.dy}
      else
        particle
      end
    end)
  end

  defp update_paddle_position(paddle, "ArrowUp", board_height, paddle_height) do
    new_y = max(0, paddle.y - @paddle_speed)
    %{paddle | y: new_y}
  end

  defp update_paddle_position(paddle, "ArrowDown", board_height, paddle_height) do
    new_y = min(board_height - paddle_height, paddle.y + @paddle_speed)
    %{paddle | y: new_y}
  end

  defp update_paddle_position(paddle, _key, _board_height, _paddle_height), do: paddle

  defp update_ball_and_check_scoring(ball, board, paddle, ball_radius, paddle_width, paddle_height, scores) do
    # Calculate new position
    new_x = ball.x + ball.dx
    new_y = ball.y + ball.dy

    # Check paddle collision
    if ball_hits_paddle?(
        new_x,
        new_y,
        ball_radius,
        paddle.x,
        paddle.y,
        paddle_width,
        paddle_height
      ) do
      # Bounce off paddle - return bounce position for sparkle
      bounce_pos = %{x: paddle.x + paddle_width, y: new_y}
      {
        %{x: new_x, y: new_y, dx: -ball.dx, dy: calculate_new_dy(new_y, ball.dy, board.height, ball_radius)},
        :playing,
        scores,
        bounce_pos,
        :paddle
      }
    else
      # Check scoring and wall collisions
      check_scoring_and_walls(new_x, new_y, ball, ball_radius, board.width, board.height, scores)
    end
  end

  defp ball_hits_paddle?(ball_x, ball_y, ball_radius, paddle_x, paddle_y, paddle_width, paddle_height) do
    # Ball is moving toward the paddle (left) and...
    ball_x - ball_radius <= paddle_x + paddle_width &&
    # Ball's right edge is past paddle's left edge and...
    ball_x + ball_radius >= paddle_x &&
    # Ball is vertically aligned with the paddle
    ball_y + ball_radius >= paddle_y &&
    ball_y - ball_radius <= paddle_y + paddle_height
  end

  defp check_scoring_and_walls(x, y, ball, ball_radius, board_width, board_height, scores) do
    cond do
      # Ball passed the paddle (left wall) - wall scores
      x - ball_radius <= 0 ->
        {
          %{x: x, y: y, dx: -ball.dx, dy: ball.dy},
          :scored,
          %{scores | wall: scores.wall + 1},
          %{x: 0, y: y},
          :wall
        }

      # Right wall collision
      x + ball_radius >= board_width && ball.dx > 0 ->
        bounce_pos = %{x: board_width, y: y}
        {
          %{x: x, y: y, dx: -ball.dx, dy: ball.dy},
          :playing,
          scores,
          bounce_pos,
          :wall
        }

      # Top/bottom wall collision
      (y + ball_radius >= board_height && ball.dy > 0) || (y - ball_radius <= 0 && ball.dy < 0) ->
        bounce_y = if y + ball_radius >= board_height, do: board_height, else: 0
        bounce_pos = %{x: x, y: bounce_y}
        {
          %{x: x, y: y, dx: ball.dx, dy: -ball.dy},
          :playing,
          scores,
          bounce_pos,
          :wall
        }

      # No collision
      true ->
        {
          %{x: x, y: y, dx: ball.dx, dy: ball.dy},
          :playing,
          scores,
          nil,
          nil
        }
    end
  end

  defp calculate_new_dy(y, dy, height, ball_radius) do
    cond do
      y + ball_radius >= height && dy > 0 -> -dy
      y - ball_radius <= 0 && dy < 0 -> -dy
      true -> dy
    end
  end

  # Helper functions for ETS storage
  defp generate_unique_id do
    # Generate a random string to use as game ID
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp store_game_state(game_id, state) do
    # Store minimal but sufficient state to keep the game running properly
    minimal_state = %{
      game_id: game_id,
      ball: state.ball,
      paddle: state.paddle,
      scores: state.scores,
      show_defeat_message: state.show_defeat_message,
      game_state: state.game_state
    }

    :ets.insert(:pong_games, {game_id, minimal_state})
  end

  # Used by GodModePongLive to fetch all games
  def get_all_games do
    :ets.tab2list(:pong_games)
    |> Enum.map(fn {_id, state} -> state end)
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col justify-center items-center p-4 bg-gray-800">
      <!-- Game ID display -->
      <div class="text-white text-xs mb-2 opacity-50">
        Game ID: <%= @game_id %>
      </div>

      <!-- Score display -->
      <div class="text-white text-xl mb-4">
        Wall: <%= @scores.wall %>
      </div>

      <div
        class="relative"
        style={"width: #{@board.width}px; height: #{@board.height}px;"}
        phx-window-keydown="keydown"
        phx-window-keyup="keyup"
        tabindex="0"
      >
        <div class="absolute w-full h-full bg-gray-900 rounded-lg border-2 border-gray-700 overflow-hidden">
          <!-- Center line -->
          <div class="absolute left-1/2 top-0 w-0.5 h-full bg-gray-700 border-dashed"></div>

          <!-- Defeat message -->
          <%= if @show_defeat_message do %>
            <div class="absolute inset-0 flex items-center justify-center z-10">
              <div
                class={"text-center text-4xl font-bold tracking-wider uppercase " <>
                  if rem(@message_timer, 10) < 5, do: "text-red-500", else: "text-yellow-500"}
                style="text-shadow: 0 0 10px currentColor, 0 0 20px currentColor;"
              >
                YOU CONTINUE<br />TO EMBRACE<br />DEFEAT
              </div>
            </div>
          <% end %>

          <!-- Trail -->
          <%= for {pos, index} <- Enum.with_index(@trail) do %>
            <div
              class="absolute rounded-full"
              style={"width: #{@ball_radius * 2 * (1 - index / @trail_length)}px; height: #{@ball_radius * 2 * (1 - index / @trail_length)}px; left: #{pos.x - @ball_radius * (1 - index / @trail_length)}px; top: #{pos.y - @ball_radius * (1 - index / @trail_length)}px; background-color: #{pos.color}; opacity: #{1 - index / @trail_length};"}
            >
            </div>
          <% end %>

          <!-- Sparkles & Burst Particles -->
          <%= for sparkle <- @sparkles do %>
            <div
              class="absolute"
              style={"width: #{sparkle.size}px; height: #{sparkle.size}px; left: #{sparkle.x - sparkle.size/2}px; top: #{sparkle.y - sparkle.size/2}px; background-color: #{sparkle.color}; opacity: #{sparkle.life / @sparkle_life}; border-radius: #{if rem(sparkle.life, 2) == 0, do: "50%", else: "0"}; transform: rotate(#{sparkle.life * 5}deg);"}
            >
            </div>
          <% end %>

          <!-- Paddle -->
          <div
            class="absolute bg-white rounded-sm"
            style={"width: #{@paddle_width}px; height: #{@paddle_height}px; left: #{@paddle.x}px; top: #{@paddle.y}px;"}
          >
          </div>

          <!-- Ball -->
          <div
            class="absolute rounded-full bg-white"
            style={"width: #{@ball_radius * 2}px; height: #{@ball_radius * 2}px; left: #{@ball.x - @ball_radius}px; top: #{@ball.y - @ball_radius}px;"}
          >
          </div>
        </div>
      </div>

      <div class="text-white text-sm mt-4">
        Use the up and down arrow keys to move the paddle
      </div>

      <div class="text-white text-sm mt-2">
        <a href={~p"/pong/god"} class="text-blue-400 hover:underline">God Mode View</a>
      </div>
    </div>
    """
  end
end
