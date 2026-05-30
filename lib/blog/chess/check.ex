defmodule Blog.Chess.Check do
  @moduledoc """
  King-safety and check detection for the chess9 variant.

  ## Functions

  - `in_check?/3`   — is `color`'s king on a specific board currently in check?
  - `any_check?/2`  — is `color` in check on any non-frozen board?
  """

  alias Blog.Chess.{Attack, Plane}
  alias Blog.Chess, as: C

  @doc """
  Returns `true` if `color`'s king exists on `board` and is attacked by the
  opposite color.

  Scans all 64 squares of `board` for a king of `color`. If no king is found,
  returns `false`. Otherwise delegates to `Attack.attacked_by?/3`.
  """
  @spec in_check?(C.State.t(), C.color(), C.board_index()) :: boolean()
  def in_check?(state, color, board) do
    case king_square(state.plane, board, color) do
      nil -> false
      sq -> Attack.attacked_by?(state.plane, sq, C.opposite(color))
    end
  end

  @doc """
  Returns `true` if `color`'s king is in check on any non-frozen board.

  Iterates all 9 board indices; boards with a frozen status (checkmate,
  stalemate, draw) are skipped.
  """
  @spec any_check?(C.State.t(), C.color()) :: boolean()
  def any_check?(state, color) do
    Enum.any?(0..8, fn board ->
      board_status = elem(state.status, board)
      not C.frozen?(board_status) and in_check?(state, color, board)
    end)
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Scan all 64 squares on `board` and return the global square of `color`'s
  # king, or nil if not present.
  defp king_square(plane, board, color) do
    {ox, oy} = C.board_origin(board)

    Enum.find_value(0..7, fn rank ->
      Enum.find_value(0..7, fn file ->
        sq = {ox + file, oy + rank}

        case Plane.piece_at(plane, sq) do
          %{type: :king, color: ^color} -> sq
          _ -> nil
        end
      end)
    end)
  end
end
