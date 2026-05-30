defmodule Blog.Chess.Types do
  @moduledoc """
  Shared type definitions for the chess9 variant — a 9-board (3x3 super-grid)
  chess game played on a 24x24 continuous coordinate plane.

  The plane uses {gx, gy} tuples as keys into a sparse map. Coordinates are
  0-based: gx and gy each range over 0..23, covering all nine 8x8 boards.

  ## Board layout

      board 0 | board 1 | board 2     gx: 0..7  | 8..15 | 16..23
      --------+---------+--------     gy: 0..7  | 0..7  | 0..7
      board 3 | board 4 | board 5          8..15 | 8..15 | 8..15
      --------+---------+--------         16..23 |16..23 |16..23
      board 6 | board 7 | board 8

  White pieces start at the bottom of each board (larger gy) and advance
  toward smaller gy. Black pieces start at the top (smaller gy).
  """

  # ---------------------------------------------------------------------------
  # Scalar coordinate types
  # ---------------------------------------------------------------------------

  @typedoc "Global x-coordinate on the 24x24 plane (0..23)"
  @type gx :: 0..23

  @typedoc "Global y-coordinate on the 24x24 plane (0..23)"
  @type gy :: 0..23

  @typedoc "Index of one of the 9 boards in the super-grid (0..8)"
  @type board_index :: 0..8

  # ---------------------------------------------------------------------------
  # Piece types and color
  # ---------------------------------------------------------------------------

  @typedoc "The color of a chess piece"
  @type color :: :white | :black

  @typedoc "The type of a chess piece"
  @type piece_type :: :king | :queen | :rook | :bishop | :knight | :pawn

  # ---------------------------------------------------------------------------
  # Coordinate compound types
  # ---------------------------------------------------------------------------

  @typedoc "A square on the global 24x24 plane, represented as {gx, gy}"
  @type global_square :: {gx(), gy()}

  # ---------------------------------------------------------------------------
  # Piece map type
  # ---------------------------------------------------------------------------

  @typedoc """
  A piece on the board. `has_moved` tracks whether the piece has ever moved,
  used for castling rights and pawn double-step eligibility.
  """
  @type piece :: %{type: piece_type(), color: color(), has_moved: boolean()}

  # ---------------------------------------------------------------------------
  # Board crossing / ledger
  # ---------------------------------------------------------------------------

  @typedoc """
  A boundary crossing event — a piece moving from one board to another.
  `credit_type` is the type of the crossing piece (kings cannot cross).
  """
  @type crossing :: %{
          from_board: board_index(),
          to_board: board_index(),
          credit_type: piece_type()
        }

  @typedoc """
  Credit ledger: tracks how many times each piece type of each color has
  crossed into each board. Key is {board_index, color, piece_type}; absent
  keys mean zero credits.
  """
  @type ledger :: %{optional({board_index(), color(), piece_type()}) => non_neg_integer()}

  # ---------------------------------------------------------------------------
  # Plane
  # ---------------------------------------------------------------------------

  @typedoc """
  Sparse map of all pieces on the 24x24 plane. Empty squares are absent from
  the map. At most 576 entries (one per cell).
  """
  @type plane :: %{optional(global_square()) => piece()}

  # ---------------------------------------------------------------------------
  # Move
  # ---------------------------------------------------------------------------

  @typedoc "The kind/variant of a move"
  @type move_kind :: :normal | :castle_kingside | :castle_queenside

  @typedoc """
  A fully-described chess move. Fields:

  - `:kind`      — variant tag
  - `:from`      — source square (global)
  - `:to`        — destination square (global)
  - `:piece`     — the moving piece
  - `:captured`  — captured piece, or nil if no capture
  - `:crossings` — list of board crossings made by this move (0 or 1 for most
                   moves; castling generates no crossings)
  """
  @type move :: %{
          kind: move_kind(),
          from: global_square(),
          to: global_square(),
          piece: piece(),
          captured: piece() | nil,
          crossings: [crossing()]
        }

  # ---------------------------------------------------------------------------
  # Board status
  # ---------------------------------------------------------------------------

  @typedoc """
  The status of an individual board within the super-grid.

  - `:active`    — game in progress on this board
  - `{:checkmate, winner}` — the given color has won this board
  - `{:draw, reason}` — this board is drawn

  Draw reasons:
  - `:fifty_move`            — fifty-move rule triggered
  - `:insufficient_material` — neither side can force checkmate
  - `:max_ply`               — maximum ply depth reached
  """
  @type board_status ::
          :active
          | {:checkmate, color()}
          | {:draw, :fifty_move | :insufficient_material | :max_ply}

  # ---------------------------------------------------------------------------
  # Clocks
  # ---------------------------------------------------------------------------

  @typedoc """
  Per-board halfmove clocks, used for the fifty-move rule. Key is board_index;
  absent keys default to 0.
  """
  @type board_clocks :: %{optional(board_index()) => non_neg_integer()}

  # ---------------------------------------------------------------------------
  # Game state
  # ---------------------------------------------------------------------------

  @typedoc """
  The complete, immutable state of a chess9 game.

  - `:plane`           — all pieces on the 24x24 plane
  - `:ledger`          — board-crossing credit counts
  - `:to_move`         — whose turn it is
  - `:status`          — list of 9 board statuses (index = board_index)
  - `:halfmove_clocks` — per-board fifty-move counters
  - `:ply`             — total half-moves played so far
  """
  @type game_state :: %{
          plane: plane(),
          ledger: ledger(),
          to_move: color(),
          status: [board_status()],
          halfmove_clocks: board_clocks(),
          ply: non_neg_integer()
        }

  # ---------------------------------------------------------------------------
  # Move errors
  # ---------------------------------------------------------------------------

  @typedoc """
  Reasons a move may be illegal.

  - `:king_cannot_cross`        — kings are not permitted to cross board boundaries
  - `:two_boundaries`           — a single move cannot cross two board boundaries
  - `:no_credit`                — the crossing piece type has no credit on the target board
  - `:path_blocked`             — a piece blocks the move's path
  - `:illegal_geometry`         — the move does not match any legal piece movement pattern
  - `:not_in_legal_set`         — the move is not in the pre-computed legal-move set
  - `{:leaves_king_in_check, board_index}` — the move would leave own king in check
  """
  @type move_error ::
          :king_cannot_cross
          | :two_boundaries
          | :no_credit
          | :path_blocked
          | :illegal_geometry
          | :not_in_legal_set
          | {:leaves_king_in_check, board_index()}

  # ---------------------------------------------------------------------------
  # Helper functions
  # ---------------------------------------------------------------------------

  @doc """
  Returns the opposite color.

      iex> Blog.Chess.Types.opposite(:white)
      :black

      iex> Blog.Chess.Types.opposite(:black)
      :white
  """
  @spec opposite(color()) :: color()
  def opposite(:white), do: :black
  def opposite(:black), do: :white

  @doc """
  Returns the board index (0..8) containing the given global coordinate.

  The board index is determined by which 8x8 cell of the 3x3 super-grid the
  square falls in: `by * 3 + bx` where `bx = div(gx, 8)` and `by = div(gy, 8)`.

      iex> Blog.Chess.Types.board_of(0, 0)
      0

      iex> Blog.Chess.Types.board_of(8, 0)
      1

      iex> Blog.Chess.Types.board_of(16, 8)
      5

      iex> Blog.Chess.Types.board_of(23, 23)
      8
  """
  @spec board_of(gx(), gy()) :: board_index()
  def board_of(gx, gy), do: div(gy, 8) * 3 + div(gx, 8)

  @doc """
  Returns the top-left (minimum gx, minimum gy) global square of the given
  board index.

      iex> Blog.Chess.Types.board_origin(0)
      {0, 0}

      iex> Blog.Chess.Types.board_origin(4)
      {8, 8}

      iex> Blog.Chess.Types.board_origin(8)
      {16, 16}
  """
  @spec board_origin(board_index()) :: global_square()
  def board_origin(board_index),
    do: {rem(board_index, 3) * 8, div(board_index, 3) * 8}
end
