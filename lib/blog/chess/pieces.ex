defmodule Blog.Chess.Pieces do
  @moduledoc """
  Pure helper functions about piece kinds — values, movement properties,
  and board-layout constants for the chess9 variant.

  These functions are stateless and work on piece types and colors directly;
  they do not touch the plane or game state.
  """

  alias Blog.Chess, as: C
  alias Blog.Chess.Piece

  # ---------------------------------------------------------------------------
  # Material values
  # ---------------------------------------------------------------------------

  @doc """
  Returns the material value of a piece type, in units of pawns.

  Values follow common engine conventions:

  | type   | value |
  |--------|-------|
  | queen  |   9.0 |
  | rook   |   5.0 |
  | bishop |  3.25 |
  | knight |   3.0 |
  | pawn   |   1.0 |
  | king   |   0.0 |

      iex> Blog.Chess.Pieces.value(:queen)
      9.0

      iex> Blog.Chess.Pieces.value(:pawn)
      1.0

      iex> Blog.Chess.Pieces.value(:king)
      0.0
  """
  @spec value(C.piece_type()) :: float()
  def value(:queen), do: 9.0
  def value(:rook), do: 5.0
  def value(:bishop), do: 3.25
  def value(:knight), do: 3.0
  def value(:pawn), do: 1.0
  def value(:king), do: 0.0

  # ---------------------------------------------------------------------------
  # Board-crossing eligibility
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` if pieces of this type may cross board boundaries.

  All piece types except `:king` may cross.

      iex> Blog.Chess.Pieces.can_cross?(:queen)
      true

      iex> Blog.Chess.Pieces.can_cross?(:rook)
      true

      iex> Blog.Chess.Pieces.can_cross?(:bishop)
      true

      iex> Blog.Chess.Pieces.can_cross?(:knight)
      true

      iex> Blog.Chess.Pieces.can_cross?(:pawn)
      true

      iex> Blog.Chess.Pieces.can_cross?(:king)
      false
  """
  @spec can_cross?(C.piece_type()) :: boolean()
  def can_cross?(:king), do: false
  def can_cross?(_), do: true

  # ---------------------------------------------------------------------------
  # Pawn direction
  # ---------------------------------------------------------------------------

  @doc """
  Returns the {dx, dy} forward direction for a pawn of the given color in
  global-coordinate space.

  White pawns advance toward smaller gy (i.e. `{0, -1}`); black pawns advance
  toward larger gy (i.e. `{0, 1}`).

      iex> Blog.Chess.Pieces.forward_dir(:white)
      {0, -1}

      iex> Blog.Chess.Pieces.forward_dir(:black)
      {0, 1}
  """
  @spec forward_dir(C.color()) :: {0, -1} | {0, 1}
  def forward_dir(:white), do: {0, -1}
  def forward_dir(:black), do: {0, 1}

  # ---------------------------------------------------------------------------
  # Pawn starting rank (local coordinates)
  # ---------------------------------------------------------------------------

  @doc """
  Returns the local rank (0..7) on `board_index` from which a pawn of
  `color` may make a double-push.

  Local rank is `gy - origin_gy` where `origin_gy = div(board_index, 3) * 8`.

  White pawns start on local rank 6 (second rank from the bottom of each
  board); black pawns start on local rank 1 (second rank from the top).

      iex> Blog.Chess.Pieces.starting_rank_gx_gy(:white, 0)
      6

      iex> Blog.Chess.Pieces.starting_rank_gx_gy(:black, 0)
      1

      iex> Blog.Chess.Pieces.starting_rank_gx_gy(:white, 4)
      6

      iex> Blog.Chess.Pieces.starting_rank_gx_gy(:black, 8)
      1
  """
  @spec starting_rank_gx_gy(C.color(), C.board_index()) :: 0..7
  def starting_rank_gx_gy(:white, _board_index), do: 6
  def starting_rank_gx_gy(:black, _board_index), do: 1

  # ---------------------------------------------------------------------------
  # Back rank piece order
  # ---------------------------------------------------------------------------

  @doc """
  Returns the ordered list of piece types for the back rank of any board,
  from file a (local x = 0) to file h (local x = 7).

  This is the standard chess back-rank setup:
  `[:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]`

      iex> Blog.Chess.Pieces.back_rank()
      [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]
  """
  @spec back_rank() :: [C.piece_type()]
  def back_rank, do: [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

  # ---------------------------------------------------------------------------
  # Rendering
  # ---------------------------------------------------------------------------

  @doc """
  Returns an ASCII character string for rendering a piece.

  White pieces use uppercase letters; black pieces use lowercase letters.

  | piece  | white | black |
  |--------|-------|-------|
  | king   | "K"   | "k"   |
  | queen  | "Q"   | "q"   |
  | rook   | "R"   | "r"   |
  | bishop | "B"   | "b"   |
  | knight | "N"   | "n"   |
  | pawn   | "P"   | "p"   |

      iex> Blog.Chess.Pieces.piece_char(%Blog.Chess.Piece{type: :king, color: :white, has_moved: false})
      "K"

      iex> Blog.Chess.Pieces.piece_char(%Blog.Chess.Piece{type: :pawn, color: :black, has_moved: false})
      "p"

      iex> Blog.Chess.Pieces.piece_char(%Blog.Chess.Piece{type: :knight, color: :white, has_moved: false})
      "N"
  """
  @spec piece_char(Piece.t()) :: String.t()
  def piece_char(%Piece{type: :king, color: :white}), do: "K"
  def piece_char(%Piece{type: :queen, color: :white}), do: "Q"
  def piece_char(%Piece{type: :rook, color: :white}), do: "R"
  def piece_char(%Piece{type: :bishop, color: :white}), do: "B"
  def piece_char(%Piece{type: :knight, color: :white}), do: "N"
  def piece_char(%Piece{type: :pawn, color: :white}), do: "P"
  def piece_char(%Piece{type: :king, color: :black}), do: "k"
  def piece_char(%Piece{type: :queen, color: :black}), do: "q"
  def piece_char(%Piece{type: :rook, color: :black}), do: "r"
  def piece_char(%Piece{type: :bishop, color: :black}), do: "b"
  def piece_char(%Piece{type: :knight, color: :black}), do: "n"
  def piece_char(%Piece{type: :pawn, color: :black}), do: "p"
end
