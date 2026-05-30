defmodule Blog.Chess.Attack do
  @moduledoc """
  Attack and threat detection for the chess9 24x24 plane.

  ## Functions

  - `attacked_by?/3`     — is a square attacked by any piece of a given color?
  - `boards_entered/2`   — which board indices does a path cross?
  - `threatens?/6`       — can an attacker on a given square reach a target board?
  """

  alias Blog.Chess.{Rays, Ledger, Plane, Piece, Pieces}
  alias Blog.Chess, as: C

  @knight_deltas [
    {1, 2},
    {2, 1},
    {-1, 2},
    {-2, 1},
    {1, -2},
    {2, -1},
    {-1, -2},
    {-2, -1}
  ]

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

  # ---------------------------------------------------------------------------
  # attacked_by?/3
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` if any piece of `by_color` attacks `sq` on the same board.

  Sliding pieces (rook, bishop, queen) walk rays clipped at the board
  boundary of `sq`. Knights and kings check their fixed offset squares.
  Pawns check the two diagonal squares behind them in the attack direction.

  This function is used for in-check detection and should only consider pieces
  physically on the same board as `sq`.
  """
  @spec attacked_by?(C.plane(), C.global_square(), C.color()) :: boolean()
  def attacked_by?(plane, sq, by_color) do
    board = C.board_of(sq)

    # Sliding: bishop directions (bishop/queen)
    bishop_attacked =
      Enum.any?(Rays.bishop_dirs(), fn dir ->
        occ = clipped_ray_first(plane, sq, dir, board)
        occ != nil and occ.color == by_color and occ.type in [:bishop, :queen]
      end)

    # Sliding: rook directions (rook/queen)
    rook_attacked =
      not bishop_attacked and
        Enum.any?(Rays.rook_dirs(), fn dir ->
          occ = clipped_ray_first(plane, sq, dir, board)
          occ != nil and occ.color == by_color and occ.type in [:rook, :queen]
        end)

    # Knights
    knight_attacked =
      not (bishop_attacked or rook_attacked) and
        Enum.any?(@knight_deltas, fn {dx, dy} ->
          case C.offset(sq, dx, dy) do
            nil -> false
            t -> C.board_of(t) == board and enemy?(plane, t, by_color, :knight)
          end
        end)

    # King
    king_attacked =
      not (bishop_attacked or rook_attacked or knight_attacked) and
        Enum.any?(@adjacent_deltas, fn {dx, dy} ->
          case C.offset(sq, dx, dy) do
            nil -> false
            t -> C.board_of(t) == board and enemy?(plane, t, by_color, :king)
          end
        end)

    # Pawns
    pawn_attacked =
      not (bishop_attacked or rook_attacked or knight_attacked or king_attacked) and
        pawn_attacks?(plane, sq, by_color, board)

    bishop_attacked or rook_attacked or knight_attacked or king_attacked or pawn_attacked
  end

  # ---------------------------------------------------------------------------
  # boards_entered/2
  # ---------------------------------------------------------------------------

  @doc """
  Returns the distinct board indices entered along the path from `from` to
  `to`, excluding the board of `from` itself.

  Walks step by step using `C.offset/3`, collecting boards when
  `C.board_of/1` changes. The direction is derived from the sign of
  `to_gx - from_gx` and `to_gy - from_gy`.
  """
  @spec boards_entered(C.global_square(), C.global_square()) :: [C.board_index()]
  def boards_entered(from, to) do
    {fx, fy} = from
    {tx, ty} = to

    dx = sign(tx - fx)
    dy = sign(ty - fy)

    do_boards_entered(from, to, dx, dy, C.board_of(from), [])
    |> Enum.reverse()
    |> Enum.uniq()
  end

  # ---------------------------------------------------------------------------
  # threatens?/6
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` if the piece of `by_color` and `piece_type` at `attacker_sq`
  can threaten squares on `target_board`.

  Rules:
  - Same board: always `true`
  - King: `false` if any boards were entered
  - Cross-board: must have a credit for each board in `entered_boards`
    (including `target_board`)
  """
  @spec threatens?(
          Ledger.t(),
          C.board_index(),
          C.global_square(),
          C.color(),
          C.piece_type(),
          [C.board_index()]
        ) :: boolean()
  def threatens?(ledger, target_board, attacker_sq, by_color, piece_type, entered_boards) do
    attacker_board = C.board_of(attacker_sq)

    cond do
      attacker_board == target_board ->
        true

      piece_type == :king ->
        false

      true ->
        Enum.all?(entered_boards, fn board ->
          Ledger.has_credit?(ledger, board, by_color, piece_type)
        end)
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Walk a ray in direction {dx, dy} from `from`, clipped to `board`.
  # Returns the first piece encountered, or nil if none.
  defp clipped_ray_first(plane, from, {dx, dy}, board) do
    case C.offset(from, dx, dy) do
      nil ->
        nil

      next ->
        if C.board_of(next) != board do
          nil
        else
          case Plane.piece_at(plane, next) do
            nil -> clipped_ray_first(plane, next, {dx, dy}, board)
            piece -> piece
          end
        end
    end
  end

  # Check whether a pawn of by_color attacks sq from behind.
  # A white pawn attacks diagonally upward (toward lower gy), so it sits at
  # {gx±1, gy+1} relative to the target. A black pawn sits at {gx±1, gy-1}.
  defp pawn_attacks?(plane, sq, by_color, board) do
    {_, fdy} = Pieces.forward_dir(by_color)

    Enum.any?([-1, 1], fn dx ->
      case C.offset(sq, dx, -fdy) do
        nil -> false
        t -> C.board_of(t) == board and enemy?(plane, t, by_color, :pawn)
      end
    end)
  end

  defp enemy?(plane, sq, color, type) do
    case Plane.piece_at(plane, sq) do
      %Piece{color: ^color, type: ^type} -> true
      _ -> false
    end
  end

  defp sign(n) when n > 0, do: 1
  defp sign(n) when n < 0, do: -1
  defp sign(0), do: 0

  defp do_boards_entered(cur, to, _dx, _dy, _prev_board, acc) when cur == to, do: acc

  defp do_boards_entered(cur, to, dx, dy, prev_board, acc) do
    case C.offset(cur, dx, dy) do
      nil ->
        acc

      next ->
        next_board = C.board_of(next)

        new_acc =
          if next_board != prev_board do
            [next_board | acc]
          else
            acc
          end

        do_boards_entered(next, to, dx, dy, next_board, new_acc)
    end
  end
end
