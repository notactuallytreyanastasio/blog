defmodule BlogWeb.PongLive do
  use BlogWeb, :live_view

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

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(trunc(@tick_rate), :tick)
    end

    initial_state = %{
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
      ball_radius: @ball_radius,
      ball_speed: @ball_speed,
      paddle_width: @paddle_width,
      paddle_height: @paddle_height,
      paddle_offset: @paddle_offset,
      game_state: :playing # :playing, :scored
    }

    socket =
      socket
      |> assign(initial_state)
      |> assign(:last_key, nil)

    {:ok, socket}
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

  def handle_info(:tick, %{assigns: %{game_state: :scored}} = socket) do
    # Reset ball after scoring
    {:noreply,
      socket
      |> assign(
          ball: %{
            x: @board_width / 2,
            y: @board_height / 2,
            dx: -@ball_speed, # Start going towards the paddle
            dy: @ball_speed
          },
          game_state: :playing
        )
    }
  end

  def handle_info(:tick, socket) do
    new_state = update_game_state(socket.assigns)
    {:noreply, assign(socket, new_state)}
  end

  defp update_game_state(assigns) do
    # First, update paddle position based on keyboard input
    new_paddle = update_paddle_position(assigns.paddle, assigns.last_key, assigns.board.height, assigns.paddle_height)

    # Then, update ball position and check for collisions
    {new_ball, new_game_state, new_scores} = update_ball_and_check_scoring(
      assigns.ball,
      assigns.board,
      new_paddle,
      assigns.ball_radius,
      assigns.paddle_width,
      assigns.paddle_height,
      assigns.scores
    )

    %{
      ball: new_ball,
      paddle: new_paddle,
      game_state: new_game_state,
      scores: new_scores
    }
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
    {new_dx, new_game_state, new_scores} =
      if ball_hits_paddle?(
          new_x,
          new_y,
          ball_radius,
          paddle.x,
          paddle.y,
          paddle_width,
          paddle_height
        ) do
        # Bounce off paddle
        {-ball.dx, :playing, scores}
      else
        # Check scoring and wall collisions
        check_scoring_and_walls(new_x, new_y, ball.dx, ball_radius, board.width, scores)
      end

    # Check top/bottom wall collisions
    new_dy = calculate_new_dy(new_y, ball.dy, board.height, ball_radius)

    # Return updated ball state and game state
    {
      %{x: new_x, y: new_y, dx: new_dx, dy: new_dy},
      new_game_state,
      new_scores
    }
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

  defp check_scoring_and_walls(x, y, dx, ball_radius, board_width, scores) do
    cond do
      # Ball passed the paddle (left wall) - wall scores
      x - ball_radius <= 0 ->
        {-dx, :scored, %{scores | wall: scores.wall + 1}}

      # Right wall collision
      x + ball_radius >= board_width && dx > 0 ->
        {-dx, :playing, scores}

      # No collision
      true ->
        {dx, :playing, scores}
    end
  end

  defp calculate_new_dy(y, dy, height, ball_radius) do
    cond do
      y + ball_radius >= height && dy > 0 -> -dy
      y - ball_radius <= 0 && dy < 0 -> -dy
      true -> dy
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col justify-center items-center p-4 bg-gray-800">
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
    </div>
    """
  end
end
