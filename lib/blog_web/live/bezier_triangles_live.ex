defmodule BlogWeb.BezierTrianglesLive do
  use BlogWeb, :live_view
  require Logger
  alias Jason

  def triangle_size(), do: 15..60 |> Enum.to_list() |> Enum.shuffle() |> List.first()

  # Animation configuration
  @fps 30
  @frame_interval trunc(1000 / @fps)
  @num_curves 10
  @num_points_per_curve 4
  @triangle_size 25
  @triangle_rotation_speed 0.1
  @triangle_step_distance 10
  @initial_triangles_per_curve 5
  @triangle_speed_min 0.003
  @triangle_speed_max 0.01
  @max_triangles 300
  @background_line_count 60
  @gradient_colors [
    # Coral red
    "#FF5E5B",
    # Light brown
    "#D8A47F",
    # Mint green
    "#7FC6A4",
    # Slate
    "#5D737E",
    # Teal
    "#468189",
    # Orange
    "#FF9E00",
    # Purple
    "#9C59D1",
    # Turquoise
    "#2EC4B6",
    # Gold
    "#FFD700",
    # Hot Pink
    "#FF69B4",
    # Pale Green
    "#98FB98",
    # Sky Blue
    "#87CEEB",
    # Light Salmon
    "#FFA07A",
    # Plum
    "#DDA0DD"
  ]

  def mount(_params, _session, socket) do
    Logger.info("BezierTrianglesLive mount called")
    viewport_width = 800
    viewport_height = 600

    # Generate initial bezier curves
    curves = generate_random_bezier_curves(@num_curves, viewport_width, viewport_height)
    Logger.info("Generated #{length(curves)} curves")

    # Initialize with many triangles already - several for each curve
    initial_triangles =
      Enum.flat_map(curves, fn curve ->
        curve_index = Enum.find_index(curves, fn c -> c == curve end)
        generate_triangles_for_curve(curve, curve_index, @initial_triangles_per_curve)
      end)

    Logger.info("Generated #{length(initial_triangles)} initial triangles")

    # Generate background lines
    background_lines =
      generate_random_lines(@background_line_count, viewport_width, viewport_height)

    socket =
      socket
      |> assign(:viewport_width, viewport_width)
      |> assign(:viewport_height, viewport_height)
      |> assign(:curves, curves)
      |> assign(:triangles, initial_triangles)
      |> assign(:background_lines, background_lines)
      |> assign(:frame, 0)
      |> assign(:num_curves, @num_curves)
      |> assign(:max_triangles, @max_triangles)
      |> assign(:page_title, "Bezier Triangles Animation")
      |> assign(:meta_attrs, [
        %{
          name: "description",
          content: "A mesmerizing animation of triangles moving along bezier curves"
        },
        %{property: "og:title", content: "Bezier Triangles Animation"},
        %{
          property: "og:description",
          content: "A mesmerizing animation of triangles moving along bezier curves"
        },
        %{property: "og:type", content: "website"}
      ])

    if connected?(socket) do
      # Start animation loop
      Process.send_after(self(), :animate, @frame_interval)
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(:animate, socket) do
    # Schedule next frame
    Process.send_after(self(), :animate, @frame_interval)

    # Update frame counter
    frame = socket.assigns.frame + 1

    if rem(frame, 100) == 0 do
      Logger.info("Animation frame #{frame}")
    end

    # Add triangles less frequently
    triangles =
      if rem(frame, 5) == 0 && length(socket.assigns.triangles) < @max_triangles do
        add_new_triangles(socket.assigns.triangles, socket.assigns.curves)
      else
        socket.assigns.triangles
      end

    # Update all triangles (move along curves, rotate)
    updated_triangles = update_triangles(triangles)

    # Occasionally regenerate background lines (every 300 frames / 10 seconds)
    background_lines =
      if rem(frame, 300) == 0 do
        generate_random_lines(
          @background_line_count,
          socket.assigns.viewport_width,
          socket.assigns.viewport_height
        )
      else
        socket.assigns.background_lines
      end

    # Occasionally generate new curves (every 900 frames / 30 seconds)
    curves =
      if rem(frame, 900) == 0 do
        generate_random_bezier_curves(
          @num_curves,
          socket.assigns.viewport_width,
          socket.assigns.viewport_height
        )
      else
        socket.assigns.curves
      end

    socket =
      socket
      |> assign(:frame, frame)
      |> assign(:triangles, updated_triangles)
      |> assign(:background_lines, background_lines)
      |> assign(:curves, curves)

    {:noreply, socket}
  end

  @impl true
  def handle_event("viewport_resize", %{"width" => width, "height" => height}, socket) do
    # Convert to integer if needed
    width = if is_binary(width), do: String.to_integer(width), else: width
    height = if is_binary(height), do: String.to_integer(height), else: height

    # Regenerate everything for the new viewport size
    curves = generate_random_bezier_curves(@num_curves, width, height)
    background_lines = generate_random_lines(@background_line_count, width, height)

    socket =
      socket
      |> assign(:viewport_width, width)
      |> assign(:viewport_height, height)
      |> assign(:curves, curves)
      |> assign(:triangles, [])
      |> assign(:background_lines, background_lines)
      |> assign(:num_curves, @num_curves)
      |> assign(:max_triangles, @max_triangles)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-gray-900">
      <div class="absolute top-4 right-4 bg-black bg-opacity-50 text-white px-3 py-2 text-sm rounded z-10">
        <div class="text-xs text-gray-300 mb-1">Bezier Triangles Animation</div>
        <div class="flex flex-col gap-1">
          <div class="flex gap-3">
            <div>Triangles: {length(@triangles)}/{@max_triangles}</div>
            <div>Curves: {@num_curves}</div>
          </div>
          <div class="text-xs text-gray-400">Optimized for performance</div>
        </div>
      </div>

      <div id="bezier-container" class="absolute inset-0" phx-hook="BezierTriangles">
        <canvas
          id="bezier-canvas"
          width={@viewport_width}
          height={@viewport_height}
          class="w-full h-full"
          data-curves={Jason.encode!(@curves)}
          data-triangles={Jason.encode!(@triangles)}
          data-background-lines={Jason.encode!(@background_lines)}
        >
        </canvas>
      </div>
    </div>
    """
  end

  # Generate random bezier curves
  defp generate_random_bezier_curves(count, max_width, max_height) do
    Enum.map(1..count, fn _ ->
      # Create better distributed control points for more visible curves
      x1 = :rand.uniform(max_width)
      y1 = :rand.uniform(max_height)

      # Control points that create more interesting curves
      x2 = :rand.uniform(max_width)
      y2 = :rand.uniform(max_height)

      x3 = :rand.uniform(max_width)
      y3 = :rand.uniform(max_height)

      # End point - ensure some distance from start
      x4 = :rand.uniform(max_width)
      y4 = :rand.uniform(max_height)

      # Package points
      points = [
        %{x: x1, y: y1},
        %{x: x2, y: y2},
        %{x: x3, y: y3},
        %{x: x4, y: y4}
      ]

      %{
        points: points,
        color: Enum.random(@gradient_colors)
      }
    end)
  end

  # Generate random background lines
  defp generate_random_lines(count, viewport_width, viewport_height) do
    Enum.map(1..count, fn _ ->
      %{
        from: %{
          x: :rand.uniform(viewport_width),
          y: :rand.uniform(viewport_height)
        },
        to: %{
          x: :rand.uniform(viewport_width),
          y: :rand.uniform(viewport_height)
        },
        color: "rgba(255, 255, 255, #{0.1 + :rand.uniform() * 0.2})"
      }
    end)
  end

  # Add new triangles at the start of random bezier curves
  defp add_new_triangles(existing_triangles, curves) do
    # Add multiple triangles to random curves
    new_triangles =
      Enum.flat_map(1..2, fn _ ->
        curve = Enum.random(curves)
        curve_index = Enum.find_index(curves, fn c -> c == curve end)
        generate_triangles_for_curve(curve, curve_index, 1)
      end)

    new_triangles ++ existing_triangles
  end

  # Generate multiple triangles along a specific curve
  defp generate_triangles_for_curve(curve, curve_index, count) do
    start_point = List.first(curve.points)

    Enum.map(0..(count - 1), fn i ->
      # Distribute triangles along the first part of the curve
      initial_t = i * (0.2 / count)

      %{
        x: start_point.x,
        y: start_point.y,
        curve_index: curve_index,
        # Position along curve (0.0 to 1.0)
        t: initial_t,
        rotation: :rand.uniform() * 2 * :math.pi(),
        size: triangle_size(),
        color: Enum.random(@gradient_colors),
        color_index: :rand.uniform(length(@gradient_colors)) - 1,
        speed: @triangle_speed_min + :rand.uniform() * (@triangle_speed_max - @triangle_speed_min)
      }
    end)
  end

  # Update all triangles
  defp update_triangles(triangles) do
    # Remove triangles that have completed their path
    active_triangles = Enum.filter(triangles, fn triangle -> triangle.t < 1.0 end)

    # Update position and rotation for remaining triangles
    Enum.map(active_triangles, fn triangle ->
      # Move triangle along its curve using its custom speed
      new_t = triangle.t + (triangle.speed || 0.005)

      # Rotate triangle
      new_rotation = triangle.rotation + @triangle_rotation_speed

      # Only change color occasionally to save calculations
      {new_color_index, new_color} =
        if rem(trunc(new_t * 100), 20) == 0 do
          next_index = rem(triangle.color_index + 1, length(@gradient_colors))
          {next_index, Enum.at(@gradient_colors, next_index)}
        else
          {triangle.color_index, triangle.color}
        end

      # Update triangle
      %{
        triangle
        | t: new_t,
          rotation: new_rotation,
          color_index: new_color_index,
          color: new_color
      }
    end)
  end
end
