defmodule Blog.Chess.Legal do
  @moduledoc """
  Legal move filtering for the chess9 variant.

  Wraps `MoveGen.pseudo_legal_moves/1` with king-safety filtering by
  simulating each candidate move via `Blog.Chess.Reducer.apply_unchecked/2`
  and discarding moves that leave the mover's own king in check.

  ## Functions

  - `legal_moves/1`              — all legal moves for `state.to_move`
  - `legal_moves_for_square/2`   — legal moves originating from a given square
  - `find_legal_move/3`          — look up or diagnose a specific from/to pair
  - `diagnose/3`                 — return a specific `move_error()` for a from/to pair
  """

  alias Blog.Chess.{MoveGen, Check, Plane, Attack, Move, Crossing, Piece, Pieces, Ledger}
  alias Blog.Chess, as: C

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Returns all fully-legal moves for `state.to_move`.

  Generates pseudo-legal moves then discards any that leave the mover's king
  in check (on any touched board) after `Blog.Chess.Reducer.apply_unchecked/2`.
  """
  @spec legal_moves(C.State.t()) :: [Move.t()]
  def legal_moves(state) do
    MoveGen.pseudo_legal_moves(state)
    |> Enum.filter(fn move -> not leaves_own_king_in_check?(state, move) end)
  end

  @doc """
  Returns all legal moves whose source square is `sq`.

  Only generates and tests pseudo-legal moves for the piece at `sq`, rather
  than all pieces on all 9 boards. This is ~100x faster than filtering
  `legal_moves/1` and is safe to call on every UI click.
  """
  @spec legal_moves_for_square(C.State.t(), C.global_square()) :: [Move.t()]
  def legal_moves_for_square(state, sq) do
    piece = elem(state.plane, C.cell_index(sq))

    cond do
      piece == nil -> []
      piece.color != state.to_move -> []
      C.frozen?(elem(state.status, C.board_of(sq))) -> []
      true ->
        MoveGen.piece_pseudo_legal_moves(state, sq, piece)
        |> Enum.reject(&leaves_own_king_in_check?(state, &1))
    end
  end

  @doc """
  Finds the legal move from `from` to `to` in the legal set, or diagnoses the
  reason it is illegal.

  Returns `{:ok, move}` when a unique legal move is found, or
  `{:error, move_error()}` otherwise.
  """
  @spec find_legal_move(C.State.t(), C.global_square(), C.global_square()) ::
          {:ok, Move.t()} | {:error, C.move_error()}
  def find_legal_move(state, from, to) do
    matches =
      legal_moves(state)
      |> Enum.filter(fn m -> m.from == from and m.to == to end)

    case matches do
      [move | _] -> {:ok, move}
      [] -> {:error, diagnose(state, from, to)}
    end
  end

  @doc """
  Diagnoses why the move from `from` to `to` is not in the legal set.

  Checks errors in priority order and returns the first matching reason:

  1. `:empty_source`           — no piece at `from`
  2. `:wrong_color`            — piece at `from` is not `state.to_move`
  3. `{:frozen_board, board}`  — the source board is in a terminal state
  4. `:king_cannot_cross`      — move crosses a boundary but piece is a king
  5. `:two_boundaries`         — move crosses more than one board boundary
  6. `{:no_credit, crossing}`  — piece type has no credit on the destination board
  7. `:path_blocked`           — a piece blocks the move's path
  8. `:illegal_geometry`       — move does not match any legal piece pattern
  9. `{:leaves_king_in_check, board}` — move leaves own king in check
  10. `:not_in_legal_set`      — fallthrough: not in the computed legal set
  """
  @spec diagnose(C.State.t(), C.global_square(), C.global_square()) :: C.move_error()
  def diagnose(state, from, to) do
    cond do
      Plane.piece_at(state.plane, from) == nil ->
        :empty_source

      Plane.piece_at(state.plane, from).color != state.to_move ->
        :wrong_color

      frozen_source?(state, from) ->
        {:frozen_board, C.board_of(from)}

      king_crossing?(state, from, to) ->
        :king_cannot_cross

      two_boundaries?(from, to) ->
        :two_boundaries

      no_credit_crossing?(state, from, to) ->
        {:no_credit, build_crossing(from, to, Plane.piece_at(state.plane, from))}

      path_blocked?(state, from, to) ->
        :path_blocked

      illegal_geometry?(state, from, to) ->
        :illegal_geometry

      leaves_king_in_check_by_pseudo?(state, from, to) ->
        board = touched_board_in_check(state, from, to)
        {:leaves_king_in_check, board}

      true ->
        :not_in_legal_set
    end
  end

  # ---------------------------------------------------------------------------
  @doc """
  Legal moves that could resolve check on `board`: pieces on that board plus
  any cross-board defenders that hold a credit to enter it. Much cheaper than
  `legal_moves/1` (no full-board sweep) and only called when the board is in check.
  """
  @spec legal_moves_for_board(C.State.t(), C.board_index()) :: [Move.t()]
  def legal_moves_for_board(state, board) do
    color = state.to_move

    # Pieces already on the checked board — can escape, block, or capture.
    on_board =
      Plane.board_pieces(state.plane, color, board)
      |> Enum.flat_map(fn {sq, piece} -> MoveGen.piece_pseudo_legal_moves(state, sq, piece) end)

    # Cross-board defenders: pieces on other boards that hold a credit for this board.
    cross_board =
      if credit_exists_for_board?(state.ledger, board, color) do
        Plane.pieces_of(state.plane, color)
        |> Enum.reject(fn {sq, _} -> C.board_of(sq) == board end)
        |> Enum.flat_map(fn {sq, piece} -> MoveGen.piece_pseudo_legal_moves(state, sq, piece) end)
        |> Enum.filter(fn m -> m.crossing != nil and m.crossing.to_board == board end)
      else
        []
      end

    (on_board ++ cross_board)
    |> Enum.reject(&leaves_own_king_in_check?(state, &1))
  end

  defp credit_exists_for_board?(ledger, board, color) do
    Enum.any?([:pawn, :knight, :bishop, :rook, :queen], fn type ->
      Ledger.has_credit?(ledger, board, color, type)
    end)
  end

  # Private helpers — king safety
  # ---------------------------------------------------------------------------

  # Boards whose occupancy changes and thus where the mover's king safety may change.
  defp touched_boards(%Move{from: from, to: to, kind: :en_passant, captured_square: csq}) do
    MapSet.new([C.board_of(from), C.board_of(to), C.board_of(csq)])
    |> MapSet.to_list()
  end

  defp touched_boards(%Move{from: from, to: to}) do
    MapSet.new([C.board_of(from), C.board_of(to)])
    |> MapSet.to_list()
  end

  # Returns true when applying `move` leaves the mover's king in check on any
  # touched board.
  #
  # Uses `apply_unchecked_no_status/2` (rather than `apply_unchecked/2`) to
  # avoid the mutual recursion:
  #   legal_moves -> leaves_own_king_in_check? -> apply_unchecked
  #              -> recompute_status -> board_status -> legal_moves ...
  defp leaves_own_king_in_check?(state, move) do
    mover = move.piece.color
    next = Blog.Chess.Reducer.apply_unchecked_no_status(state, move)

    Enum.any?(touched_boards(move), fn board ->
      Check.in_check?(next, mover, board)
    end)
  end

  # ---------------------------------------------------------------------------
  # Private helpers — diagnose sub-checks
  # ---------------------------------------------------------------------------

  defp frozen_source?(state, from) do
    board = C.board_of(from)
    C.frozen?(elem(state.status, board))
  end

  defp king_crossing?(state, from, to) do
    piece = Plane.piece_at(state.plane, from)
    piece != nil and piece.type == :king and C.board_of(from) != C.board_of(to)
  end

  defp two_boundaries?(from, to) do
    boards = Attack.boards_entered(from, to)
    # boards_entered returns all boards entered *after* from; if from and to are
    # on different boards there is at least one entry.  Two boundaries means two
    # distinct new boards are entered.
    length(Enum.uniq(boards)) >= 2
  end

  defp no_credit_crossing?(state, from, to) do
    piece = Plane.piece_at(state.plane, from)

    if piece == nil or not Pieces.can_cross?(piece.type) do
      false
    else
      from_board = C.board_of(from)
      to_board = C.board_of(to)

      from_board != to_board and
        not Ledger.has_credit?(state.ledger, to_board, piece.color, piece.type)
    end
  end

  defp build_crossing(from, to, piece) do
    %Crossing{
      from_board: C.board_of(from),
      to_board: C.board_of(to),
      credit_type: piece.type
    }
  end

  # Returns true if the move is geometrically impossible for the piece type.
  # We approximate by checking whether any pseudo-legal move from `from` lands
  # on `to` (ignoring credit / king-safety issues).
  defp path_blocked?(state, from, to) do
    piece = Plane.piece_at(state.plane, from)

    if piece == nil do
      false
    else
      # Build a pseudo-legal set for just this square (using the full state
      # so rays stop at real pieces), then check if any move reaches `to`.
      # If the geometry matches but no pseudo-legal move reaches `to`, the
      # path must be blocked.
      has_geometry = has_any_geometry?(piece, from, to)

      if not has_geometry do
        false
      else
        pseudo =
          MoveGen.pseudo_legal_moves(state)
          |> Enum.filter(fn m -> m.from == from end)

        not Enum.any?(pseudo, fn m -> m.to == to end)
      end
    end
  end

  # Returns true when no pseudo-legal move from `from` reaches `to` AND the
  # move geometry does not match the piece type at all.
  defp illegal_geometry?(state, from, to) do
    piece = Plane.piece_at(state.plane, from)

    if piece == nil do
      false
    else
      not has_any_geometry?(piece, from, to)
    end
  end

  # Checks raw move geometry (ignoring board state) — does the delta from
  # `from` to `to` match what `piece` can produce?
  defp has_any_geometry?(%Piece{type: type}, from, to) do
    {fx, fy} = from
    {tx, ty} = to
    dx = tx - fx
    dy = ty - fy
    adx = abs(dx)
    ady = abs(dy)

    case type do
      :king ->
        adx <= 1 and ady <= 1 and (adx + ady) > 0

      :knight ->
        (adx == 2 and ady == 1) or (adx == 1 and ady == 2)

      :bishop ->
        adx == ady and adx > 0

      :rook ->
        (dx == 0 or dy == 0) and (adx + ady) > 0

      :queen ->
        ((dx == 0 or dy == 0) or adx == ady) and (adx + ady) > 0

      :pawn ->
        # Forward push (1 or 2 squares) or diagonal capture — permissive check
        (adx == 0 and ady in [1, 2]) or (adx == 1 and ady == 1)
    end
  end

  # Returns true if a pseudo-legal move from `from` to `to` exists but it
  # leaves the mover's king in check.
  defp leaves_king_in_check_by_pseudo?(state, from, to) do
    pseudo =
      MoveGen.pseudo_legal_moves(state)
      |> Enum.filter(fn m -> m.from == from and m.to == to end)

    Enum.any?(pseudo, fn move -> leaves_own_king_in_check?(state, move) end)
  end

  # Returns the first board where the king would be left in check.
  defp touched_board_in_check(state, from, to) do
    mover = state.to_move

    pseudo =
      MoveGen.pseudo_legal_moves(state)
      |> Enum.filter(fn m -> m.from == from and m.to == to end)

    case pseudo do
      [move | _] ->
        next = Blog.Chess.Reducer.apply_unchecked_no_status(state, move)

        Enum.find(touched_boards(move), fn board ->
          Check.in_check?(next, mover, board)
        end) || C.board_of(from)

      [] ->
        C.board_of(from)
    end
  end
end
