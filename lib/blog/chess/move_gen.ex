defmodule Blog.Chess.MoveGen do
  @moduledoc """
  Pseudo-legal move generation for the chess9 variant.

  Generates all moves for `state.to_move` without filtering for leaving the
  king in check (that is the caller's responsibility). Pieces on frozen boards
  are skipped entirely.

  ## Entry point

      MoveGen.pseudo_legal_moves(state) -> [Move.t()]

  Castling, en passant, promotion, double-pawn pushes, and board-boundary
  crossings are all handled here.
  """

  alias Blog.Chess.{Rays, Attack, Plane, Piece, Move, Crossing, Pieces, Ledger}
  alias Blog.Chess, as: C

  @promotions [:queen, :rook, :bishop, :knight]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Returns all pseudo-legal moves for `state.to_move`.

  Pieces on frozen boards (boards whose status satisfies `C.frozen?/1`) are
  skipped. King-safety filtering is NOT applied.
  """
  @spec pseudo_legal_moves(C.State.t()) :: [Move.t()]
  def pseudo_legal_moves(state) do
    color = state.to_move

    Plane.pieces_of(state.plane, color)
    |> Enum.flat_map(fn {sq, piece} ->
      board = C.board_of(sq)
      board_status = elem(state.status, board)

      if C.frozen?(board_status) do
        []
      else
        moves_for(state, sq, piece)
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # Per-piece dispatch
  # ---------------------------------------------------------------------------

  defp moves_for(state, sq, %Piece{type: :pawn} = piece),
    do: pawn_moves(state, sq, piece)

  defp moves_for(state, sq, %Piece{type: :knight} = piece),
    do: knight_moves(state, sq, piece)

  defp moves_for(state, sq, %Piece{type: :bishop} = piece),
    do: sliding_moves(state, sq, piece, Rays.bishop_dirs())

  defp moves_for(state, sq, %Piece{type: :rook} = piece),
    do: sliding_moves(state, sq, piece, Rays.rook_dirs())

  defp moves_for(state, sq, %Piece{type: :queen} = piece),
    do: sliding_moves(state, sq, piece, Rays.queen_dirs())

  defp moves_for(state, sq, %Piece{type: :king} = piece),
    do: king_moves(state, sq, piece)

  # ---------------------------------------------------------------------------
  # Pawn moves
  # ---------------------------------------------------------------------------

  @doc false
  @spec pawn_moves(C.State.t(), C.global_square(), Piece.t()) :: [Move.t()]
  def pawn_moves(state, from, piece) do
    color = piece.color
    {_dx, fdy} = Pieces.forward_dir(color)
    from_board = C.board_of(from)
    {_ox, oy} = C.board_origin(from_board)
    {_fx, fy} = from

    acc = []

    # ---- Forward push -------------------------------------------------------
    acc =
      case C.offset(from, 0, fdy) do
        nil ->
          acc

        one ->
          if C.board_of(one) != from_board do
            # Forward push would cross a boundary — pawns cannot push forward across boards
            acc
          else
            if Plane.piece_at(state.plane, one) == nil do
              if promotion_square?(color, one) do
                # Promotion via forward push
                Enum.reduce(@promotions, acc, fn pt, a ->
                  [%Move{
                     kind: :promotion,
                     from: from,
                     to: one,
                     piece: piece,
                     captured: nil,
                     crossing: nil,
                     promote_to: pt
                   }
                   | a]
                end)
              else
                acc = [
                  %Move{kind: :normal, from: from, to: one, piece: piece, captured: nil, crossing: nil}
                  | acc
                ]

                # Double push from home rank
                local_rank = fy - oy

                if not piece.has_moved and local_rank == Pieces.starting_rank_gx_gy(color, from_board) do
                  case C.offset(from, 0, 2 * fdy) do
                    nil ->
                      acc

                    two ->
                      if C.board_of(two) == from_board and Plane.piece_at(state.plane, two) == nil do
                        [%Move{kind: :double_pawn, from: from, to: two, piece: piece, captured: nil, crossing: nil} | acc]
                      else
                        acc
                      end
                  end
                else
                  acc
                end
              end
            else
              acc
            end
          end
      end

    # ---- Diagonal captures (and en passant) ---------------------------------
    Enum.reduce([-1, 1], acc, fn dx, a ->
      case C.offset(from, dx, fdy) do
        nil ->
          a

        to ->
          to_board = C.board_of(to)

          if frozen_board?(state, to_board) do
            a
          else
            crossing = resolve_crossing(state, color, piece, from, to)

            case crossing do
              :no_crossing_allowed ->
                a

              crossing_val ->
                occ = Plane.piece_at(state.plane, to)

                cond do
                  # Normal diagonal capture
                  occ != nil and occ.color != color ->
                    if promotion_square?(color, to) or crosses_board_boundary?(from, to) do
                      Enum.reduce(@promotions, a, fn pt, aa ->
                        [%Move{
                           kind: :promotion,
                           from: from,
                           to: to,
                           piece: piece,
                           captured: occ,
                           crossing: crossing_val,
                           promote_to: pt
                         }
                         | aa]
                      end)
                    else
                      [%Move{kind: :normal, from: from, to: to, piece: piece, captured: occ, crossing: crossing_val} | a]
                    end

                  # En passant
                  occ == nil and state.en_passant == to ->
                    captured_sq = C.offset(to, 0, -fdy)

                    case captured_sq do
                      nil ->
                        a

                      csq ->
                        captured_pawn = Plane.piece_at(state.plane, csq)

                        if captured_pawn != nil and captured_pawn.type == :pawn and
                             captured_pawn.color != color do
                          [%Move{
                             kind: :en_passant,
                             from: from,
                             to: to,
                             piece: piece,
                             captured: captured_pawn,
                             crossing: crossing_val,
                             captured_square: csq
                           }
                           | a]
                        else
                          a
                        end
                    end

                  true ->
                    a
                end
            end
          end
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # Sliding moves
  # ---------------------------------------------------------------------------

  @doc false
  @spec sliding_moves(C.State.t(), C.global_square(), Piece.t(), [{integer(), integer()}]) ::
          [Move.t()]
  def sliding_moves(state, from, piece, directions) do
    color = piece.color

    Enum.flat_map(directions, fn dir ->
      Rays.ray(from, dir, state.plane)
      |> Enum.reduce_while([], fn sq, acc ->
        to_board = C.board_of(sq)

        if frozen_board?(state, to_board) do
          {:halt, acc}
        else
          occ = Plane.piece_at(state.plane, sq)

          if occ != nil and occ.color == color do
            # Own piece blocks — stop ray in this direction
            {:halt, acc}
          else
            crossing = resolve_crossing(state, color, piece, from, sq)

            case crossing do
              :no_crossing_allowed ->
                # Cannot cross (king or no credit) — stop ray
                {:halt, acc}

              crossing_val ->
                move = %Move{
                  kind: :normal,
                  from: from,
                  to: sq,
                  piece: piece,
                  captured: occ,
                  crossing: crossing_val
                }

                if occ != nil do
                  # Capture — include the square but stop the ray
                  {:halt, [move | acc]}
                else
                  {:cont, [move | acc]}
                end
            end
          end
        end
      end)
    end)
  end

  # ---------------------------------------------------------------------------
  # Knight moves
  # ---------------------------------------------------------------------------

  @knight_deltas [
    {2, 1},
    {2, -1},
    {-2, 1},
    {-2, -1},
    {1, 2},
    {1, -2},
    {-1, 2},
    {-1, -2}
  ]

  @doc false
  @spec knight_moves(C.State.t(), C.global_square(), Piece.t()) :: [Move.t()]
  def knight_moves(state, from, piece) do
    color = piece.color

    Enum.flat_map(@knight_deltas, fn {dx, dy} ->
      case C.offset(from, dx, dy) do
        nil ->
          []

        to ->
          to_board = C.board_of(to)

          if frozen_board?(state, to_board) do
            []
          else
            occ = Plane.piece_at(state.plane, to)

            if occ != nil and occ.color == color do
              []
            else
              crossing = resolve_crossing(state, color, piece, from, to)

              case crossing do
                :no_crossing_allowed ->
                  []

                crossing_val ->
                  [%Move{kind: :normal, from: from, to: to, piece: piece, captured: occ, crossing: crossing_val}]
              end
            end
          end
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # King moves (no crossing)
  # ---------------------------------------------------------------------------

  @adjacent_deltas [
    {1, 0},
    {-1, 0},
    {0, 1},
    {0, -1},
    {1, 1},
    {1, -1},
    {-1, 1},
    {-1, -1}
  ]

  @doc false
  @spec king_moves(C.State.t(), C.global_square(), Piece.t()) :: [Move.t()]
  def king_moves(state, from, piece) do
    color = piece.color
    from_board = C.board_of(from)

    normal_moves =
      Enum.flat_map(@adjacent_deltas, fn {dx, dy} ->
        case C.offset(from, dx, dy) do
          nil ->
            []

          to ->
            # Kings cannot cross board boundaries
            if C.board_of(to) != from_board do
              []
            else
              occ = Plane.piece_at(state.plane, to)

              if occ != nil and occ.color == color do
                []
              else
                [%Move{kind: :normal, from: from, to: to, piece: piece, captured: occ, crossing: nil}]
              end
            end
        end
      end)

    castle_ms = castle_moves(state, from, piece)
    normal_moves ++ castle_ms
  end

  # ---------------------------------------------------------------------------
  # Castling
  # ---------------------------------------------------------------------------

  @king_home_file 4
  @white_home_rank 7
  @black_home_rank 0

  @doc false
  @spec castle_moves(C.State.t(), C.global_square(), Piece.t()) :: [Move.t()]
  def castle_moves(state, from, piece) do
    if piece.has_moved do
      []
    else
      from_board = C.board_of(from)
      {ox, oy} = C.board_origin(from_board)
      {gx, gy} = from
      local_file = gx - ox
      local_rank = gy - oy

      home_rank =
        case piece.color do
          :white -> @white_home_rank
          :black -> @black_home_rank
        end

      if local_file != @king_home_file or local_rank != home_rank do
        []
      else
        enemy = C.opposite(piece.color)

        # Cannot castle out of check
        if Attack.attacked_by?(state.plane, from, enemy) do
          []
        else
          at = fn file -> C.offset({ox, oy}, file, local_rank) end
          empty? = fn sq -> sq != nil and Plane.piece_at(state.plane, sq) == nil end
          safe? = fn sq -> sq != nil and not Attack.attacked_by?(state.plane, sq, enemy) end

          corner_rook? = fn sq ->
            if sq == nil do
              false
            else
              p = Plane.piece_at(state.plane, sq)
              p != nil and p.type == :rook and p.color == piece.color and not p.has_moved
            end
          end

          kingside =
            with f when not is_nil(f) <- at.(5),
                 g when not is_nil(g) <- at.(6),
                 h_rook when not is_nil(h_rook) <- at.(7),
                 true <- corner_rook?.(h_rook),
                 true <- empty?.(f),
                 true <- empty?.(g),
                 true <- safe?.(f),
                 true <- safe?.(g) do
              [%Move{
                 kind: :castle_kingside,
                 from: from,
                 to: g,
                 piece: piece,
                 captured: nil,
                 crossing: nil,
                 rook_from: h_rook,
                 rook_to: f
               }]
            else
              _ -> []
            end

          queenside =
            with d when not is_nil(d) <- at.(3),
                 c when not is_nil(c) <- at.(2),
                 b when not is_nil(b) <- at.(1),
                 a_rook when not is_nil(a_rook) <- at.(0),
                 true <- corner_rook?.(a_rook),
                 true <- empty?.(d),
                 true <- empty?.(c),
                 true <- empty?.(b),
                 true <- safe?.(d),
                 true <- safe?.(c) do
              [%Move{
                 kind: :castle_queenside,
                 from: from,
                 to: c,
                 piece: piece,
                 captured: nil,
                 crossing: nil,
                 rook_from: a_rook,
                 rook_to: d
               }]
            else
              _ -> []
            end

          kingside ++ queenside
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns true if the board at `board_index` is frozen (terminal state).
  defp frozen_board?(state, board_index) do
    C.frozen?(elem(state.status, board_index))
  end

  # Resolves whether the move from->to crosses a board boundary and whether
  # that crossing is permitted.
  #
  # Returns:
  #   - nil               if both squares are on the same board
  #   - %Crossing{}       if crossing is allowed
  #   - :no_crossing_allowed  if the crossing is forbidden (king, or no credit)
  defp resolve_crossing(state, color, piece, from, to) do
    from_board = C.board_of(from)
    to_board = C.board_of(to)

    if from_board == to_board do
      nil
    else
      if not Pieces.can_cross?(piece.type) do
        :no_crossing_allowed
      else
        if Ledger.has_credit?(state.ledger, to_board, color, piece.type) do
          %Crossing{from_board: from_board, to_board: to_board, credit_type: piece.type}
        else
          :no_crossing_allowed
        end
      end
    end
  end

  # Returns true if the destination square is the opponent's back rank (local
  # rank 0 for white moving, local rank 7 for black moving).
  defp promotion_square?(color, {_gx, gy}) do
    case color do
      :white ->
        # White advances toward lower gy; promotion at local rank 0 of any board
        rem(gy, 8) == 0

      :black ->
        # Black advances toward higher gy; promotion at local rank 7 of any board
        rem(gy, 8) == 7
    end
  end

  # Returns true if the move from->to crosses a board boundary (i.e. the
  # boards are different). Used to trigger promotion on cross-boundary pawn moves.
  defp crosses_board_boundary?(from, to) do
    C.board_of(from) != C.board_of(to)
  end
end
