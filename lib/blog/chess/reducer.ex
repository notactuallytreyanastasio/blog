defmodule Blog.Chess.Reducer do
  @moduledoc """
  State transition functions for the chess9 variant.

  ## Public API

  - `apply_move/2`      — validate move is in the legal set, then apply it
  - `apply_unchecked/2` — apply a move without legality checking (used by Legal)
  """

  alias Blog.Chess.{Legal, Check, Draws, Plane, Ledger, Move, Piece, State}
  alias Blog.Chess, as: C

  @fifty_move_plies C.fifty_move_plies()
  @max_ply C.max_ply()

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Applies `move` to `state` after confirming it is in the legal-move set.

  Returns `{:ok, new_state}` on success or `{:error, :not_in_legal_set}` when
  the move is not found in `Legal.legal_moves/1`.
  """
  @spec apply_move(State.t(), Move.t()) :: {:ok, State.t()} | {:error, C.move_error()}
  def apply_move(state, move) do
    legal = Legal.legal_moves(state)

    case Enum.find(legal, fn m -> moves_match?(m, move) end) do
      nil -> {:error, :not_in_legal_set}
      canonical -> {:ok, apply_unchecked(state, canonical)}
    end
  end

  @doc """
  Applies a move without legality checking.

  Used by `Legal` to simulate candidate moves for king-safety filtering.
  Do NOT call this from within `Legal.legal_moves/1`'s guard path through
  `apply_move/2` — that would recurse.

  Steps applied:
  1. Plane updates (move piece, castle rook, remove EP pawn, place promoted piece).
  2. Ledger: credit captured crossing pieces; spend crossing credit if applicable.
  3. En-passant square: set on double-pawn, clear otherwise.
  4. Toggle `to_move`.
  5. Increment `ply`.
  6. Tick halfmove clocks via `Draws.tick_clocks/3`.
  7. Recompute status for every non-frozen board.
  """
  @spec apply_unchecked(State.t(), Move.t()) :: State.t()
  def apply_unchecked(state, move) do
    mid = apply_core(state, move)

    # Step 7 — recompute status for non-frozen boards
    status = recompute_status(mid)

    %{mid | status: status}
  end

  @doc """
  Applies a move without legality checking and **without** recomputing board
  status. Used internally by `Legal` for king-safety simulations to break
  the mutual recursion between `legal_moves/1` and `apply_unchecked/2`.
  """
  @spec apply_unchecked_no_status(State.t(), Move.t()) :: State.t()
  def apply_unchecked_no_status(state, move), do: apply_core(state, move)

  # Shared core: apply all state transitions except status recomputation.
  defp apply_core(state, move) do
    # Step 1 — plane
    plane = apply_plane(state.plane, move)

    # Step 2 — ledger
    ledger = apply_ledger(state.ledger, move)

    # Step 3 — en passant square
    en_passant = next_en_passant(move)

    # Step 4 — toggle side to move
    to_move = C.opposite(state.to_move)

    # Step 5 — ply
    ply = state.ply + 1

    # Step 6 — tick clocks
    touched = touched_boards(move)
    clocks = Draws.tick_clocks(state.clocks, touched, move)

    %State{
      plane: plane,
      to_move: to_move,
      ledger: ledger,
      status: state.status,
      clocks: clocks,
      en_passant: en_passant,
      ply: ply
    }
  end

  # ---------------------------------------------------------------------------
  # Step 1 — Plane updates
  # ---------------------------------------------------------------------------

  defp apply_plane(plane, %Move{kind: :en_passant} = move) do
    plane
    |> Plane.with_piece(move.from, nil)
    |> Plane.with_piece(move.captured_square, nil)
    |> Plane.with_piece(move.to, moved_piece(move))
  end

  defp apply_plane(plane, %Move{kind: kind} = move) when kind in [:castle_kingside, :castle_queenside] do
    plane
    |> Plane.with_piece(move.from, nil)
    |> Plane.with_piece(move.to, moved_piece(move))
    |> Plane.with_piece(move.rook_from, nil)
    |> Plane.with_piece(move.rook_to, %Piece{type: :rook, color: move.piece.color, has_moved: true})
  end

  defp apply_plane(plane, %Move{kind: :promotion} = move) do
    plane
    |> Plane.with_piece(move.from, nil)
    |> Plane.with_piece(move.to, moved_piece(move))
  end

  defp apply_plane(plane, move) do
    # :normal, :double_pawn
    plane
    |> Plane.with_piece(move.from, nil)
    |> Plane.with_piece(move.to, moved_piece(move))
  end

  # The piece that lands on the destination square (with has_moved: true).
  defp moved_piece(%Move{kind: :promotion, piece: piece, promote_to: pt}) do
    %Piece{type: pt, color: piece.color, has_moved: true}
  end

  defp moved_piece(%Move{piece: piece}) do
    %Piece{type: piece.type, color: piece.color, has_moved: true}
  end

  # ---------------------------------------------------------------------------
  # Step 2 — Ledger
  # ---------------------------------------------------------------------------

  defp apply_ledger(ledger, %Move{kind: :en_passant} = move) do
    ledger
    |> maybe_credit(move.captured_square, move.captured)
    |> maybe_spend_crossing(move)
  end

  defp apply_ledger(ledger, move) do
    ledger
    |> maybe_credit(move.to, move.captured)
    |> maybe_spend_crossing(move)
  end

  # Grant a crossing credit when the captured piece is a crossing-eligible type.
  defp maybe_credit(ledger, sq, captured) when captured != nil do
    if C.Pieces.can_cross?(captured.type) do
      board = C.board_of(sq)
      Ledger.add_credit(ledger, board, captured.color, captured.type)
    else
      ledger
    end
  end

  defp maybe_credit(ledger, _sq, nil), do: ledger

  # Spend the crossing credit when a piece crosses a board boundary.
  defp maybe_spend_crossing(ledger, %Move{crossing: nil}), do: ledger

  defp maybe_spend_crossing(ledger, %Move{crossing: crossing, piece: piece}) do
    case Ledger.spend_crossing_credits(ledger, crossing, piece.color) do
      {:ok, updated} -> updated
      # Legal moves are validated to hold the credit; ignore the error defensively.
      {:error, :no_credit} -> ledger
    end
  end

  # ---------------------------------------------------------------------------
  # Step 3 — En passant square
  # ---------------------------------------------------------------------------

  defp next_en_passant(%Move{kind: :double_pawn, piece: piece, from: from}) do
    # The en-passant target square is one step forward from the pawn's origin.
    {_dx, fdy} = C.Pieces.forward_dir(piece.color)
    C.offset(from, 0, fdy)
  end

  defp next_en_passant(_move), do: nil

  # ---------------------------------------------------------------------------
  # Step 7 — Status recomputation
  # ---------------------------------------------------------------------------

  defp touched_boards(%Move{kind: :en_passant, from: from, to: to, captured_square: csq}) do
    MapSet.new([C.board_of(from), C.board_of(to), C.board_of(csq)])
    |> MapSet.to_list()
  end

  defp touched_boards(%Move{from: from, to: to}) do
    MapSet.new([C.board_of(from), C.board_of(to)])
    |> MapSet.to_list()
  end

  defp recompute_status(state) do
    # Compute legal moves ONCE for all boards rather than once per board.
    all_legal = Legal.legal_moves(state)

    Enum.reduce(0..8, state.status, fn board, acc ->
      current = elem(acc, board)

      if C.frozen?(current) do
        acc
      else
        new_status = board_status(state, board, all_legal)
        :erlang.setelement(board + 1, acc, new_status)
      end
    end)
  end

  defp board_status(state, board, all_legal) do
    clock = elem(state.clocks, board)
    to_move = state.to_move

    legal_on_board = Enum.filter(all_legal, fn m -> C.board_of(m.from) == board end)

    in_check = Check.in_check?(state, to_move, board)
    no_legal = legal_on_board == []

    cond do
      in_check and no_legal ->
        {:checkmate, C.opposite(to_move), to_move}

      Draws.insufficient_material?(state.plane, board) ->
        {:draw, :insufficient_material}

      clock >= @fifty_move_plies ->
        {:draw, :fifty_move}

      state.ply >= @max_ply ->
        {:draw, :fifty_move}

      no_legal ->
        # Stalemate
        :stalemate

      in_check ->
        {:check, to_move}

      true ->
        :active
    end
  end

  # ---------------------------------------------------------------------------
  # Move identity matching
  # ---------------------------------------------------------------------------

  defp moves_match?(%Move{} = a, %Move{} = b) do
    a.kind == b.kind and
      a.from == b.from and
      a.to == b.to and
      (a.kind != :promotion or a.promote_to == b.promote_to)
  end
end
