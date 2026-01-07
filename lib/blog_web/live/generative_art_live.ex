defmodule BlogWeb.GenerativeArtLive do
  use BlogWeb, :live_view

  @fps 30
  @ball_radius 10
  @ball_speed 5
  @trail_length 100
  @auto_curve_interval 2
  # Fixed black background
  @background_color "#000000"

  def mount(_params, _session, socket) do
    viewport_width = 800
    viewport_height = 600

    # Create data for the bezier curve and triangles
    bezier_data = %{
      width: viewport_width,
      height: viewport_height,
      draw: true,
      progress: 0,
      reset: true
    }

    socket =
      socket
      |> assign(:viewport_width, viewport_width)
      |> assign(:viewport_height, viewport_height)
      |> assign(:bezier_data, bezier_data)
      |> assign(:ball, %{
        x: viewport_width / 2,
        y: viewport_height / 2,
        dx: @ball_speed,
        dy: @ball_speed,
        radius: @ball_radius
      })
      |> assign(:trail, [])
      |> assign(:trail_length, @trail_length)
      # Use the fixed background color
      |> assign(:background_color, @background_color)
      |> assign(:colors, generate_rainbow_colors(@trail_length))
      |> assign(:curve_count, 0)
      |> assign(:last_auto_curve_time, System.os_time(:second))

    if connected?(socket) do
      Process.send_after(self(), :tick, trunc(1000 / @fps))
    end

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, trunc(1000 / @fps))

    socket =
      socket
      |> update_ball()
      |> update_trail()
      |> maybe_add_new_curve()

    {:noreply, socket}
  end

  # Occasionally add a new curve set automatically
  defp maybe_add_new_curve(socket) do
    current_time = System.os_time(:second)
    time_since_last = current_time - socket.assigns.last_auto_curve_time

    # Check if enough time has passed and we're not currently drawing
    # Increased probability from 30% to 50%
    if socket.assigns.curve_count > 0 &&
         time_since_last >= @auto_curve_interval &&
         !socket.assigns.bezier_data.draw &&
         :rand.uniform(100) < 50 do
      bezier_data = %{
        width: socket.assigns.viewport_width,
        height: socket.assigns.viewport_height,
        draw: true,
        progress: 0,
        # Don't clear existing triangles
        reset: false
      }

      socket
      |> assign(:bezier_data, bezier_data)
      |> assign(:curve_count, socket.assigns.curve_count + 1)
      |> assign(:last_auto_curve_time, current_time)
    else
      socket
    end
  end

  def handle_event("viewport_resize", %{"width" => width, "height" => height}, socket) do
    width = width |> String.to_float() |> trunc()
    height = height |> String.to_float() |> trunc()

    # Reset ball position with new viewport dimensions
    ball = %{
      x: width / 2,
      y: height / 2,
      dx: @ball_speed,
      dy: @ball_speed,
      radius: @ball_radius
    }

    # Update bezier data with new dimensions
    bezier_data = %{
      width: width,
      height: height,
      draw: true,
      progress: 0,
      # Full reset on resize
      reset: true
    }

    socket =
      socket
      |> assign(:viewport_width, width)
      |> assign(:viewport_height, height)
      |> assign(:bezier_data, bezier_data)
      |> assign(:ball, ball)
      |> assign(:trail, [])
      |> assign(:curve_count, 1)
      |> assign(:last_auto_curve_time, System.os_time(:second))

    {:noreply, socket}
  end

  def handle_event("keydown", _params, socket) do
    # No longer change background color, just trigger new curves
    bezier_data = %{
      width: socket.assigns.viewport_width,
      height: socket.assigns.viewport_height,
      draw: true,
      progress: 0
      # reset: true  # Clear existing triangles on keypress
    }

    socket =
      socket
      |> assign(:bezier_data, bezier_data)
      |> assign(:curve_count, 1)
      |> assign(:last_auto_curve_time, System.os_time(:second))

    {:noreply, socket}
  end

  def handle_event("drawing_progress", %{"progress" => progress}, socket) do
    # Update the progress
    bezier_data = Map.put(socket.assigns.bezier_data, :progress, progress)
    {:noreply, assign(socket, :bezier_data, bezier_data)}
  end

  def handle_event("drawing_complete", _params, socket) do
    # Update the draw flag to false once drawn
    bezier_data = Map.put(socket.assigns.bezier_data, :draw, false)

    # Immediately try to add more curves with a higher chance after completion
    current_time = System.os_time(:second)
    # Increased from 40% to 60% chance to immediately add more
    should_add_more = :rand.uniform(100) < 60

    socket =
      if should_add_more do
        new_bezier_data = %{
          width: socket.assigns.viewport_width,
          height: socket.assigns.viewport_height,
          draw: true,
          progress: 0,
          # Don't clear existing triangles
          reset: false
        }

        socket
        |> assign(:bezier_data, new_bezier_data)
        |> assign(:curve_count, socket.assigns.curve_count + 1)
        |> assign(:last_auto_curve_time, current_time)
      else
        assign(socket, :bezier_data, bezier_data)
      end

    {:noreply, socket}
  end

  # Add a function to generate random triangles across the entire screen
  # This will be called on initial load to ensure immediate coverage
  defp generate_random_triangles(width, height, count) do
    Enum.map(1..count, fn _ ->
      x = :rand.uniform(width)
      y = :rand.uniform(height)
      size = :rand.uniform(50) + 20
      rotation = :rand.uniform() * 2 * :math.pi()

      %{
        x: x,
        y: y,
        size: size,
        rotation: rotation,
        color: generate_random_color()
      }
    end)
  end

  defp update_ball(socket) do
    %{ball: ball, viewport_width: width, viewport_height: height} = socket.assigns

    # Update position
    new_x = ball.x + ball.dx
    new_y = ball.y + ball.dy

    # Handle collisions with walls
    {new_x, new_dx} =
      cond do
        new_x - ball.radius < 0 -> {ball.radius, abs(ball.dx)}
        new_x + ball.radius > width -> {width - ball.radius, -abs(ball.dx)}
        true -> {new_x, ball.dx}
      end

    {new_y, new_dy} =
      cond do
        new_y - ball.radius < 0 -> {ball.radius, abs(ball.dy)}
        new_y + ball.radius > height -> {height - ball.radius, -abs(ball.dy)}
        true -> {new_y, ball.dy}
      end

    new_ball = %{
      x: new_x,
      y: new_y,
      dx: new_dx,
      dy: new_dy,
      radius: ball.radius
    }

    assign(socket, :ball, new_ball)
  end

  defp update_trail(socket) do
    %{trail: trail, ball: ball, trail_length: trail_length} = socket.assigns

    # Add current position to trail
    new_trail =
      [[ball.x, ball.y] | trail]
      |> Enum.take(trail_length)

    assign(socket, :trail, new_trail)
  end

  defp generate_rainbow_colors(count) do
    Enum.map(0..(count - 1), fn i ->
      hue = trunc(360 * i / count)
      "hsl(#{hue}, 100%, 50%)"
    end)
  end

  defp generate_random_color do
    r = Enum.random(0..255)
    g = Enum.random(0..255)
    b = Enum.random(0..255)

    "##{Integer.to_string(r, 16) |> String.pad_leading(2, "0")}#{Integer.to_string(g, 16) |> String.pad_leading(2, "0")}#{Integer.to_string(b, 16) |> String.pad_leading(2, "0")}"
  end

  def render(assigns) do
    ~H"""
    <div
      id="generative-art"
      class="fixed inset-0 overflow-hidden"
      style={"background-color: #{@background_color};"}
      phx-hook="GenerativeArt"
      phx-window-keydown="keydown"
    >
      <div class="absolute inset-0">
        <!-- Bezier Curve and Triangles - Using canvas for better performance -->
        <canvas
          id="bezier-canvas"
          width={@viewport_width}
          height={@viewport_height}
          class="absolute inset-0"
          phx-update="ignore"
          data-bezier={Jason.encode!(@bezier_data)}
        >
        </canvas>
        
    <!-- SVG for ball and trail -->
        <svg width="100%" height="100%" class="absolute inset-0 pointer-events-none">
          <!-- Ball Trail -->
          <%= for {[x, y], index} <- Enum.with_index(@trail) do %>
            <circle
              cx={x}
              cy={y}
              r={3 + (@trail_length - index) / 10}
              fill={Enum.at(@colors, index, "#ffffff")}
              opacity={1.0}
            />
          <% end %>
          
    <!-- Ball -->
          <circle
            cx={@ball.x}
            cy={@ball.y}
            r={@ball.radius}
            fill="white"
            stroke="black"
            stroke-width="2"
          />
        </svg>
      </div>
    </div>
    """
  end
end
