defmodule BlogWeb.PongLive do
  use BlogWeb, :live_view

  @fps 60
  @tick_rate 1000 / @fps
  @ball_radius 10
  @ball_speed 5
  @board_width 800
  @board_height 600

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
      board: %{
        width: @board_width,
        height: @board_height
      },
      ball_radius: @ball_radius,
      ball_speed: @ball_speed,
      board_width: @board_width,
      board_height: @board_height
    }

    {:ok, assign(socket, initial_state)}
  end

  def handle_info(:tick, socket) do
    new_ball = update_ball_position(socket.assigns)
    {:noreply, assign(socket, ball: new_ball)}
  end

  defp update_ball_position(%{ball: ball, board: board, ball_radius: ball_radius}) do
    # Calculate new position
    new_x = ball.x + ball.dx
    new_y = ball.y + ball.dy

    # Calculate new directions based on collisions
    new_dx = calculate_new_dx(new_x, ball.dx, board.width, ball_radius)
    new_dy = calculate_new_dy(new_y, ball.dy, board.height, ball_radius)

    # Return updated ball state
    %{
      x: new_x,
      y: new_y,
      dx: new_dx,
      dy: new_dy
    }
  end

  defp calculate_new_dx(x, dx, width, ball_radius) do
    cond do
      x + ball_radius >= width and dx > 0 -> -dx
      x - ball_radius <= 0 and dx < 0 -> -dx
      true -> dx
    end
  end

  defp calculate_new_dy(y, dy, height, ball_radius) do
    cond do
      y + ball_radius >= height and dy > 0 -> -dy
      y - ball_radius <= 0 and dy < 0 -> -dy
      true -> dy
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex justify-center items-center p-4 bg-gray-800">
      <div class="relative" style={"width: #{@board.width}px; height: #{@board.height}px;"}>
        <div class="absolute w-full h-full bg-gray-900 rounded-lg border-2 border-gray-700 overflow-hidden">
          <!-- Ball -->
          <div
            class="absolute rounded-full bg-white"
            style={"width: #{@ball_radius * 2}px; height: #{@ball_radius * 2}px; left: #{@ball.x - @ball_radius}px; top: #{@ball.y - @ball_radius}px;"}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end
end
