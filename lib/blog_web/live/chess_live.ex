defmodule BlogWeb.ChessLive do
  use BlogWeb, :live_view

  alias Blog.Chess.{Setup, Legal, Reducer, Scoring}
  alias Blog.Chess, as: C
  alias Blog.Content.ImageGenerator

  # ---------------------------------------------------------------------------
  # Mount
  # ---------------------------------------------------------------------------

  @impl true
  def mount(_params, _session, socket) do
    game = Setup.initial_state()

    socket =
      socket
      |> assign(:game, game)
      |> assign(:selected, nil)
      |> assign(:legal_targets, [])
      |> assign(:last_move, nil)
      |> assign(:bot_thinking, false)
      |> assign(:show_rules, true)
      |> assign_og_tags()

    {:ok, socket}
  end

  defp assign_og_tags(socket) do
    image_path = ImageGenerator.ensure_post_image("chess-game")
    image_url = if image_path, do: BlogWeb.Endpoint.url() <> image_path
    description = "Nine chess boards in a 3x3 grid. Pieces may cross board boundaries when credits have been earned. Win by checkmating the opponent on more boards."

    meta_tags = [
      %{name: "description", content: description},
      %{property: "og:title", content: "Chess-9 — play online"},
      %{property: "og:description", content: description},
      %{property: "og:type", content: "website"},
      %{property: "og:site_name", content: "bobbby.online"},
      %{name: "twitter:card", content: "summary_large_image"},
      %{name: "twitter:title", content: "Chess-9"},
      %{name: "twitter:description", content: description}
    ]

    meta_tags = if image_url do
      meta_tags ++ [
        %{property: "og:image", content: image_url},
        %{property: "og:image:width", content: "1200"},
        %{property: "og:image:height", content: "630"},
        %{name: "twitter:image", content: image_url}
      ]
    else
      meta_tags
    end

    socket
    |> assign(:page_title, "Chess-9")
    |> assign(:meta_tags, meta_tags)
  end

  # ---------------------------------------------------------------------------
  # New game
  # ---------------------------------------------------------------------------

  @impl true
  def handle_event("new_game", _params, socket) do
    game = Setup.initial_state()

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:selected, nil)
     |> assign(:legal_targets, [])
     |> assign(:last_move, nil)
     |> assign(:bot_thinking, false)}
  end

  @impl true
  def handle_event("close_rules", _params, socket) do
    {:noreply, assign(socket, :show_rules, false)}
  end

  # ---------------------------------------------------------------------------
  # Click-square event
  # ---------------------------------------------------------------------------

  @impl true
  def handle_event("click_square", %{"gx" => gx_s, "gy" => gy_s}, socket) do
    gx = String.to_integer(gx_s)
    gy = String.to_integer(gy_s)
    sq = {gx, gy}

    game = socket.assigns.game
    selected = socket.assigns.selected

    # Only allow white (human) to move; ignore clicks when bot is thinking or board is over
    if game.to_move != :white or socket.assigns.bot_thinking or Scoring.game_over?(game.status) do
      {:noreply, socket}
    else
      piece_at = fn sq -> elem(game.plane, C.cell_index(sq)) end

      cond do
        # Nothing selected → select if white piece
        is_nil(selected) ->
          piece = piece_at.(sq)

          if piece != nil and piece.color == :white and
               not C.frozen?(elem(game.status, C.board_of(sq))) do
            targets = compute_targets(game, sq)
            {:noreply, assign(socket, selected: sq, legal_targets: targets)}
          else
            {:noreply, socket}
          end

        # Clicked the already-selected square → deselect
        sq == selected ->
          {:noreply, assign(socket, selected: nil, legal_targets: [])}

        # Clicked a legal target → apply move
        sq in socket.assigns.legal_targets ->
          case Legal.find_legal_move(game, selected, sq) do
            {:ok, move} ->
              new_game = Reducer.apply_unchecked(game, move)
              send(self(), :bot_move)

              {:noreply,
               socket
               |> assign(:game, new_game)
               |> assign(:selected, nil)
               |> assign(:legal_targets, [])
               |> assign(:last_move, {selected, sq})
               |> assign(:bot_thinking, true)}

            {:error, _} ->
              {:noreply, assign(socket, selected: nil, legal_targets: [])}
          end

        # Clicked own piece → re-select
        match?(%{color: :white}, piece_at.(sq)) ->
          if not C.frozen?(elem(game.status, C.board_of(sq))) do
            targets = compute_targets(game, sq)
            {:noreply, assign(socket, selected: sq, legal_targets: targets)}
          else
            {:noreply, assign(socket, selected: nil, legal_targets: [])}
          end

        # Else → deselect
        true ->
          {:noreply, assign(socket, selected: nil, legal_targets: [])}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Bot move
  # ---------------------------------------------------------------------------

  # Kick off the bot search in a background Task so the LiveView process
  # never blocks. The result comes back as {:bot_move_result, move_or_nil}.
  @impl true
  def handle_info(:bot_move, socket) do
    game = socket.assigns.game

    if game.to_move == :black and not Scoring.game_over?(game.status) do
      parent = self()
      Task.start(fn ->
        move = Blog.Chess.Bot.best_move(game)
        send(parent, {:bot_move_result, move, game.ply})
      end)
      {:noreply, socket}
    else
      {:noreply, assign(socket, :bot_thinking, false)}
    end
  end

  # Guard with the ply the task was started at so a stale result
  # (e.g. from a reconnect replay) doesn't clobber a newer game state.
  @impl true
  def handle_info({:bot_move_result, move, ply}, socket) do
    game = socket.assigns.game

    cond do
      game.ply != ply ->
        # Stale result — game moved on, ignore
        {:noreply, assign(socket, :bot_thinking, false)}

      move == nil ->
        {:noreply, assign(socket, :bot_thinking, false)}

      true ->
        new_game = Reducer.apply_unchecked(game, move)
        {:noreply,
         socket
         |> assign(:game, new_game)
         |> assign(:last_move, {move.from, move.to})
         |> assign(:bot_thinking, false)}
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp compute_targets(game, sq) do
    Legal.legal_moves_for_square(game, sq)
    |> Enum.map(fn m -> m.to end)
  end

  defp board_index(board_col, board_row) do
    board_row * 3 + board_col
  end

  defp piece_unicode(%{type: :king, color: :white}), do: "♔"
  defp piece_unicode(%{type: :queen, color: :white}), do: "♕"
  defp piece_unicode(%{type: :rook, color: :white}), do: "♖"
  defp piece_unicode(%{type: :bishop, color: :white}), do: "♗"
  defp piece_unicode(%{type: :knight, color: :white}), do: "♘"
  defp piece_unicode(%{type: :pawn, color: :white}), do: "♙"
  defp piece_unicode(%{type: :king, color: :black}), do: "♚"
  defp piece_unicode(%{type: :queen, color: :black}), do: "♛"
  defp piece_unicode(%{type: :rook, color: :black}), do: "♜"
  defp piece_unicode(%{type: :bishop, color: :black}), do: "♝"
  defp piece_unicode(%{type: :knight, color: :black}), do: "♞"
  defp piece_unicode(%{type: :pawn, color: :black}), do: "♟"

  defp board_status_label(:active), do: nil
  defp board_status_label({:check, color}), do: "#{color} in check"
  defp board_status_label({:checkmate, winner, _loser}), do: "#{winner} wins"
  defp board_status_label(:stalemate), do: "stalemate"
  defp board_status_label({:draw, reason}), do: "draw (#{reason})"

  defp board_frozen?(:active), do: false
  defp board_frozen?({:check, _}), do: false
  defp board_frozen?(_), do: true

  defp score_bar(status) do
    white = Scoring.boards_won(status, :white)
    black = Scoring.boards_won(status, :black)
    {white, black}
  end

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .chess-page {
        font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
        min-height: 100vh;
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 24px 16px;
        color: #e0e0e0;
      }

      .mac-window {
        background: #2a2a3e;
        border-radius: 10px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.08);
        overflow: hidden;
        width: 100%;
        max-width: 920px;
      }

      .mac-titlebar {
        background: linear-gradient(180deg, #3a3a4e 0%, #2a2a3e 100%);
        padding: 10px 14px;
        display: flex;
        align-items: center;
        gap: 8px;
        border-bottom: 1px solid rgba(255,255,255,0.08);
      }

      .mac-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
      }
      .mac-dot-red   { background: #ff5f57; }
      .mac-dot-yellow{ background: #febc2e; }
      .mac-dot-green { background: #28c840; }

      .mac-title {
        flex: 1;
        text-align: center;
        font-size: 12px;
        color: #aaa;
        letter-spacing: 0.05em;
      }

      .mac-body {
        padding: 20px;
      }

      .chess-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 14px;
        flex-wrap: wrap;
        gap: 10px;
      }

      .game-title {
        font-size: 18px;
        font-weight: bold;
        color: #c8c8e8;
        letter-spacing: 0.1em;
      }

      .new-game-btn {
        background: linear-gradient(135deg, #3a7bd5, #00d2ff);
        color: white;
        border: none;
        border-radius: 6px;
        padding: 6px 16px;
        font-family: inherit;
        font-size: 12px;
        cursor: pointer;
        letter-spacing: 0.05em;
        transition: opacity 0.15s;
      }
      .new-game-btn:hover { opacity: 0.85; }

      .score-bar {
        display: flex;
        align-items: center;
        gap: 12px;
        background: rgba(0,0,0,0.25);
        border-radius: 8px;
        padding: 8px 14px;
        margin-bottom: 16px;
        font-size: 13px;
      }

      .score-label { color: #888; }

      .score-white {
        background: #f0f0f0;
        color: #111;
        border-radius: 4px;
        padding: 2px 8px;
        font-weight: bold;
      }

      .score-black {
        background: #222;
        color: #f0f0f0;
        border: 1px solid #555;
        border-radius: 4px;
        padding: 2px 8px;
        font-weight: bold;
      }

      .score-pip {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        display: inline-block;
        margin-right: 3px;
      }

      .status-line {
        font-size: 12px;
        color: #aac;
        margin-bottom: 14px;
        min-height: 18px;
      }

      /* 3x3 super-grid */
      .super-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
      }

      .board-cell {
        position: relative;
      }

      /* Each individual 8x8 board */
      .board-grid {
        display: grid;
        grid-template-columns: repeat(8, 1fr);
        width: 100%;
        aspect-ratio: 1;
        border-radius: 3px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.5);
      }

      /* Individual squares */
      .sq {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        user-select: none;
      }

      .sq:hover { filter: brightness(1.15); }

      .sq-piece {
        font-size: clamp(10px, 2.2vw, 22px);
        line-height: 1;
        z-index: 2;
        pointer-events: none;
      }

      .piece-white {
        color: #fff;
        text-shadow:
          0 0 2px #000,
          0 0 2px #000,
          1px 1px 0 #000,
          -1px -1px 0 #000,
          1px -1px 0 #000,
          -1px 1px 0 #000;
      }

      .piece-black {
        color: #1a1a1a;
        text-shadow:
          0 0 2px rgba(255,255,255,0.6),
          1px 1px 0 rgba(255,255,255,0.4);
      }

      /* Overlays */
      .sq-overlay {
        position: absolute;
        inset: 0;
        z-index: 1;
        pointer-events: none;
      }

      .overlay-selected {
        background: rgba(245, 158, 11, 0.55);
      }

      .overlay-last-move {
        background: rgba(59, 130, 246, 0.4);
      }

      .overlay-legal {
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .legal-dot {
        width: 28%;
        height: 28%;
        border-radius: 50%;
        background: rgba(34, 197, 94, 0.7);
        z-index: 1;
      }

      /* Frozen board overlay */
      .board-frozen-overlay {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.45);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10;
        border-radius: 3px;
        pointer-events: none;
      }

      .frozen-label {
        background: rgba(20,20,30,0.9);
        color: #e0e0f0;
        font-size: clamp(8px, 1.2vw, 12px);
        padding: 3px 7px;
        border-radius: 4px;
        text-align: center;
        letter-spacing: 0.04em;
        border: 1px solid rgba(255,255,255,0.15);
      }

      .bot-indicator {
        font-size: 12px;
        color: #febc2e;
        animation: pulse 1s ease-in-out infinite;
      }

      @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.3; }
      }

      .game-over-banner {
        text-align: center;
        padding: 12px;
        border-radius: 8px;
        margin-bottom: 14px;
        font-size: 14px;
        font-weight: bold;
        letter-spacing: 0.08em;
      }

      .game-over-white {
        background: linear-gradient(135deg, rgba(240,240,200,0.15), rgba(240,240,200,0.05));
        color: #f0f0c8;
        border: 1px solid rgba(240,240,200,0.3);
      }

      .game-over-black {
        background: linear-gradient(135deg, rgba(100,100,200,0.15), rgba(100,100,200,0.05));
        color: #c8c8f0;
        border: 1px solid rgba(100,100,200,0.3);
      }

      .game-over-draw {
        background: linear-gradient(135deg, rgba(150,150,150,0.15), rgba(150,150,150,0.05));
        color: #d0d0d0;
        border: 1px solid rgba(150,150,150,0.3);
      }

      @media (max-width: 600px) {
        .super-grid { gap: 6px; }
        .mac-body { padding: 12px; }
      }
    </style>

    <div class="chess-page">
      <div class="mac-window">
        <div class="mac-titlebar">
          <div class="mac-dot mac-dot-red"></div>
          <div class="mac-dot mac-dot-yellow"></div>
          <div class="mac-dot mac-dot-green"></div>
          <div class="mac-title">chess9 — 3×3 super-grid</div>
        </div>

        <div class="mac-body">
          <%
            {white_score, black_score} = score_bar(@game.status)
            game_over = Scoring.game_over?(@game.status)
          %>

          <div class="chess-header">
            <div class="game-title">CHESS9</div>
            <div style="display:flex;align-items:center;gap:12px;">
              <%= if @bot_thinking do %>
                <span class="bot-indicator">⟳ bot thinking…</span>
              <% end %>
              <button phx-click="new_game" class="new-game-btn">NEW GAME</button>
            </div>
          </div>

          <div class="score-bar">
            <span class="score-label">boards won:</span>
            <span class="score-white">
              <span class="score-pip" style="background:#f0f0f0;border:1px solid #aaa;"></span>
              white <%= white_score %>
            </span>
            <span class="score-black">
              <span class="score-pip" style="background:#222;"></span>
              black <%= black_score %>
            </span>
            <span style="flex:1"></span>
            <%= if not game_over do %>
              <span style="font-size:12px;color:#aac;">
                <%= if @game.to_move == :white, do: "your turn (white)", else: "black to move" %>
              </span>
            <% end %>
          </div>

          <%= if game_over do %>
            <%
              result = Scoring.winner(@game.status)
              {banner_class, banner_text} = case result do
                {:winner, :white} -> {"game-over-white", "WHITE WINS the match!"}
                {:winner, :black} -> {"game-over-black", "BLACK WINS the match!"}
                :draw             -> {"game-over-draw", "MATCH DRAWN"}
              end
            %>
            <div class={"game-over-banner #{banner_class}"}><%= banner_text %></div>
          <% end %>

          <div class="super-grid">
            <%= for board_row <- 0..2 do %>
              <%= for board_col <- 0..2 do %>
                <%
                  bi = board_index(board_col, board_row)
                  {origin_gx, origin_gy} = C.board_origin(bi)
                  board_status = elem(@game.status, bi)
                  frozen = board_frozen?(board_status)
                  status_label = board_status_label(board_status)
                %>
                <div class="board-cell">
                  <div class="board-grid">
                    <%= for local_rank <- 0..7 do %>
                      <%= for local_file <- 0..7 do %>
                        <%
                          gx = origin_gx + local_file
                          gy = origin_gy + local_rank
                          sq = {gx, gy}
                          piece = elem(@game.plane, C.cell_index(sq))
                          is_light = rem(local_file + local_rank, 2) == 0
                          bg = if is_light, do: "#F0D9B5", else: "#B58863"
                          is_selected = @selected == sq
                          is_legal = sq in @legal_targets
                          is_last_from = match?({^sq, _}, @last_move)
                          is_last_to   = match?({_, ^sq}, @last_move)
                        %>
                        <div
                          class="sq"
                          style={"background:#{bg};"}
                          phx-click="click_square"
                          phx-value-gx={gx}
                          phx-value-gy={gy}
                        >
                          <%= if is_selected do %>
                            <div class="sq-overlay overlay-selected"></div>
                          <% end %>
                          <%= if (is_last_from or is_last_to) and not is_selected do %>
                            <div class="sq-overlay overlay-last-move"></div>
                          <% end %>
                          <%= if is_legal do %>
                            <div class="sq-overlay overlay-legal">
                              <div class="legal-dot"></div>
                            </div>
                          <% end %>
                          <%= if piece != nil do %>
                            <span class={"sq-piece #{if piece.color == :white, do: "piece-white", else: "piece-black"}"}><%= piece_unicode(piece) %></span>
                          <% end %>
                        </div>
                      <% end %>
                    <% end %>
                  </div>

                  <%= if frozen and status_label != nil do %>
                    <div class="board-frozen-overlay">
                      <div class="frozen-label"><%= status_label %></div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>

          <div style="margin-top:16px;font-size:11px;color:#555;text-align:center;letter-spacing:0.05em;">
            9 boards · pieces may cross boundaries · win by checkmating on more boards
          </div>
        </div>
      </div>
    </div>

    <%= if @show_rules do %>
    <div
      id="rules-modal"
      style="position:fixed;inset:0;background:rgba(0,0,0,0.72);z-index:1000;display:flex;align-items:center;justify-content:center;padding:16px;"
      phx-click="close_rules"
    >
      <div
        style="background:#1a1a2e;border:1px solid #3a3a5c;border-radius:10px;max-width:480px;width:100%;padding:28px 24px;color:#d0d0e8;font-family:monospace;max-height:90vh;overflow-y:auto;"
        phx-click-away="close_rules"
      >
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
          <span style="font-size:18px;font-weight:bold;color:#e0e0f8;">Chess-9</span>
          <button
            phx-click="close_rules"
            style="background:none;border:1px solid #444;color:#999;cursor:pointer;padding:4px 10px;border-radius:4px;font-family:monospace;font-size:13px;"
          >play →</button>
        </div>

        <p style="color:#aaa;font-size:13px;line-height:1.6;margin-bottom:16px;">
          Nine standard chess boards arranged in a 3×3 grid. All nine games are live at the same time.
          You play white on every board. One move per turn, on any board you choose.
          Win by checkmating the opponent on more boards than they checkmate you.
        </p>

        <div style="font-size:12px;color:#c0c0e0;margin-bottom:12px;font-weight:bold;letter-spacing:0.08em;">CROSSING RULE</div>
        <p style="color:#aaa;font-size:13px;line-height:1.6;margin-bottom:16px;">
          A piece may slide across a board boundary only when one of its own kind has already been captured on the destination board.
          Losing your bishop on board 4 earns you a bishop-crossing credit for board 4.
          Credits are spent one per crossing.
          Kings never cross. Any pawn that crosses a boundary promotes on arrival.
        </p>

        <div style="font-size:12px;color:#c0c0e0;margin-bottom:12px;font-weight:bold;letter-spacing:0.08em;">GEOMETRY</div>
        <p style="color:#aaa;font-size:13px;line-height:1.6;margin-bottom:16px;">
          The nine boards form a continuous 24×24 plane. Board boundaries are invisible to piece geometry.
          A bishop on the edge of one board slides diagonally onto the next along the same diagonal,
          if it holds the credit to enter it.
          A piece on a neighboring board can give check across the seam if it holds enough credits.
        </p>

        <div style="font-size:12px;color:#c0c0e0;margin-bottom:12px;font-weight:bold;letter-spacing:0.08em;">DRAW CONDITIONS</div>
        <p style="color:#aaa;font-size:13px;line-height:1.6;margin-bottom:4px;">
          A board draws by the 50-move rule or insufficient material.
          A drawn board is frozen and cannot be fought over.
        </p>
      </div>
    </div>
    <% end %>
    """
  end
end
