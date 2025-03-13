defmodule BlogWeb.PongLive do
  use BlogWeb, :live_view
  alias Phoenix.LiveView.Socket
  require Logger

  @fps 30
  @tick_rate 1000 / @fps
  @ball_radius 10
  @ball_speed 5
  @board_width 800
  @board_height 600
  @paddle_width 15
  @paddle_height 100
  @paddle_offset 30
  @paddle_speed 10
  @trail_length 125
  @sparkle_life 30
  @defeat_message_duration 60
  @jitter_amount 40
  @initial_jitter_amount 15
  @burst_particle_count 30
  @game_width 800
  @game_height 600
  @ball_size 10
  @frame_rate 33
  @ai_reaction_time 150
  @max_bounce_count 30
  @progressive_speed_increase 0.02
  @max_speed_multiplier 1.6

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
        x: @game_width / 2,
        y: @game_height / 2,
        dx: -@ball_speed, # Always start moving toward the player
        dy: (:rand.uniform() - 0.5) * @ball_speed, # Small random vertical component
        bounce_count: 0, # Track number of bounces
        speed_multiplier: 1.0 # Track speed multiplier
      },
      paddle: %{
        x: @paddle_offset,
        y: @game_height / 2 - @paddle_height / 2
      },
      scores: %{
        wall: 0
      },
      board: %{
        width: @game_width,
        height: @game_height
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
      game_state: :ready, # :ready, :playing, :defeat_message
      ai_controlled: true # Start with AI control enabled
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
          updated_state = Map.merge(initial_state, %{
            ball: existing_state.ball,
            paddle: existing_state.paddle,
            scores: existing_state.scores,
            game_state: Map.get(existing_state, :game_state, :playing),
            show_defeat_message: Map.get(existing_state, :show_defeat_message, false),
            ai_controlled: Map.get(existing_state, :ai_controlled, true)
          })
          Phoenix.PubSub.subscribe(Blog.PubSub, "pong:#{game_id}")
          initial_state = updated_state
      end

      # Start the AI timer if AI is enabled
      if initial_state.ai_controlled do
        :timer.send_interval(@ai_reaction_time, :ai_move)
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
    # When user presses a key, disable AI control
    updated_socket = if socket.assigns.ai_controlled do
      assign(socket, ai_controlled: false)
    else
      socket
    end

    {:noreply, assign(updated_socket, :last_key, key)}
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

  # Toggle AI control
  def handle_event("toggle_ai", _params, socket) do
    updated_socket = assign(socket, ai_controlled: !socket.assigns.ai_controlled)

    # Store the updated game state
    store_game_state(socket.assigns.game_id, updated_socket.assigns)

    {:noreply, updated_socket}
  end

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

  def handle_info(:ai_move, socket) do
    # Only move the AI paddle if the game is in playing state and AI is enabled
    if socket.assigns.game_state == :playing && socket.assigns.ai_controlled do
      # AI logic to track the ball
      target_y = ai_calculate_target_position(socket.assigns.ball)

      # Move paddle towards target with some "reaction time" delay
      current_y = socket.assigns.paddle.y
      ai_speed = 10 # Adjust this to change AI difficulty

      # Move towards target with limited speed
      new_y = cond do
        current_y < target_y - ai_speed -> current_y + ai_speed
        current_y > target_y + ai_speed -> current_y - ai_speed
        true -> target_y
      end

      # Ensure paddle stays within bounds
      new_y = max(0, min(new_y, @game_height - @paddle_height))

      # Update paddle position
      updated_socket = assign(socket, paddle: %{socket.assigns.paddle | y: new_y})

      # Store the updated game state in ETS
      store_game_state(updated_socket.assigns.game_id, updated_socket.assigns)

      {:noreply, updated_socket}
    else
      {:noreply, socket}
    end
  end

  # Reset ball with random jitter
  defp reset_ball_with_jitter(socket) do
    # Add random jitter to starting position - use full jitter amount after first point
    jitter_amount = if socket.assigns.scores.wall > 0, do: @jitter_amount, else: @initial_jitter_amount
    x_jitter = :rand.uniform(jitter_amount) - (jitter_amount / 2)
    y_jitter = :rand.uniform(jitter_amount) - (jitter_amount / 2)

    # Make sure ball stays in bounds despite jitter
    new_x = min(max(@game_width / 2 + x_jitter, @ball_radius * 2), @game_width - @ball_radius * 2)
    new_y = min(max(@game_height / 2 + y_jitter, @ball_radius * 2), @game_height - @ball_radius * 2)

    # Random slight variation in angle - reduced for initial ball
    max_angle = if socket.assigns.scores.wall > 0, do: 40, else: 20
    angle_variation = (:rand.uniform(max_angle) - (max_angle / 2)) * :math.pi / 180
    base_speed = @ball_speed

    # Calculate new dx/dy with the angle variation
    # Always move toward the paddle (negative dx)
    dx = -base_speed * :math.cos(angle_variation)

    # Ensure vertical component is reasonable but not extreme
    dy = base_speed * :math.sin(angle_variation)

    # Ensure the ball is moving toward the player at a reasonable angle
    # If angle is too steep, adjust it
    if abs(dy) > abs(dx) * 1.5 do
      dy = sign(dy) * abs(dx) * 1.5
    end

    assign(socket,
      ball: %{
        x: new_x,
        y: new_y,
        dx: dx,
        dy: dy,
        bounce_count: 0, # Reset bounce count
        speed_multiplier: 1.0 # Reset speed multiplier
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
      speed = :rand.uniform(6) + 2

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
        life: @sparkle_life + :rand.uniform(20),
        size: :rand.uniform(6) + 2,
        color: "hsl(#{:rand.uniform(60)}, 100%, #{50 + :rand.uniform(40)}%)" # Red/orange hues
      }
    end

    # Combine with existing sparkles and limit to a reasonable number
    (new_particles ++ Enum.map(existing_sparkles, &age_sparkle/1))
    |> Enum.filter(&(&1.life > 0))
    |> Enum.take(120)
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
    # Cycle through the rainbow colors with more variation
    # Use a different formula to create more varied colors
    # Add a time-based component to make colors shift over time
    timestamp = System.os_time(:millisecond)
    base_hue = rem(timestamp, 360)
    hue = rem(base_hue + index * 15, 360)
    saturation = 90 + rem(index, 10)
    lightness = 50 + rem(index * 7, 20)
    "hsl(#{hue}, #{saturation}%, #{lightness}%)"
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
      size: :rand.uniform(5) + 3,
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
    |> Enum.take(30)
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

      # Increment bounce count
      new_bounce_count = (ball.bounce_count || 0) + 1

      # Increase speed multiplier progressively
      new_speed_multiplier = min(
        (ball.speed_multiplier || 1.0) + @progressive_speed_increase,
        @max_speed_multiplier
      )

      # Calculate new ball direction with more randomness for higher bounce counts
      {new_dx, new_dy} = calculate_new_direction(
        ball.dx,
        ball.dy,
        new_bounce_count,
        new_speed_multiplier,
        new_y,
        paddle.y,
        paddle_height
      )

      # Ensure the ball is positioned outside the paddle to prevent immediate scoring
      # Place the ball just to the right of the paddle
      adjusted_x = paddle.x + paddle_width + ball_radius + 1

      {
        %{
          x: adjusted_x,
          y: new_y,
          dx: new_dx,
          dy: new_dy,
          bounce_count: new_bounce_count,
          speed_multiplier: new_speed_multiplier
        },
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

  # Calculate new ball direction with progressive randomness
  defp calculate_new_direction(dx, dy, bounce_count, speed_multiplier, ball_y, paddle_y, paddle_height) do
    # Base reflection - reverse x direction and ensure it's moving right (positive)
    new_dx = abs(dx)

    # Calculate angle based on where ball hits paddle
    paddle_center = paddle_y + paddle_height / 2
    hit_position = (ball_y - paddle_center) / (paddle_height / 2)

    # More extreme angles as bounce count increases, but more gradually
    angle_factor = hit_position * (1.0 + min(bounce_count / 20, 0.8))

    # Add increasing randomness based on bounce count, but more controlled
    random_factor = if bounce_count > @max_bounce_count do
      # After max bounces, add moderate randomness to break patterns
      (:rand.uniform() - 0.5) * 0.3
    else
      # Gradual increase in randomness
      (:rand.uniform() - 0.5) * 0.1 * (bounce_count / 15)
    end

    # Calculate new dy with angle and randomness
    new_dy = dy + (angle_factor + random_factor) * abs(dx)

    # Apply speed multiplier
    speed = :math.sqrt(dx * dx + dy * dy) * speed_multiplier

    # Normalize to maintain consistent speed
    magnitude = :math.sqrt(new_dx * new_dx + new_dy * new_dy)
    normalized_dx = new_dx * speed / magnitude
    normalized_dy = new_dy * speed / magnitude

    # Ensure minimum vertical movement to prevent horizontal stalemates
    # But keep it subtle
    if abs(normalized_dy) < speed * 0.05 do
      normalized_dy = if normalized_dy >= 0, do: speed * 0.05, else: -speed * 0.05
    end

    {normalized_dx, normalized_dy}
  end

  defp ball_hits_paddle?(ball_x, ball_y, ball_radius, paddle_x, paddle_y, paddle_width, paddle_height) do
    # We need to check if the ball is about to collide with the paddle
    # The ball's current position is already updated with velocity in update_ball_and_check_scoring

    # Check if the ball is in the paddle's vertical range
    ball_in_paddle_vertical_range =
      ball_y + ball_radius >= paddle_y &&
      ball_y - ball_radius <= paddle_y + paddle_height

    # Check if the ball is at or past the paddle's right edge
    ball_at_paddle_horizontal_range =
      ball_x - ball_radius <= paddle_x + paddle_width &&
      ball_x + ball_radius >= paddle_x

    # Check if the ball is moving toward the paddle (negative x direction)
    ball_moving_toward_paddle = true  # We'll assume this is always true for simplicity

    # All conditions must be true for a collision
    ball_in_paddle_vertical_range && ball_at_paddle_horizontal_range && ball_moving_toward_paddle
  end

  defp check_scoring_and_walls(x, y, ball, ball_radius, board_width, board_height, scores) do
    cond do
      # Ball passed the paddle (left wall) - wall scores
      x - ball_radius <= 0 ->
        {
          %{
            x: x,
            y: y,
            dx: -ball.dx,
            dy: ball.dy,
            bounce_count: ball.bounce_count || 0,
            speed_multiplier: ball.speed_multiplier || 1.0
          },
          :scored,
          %{scores | wall: scores.wall + 1},
          %{x: 0, y: y},
          :wall
        }

      # Right wall collision
      x + ball_radius >= board_width && ball.dx > 0 ->
        bounce_pos = %{x: board_width, y: y}

        # Add small random angle change on wall bounce to break patterns
        # Reduced from 0.3 to 0.15 for more predictable bounces
        angle_change = (:rand.uniform() - 0.5) * 0.15
        speed = :math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
        angle = :math.atan2(ball.dy, ball.dx) + angle_change
        new_dx = -abs(:math.cos(angle) * speed)
        new_dy = :math.sin(angle) * speed

        {
          %{
            x: x,
            y: y,
            dx: new_dx,
            dy: new_dy,
            bounce_count: ball.bounce_count || 0,
            speed_multiplier: ball.speed_multiplier || 1.0
          },
          :playing,
          scores,
          bounce_pos,
          :wall
        }

      # Top/bottom wall collision
      (y + ball_radius >= board_height && ball.dy > 0) || (y - ball_radius <= 0 && ball.dy < 0) ->
        bounce_y = if y + ball_radius >= board_height, do: board_height, else: 0
        bounce_pos = %{x: x, y: bounce_y}

        # Add small random angle change on wall bounce to break patterns
        # Reduced from 0.3 to 0.15 for more predictable bounces
        angle_change = (:rand.uniform() - 0.5) * 0.15
        speed = :math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
        angle = :math.atan2(ball.dy, ball.dx) + angle_change
        new_dx = ball.dx
        new_dy = -abs(ball.dy) * sign(ball.dy)

        {
          %{
            x: x,
            y: y,
            dx: new_dx,
            dy: new_dy,
            bounce_count: ball.bounce_count || 0,
            speed_multiplier: ball.speed_multiplier || 1.0
          },
          :playing,
          scores,
          bounce_pos,
          :wall
        }

      # No collision
      true ->
        {
          %{
            x: x,
            y: y,
            dx: ball.dx,
            dy: ball.dy,
            bounce_count: ball.bounce_count || 0,
            speed_multiplier: ball.speed_multiplier || 1.0
          },
          :playing,
          scores,
          nil,
          nil
        }
    end
  end

  # Helper function to get the sign of a number
  defp sign(x) when x > 0, do: 1
  defp sign(x) when x < 0, do: -1
  defp sign(_), do: 0

  # AI logic to calculate where to move the paddle
  defp ai_calculate_target_position(ball) do
    # Simple AI: try to keep the paddle center aligned with the ball
    # Add some imperfection to make it beatable
    target_y = ball.y - (@paddle_height / 2)

    # Add increasing randomness based on ball speed to make AI less perfect at higher speeds
    # But keep it more controlled
    speed_factor = (ball.speed_multiplier || 1.0)
    randomness = :rand.uniform(80) - 40  # Reduced from 100-50 to 80-40

    # More randomness at higher speeds, but more gradual
    randomness = randomness * (speed_factor * 0.8)

    # Add a slight delay effect by occasionally targeting the wrong position
    # But make it less frequent
    if :rand.uniform() < 0.05 * speed_factor do
      # Occasionally aim at a random position to simulate mistakes
      target_y + randomness * 1.5
    else
      target_y + randomness
    end
  end

  # Helper functions for ETS storage
  defp generate_unique_id do
    # Generate a random string to use as game ID
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp store_game_state(game_id, state) do
    # Ensure the ETS table exists
    create_ets_table_if_not_exists()

    # Store minimal but sufficient state to keep the game running properly
    minimal_state = %{
      game_id: game_id,
      ball: state.ball,
      paddle: state.paddle,
      scores: state.scores,
      show_defeat_message: state.show_defeat_message,
      game_state: state.game_state,
      ai_controlled: state.ai_controlled
    }

    :ets.insert(:pong_games, {game_id, minimal_state})
  end

  # Create ETS table if it doesn't exist
  defp create_ets_table_if_not_exists do
    if :ets.whereis(:pong_games) == :undefined do
      :ets.new(:pong_games, [:named_table, :public, :set])
    end
  end

  # Used by GodModePongLive to fetch all games
  def get_all_games do
    # Ensure the ETS table exists
    create_ets_table_if_not_exists()

    :ets.tab2list(:pong_games)
    |> Enum.map(fn {_id, state} -> state end)
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col justify-center items-center p-4 bg-gradient-to-br from-gray-900 to-gray-800">
      <!-- Game ID display -->
      <div class="text-white text-xs mb-2 opacity-50">
        Game ID: <%= @game_id %>
      </div>

      <!-- Score display with rainbow gradient -->
      <div class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-2xl font-bold mb-4">
        Wall: <%= @scores.wall %>
      </div>

      <!-- AI Control Toggle Button with gradient -->
      <div class="rounded-lg shadow-md mb-4">
        <button
          phx-click="toggle_ai"
          class={"px-4 py-2 rounded-md font-bold transition-colors bg-gray-900 hover:bg-gray-800 text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500"}
        >
          <%= if @ai_controlled do %>
            AI Playing (Click to Take Control)
          <% else %>
            Manual Control (Click for AI Help)
          <% end %>
        </button>
      </div>

      <div
        class="relative"
        style={"width: #{@board.width}px; height: #{@board.height}px;"}
        phx-window-keydown="keydown"
        phx-window-keyup="keyup"
        tabindex="0"
      >
        <!-- Game board with gradient border -->
        <div class="absolute w-full h-full bg-gray-900 rounded-lg overflow-hidden p-0.5 bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500">
          <div class="w-full h-full bg-gray-900 rounded-lg overflow-hidden">
            <!-- Center line -->
            <div class="absolute left-1/2 top-0 w-0.5 h-full bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 opacity-30"></div>

            <!-- Defeat message -->
            <%= if @show_defeat_message do %>
              <div class="absolute inset-0 flex items-center justify-center z-10">
                <div
                  class="text-center text-4xl font-bold tracking-wider uppercase text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500"
                  style="text-shadow: 0 0 10px rgba(217, 70, 239, 0.5), 0 0 20px rgba(8, 145, 178, 0.5);"
                >
                  YOU CONTINUE<br />TO EMBRACE<br />DEFEAT
                </div>
              </div>
            <% end %>

            <!-- Trail with enhanced rainbow effect -->
            <%= for {pos, index} <- Enum.with_index(@trail) do %>
              <div
                class="absolute rounded-full"
                style={"width: #{@ball_radius * 2 * (1 - index / @trail_length)}px; height: #{@ball_radius * 2 * (1 - index / @trail_length)}px; left: #{pos.x - @ball_radius * (1 - index / @trail_length)}px; top: #{pos.y - @ball_radius * (1 - index / @trail_length)}px; background-color: #{pos.color}; opacity: #{1 - index / @trail_length * 0.7}; filter: blur(#{index / 10}px);"}
              >
              </div>
            <% end %>

            <!-- Sparkles & Burst Particles -->
            <%= for sparkle <- @sparkles do %>
              <div
                class="absolute"
                style={"width: #{sparkle.size}px; height: #{sparkle.size}px; left: #{sparkle.x - sparkle.size/2}px; top: #{sparkle.y - sparkle.size/2}px; background-color: #{sparkle.color}; opacity: #{sparkle.life / @sparkle_life}; border-radius: #{if rem(sparkle.life, 2) == 0, do: "50%", else: "0"}; transform: rotate(#{sparkle.life * 5}deg); filter: blur(1px);"}
              >
              </div>
            <% end %>

            <!-- Paddle with gradient -->
            <div class="absolute" style={"width: #{@paddle_width}px; height: #{@paddle_height}px; left: #{@paddle.x}px; top: #{@paddle.y}px;"}>
              <div class="w-full h-full bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 rounded-sm"></div>
            </div>

            <!-- Ball with gradient -->
            <div
              class="absolute rounded-full bg-gradient-to-br from-fuchsia-500 via-purple-500 to-cyan-500"
              style={"width: #{@ball_radius * 2}px; height: #{@ball_radius * 2}px; left: #{@ball.x - @ball_radius}px; top: #{@ball.y - @ball_radius}px; filter: drop-shadow(0 0 4px rgba(217, 70, 239, 0.5));"}
            >
            </div>
          </div>
        </div>
      </div>

      <div class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-sm font-bold mt-4">
        Use the up and down arrow keys to move the paddle
      </div>

      <div class="mt-2">
        <a href={~p"/pong/god"} class="inline-block px-3 py-1 rounded-md bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-white font-bold hover:shadow-lg transition-shadow">God Mode View</a>
      </div>
    </div>
    """
  end
end
