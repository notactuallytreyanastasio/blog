defmodule Blog.Chess.Draws do
  @moduledoc """
  Draw-condition helpers for the chess9 variant.

  ## Functions

  - `insufficient_material?/2` — conservative test for dead positions on a single board
  - `tick_clocks/3`            — advance or reset per-board halfmove clocks after a move
  """

  alias Blog.Chess.{Plane, Piece}
  alias Blog.Chess, as: C

  # ---------------------------------------------------------------------------
  # Insufficient material
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` if the given board contains only material that cannot
  force checkmate: bare kings, or a lone king vs. king + one minor
  (bishop or knight).

  Anything richer — a pawn, rook, queen, or two or more minors — is treated
  as sufficient, so this function never declares a draw while a forced mate
  remains possible.

      iex> alias Blog.Chess.{Plane, Piece, Draws}
      iex> p = Plane.empty_plane()
      iex> p = Plane.with_pieces(p, [{{4, 7}, Piece.new(:king, :white)}, {{4, 0}, Piece.new(:king, :black)}])
      iex> Draws.insufficient_material?(p, 0)
      true

      iex> alias Blog.Chess.{Plane, Piece, Draws}
      iex> p = Plane.empty_plane()
      iex> p = Plane.with_pieces(p, [
      ...>   {{4, 7}, Piece.new(:king, :white)},
      ...>   {{4, 0}, Piece.new(:king, :black)},
      ...>   {{3, 0}, Piece.new(:bishop, :black)}
      ...> ])
      iex> Draws.insufficient_material?(p, 0)
      true

      iex> alias Blog.Chess.{Plane, Piece, Draws}
      iex> p = Plane.empty_plane()
      iex> p = Plane.with_pieces(p, [
      ...>   {{4, 7}, Piece.new(:king, :white)},
      ...>   {{4, 0}, Piece.new(:king, :black)},
      ...>   {{3, 7}, Piece.new(:pawn, :white)}
      ...> ])
      iex> Draws.insufficient_material?(p, 0)
      false

      iex> alias Blog.Chess.{Plane, Piece, Draws}
      iex> p = Plane.empty_plane()
      iex> p = Plane.with_pieces(p, [
      ...>   {{4, 7}, Piece.new(:king, :white)},
      ...>   {{4, 0}, Piece.new(:king, :black)},
      ...>   {{2, 0}, Piece.new(:knight, :black)},
      ...>   {{3, 0}, Piece.new(:bishop, :black)}
      ...> ])
      iex> Draws.insufficient_material?(p, 0)
      false
  """
  @spec insufficient_material?(C.plane(), C.board_index()) :: boolean()
  def insufficient_material?(plane, board) do
    {ox, oy} = C.board_origin(board)

    result =
      Enum.reduce_while(0..7, {false, false, 0}, fn r, {wk, bk, minors} ->
        row_result =
          Enum.reduce_while(0..7, {wk, bk, minors}, fn f, {wk_acc, bk_acc, minors_acc} ->
            sq = C.offset({ox, oy}, f, r)

            case sq && Plane.piece_at(plane, sq) do
              nil ->
                {:cont, {wk_acc, bk_acc, minors_acc}}

              %Piece{type: :king, color: :white} ->
                {:cont, {true, bk_acc, minors_acc}}

              %Piece{type: :king, color: :black} ->
                {:cont, {wk_acc, true, minors_acc}}

              %Piece{type: type} when type in [:bishop, :knight] ->
                {:cont, {wk_acc, bk_acc, minors_acc + 1}}

              _other ->
                # pawn, rook, or queen — mate is possible
                {:halt, :sufficient}
            end
          end)

        case row_result do
          :sufficient -> {:halt, :sufficient}
          acc -> {:cont, acc}
        end
      end)

    case result do
      :sufficient -> false
      {white_king, black_king, minor_count} -> white_king and black_king and minor_count <= 1
    end
  end

  # ---------------------------------------------------------------------------
  # Halfmove clocks
  # ---------------------------------------------------------------------------

  @doc """
  Advances the halfmove clocks for every board in `touched` after a move.

  Each touched board's clock is reset to `0` if the move was a pawn move or
  a capture; otherwise it is incremented by `1`.

  Boards not in `touched` are left unchanged.

  The clocks tuple is a 9-element tuple indexed by `board_index` (see
  `Blog.Chess.State.t/0`). Absent indices are treated as `0`.

      iex> alias Blog.Chess.{Draws, Move, Piece}
      iex> clocks = List.to_tuple(List.duplicate(0, 9))
      iex> move = %Move{kind: :normal, from: {4, 6}, to: {4, 5}, piece: Piece.new(:rook, :white)}
      iex> clocks2 = Draws.tick_clocks(clocks, [0], move)
      iex> elem(clocks2, 0)
      1

      iex> alias Blog.Chess.{Draws, Move, Piece}
      iex> clocks = List.to_tuple(List.duplicate(5, 9))
      iex> move = %Move{kind: :normal, from: {4, 6}, to: {4, 5}, piece: Piece.new(:pawn, :white)}
      iex> clocks2 = Draws.tick_clocks(clocks, [0], move)
      iex> elem(clocks2, 0)
      0

      iex> alias Blog.Chess.{Draws, Move, Piece}
      iex> clocks = List.to_tuple(List.duplicate(5, 9))
      iex> captured = Piece.new(:knight, :black)
      iex> move = %Move{kind: :normal, from: {4, 6}, to: {4, 5}, piece: Piece.new(:rook, :white), captured: captured}
      iex> clocks2 = Draws.tick_clocks(clocks, [0], move)
      iex> elem(clocks2, 0)
      0
  """
  @spec tick_clocks(tuple(), [C.board_index()], C.Move.t()) :: tuple()
  def tick_clocks(clocks, touched, move) do
    reset? = move.piece.type == :pawn or move.captured != nil

    Enum.reduce(touched, clocks, fn board, acc ->
      new_val = if reset?, do: 0, else: elem(acc, board) + 1
      :erlang.setelement(board + 1, acc, new_val)
    end)
  end
end
