defmodule Blog.Chess.Rays do
  @moduledoc """
  Sliding-ray and direction helpers for the chess9 24x24 plane.

  Rays walk across the FULL 24x24 plane and are NOT clipped at board
  boundaries — boundary-crossing logic lives in the move-legality layer.

  ## Direction constants

  The module exposes four sets of `{dx, dy}` direction vectors mirroring the
  TypeScript source:

  | constant          | directions                        |
  |-------------------|-----------------------------------|
  | `@diagonals`      | four diagonal unit vectors        |
  | `@orthogonals`    | four axis-aligned unit vectors    |
  | `bishop_dirs/0`   | same as diagonals                 |
  | `rook_dirs/0`     | same as orthogonals               |
  | `queen_dirs/0`    | all eight directions              |
  | `directions_for/1`| per piece-type direction list     |
  """

  alias Blog.Chess, as: C
  alias Blog.Chess.Plane

  @diagonals [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
  @orthogonals [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

  # ---------------------------------------------------------------------------
  # Direction constants
  # ---------------------------------------------------------------------------

  @doc "Returns the four diagonal unit vectors used by bishops and queens."
  @spec bishop_dirs() :: [{integer(), integer()}]
  def bishop_dirs, do: @diagonals

  @doc "Returns the four orthogonal unit vectors used by rooks and queens."
  @spec rook_dirs() :: [{integer(), integer()}]
  def rook_dirs, do: @orthogonals

  @doc "Returns all eight unit vectors used by queens."
  @spec queen_dirs() :: [{integer(), integer()}]
  def queen_dirs, do: @diagonals ++ @orthogonals

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

  @king_deltas @diagonals ++ @orthogonals

  @doc """
  Returns the direction vectors for a given piece type.

  - `:bishop`  → four diagonals
  - `:rook`    → four orthogonals
  - `:queen`   → all eight directions
  - `:knight`  → eight knight-jump deltas
  - `:king`    → all eight unit vectors (same as queen, but kings cannot cross)
  - `:pawn`    → empty list (pawn moves are handled separately)

      iex> Blog.Chess.Rays.directions_for(:bishop)
      [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

      iex> Blog.Chess.Rays.directions_for(:rook)
      [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

      iex> length(Blog.Chess.Rays.directions_for(:queen))
      8

      iex> length(Blog.Chess.Rays.directions_for(:knight))
      8

      iex> length(Blog.Chess.Rays.directions_for(:king))
      8

      iex> Blog.Chess.Rays.directions_for(:pawn)
      []
  """
  @spec directions_for(C.piece_type()) :: [{integer(), integer()}]
  def directions_for(:bishop), do: @diagonals
  def directions_for(:rook), do: @orthogonals
  def directions_for(:queen), do: @diagonals ++ @orthogonals
  def directions_for(:knight), do: @knight_deltas
  def directions_for(:king), do: @king_deltas
  def directions_for(:pawn), do: []

  # ---------------------------------------------------------------------------
  # Core ray walk
  # ---------------------------------------------------------------------------

  @doc """
  Walks a sliding ray from `from` in direction `{dx, dy}` across the full
  24x24 plane.

  The ray continues until:
  - the next step would leave the plane (out of bounds), or
  - a piece is encountered on the current step.

  The blocking piece's square **is included** in the returned list (it is a
  potential capture target). Empty squares before the blocker are also included.

  Uses `C.offset/3` recursively; returns squares in order from closest to
  farthest.

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> Blog.Chess.Rays.ray({0, 0}, {1, 0}, plane)
      [{1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0},
       {9, 0}, {10, 0}, {11, 0}, {12, 0}, {13, 0}, {14, 0}, {15, 0},
       {16, 0}, {17, 0}, {18, 0}, {19, 0}, {20, 0}, {21, 0}, {22, 0}, {23, 0}]

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> blocker = Blog.Chess.Piece.new(:pawn, :black)
      iex> plane = Blog.Chess.Plane.with_piece(plane, {3, 0}, blocker)
      iex> Blog.Chess.Rays.ray({0, 0}, {1, 0}, plane)
      [{1, 0}, {2, 0}, {3, 0}]

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> Blog.Chess.Rays.ray({0, 0}, {-1, 0}, plane)
      []
  """
  @spec ray(C.global_square(), {integer(), integer()}, C.plane()) :: [C.global_square()]
  def ray(from, {dx, dy}, plane) do
    case C.offset(from, dx, dy) do
      nil ->
        []

      next ->
        if Plane.piece_at(plane, next) != nil do
          [next]
        else
          [next | ray(next, {dx, dy}, plane)]
        end
    end
  end

  @doc """
  Walks a sliding ray and returns only the empty squares before any blocker.

  Identical to `ray/3` but stops **before** the first occupied square, so the
  blocker's square is not included. Returns only squares the piece can slide
  through without capturing.

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> blocker = Blog.Chess.Piece.new(:pawn, :black)
      iex> plane = Blog.Chess.Plane.with_piece(plane, {3, 0}, blocker)
      iex> Blog.Chess.Rays.ray_clear({0, 0}, {1, 0}, plane)
      [{1, 0}, {2, 0}]

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> Blog.Chess.Rays.ray_clear({0, 0}, {-1, 0}, plane)
      []
  """
  @spec ray_clear(C.global_square(), {integer(), integer()}, C.plane()) :: [C.global_square()]
  def ray_clear(from, {dx, dy}, plane) do
    case C.offset(from, dx, dy) do
      nil ->
        []

      next ->
        if Plane.piece_at(plane, next) != nil do
          []
        else
          [next | ray_clear(next, {dx, dy}, plane)]
        end
    end
  end

  @doc """
  Returns the union of rays in all given directions from `from`.

  Calls `ray/3` for each `{dx, dy}` in `dirs` and concatenates the results.
  Order of squares in the result mirrors the order of `dirs`.

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> squares = Blog.Chess.Rays.sliding_destinations({12, 12}, Blog.Chess.Rays.rook_dirs(), plane)
      iex> length(squares)
      46

      iex> plane = Blog.Chess.Plane.empty_plane()
      iex> Blog.Chess.Rays.sliding_destinations({0, 0}, [], plane)
      []
  """
  @spec sliding_destinations(C.global_square(), [{integer(), integer()}], C.plane()) ::
          [C.global_square()]
  def sliding_destinations(from, dirs, plane) do
    Enum.flat_map(dirs, fn dir -> ray(from, dir, plane) end)
  end
end
