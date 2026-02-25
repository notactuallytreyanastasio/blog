defmodule BlogWeb.PongLive.GameLogic do
  @moduledoc """
  Pure game logic for Pong. No side effects, no socket, no ETS.
  All functions take data in, return data out.
  """

  @ball_radius 10
  @ball_speed 5
  @game_width 800
  @game_height 600
  @paddle_width 15
  @paddle_height 100
  @paddle_offset 30
  @paddle_speed 10
  @trail_length 80
  @sparkle_life 30
  @jitter_amount 40
  @initial_jitter_amount 15
  @burst_particle_count 30
  @max_bounce_count 30
  @progressive_speed_increase 0.02
  @max_speed_multiplier 1.6

  def ball_radius, do: @ball_radius
  def ball_speed, do: @ball_speed
  def game_width, do: @game_width
  def game_height, do: @game_height
  def paddle_width, do: @paddle_width
  def paddle_height, do: @paddle_height
  def paddle_offset, do: @paddle_offset
  def trail_length, do: @trail_length
  def sparkle_life, do: @sparkle_life

  @doc """
  Build the initial game state map (no socket, no ETS).
  """
  def initial_state(game_id) do
    %{
      game_id: game_id,
      ball: %{
        x: @game_width / 2,
        y: @game_height / 2,
        dx: -@ball_speed,
        dy: (:rand.uniform() - 0.5) * @ball_speed,
        bounce_count: 0,
        speed_multiplier: 1.0
      },
      paddle: %{
        x: @paddle_offset,
        y: @game_height / 2 - @paddle_height / 2
      },
      scores: %{wall: 0},
      board: %{width: @game_width, height: @game_height},
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
      defeat_message_duration: 60,
      show_defeat_message: false,
      game_state: :ready,
      ai_controlled: true
    }
  end

  @doc """
  Merge persisted ETS state into a fresh initial state.
  """
  def merge_existing_state(init, existing) do
    Map.merge(init, %{
      ball: existing.ball,
      paddle: existing.paddle,
      scores: existing.scores,
      game_state: Map.get(existing, :game_state, :playing),
      show_defeat_message: Map.get(existing, :show_defeat_message, false),
      ai_controlled: Map.get(existing, :ai_controlled, true)
    })
  end

  @doc """
  Advance one tick for a game in the :playing or :ready state.
  Returns a map of changed assigns.
  """
  def tick(assigns) do
    new_paddle =
      update_paddle_position(
        assigns.paddle,
        assigns.last_key,
        assigns.board.height,
        assigns.paddle_height
      )

    {new_ball, new_game_state, new_scores, bounce_position, bounce_type} =
      update_ball_and_check_scoring(
        assigns.ball,
        assigns.board,
        new_paddle,
        assigns.ball_radius,
        assigns.paddle_width,
        assigns.paddle_height,
        assigns.scores
      )

    new_trail = update_trail(assigns.trail, new_ball)

    new_sparkles =
      if new_game_state == :scored do
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

  @doc """
  Reset the ball with random jitter after a score.
  Returns updated ball and trail assigns.
  """
  def reset_ball(wall_score) do
    jitter_amount = if wall_score > 0, do: @jitter_amount, else: @initial_jitter_amount

    x_jitter = :rand.uniform(jitter_amount) - jitter_amount / 2
    y_jitter = :rand.uniform(jitter_amount) - jitter_amount / 2

    new_x = clamp(@game_width / 2 + x_jitter, @ball_radius * 2, @game_width - @ball_radius * 2)
    new_y = clamp(@game_height / 2 + y_jitter, @ball_radius * 2, @game_height - @ball_radius * 2)

    max_angle = if wall_score > 0, do: 40, else: 20
    angle_variation = (:rand.uniform(max_angle) - max_angle / 2) * :math.pi() / 180

    dx = -@ball_speed * :math.cos(angle_variation)
    raw_dy = @ball_speed * :math.sin(angle_variation)
    dy = clamp_vertical_component(raw_dy, dx)

    ball = %{
      x: new_x,
      y: new_y,
      dx: dx,
      dy: dy,
      bounce_count: 0,
      speed_multiplier: 1.0
    }

    %{ball: ball, trail: []}
  end

  @doc """
  Move the paddle toward a target y position for AI control.
  Clamps the result to stay within bounds.
  """
  def ai_move_paddle(paddle, ball) do
    target_y = ai_calculate_target_position(ball)
    ai_speed = 10

    new_y =
      cond do
        paddle.y < target_y - ai_speed -> paddle.y + ai_speed
        paddle.y > target_y + ai_speed -> paddle.y - ai_speed
        true -> target_y
      end

    new_y = clamp(new_y, 0, @game_height - @paddle_height)
    %{paddle | y: new_y}
  end

  # -- Paddle ------------------------------------------------------------------

  def update_paddle_position(paddle, "ArrowUp", _board_height, _paddle_height) do
    %{paddle | y: max(0, paddle.y - @paddle_speed)}
  end

  def update_paddle_position(paddle, "ArrowDown", board_height, paddle_height) do
    %{paddle | y: min(board_height - paddle_height, paddle.y + @paddle_speed)}
  end

  def update_paddle_position(paddle, _key, _board_height, _paddle_height), do: paddle

  # -- Ball / scoring ----------------------------------------------------------

  def update_ball_and_check_scoring(ball, board, paddle, ball_radius, paddle_width, paddle_height, scores) do
    new_x = ball.x + ball.dx
    new_y = ball.y + ball.dy

    if ball_hits_paddle?(new_x, new_y, ball_radius, paddle.x, paddle.y, paddle_width, paddle_height) do
      handle_paddle_bounce(ball, new_x, new_y, paddle, ball_radius, paddle_width, paddle_height, scores)
    else
      check_scoring_and_walls(new_x, new_y, ball, ball_radius, board.width, board.height, scores)
    end
  end

  def ball_hits_paddle?(ball_x, ball_y, ball_radius, paddle_x, paddle_y, paddle_width, paddle_height) do
    in_vertical_range =
      ball_y + ball_radius >= paddle_y &&
        ball_y - ball_radius <= paddle_y + paddle_height

    in_horizontal_range =
      ball_x - ball_radius <= paddle_x + paddle_width &&
        ball_x + ball_radius >= paddle_x

    in_vertical_range && in_horizontal_range
  end

  # -- Trail / sparkles --------------------------------------------------------

  def update_trail(trail, ball) do
    new_position = %{
      x: ball.x,
      y: ball.y,
      color: generate_rainbow_color(length(trail))
    }

    [new_position | Enum.take(trail, @trail_length - 1)]
  end

  def generate_rainbow_color(index) do
    timestamp = System.os_time(:millisecond)
    base_hue = rem(timestamp, 360)
    hue = rem(base_hue + index * 15, 360)
    saturation = 90 + rem(index, 10)
    lightness = 50 + rem(index * 7, 20)
    "hsl(#{hue}, #{saturation}%, #{lightness}%)"
  end

  def create_defeat_burst(existing_sparkles, ball) do
    new_particles =
      for _i <- 1..@burst_particle_count do
        angle = :rand.uniform() * 2 * :math.pi()
        speed = :rand.uniform(6) + 2
        dx = :math.cos(angle) * speed
        dy = :math.sin(angle) * speed

        %{
          x: ball.x,
          y: ball.y,
          dx: dx,
          dy: dy,
          type: :burst,
          life: @sparkle_life + :rand.uniform(20),
          size: :rand.uniform(6) + 2,
          color: "hsl(#{:rand.uniform(60)}, 100%, #{50 + :rand.uniform(40)}%)"
        }
      end

    (new_particles ++ Enum.map(existing_sparkles, &age_sparkle/1))
    |> Enum.filter(&(&1.life > 0))
    |> Enum.take(120)
  end

  def update_sparkles(sparkles, nil, _type) do
    sparkles
    |> Enum.map(&age_sparkle/1)
    |> update_particle_positions()
    |> Enum.filter(&(&1.life > 0))
  end

  def update_sparkles(sparkles, bounce_position, bounce_type) do
    new_sparkle = %{
      x: bounce_position.x,
      y: bounce_position.y,
      dx: 0,
      dy: 0,
      type: bounce_type,
      life: @sparkle_life,
      size: :rand.uniform(5) + 3,
      color: sparkle_color(bounce_type)
    }

    [new_sparkle | Enum.map(sparkles, &age_sparkle/1)]
    |> update_particle_positions()
    |> Enum.filter(&(&1.life > 0))
    |> Enum.take(30)
  end

  def age_sparkle(sparkle) do
    %{sparkle | life: sparkle.life - 1}
  end

  def update_particle_positions(particles) do
    Enum.map(particles, fn particle ->
      if particle.dx != 0 || particle.dy != 0 do
        %{particle | x: particle.x + particle.dx, y: particle.y + particle.dy}
      else
        particle
      end
    end)
  end

  # -- Helpers (private) -------------------------------------------------------

  defp sparkle_color(:paddle), do: "hsl(#{:rand.uniform(60) + 180}, 100%, 70%)"
  defp sparkle_color(:wall), do: "hsl(#{:rand.uniform(60)}, 100%, 70%)"
  defp sparkle_color(_), do: "hsl(#{:rand.uniform(360)}, 100%, 70%)"

  defp handle_paddle_bounce(ball, _new_x, new_y, paddle, ball_radius, paddle_width, paddle_height, scores) do
    bounce_pos = %{x: paddle.x + paddle_width, y: new_y}
    new_bounce_count = ball.bounce_count + 1

    new_speed_multiplier =
      min(ball.speed_multiplier + @progressive_speed_increase, @max_speed_multiplier)

    {new_dx, new_dy} =
      calculate_new_direction(
        ball.dx,
        ball.dy,
        new_bounce_count,
        new_speed_multiplier,
        new_y,
        paddle.y,
        paddle_height
      )

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
  end

  defp calculate_new_direction(dx, dy, bounce_count, speed_multiplier, ball_y, paddle_y, paddle_height) do
    new_dx = abs(dx)
    paddle_center = paddle_y + paddle_height / 2
    hit_position = (ball_y - paddle_center) / (paddle_height / 2)

    angle_factor = hit_position * (1.0 + min(bounce_count / 20, 0.8))

    random_factor =
      if bounce_count > @max_bounce_count do
        (:rand.uniform() - 0.5) * 0.3
      else
        (:rand.uniform() - 0.5) * 0.1 * (bounce_count / 15)
      end

    new_dy = dy + (angle_factor + random_factor) * abs(dx)

    speed = :math.sqrt(dx * dx + dy * dy) * speed_multiplier
    magnitude = :math.sqrt(new_dx * new_dx + new_dy * new_dy)
    normalized_dx = new_dx * speed / magnitude
    raw_normalized_dy = new_dy * speed / magnitude

    normalized_dy = ensure_minimum_vertical(raw_normalized_dy, speed)

    {normalized_dx, normalized_dy}
  end

  defp ensure_minimum_vertical(dy, speed) do
    if abs(dy) < speed * 0.05 do
      if dy >= 0, do: speed * 0.05, else: -(speed * 0.05)
    else
      dy
    end
  end

  defp check_scoring_and_walls(x, y, ball, ball_radius, board_width, board_height, scores) do
    cond do
      # Ball passed the paddle (left wall) -- wall scores
      x - ball_radius <= 0 ->
        {
          %{x: x, y: y, dx: -ball.dx, dy: ball.dy, bounce_count: ball.bounce_count, speed_multiplier: ball.speed_multiplier},
          :scored,
          %{scores | wall: scores.wall + 1},
          %{x: 0, y: y},
          :wall
        }

      # Right wall collision
      x + ball_radius >= board_width && ball.dx > 0 ->
        right_wall_bounce(x, y, ball, scores, board_width)

      # Top/bottom wall collision
      (y + ball_radius >= board_height && ball.dy > 0) || (y - ball_radius <= 0 && ball.dy < 0) ->
        top_bottom_bounce(x, y, ball, ball_radius, board_height, scores)

      # No collision
      true ->
        {
          %{x: x, y: y, dx: ball.dx, dy: ball.dy, bounce_count: ball.bounce_count, speed_multiplier: ball.speed_multiplier},
          :playing,
          scores,
          nil,
          nil
        }
    end
  end

  defp right_wall_bounce(x, y, ball, scores, board_width) do
    angle_change = (:rand.uniform() - 0.5) * 0.15
    speed = :math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
    angle = :math.atan2(ball.dy, ball.dx) + angle_change
    new_dx = -abs(:math.cos(angle) * speed)
    new_dy = :math.sin(angle) * speed

    {
      %{x: x, y: y, dx: new_dx, dy: new_dy, bounce_count: ball.bounce_count, speed_multiplier: ball.speed_multiplier},
      :playing,
      scores,
      %{x: board_width, y: y},
      :wall
    }
  end

  defp top_bottom_bounce(x, y, ball, _ball_radius, board_height, scores) do
    bounce_y = if y + ball.dy >= board_height, do: board_height, else: 0
    new_dy = -ball.dy

    {
      %{x: x, y: y, dx: ball.dx, dy: new_dy, bounce_count: ball.bounce_count, speed_multiplier: ball.speed_multiplier},
      :playing,
      scores,
      %{x: x, y: bounce_y},
      :wall
    }
  end

  defp ai_calculate_target_position(ball) do
    target_y = ball.y - @paddle_height / 2
    speed_factor = ball.speed_multiplier || 1.0
    randomness = (:rand.uniform(80) - 40) * (speed_factor * 0.8)

    if :rand.uniform() < 0.05 * speed_factor do
      target_y + randomness * 1.5
    else
      target_y + randomness
    end
  end

  @doc """
  Clamp `value` between `lo` and `hi`.
  """
  def clamp(value, lo, hi) do
    value |> max(lo) |> min(hi)
  end

  defp clamp_vertical_component(dy, dx) do
    if abs(dy) > abs(dx) * 1.5 do
      sign(dy) * abs(dx) * 1.5
    else
      dy
    end
  end

  defp sign(x) when x > 0, do: 1
  defp sign(x) when x < 0, do: -1
  defp sign(_), do: 0
end
