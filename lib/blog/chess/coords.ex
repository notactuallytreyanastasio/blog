defmodule Blog.Chess.Coords do
  @moduledoc """
  Smart constructors and coordinate utilities for the chess9 24x24 plane.

  The plane is a 24x24 grid of global squares, tiling nine 8x8 boards in a
  3x3 super-grid.  This module provides:

  - Validated constructors returning `{:ok, value} | {:error, :out_of_range}`
  - Conversion between global and local (per-board) coordinate spaces
  - Board and plane enumeration helpers

  ## Coordinate conventions

      board 0 | board 1 | board 2     gx: 0..7  | 8..15 | 16..23
      --------+---------+--------     gy: 0..7  | 0..7  | 0..7
      board 3 | board 4 | board 5          8..15 | 8..15 | 8..15
      --------+---------+--------         16..23 |16..23 |16..23
      board 6 | board 7 | board 8

  Within a single board, file (local x) and rank (local y) are each 0..7.
  Local {file=0, rank=0} is the top-left corner of the board (smallest gx,
  smallest gy).
  """

  alias Blog.Chess, as: C

  # ---------------------------------------------------------------------------
  # Validated scalar constructors
  # ---------------------------------------------------------------------------

  @doc """
  Validates and returns a global x-coordinate in 0..23.

      iex> Blog.Chess.Coords.mk_gx(0)
      {:ok, 0}

      iex> Blog.Chess.Coords.mk_gx(23)
      {:ok, 23}

      iex> Blog.Chess.Coords.mk_gx(24)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_gx(-1)
      {:error, :out_of_range}
  """
  @spec mk_gx(integer()) :: {:ok, C.gx()} | {:error, :out_of_range}
  def mk_gx(n) when is_integer(n) and n >= 0 and n <= 23, do: {:ok, n}
  def mk_gx(_), do: {:error, :out_of_range}

  @doc """
  Validates and returns a global y-coordinate in 0..23.

      iex> Blog.Chess.Coords.mk_gy(0)
      {:ok, 0}

      iex> Blog.Chess.Coords.mk_gy(23)
      {:ok, 23}

      iex> Blog.Chess.Coords.mk_gy(24)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_gy(-1)
      {:error, :out_of_range}
  """
  @spec mk_gy(integer()) :: {:ok, C.gy()} | {:error, :out_of_range}
  def mk_gy(n) when is_integer(n) and n >= 0 and n <= 23, do: {:ok, n}
  def mk_gy(_), do: {:error, :out_of_range}

  @doc """
  Validates and returns a local file (column) index in 0..7.

      iex> Blog.Chess.Coords.mk_file(0)
      {:ok, 0}

      iex> Blog.Chess.Coords.mk_file(7)
      {:ok, 7}

      iex> Blog.Chess.Coords.mk_file(8)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_file(-1)
      {:error, :out_of_range}
  """
  @spec mk_file(integer()) :: {:ok, 0..7} | {:error, :out_of_range}
  def mk_file(n) when is_integer(n) and n >= 0 and n <= 7, do: {:ok, n}
  def mk_file(_), do: {:error, :out_of_range}

  @doc """
  Validates and returns a local rank (row) index in 0..7.

      iex> Blog.Chess.Coords.mk_rank(0)
      {:ok, 0}

      iex> Blog.Chess.Coords.mk_rank(7)
      {:ok, 7}

      iex> Blog.Chess.Coords.mk_rank(8)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_rank(-1)
      {:error, :out_of_range}
  """
  @spec mk_rank(integer()) :: {:ok, 0..7} | {:error, :out_of_range}
  def mk_rank(n) when is_integer(n) and n >= 0 and n <= 7, do: {:ok, n}
  def mk_rank(_), do: {:error, :out_of_range}

  @doc """
  Validates and returns a board index in 0..8.

      iex> Blog.Chess.Coords.mk_board_index(0)
      {:ok, 0}

      iex> Blog.Chess.Coords.mk_board_index(8)
      {:ok, 8}

      iex> Blog.Chess.Coords.mk_board_index(9)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_board_index(-1)
      {:error, :out_of_range}
  """
  @spec mk_board_index(integer()) :: {:ok, C.board_index()} | {:error, :out_of_range}
  def mk_board_index(n) when is_integer(n) and n >= 0 and n <= 8, do: {:ok, n}
  def mk_board_index(_), do: {:error, :out_of_range}

  @doc """
  Validates both coordinates and returns a global square `{gx, gy}`.

  Returns `{:error, :out_of_range}` if either coordinate is outside 0..23.

      iex> Blog.Chess.Coords.mk_global(0, 0)
      {:ok, {0, 0}}

      iex> Blog.Chess.Coords.mk_global(23, 23)
      {:ok, {23, 23}}

      iex> Blog.Chess.Coords.mk_global(24, 0)
      {:error, :out_of_range}

      iex> Blog.Chess.Coords.mk_global(0, -1)
      {:error, :out_of_range}
  """
  @spec mk_global(integer(), integer()) :: {:ok, C.global_square()} | {:error, :out_of_range}
  def mk_global(gx, gy)
      when is_integer(gx) and gx >= 0 and gx <= 23 and
             is_integer(gy) and gy >= 0 and gy <= 23 do
    {:ok, {gx, gy}}
  end

  def mk_global(_, _), do: {:error, :out_of_range}

  # ---------------------------------------------------------------------------
  # Board mapping
  # ---------------------------------------------------------------------------

  @doc """
  Returns the board index (0..8) that contains the given global square.

      iex> Blog.Chess.Coords.board_of({0, 0})
      0

      iex> Blog.Chess.Coords.board_of({8, 0})
      1

      iex> Blog.Chess.Coords.board_of({0, 8})
      3

      iex> Blog.Chess.Coords.board_of({23, 23})
      8
  """
  @spec board_of(C.global_square()) :: C.board_index()
  def board_of({gx, gy}), do: C.board_of({gx, gy})

  @doc """
  Returns the top-left global square `{gx_min, gy_min}` of a board.

      iex> Blog.Chess.Coords.board_origin(0)
      {0, 0}

      iex> Blog.Chess.Coords.board_origin(4)
      {8, 8}

      iex> Blog.Chess.Coords.board_origin(8)
      {16, 16}
  """
  @spec board_origin(C.board_index()) :: C.global_square()
  def board_origin(board_index), do: C.board_origin(board_index)

  # ---------------------------------------------------------------------------
  # Global <-> board-local conversion
  # ---------------------------------------------------------------------------

  @doc """
  Decomposes a global square into its board index, file, and rank.

  Returns `{board_index, file, rank}` where `file = rem(gx, 8)` and
  `rank = rem(gy, 8)`.

      iex> Blog.Chess.Coords.global_to_board({0, 0})
      {0, 0, 0}

      iex> Blog.Chess.Coords.global_to_board({7, 7})
      {0, 7, 7}

      iex> Blog.Chess.Coords.global_to_board({8, 8})
      {4, 0, 0}

      iex> Blog.Chess.Coords.global_to_board({11, 13})
      {4, 3, 5}

      iex> Blog.Chess.Coords.global_to_board({23, 23})
      {8, 7, 7}
  """
  @spec global_to_board(C.global_square()) :: {C.board_index(), 0..7, 0..7}
  def global_to_board({gx, gy}) do
    board = C.board_of({gx, gy})
    file = rem(gx, 8)
    rank = rem(gy, 8)
    {board, file, rank}
  end

  @doc """
  Converts a board index, file, and rank to a global square.

      iex> Blog.Chess.Coords.board_to_global(0, 0, 0)
      {0, 0}

      iex> Blog.Chess.Coords.board_to_global(0, 7, 7)
      {7, 7}

      iex> Blog.Chess.Coords.board_to_global(4, 0, 0)
      {8, 8}

      iex> Blog.Chess.Coords.board_to_global(4, 3, 5)
      {11, 13}

      iex> Blog.Chess.Coords.board_to_global(8, 7, 7)
      {23, 23}
  """
  @spec board_to_global(C.board_index(), 0..7, 0..7) :: C.global_square()
  def board_to_global(board_index, file, rank) do
    {ox, oy} = C.board_origin(board_index)
    {ox + file, oy + rank}
  end

  # ---------------------------------------------------------------------------
  # Square enumeration
  # ---------------------------------------------------------------------------

  @doc """
  Returns all 64 global squares belonging to the given board, in row-major
  order (rank increasing, then file increasing within each rank).

      iex> squares = Blog.Chess.Coords.squares_of_board(0)
      iex> length(squares)
      64
      iex> hd(squares)
      {0, 0}
      iex> List.last(squares)
      {7, 7}

      iex> squares = Blog.Chess.Coords.squares_of_board(4)
      iex> hd(squares)
      {8, 8}
      iex> List.last(squares)
      {15, 15}
  """
  @spec squares_of_board(C.board_index()) :: [C.global_square()]
  def squares_of_board(board_index) do
    {ox, oy} = C.board_origin(board_index)

    for rank <- 0..7, file <- 0..7 do
      {ox + file, oy + rank}
    end
  end

  @doc """
  Returns all 576 global squares on the plane, in row-major order
  (gy increasing, then gx increasing within each row).

      iex> squares = Blog.Chess.Coords.all_squares()
      iex> length(squares)
      576
      iex> hd(squares)
      {0, 0}
      iex> List.last(squares)
      {23, 23}
  """
  @spec all_squares() :: [C.global_square()]
  def all_squares do
    for gy <- 0..23, gx <- 0..23 do
      {gx, gy}
    end
  end

  # ---------------------------------------------------------------------------
  # Bounds check and movement
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` if `{gx, gy}` is within the 24x24 plane.

      iex> Blog.Chess.Coords.in_bounds?(0, 0)
      true

      iex> Blog.Chess.Coords.in_bounds?(23, 23)
      true

      iex> Blog.Chess.Coords.in_bounds?(24, 0)
      false

      iex> Blog.Chess.Coords.in_bounds?(0, -1)
      false
  """
  @spec in_bounds?(integer(), integer()) :: boolean()
  def in_bounds?(gx, gy), do: C.in_bounds?(gx, gy)

  @doc """
  Applies an offset `{dx, dy}` to a global square, returning the resulting
  square or `nil` if the result leaves the plane.

      iex> Blog.Chess.Coords.offset({0, 0}, 1, 1)
      {1, 1}

      iex> Blog.Chess.Coords.offset({23, 23}, 1, 0)
      nil

      iex> Blog.Chess.Coords.offset({0, 0}, -1, 0)
      nil
  """
  @spec offset(C.global_square(), integer(), integer()) :: C.global_square() | nil
  def offset(sq, dx, dy), do: C.offset(sq, dx, dy)
end
