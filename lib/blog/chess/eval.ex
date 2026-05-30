defmodule Blog.Chess.Eval do
  @moduledoc """
  Static evaluation for the chess9 variant.

  ## Functions

  - `evaluate/2`   — heuristic evaluation from `color`'s perspective
  - `leaf_score/2` — terminal-node score (game-over values) or `evaluate/2`
  """

  alias Blog.Chess.{Scoring, MoveGen, Plane, Pieces, Ledger}
  alias Blog.Chess, as: C

  # ---------------------------------------------------------------------------
  # Tuning constants (mirror chess9 TypeScript reference engine)
  # ---------------------------------------------------------------------------

  @board_win_score 50.0
  @cross_option 6.0
  @cross_check 70.0
  @cross_capture_div 8.0
  @credit_bonus 8.0
  @credit_types [:pawn, :knight, :bishop, :rook, :queen]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Heuristic evaluation from `color`'s point of view.

  Returns a float representing the estimated advantage for `color`:

      board_score + material + cross_threat_bonus

  where:

  - `board_score`        — 50.0 per board won by `color` minus 50.0 per board
                           won by the opponent
  - `material`           — total piece value for `color` minus opponent's total
  - `cross_threat_bonus` — credits held that enable crossing moves, plus bonuses
                           for playable crossing moves (especially those that
                           deliver check or capture on entry)
  """
  @spec evaluate(C.State.t(), C.color()) :: float()
  def evaluate(state, color) do
    opp = C.opposite(color)

    board_score =
      Scoring.boards_won(state.status, color) * @board_win_score -
        Scoring.boards_won(state.status, opp) * @board_win_score

    material =
      Scoring.material_score(state.plane, color) -
        Scoring.material_score(state.plane, opp)

    cross_threat = cross_threat_bonus(state, color) - cross_threat_bonus(state, opp)

    board_score + material + cross_threat
  end

  @doc """
  Leaf node score for negamax / alpha-beta search.

  Returns `+10000.0` when all boards are frozen and `color` is the winner,
  `-10000.0` when the opponent has won, `0.0` for a draw, and
  `evaluate/2` when the game is still in progress.
  """
  @spec leaf_score(C.State.t(), C.color()) :: float()
  def leaf_score(state, color) do
    if Scoring.game_over?(state.status) do
      case Scoring.winner(state.status) do
        {:winner, ^color} -> 10_000.0
        {:winner, _opp} -> -10_000.0
        :draw -> 0.0
      end
    else
      evaluate(state, color)
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns the cross-threat bonus for `color`:
  #   - @credit_bonus  per credit held in the ledger (latent optionality)
  #   - @cross_option  per actually-playable crossing move
  #   - captured-piece share  when the crossing move wins material on entry
  #   - @cross_check   when the crossing move delivers check on the destination board
  defp cross_threat_bonus(state, color) do
    credit_score = ledger_credit_score(state.ledger, color)

    moves = MoveGen.pseudo_legal_moves(%{state | to_move: color})
    move_score = crossing_move_score(state, moves, color)

    credit_score + move_score
  end

  # Sum @credit_bonus for every credit held by `color` across all boards and
  # piece types.
  defp ledger_credit_score(ledger, color) do
    for board <- 0..8,
        type <- @credit_types,
        count = Ledger.credit_count(ledger, board, color, type),
        count > 0,
        reduce: 0.0 do
      acc -> acc + @credit_bonus * count
    end
  end

  # Score crossing moves from the pseudo-legal move list.
  defp crossing_move_score(state, moves, color) do
    Enum.reduce(moves, 0.0, fn move, acc ->
      if move.crossing == nil do
        acc
      else
        base = @cross_option

        capture_bonus =
          if move.captured != nil do
            Pieces.value(move.captured.type) / @cross_capture_div
          else
            0.0
          end

        check_bonus =
          if crossing_checks?(state.plane, move, color) do
            @cross_check
          else
            0.0
          end

        acc + base + capture_bonus + check_bonus
      end
    end)
  end

  # Returns true when the crossing move lands a piece that attacks the enemy
  # king on the destination board.
  defp crossing_checks?(plane, move, color) do
    opp = C.opposite(color)
    dest_board = C.board_of(move.to)

    # Simulate the move: remove from source, place on destination.
    moved_piece = %{move.piece | has_moved: true}

    sim =
      plane
      |> Plane.with_piece(move.from, nil)
      |> Plane.with_piece(move.to, moved_piece)

    # Find the opponent king on the destination board.
    {ox, oy} = C.board_origin(dest_board)

    king_sq =
      Enum.find_value(0..7, fn rank ->
        Enum.find_value(0..7, fn file ->
          sq = {ox + file, oy + rank}

          case Plane.piece_at(sim, sq) do
            %{type: :king, color: ^opp} -> sq
            _ -> nil
          end
        end)
      end)

    king_sq != nil and Blog.Chess.Attack.attacked_by?(sim, king_sq, color)
  end
end
