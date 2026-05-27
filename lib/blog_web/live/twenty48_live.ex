defmodule BlogWeb.Twenty48Live do
  use BlogWeb, :live_view
  alias Blog.Games.Twenty48

  @default_blitz_ms 5000
  @blitz_options [1000, 2000, 3000, 5000]
  @sizes [4, 8, 10, 12]

  @impl true
  def mount(_params, _session, socket) do
    game = Twenty48.new(8)

    {:ok,
     socket
     |> assign(:game, game)
     |> assign(:size, 8)
     |> assign(:blitz, true)
     |> assign(:blitz_expired, false)
     |> assign(:timer_ref, nil)
     |> assign(:blitz_ms, @default_blitz_ms)
     |> assign(:time_left, @default_blitz_ms)
     |> assign(:best, 0)
     |> assign(:show_howto, true)
     |> assign(:timer_gen, 0)
     |> assign(:sizes, @sizes)
     |> assign(:blitz_options, @blitz_options)
     |> assign(:page_title, "2048 — Blitz Edition")
     |> assign(:page_description, "The classic 2048 puzzle with a twist: Blitz mode gives you 2 seconds per move. Adjustable board sizes up to 12x12. Retro 1980s Macintosh style.")
     |> assign(:page_image, "https://www.bobbby.online/images/og-2048.png")}
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    direction =
      case key do
        "ArrowLeft" -> :left
        "ArrowRight" -> :right
        "ArrowUp" -> :up
        "ArrowDown" -> :down
        _ -> nil
      end

    if direction, do: {:noreply, do_move(socket, direction)}, else: {:noreply, socket}
  end

  def handle_event("swipe", %{"direction" => dir}, socket) do
    direction =
      case dir do
        "left" -> :left
        "right" -> :right
        "up" -> :up
        "down" -> :down
        _ -> nil
      end

    if direction, do: {:noreply, do_move(socket, direction)}, else: {:noreply, socket}
  end

  def handle_event("start_game", _params, socket) do
    game = Twenty48.new(socket.assigns.size)

    {:noreply,
     socket
     |> assign(:show_howto, false)
     |> assign(:game, game)
     |> assign(:blitz_expired, false)
     |> assign(:timer_ref, nil)
     |> assign(:time_left, socket.assigns.blitz_ms)
     |> maybe_start_blitz_timer()}
  end

  def handle_event("new_game", _params, socket) do
    cancel_timer(socket.assigns.timer_ref)
    game = Twenty48.new(socket.assigns.size)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:blitz_expired, false)
     |> assign(:timer_ref, nil)
     |> assign(:time_left, socket.assigns.blitz_ms)
     |> maybe_start_blitz_timer()}
  end

  def handle_event("toggle_blitz", _params, socket) do
    cancel_timer(socket.assigns.timer_ref)
    new_blitz = not socket.assigns.blitz

    socket =
      socket
      |> assign(:blitz, new_blitz)
      |> assign(:blitz_expired, false)
      |> assign(:timer_ref, nil)
      |> assign(:time_left, socket.assigns.blitz_ms)

    socket = if new_blitz, do: start_blitz_timer(socket), else: socket
    {:noreply, socket}
  end

  def handle_event("set_blitz_time", %{"ms" => ms_str}, socket) do
    ms = String.to_integer(ms_str)
    cancel_timer(socket.assigns.timer_ref)

    socket =
      socket
      |> assign(:blitz_ms, ms)
      |> assign(:time_left, ms)
      |> assign(:timer_ref, nil)

    socket = if socket.assigns.blitz, do: start_blitz_timer(socket), else: socket
    {:noreply, socket}
  end

  def handle_event("set_size", %{"size" => size_str}, socket) do
    size = String.to_integer(size_str)
    cancel_timer(socket.assigns.timer_ref)
    game = Twenty48.new(size)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:size, size)
     |> assign(:blitz_expired, false)
     |> assign(:timer_ref, nil)
     |> assign(:time_left, socket.assigns.blitz_ms)
     |> maybe_start_blitz_timer()}
  end

  @impl true
  def handle_info({:blitz_tick, gen}, socket) do
    # Ignore stale ticks from a previous timer generation
    if gen != socket.assigns.timer_gen do
      {:noreply, socket}
    else
      time_left = socket.assigns.time_left - 100

      if time_left <= 0 do
        game = %{socket.assigns.game | game_over: true}

        {:noreply,
         socket
         |> assign(:game, game)
         |> assign(:blitz_expired, true)
         |> assign(:time_left, 0)
         |> assign(:timer_ref, nil)
         |> update_best()}
      else
        ref = Process.send_after(self(), {:blitz_tick, gen}, 100)

        {:noreply,
         socket
         |> assign(:time_left, time_left)
         |> assign(:timer_ref, ref)}
      end
    end
  end

  defp do_move(socket, direction) do
    if socket.assigns.show_howto or socket.assigns.game.game_over do
      socket
    else
      apply_move(socket, direction)
    end
  end

  defp apply_move(socket, direction) do
    old_board = socket.assigns.game.board
    new_game = Twenty48.move(socket.assigns.game, direction)

    if new_game.board == old_board do
      socket
    else
      socket
      |> assign(:game, new_game)
      |> update_best()
      |> reset_blitz_timer()
    end
  end

  defp update_best(socket) do
    if socket.assigns.game.score > socket.assigns.best do
      assign(socket, :best, socket.assigns.game.score)
    else
      socket
    end
  end

  defp maybe_start_blitz_timer(socket) do
    if socket.assigns.blitz, do: start_blitz_timer(socket), else: socket
  end

  defp start_blitz_timer(socket) do
    gen = socket.assigns.timer_gen + 1
    ref = Process.send_after(self(), {:blitz_tick, gen}, 100)
    assign(socket, timer_ref: ref, time_left: socket.assigns.blitz_ms, timer_gen: gen)
  end

  defp reset_blitz_timer(socket) do
    if socket.assigns.blitz and not socket.assigns.game.game_over do
      cancel_timer(socket.assigns.timer_ref)
      start_blitz_timer(socket)
    else
      socket
    end
  end

  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)

  defp tile_class(0), do: "tile-empty"
  defp tile_class(2), do: "tile-2"
  defp tile_class(4), do: "tile-4"
  defp tile_class(8), do: "tile-8"
  defp tile_class(16), do: "tile-16"
  defp tile_class(32), do: "tile-32"
  defp tile_class(64), do: "tile-64"
  defp tile_class(128), do: "tile-128"
  defp tile_class(256), do: "tile-256"
  defp tile_class(512), do: "tile-512"
  defp tile_class(1024), do: "tile-1024"
  defp tile_class(2048), do: "tile-2048"
  defp tile_class(_), do: "tile-super"

  defp tile_font_size(val, size) when size == 12 and val >= 1000, do: "font-size: 1.8vmin;"
  defp tile_font_size(val, size) when size == 12 and val >= 100, do: "font-size: 2.2vmin;"
  defp tile_font_size(_val, size) when size == 12, do: "font-size: 2.6vmin;"
  defp tile_font_size(val, size) when size == 10 and val >= 1000, do: "font-size: 2.2vmin;"
  defp tile_font_size(val, size) when size == 10 and val >= 100, do: "font-size: 2.8vmin;"
  defp tile_font_size(_val, size) when size == 10, do: "font-size: 3.2vmin;"
  defp tile_font_size(val, size) when size == 8 and val >= 1000, do: "font-size: 3vmin;"
  defp tile_font_size(val, size) when size == 8 and val >= 100, do: "font-size: 3.6vmin;"
  defp tile_font_size(_val, size) when size == 8, do: "font-size: 4.2vmin;"
  defp tile_font_size(val, _size) when val >= 1000, do: "font-size: 5vmin;"
  defp tile_font_size(val, _size) when val >= 100, do: "font-size: 6vmin;"
  defp tile_font_size(_val, _size), do: ""

  defp blitz_bar_pct(time_left, blitz_ms), do: time_left / blitz_ms * 100
end
