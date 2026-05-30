defmodule Blog.Chess do
  @moduledoc """
  Root module for the chess9 variant — a 9-board (3x3 super-grid) chess game
  played on a 24x24 continuous coordinate plane.

  Defines all shared types, constants, and coordinate helper functions used
  throughout the chess9 subsystem.

  ## Board layout

      board 0 | board 1 | board 2     gx: 0..7  | 8..15 | 16..23
      --------+---------+--------     gy: 0..7  | 0..7  | 0..7
      board 3 | board 4 | board 5          8..15 | 8..15 | 8..15
      --------+---------+--------         16..23 |16..23 |16..23
      board 6 | board 7 | board 8

  ## Plane representation

  The plane is a 576-element Erlang tuple. Empty cells hold `nil`; occupied
  cells hold a `Blog.Chess.Piece.t()`. Access is O(1) via `elem/2` (1-indexed
  in Erlang; this module uses 0-based `cell_index/1` and adjusts internally).
  """

  # ---------------------------------------------------------------------------
  # Constants
  # ---------------------------------------------------------------------------

  @board_size 8
  @grid 3
  @plane_size 24
  @squares 576
  @boards 9
  @fifty_move_plies 100
  @max_ply 600

  def board_size, do: @board_size
  def grid, do: @grid
  def plane_size, do: @plane_size
  def squares, do: @squares
  def boards, do: @boards
  def fifty_move_plies, do: @fifty_move_plies
  def max_ply, do: @max_ply

  # ---------------------------------------------------------------------------
  # Types
  # ---------------------------------------------------------------------------

  @typedoc "The color of a chess piece"
  @type color :: :white | :black

  @typedoc "The type of a chess piece"
  @type piece_type :: :pawn | :knight | :bishop | :rook | :queen | :king

  @typedoc "Piece types that may cross board boundaries (all except king)"
  @type crossing_type :: :pawn | :knight | :bishop | :rook | :queen

  @typedoc "Piece types a pawn may promote to"
  @type promotion_type :: :knight | :bishop | :rook | :queen

  @typedoc "Index of one of the 9 boards in the super-grid (0..8)"
  @type board_index :: 0..8

  @typedoc "Global x-coordinate on the 24x24 plane (0..23)"
  @type gx :: 0..23

  @typedoc "Global y-coordinate on the 24x24 plane (0..23)"
  @type gy :: 0..23

  @typedoc "A square on the global 24x24 plane, represented as {gx, gy}"
  @type global_square :: {gx(), gy()}

  @typedoc "0-based flat index into the 576-element plane tuple (gy*24 + gx)"
  @type cell_index :: 0..575

  @typedoc """
  The status of an individual board within the super-grid.

  - `:active`                           — game in progress
  - `{:check, color}`                   — `color` is in check (transient, not frozen)
  - `{:checkmate, winner, loser}`       — `winner` has checkmated `loser` (frozen)
  - `:stalemate`                        — stalemate (frozen, unscored)
  - `{:draw, reason}`                   — drawn game (frozen, unscored)

  Draw reasons: `:fifty_move` | `:insufficient_material`
  """
  @type board_status ::
          :active
          | {:check, color()}
          | {:checkmate, color(), color()}
          | :stalemate
          | {:draw, :fifty_move | :insufficient_material}

  @typedoc """
  Reasons a move may be rejected.

  - `:not_your_turn`             — piece belongs to the player not to move
  - `:empty_source`              — no piece at the source square
  - `:wrong_color`               — piece color does not match the moving player
  - `{:frozen_board, board}`     — the board is in a terminal state
  - `:illegal_geometry`          — move shape does not match any legal piece pattern
  - `:path_blocked`              — an intervening piece blocks the move
  - `:two_boundaries`            — a single move cannot cross two board boundaries
  - `{:no_credit, crossing}`     — the crossing piece type has no credit on the target board
  - `:king_cannot_cross`         — kings are not permitted to cross board boundaries
  - `{:leaves_king_in_check, b}` — the move would leave the moving player's king in check
  - `:not_in_legal_set`          — move is not in the pre-computed legal-move set
  """
  @type move_error ::
          :not_your_turn
          | :empty_source
          | :wrong_color
          | {:frozen_board, board_index()}
          | :illegal_geometry
          | :path_blocked
          | :two_boundaries
          | {:no_credit, Blog.Chess.Crossing.t()}
          | :king_cannot_cross
          | {:leaves_king_in_check, board_index()}
          | :not_in_legal_set

  @typedoc """
  The board plane: a 576-element tuple indexed by `cell_index()`.
  Each element is either `nil` (empty) or a `Blog.Chess.Piece.t()`.
  Use `elem(plane, cell_index({gx, gy}))` for O(1) reads and
  `:erlang.setelement(cell_index({gx, gy}) + 1, plane, piece)` for O(1)
  copy-on-write updates (Erlang tuple indices are 1-based).
  """
  @type plane :: tuple()

  # ---------------------------------------------------------------------------
  # Helper functions
  # ---------------------------------------------------------------------------

  @doc """
  Returns the opposite color.

      iex> Blog.Chess.opposite(:white)
      :black

      iex> Blog.Chess.opposite(:black)
      :white
  """
  @spec opposite(color()) :: color()
  def opposite(:white), do: :black
  def opposite(:black), do: :white

  @doc """
  Returns the board index (0..8) containing the given global square.

  Board index is `div(gy, 8) * 3 + div(gx, 8)`.

      iex> Blog.Chess.board_of({0, 0})
      0

      iex> Blog.Chess.board_of({8, 0})
      1

      iex> Blog.Chess.board_of({16, 8})
      5

      iex> Blog.Chess.board_of({23, 23})
      8
  """
  @spec board_of(global_square()) :: board_index()
  def board_of({gx, gy}), do: div(gy, 8) * 3 + div(gx, 8)

  @doc """
  Returns the top-left (minimum gx, minimum gy) global square of the given board.

      iex> Blog.Chess.board_origin(0)
      {0, 0}

      iex> Blog.Chess.board_origin(4)
      {8, 8}

      iex> Blog.Chess.board_origin(8)
      {16, 16}
  """
  @spec board_origin(board_index()) :: global_square()
  def board_origin(bi), do: {rem(bi, 3) * 8, div(bi, 3) * 8}

  @doc """
  Converts a global square to its 0-based flat index into the 576-element plane tuple.

  `cell_index({gx, gy}) == gy * 24 + gx`

      iex> Blog.Chess.cell_index({0, 0})
      0

      iex> Blog.Chess.cell_index({23, 23})
      575

      iex> Blog.Chess.cell_index({1, 0})
      1

      iex> Blog.Chess.cell_index({0, 1})
      24
  """
  @spec cell_index(global_square()) :: cell_index()
  def cell_index({gx, gy}), do: gy * 24 + gx

  @doc """
  Converts a 0-based flat cell index back to a global square.

  Inverse of `cell_index/1`.

      iex> Blog.Chess.square_at(0)
      {0, 0}

      iex> Blog.Chess.square_at(575)
      {23, 23}

      iex> Blog.Chess.square_at(24)
      {0, 1}
  """
  @spec square_at(cell_index()) :: global_square()
  def square_at(idx), do: {rem(idx, 24), div(idx, 24)}

  @doc """
  Returns `true` if `{gx, gy}` is within the 24x24 plane.

      iex> Blog.Chess.in_bounds?(0, 0)
      true

      iex> Blog.Chess.in_bounds?(23, 23)
      true

      iex> Blog.Chess.in_bounds?(24, 0)
      false

      iex> Blog.Chess.in_bounds?(0, -1)
      false
  """
  @spec in_bounds?(integer(), integer()) :: boolean()
  def in_bounds?(gx, gy), do: gx in 0..23 and gy in 0..23

  @doc """
  Applies an offset `{dx, dy}` to a global square, returning the resulting
  square or `nil` if the result is out of bounds.

      iex> Blog.Chess.offset({0, 0}, 1, 1)
      {1, 1}

      iex> Blog.Chess.offset({23, 23}, 1, 0)
      nil

      iex> Blog.Chess.offset({0, 0}, -1, 0)
      nil
  """
  @spec offset(global_square(), integer(), integer()) :: global_square() | nil
  def offset({gx, gy}, dx, dy) do
    nx = gx + dx
    ny = gy + dy
    if in_bounds?(nx, ny), do: {nx, ny}, else: nil
  end

  @doc """
  Returns `true` if the given board status is a terminal (frozen) state.

  Active and check statuses are not frozen; checkmate, stalemate, and draw are.

      iex> Blog.Chess.frozen?(:active)
      false

      iex> Blog.Chess.frozen?({:check, :white})
      false

      iex> Blog.Chess.frozen?({:checkmate, :white, :black})
      true

      iex> Blog.Chess.frozen?(:stalemate)
      true

      iex> Blog.Chess.frozen?({:draw, :fifty_move})
      true
  """
  @spec frozen?(board_status()) :: boolean()
  def frozen?(:active), do: false
  def frozen?({:check, _}), do: false
  def frozen?(_), do: true
end

defmodule Blog.Chess.Piece do
  @moduledoc """
  A chess piece with type, color, and movement history.

  `has_moved` tracks whether the piece has ever moved, which controls
  castling eligibility (king and rook) and pawn double-step availability.
  """

  @enforce_keys [:type, :color]
  defstruct [:type, :color, has_moved: false]

  @type t :: %__MODULE__{
          type: Blog.Chess.piece_type(),
          color: Blog.Chess.color(),
          has_moved: boolean()
        }

  @doc """
  Constructs a new piece.

      iex> Blog.Chess.Piece.new(:king, :white)
      %Blog.Chess.Piece{type: :king, color: :white, has_moved: false}

      iex> Blog.Chess.Piece.new(:pawn, :black, true)
      %Blog.Chess.Piece{type: :pawn, color: :black, has_moved: true}
  """
  @spec new(Blog.Chess.piece_type(), Blog.Chess.color(), boolean()) :: t()
  def new(type, color, has_moved \\ false),
    do: %__MODULE__{type: type, color: color, has_moved: has_moved}
end

defmodule Blog.Chess.Crossing do
  @moduledoc """
  A board-boundary crossing event.

  When a piece moves from one 8x8 board to an adjacent one it generates a
  crossing. The crossing records which board was left, which was entered, and
  the piece type (kings are prohibited from crossing).

  The `credit_type` field matches `Blog.Chess.crossing_type()`: any piece
  type except `:king`.
  """

  @enforce_keys [:from_board, :to_board, :credit_type]
  defstruct [:from_board, :to_board, :credit_type]

  @type t :: %__MODULE__{
          from_board: Blog.Chess.board_index(),
          to_board: Blog.Chess.board_index(),
          credit_type: Blog.Chess.crossing_type()
        }
end

defmodule Blog.Chess.Move do
  @moduledoc """
  A fully-described chess move in global coordinate space.

  The `kind` field is the discriminant:

  - `:normal`            — standard piece move or capture
  - `:double_pawn`       — pawn advances two squares from starting rank
  - `:en_passant`        — pawn captures en passant
  - `:promotion`         — pawn reaches the back rank and promotes
  - `:castle_kingside`   — king-side castling
  - `:castle_queenside`  — queen-side castling

  Optional fields are `nil` unless relevant to the move kind:

  - `captured`        — piece removed (nil for non-captures; set separately for en passant via `captured_square`)
  - `crossing`        — non-nil when exactly one board boundary is crossed
  - `promote_to`      — promotion target type (`:promotion` moves only)
  - `rook_from`       — rook's source square (castling moves only)
  - `rook_to`         — rook's destination square (castling moves only)
  - `captured_square` — square of the captured pawn (`:en_passant` only, differs from `to`)
  """

  @enforce_keys [:kind, :from, :to, :piece]
  defstruct [
    :kind,
    :from,
    :to,
    :piece,
    captured: nil,
    crossing: nil,
    promote_to: nil,
    rook_from: nil,
    rook_to: nil,
    captured_square: nil
  ]

  @type t :: %__MODULE__{
          kind:
            :normal
            | :double_pawn
            | :en_passant
            | :promotion
            | :castle_kingside
            | :castle_queenside,
          from: Blog.Chess.global_square(),
          to: Blog.Chess.global_square(),
          piece: Blog.Chess.Piece.t(),
          captured: Blog.Chess.Piece.t() | nil,
          crossing: Blog.Chess.Crossing.t() | nil,
          promote_to: Blog.Chess.promotion_type() | nil,
          rook_from: Blog.Chess.global_square() | nil,
          rook_to: Blog.Chess.global_square() | nil,
          captured_square: Blog.Chess.global_square() | nil
        }
end

defmodule Blog.Chess.State do
  @moduledoc """
  The complete, immutable state of a chess9 game.

  ## Fields

  - `plane`      — 576-element tuple; element at `cell_index({gx,gy})` is
                   a `Blog.Chess.Piece.t()` or `nil`
  - `to_move`    — whose turn it is
  - `ledger`     — capture-credit ledger: `%{{board_index, color, piece_type} => count}`
  - `status`     — 9-element tuple of `board_status()`, indexed by board index
  - `clocks`     — 9-element tuple of non-negative integers (half-move clocks
                   since last pawn move or capture, per board)
  - `en_passant` — the pawn-capturable square for this ply only, or `nil`
  - `ply`        — total half-moves played (also encodes turn parity)
  """

  @enforce_keys [:plane, :to_move, :ledger, :status, :clocks]
  defstruct [:plane, :to_move, :ledger, :status, :clocks, en_passant: nil, ply: 0]

  @type t :: %__MODULE__{
          plane: Blog.Chess.plane(),
          to_move: Blog.Chess.color(),
          ledger: map(),
          status: tuple(),
          clocks: tuple(),
          en_passant: Blog.Chess.global_square() | nil,
          ply: non_neg_integer()
        }
end
