defmodule BlogWeb.Twenty48Live do
  use BlogWeb, :live_view
  alias Blog.Games.Twenty48

  @default_blitz_ms 2000
  @blitz_options [1000, 2000, 3000, 5000]
  @sizes [4, 8, 10, 12]

  @impl true
  def mount(_params, _session, socket) do
    game = Twenty48.new(4)

    {:ok,
     socket
     |> assign(:game, game)
     |> assign(:size, 4)
     |> assign(:blitz, false)
     |> assign(:blitz_expired, false)
     |> assign(:timer_ref, nil)
     |> assign(:blitz_ms, @default_blitz_ms)
     |> assign(:time_left, @default_blitz_ms)
     |> assign(:best, 0)
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
  def handle_info(:blitz_tick, socket) do
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
      ref = Process.send_after(self(), :blitz_tick, 100)

      {:noreply,
       socket
       |> assign(:time_left, time_left)
       |> assign(:timer_ref, ref)}
    end
  end

  defp do_move(socket, direction) do
    game = socket.assigns.game
    if game.game_over, do: socket, else: apply_move(socket, direction)
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
    ref = Process.send_after(self(), :blitz_tick, 100)
    assign(socket, timer_ref: ref, time_left: socket.assigns.blitz_ms)
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

  @impl true
  def render(assigns) do
    assigns = assigns |> assign(:sizes, @sizes) |> assign(:blitz_options, @blitz_options)

    ~H"""
    <div id="twenty48-container" phx-hook="Swipe" phx-window-keydown="keydown" class="twenty48-wrap">
      <style>
        /* === 1980s Macintosh Aesthetic === */
        @import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');

        .twenty48-wrap {
          font-family: 'VT323', 'Chicago', 'Geneva', monospace;
          background: #c0c0c0;
          min-height: 100vh;
          display: flex;
          align-items: flex-start;
          justify-content: center;
          padding: 12px;
          box-sizing: border-box;
          -webkit-user-select: none;
          user-select: none;
          image-rendering: pixelated;
        }
        .mac-window {
          background: #fff;
          border: 2px solid #000;
          box-shadow: 2px 2px 0px #000;
          width: 100%;
          max-width: 520px;
        }
        .mac-title-bar {
          background: #fff;
          border-bottom: 2px solid #000;
          padding: 3px 8px;
          display: flex;
          align-items: center;
          gap: 8px;
          height: 22px;
        }
        .mac-close-box {
          width: 12px;
          height: 12px;
          border: 1px solid #000;
          flex-shrink: 0;
        }
        .mac-title-stripes {
          flex: 1;
          height: 12px;
          background: repeating-linear-gradient(
            to bottom,
            #000 0px, #000 1px,
            #fff 1px, #fff 3px
          );
        }
        .mac-title-text {
          font-size: 14px;
          font-weight: bold;
          padding: 0 8px;
          background: #fff;
          white-space: nowrap;
        }
        .mac-body {
          padding: 12px;
        }

        /* Score row */
        .score-row {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 10px;
          flex-wrap: wrap;
          gap: 6px;
        }
        .score-box {
          border: 1px solid #000;
          padding: 3px 10px;
          text-align: center;
          font-size: 18px;
        }
        .score-box .label {
          font-size: 12px;
          letter-spacing: 1px;
        }

        /* Controls */
        .controls-row {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-bottom: 10px;
          flex-wrap: wrap;
        }
        .mac-btn {
          font-family: 'VT323', monospace;
          font-size: 16px;
          background: #fff;
          border: 2px solid #000;
          border-radius: 6px;
          padding: 3px 14px;
          cursor: pointer;
          box-shadow: 1px 1px 0 #000;
          white-space: nowrap;
        }
        .mac-btn:active {
          box-shadow: none;
          transform: translate(1px, 1px);
        }
        .mac-btn.active {
          background: #000;
          color: #fff;
        }
        .size-btn {
          min-width: 36px;
          text-align: center;
        }

        /* Blitz checkbox */
        .blitz-check {
          display: flex;
          align-items: center;
          gap: 4px;
          cursor: pointer;
          font-size: 16px;
        }
        .blitz-check input[type="checkbox"] {
          appearance: none;
          -webkit-appearance: none;
          width: 14px;
          height: 14px;
          border: 1px solid #000;
          background: #fff;
          cursor: pointer;
          position: relative;
        }
        .blitz-check input[type="checkbox"]:checked::after {
          content: "X";
          position: absolute;
          top: -2px;
          left: 1px;
          font-size: 14px;
          font-family: 'VT323', monospace;
          line-height: 1;
        }

        /* Blitz timer bar */
        .blitz-bar-wrap {
          height: 8px;
          border: 1px solid #000;
          margin-bottom: 8px;
          background: #fff;
        }
        .blitz-bar {
          height: 100%;
          background: #000;
          transition: width 0.1s linear;
        }
        .blitz-bar.danger {
          background: repeating-linear-gradient(
            45deg,
            #000 0px, #000 3px,
            #fff 3px, #fff 6px
          );
        }

        /* Board */
        .board-grid {
          display: grid;
          gap: 2px;
          border: 2px solid #000;
          background: #000;
          padding: 2px;
          aspect-ratio: 1;
        }
        .tile {
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 8vmin;
          aspect-ratio: 1;
          border: 1px solid #888;
          box-sizing: border-box;
          overflow: hidden;
          transition: background-color 0.25s cubic-bezier(0.22, 1, 0.36, 1),
                     color 0.25s cubic-bezier(0.22, 1, 0.36, 1),
                     border-color 0.25s ease;
        }
        @keyframes tile-pop {
          0% { transform: scale(0); opacity: 0; }
          40% { transform: scale(1.15); opacity: 1; }
          70% { transform: scale(0.95); }
          100% { transform: scale(1); }
        }
        @keyframes tile-merge {
          0% { transform: scale(1); }
          30% { transform: scale(1.2); }
          100% { transform: scale(1); }
        }
        .tile-new {
          animation: tile-pop 0.3s cubic-bezier(0.22, 1, 0.36, 1);
        }
        .tile-merged {
          animation: tile-merge 0.25s cubic-bezier(0.22, 1, 0.36, 1);
        }
        .tile-empty { background: #e8e8e8; color: transparent; }
        .tile-2     { background: #fff; color: #000; }
        .tile-4     { background: #f0f0f0; color: #000; }
        .tile-8     { background: #d0d0d0; color: #000; }
        .tile-16    { background: #b0b0b0; color: #000; }
        .tile-32    { background: #909090; color: #fff; }
        .tile-64    { background: #707070; color: #fff; }
        .tile-128   { background: #505050; color: #fff; border: 1px solid #fff; }
        .tile-256   { background: #383838; color: #fff; border: 1px solid #fff; }
        .tile-512   { background: #202020; color: #fff; border: 1px solid #fff; }
        .tile-1024  { background: #101010; color: #fff; border: 1px solid #aaa; }
        .tile-2048  { background: #000; color: #fff; border: 2px solid #fff; }
        .tile-super { background: #000; color: #fff; border: 2px dashed #fff; }

        /* Game over overlay */
        .game-over-overlay {
          position: absolute;
          inset: 0;
          background: rgba(255,255,255,0.85);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          z-index: 10;
        }
        .game-over-overlay h2 {
          font-size: 32px;
          margin: 0 0 4px;
          font-family: 'VT323', monospace;
        }
        .game-over-overlay p {
          font-size: 20px;
          margin: 0 0 12px;
          font-family: 'VT323', monospace;
        }
        .board-container {
          position: relative;
        }

        /* Won banner */
        .won-banner {
          text-align: center;
          font-size: 20px;
          border: 2px solid #000;
          padding: 4px;
          margin-bottom: 8px;
          background: #fff;
          letter-spacing: 2px;
        }

        /* D-pad for mobile */
        .dpad {
          display: none;
          margin-top: 12px;
        }
        .dpad-grid {
          display: grid;
          grid-template-columns: 50px 50px 50px;
          grid-template-rows: 50px 50px 50px;
          gap: 3px;
          margin: 0 auto;
          width: fit-content;
        }
        .dpad-btn {
          font-family: 'VT323', monospace;
          font-size: 24px;
          background: #fff;
          border: 2px solid #000;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 1px 1px 0 #000;
        }
        .dpad-btn:active {
          box-shadow: none;
          transform: translate(1px, 1px);
          background: #000;
          color: #fff;
        }
        .dpad-spacer { visibility: hidden; }

        @media (max-width: 600px) {
          .twenty48-wrap { padding: 4px; }
          .mac-window { max-width: 100%; }
          .mac-body { padding: 8px; }
          .dpad { display: block; }
          .score-box { font-size: 16px; padding: 2px 8px; }
        }

        @media (hover: none) and (pointer: coarse) {
          .dpad { display: block; }
        }
      </style>

      <div class="mac-window">
        <div class="mac-title-bar">
          <div class="mac-close-box"></div>
          <div class="mac-title-stripes"></div>
          <div class="mac-title-text">2048</div>
          <div class="mac-title-stripes"></div>
        </div>

        <div class="mac-body">
          <div class="score-row">
            <div class="score-box">
              <div class="label">SCORE</div>
              <div><%= @game.score %></div>
            </div>
            <div class="score-box">
              <div class="label">BEST</div>
              <div><%= @best %></div>
            </div>
            <button class="mac-btn" phx-click="new_game">New Game</button>
          </div>

          <div class="controls-row">
            <label class="blitz-check" phx-click="toggle_blitz">
              <input type="checkbox" checked={@blitz} readonly tabindex="-1" />
              BLITZ
            </label>

            <%= if @blitz do %>
              <%= for ms <- @blitz_options do %>
                <button
                  class={"mac-btn size-btn #{if ms == @blitz_ms, do: "active"}"}
                  phx-click="set_blitz_time"
                  phx-value-ms={ms}
                >
                  <%= div(ms, 1000) %>s
                </button>
              <% end %>
            <% end %>
          </div>

          <div class="controls-row">
            <span style="font-size:13px;color:#555;">Board:</span>
            <%= for s <- @sizes do %>
              <button
                class={"mac-btn size-btn #{if s == @size, do: "active"}"}
                phx-click="set_size"
                phx-value-size={s}
              >
                <%= s %>
              </button>
            <% end %>
          </div>

          <%= if @blitz do %>
            <div class="blitz-bar-wrap">
              <div
                class={"blitz-bar #{if @time_left < 600, do: "danger"}"}
                style={"width: #{blitz_bar_pct(@time_left, @blitz_ms)}%"}
              ></div>
            </div>
          <% end %>

          <%= if @game.won and not @game.game_over do %>
            <div class="won-banner">YOU HIT 2048!</div>
          <% end %>

          <div class="board-container">
            <div
              class="board-grid"
              style={"grid-template-columns: repeat(#{@game.size}, 1fr);"}
            >
              <%= for r <- 0..(@game.size - 1) do %>
                <%= for c <- 0..(@game.size - 1) do %>
                  <% val = @game.board[{r, c}] %>
                  <% anim =
                    cond do
                      @game.new_tile == {r, c} -> "tile-new"
                      MapSet.member?(@game.merged_tiles, {r, c}) -> "tile-merged"
                      true -> ""
                    end
                  %>
                  <div
                    class={"tile #{tile_class(val)} #{anim}"}
                    style={tile_font_size(val, @game.size)}
                  >
                    <%= if val > 0, do: val %>
                  </div>
                <% end %>
              <% end %>
            </div>

            <%= if @game.game_over do %>
              <div class="game-over-overlay">
                <h2><%= if @blitz_expired, do: "TIME'S UP!", else: "GAME OVER" %></h2>
                <p>Score: <%= @game.score %></p>
                <button class="mac-btn" phx-click="new_game">Play Again</button>
              </div>
            <% end %>
          </div>

          <div class="dpad">
            <div class="dpad-grid">
              <div class="dpad-spacer"></div>
              <button class="dpad-btn" phx-click="swipe" phx-value-direction="up">&#9650;</button>
              <div class="dpad-spacer"></div>
              <button class="dpad-btn" phx-click="swipe" phx-value-direction="left">&#9664;</button>
              <div class="dpad-spacer"></div>
              <button class="dpad-btn" phx-click="swipe" phx-value-direction="right">&#9654;</button>
              <div class="dpad-spacer"></div>
              <button class="dpad-btn" phx-click="swipe" phx-value-direction="down">&#9660;</button>
              <div class="dpad-spacer"></div>
            </div>
          </div>

        </div>
      </div>
    </div>
    """
  end
end
