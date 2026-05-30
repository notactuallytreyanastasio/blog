defmodule Blog.Chess.Plane do
  @moduledoc """
  Operations on the 576-element tuple that represents the chess9 board plane.

  The plane is an Erlang tuple with 576 elements (24x24 = 576 cells). Each
  element is either `nil` (empty) or a `Blog.Chess.Piece.t()`.

  Index mapping: `cell_index({gx, gy}) == gy * 24 + gx` (0-based).

  ## Read vs. write indexing

  - Reads:  `elem(plane, C.cell_index(sq))`          — `elem/2` is 0-based
  - Writes: `:erlang.setelement(C.cell_index(sq) + 1, plane, val)` — 1-based
  """

  alias Blog.Chess, as: C
  alias Blog.Chess.Piece

  # ---------------------------------------------------------------------------
  # Construction
  # ---------------------------------------------------------------------------

  @doc """
  Returns an empty 576-element plane tuple with every cell set to `nil`.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> tuple_size(p)
      576
      iex> elem(p, 0)
      nil
  """
  @spec empty_plane() :: C.plane()
  def empty_plane do
    List.to_tuple(List.duplicate(nil, 576))
  end

  # ---------------------------------------------------------------------------
  # Single-cell reads / writes
  # ---------------------------------------------------------------------------

  @doc """
  Returns the piece at `sq`, or `nil` if the cell is empty.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> Blog.Chess.Plane.piece_at(p, {0, 0})
      nil

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> piece = Blog.Chess.Piece.new(:king, :white)
      iex> p = Blog.Chess.Plane.with_piece(p, {4, 7}, piece)
      iex> Blog.Chess.Plane.piece_at(p, {4, 7})
      %Blog.Chess.Piece{type: :king, color: :white, has_moved: false}
  """
  @spec piece_at(C.plane(), C.global_square()) :: Piece.t() | nil
  def piece_at(plane, sq) do
    elem(plane, C.cell_index(sq))
  end

  @doc """
  Returns a new plane with `sq` set to `piece` (copy-on-write).

  Pass `nil` to clear the cell.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> piece = Blog.Chess.Piece.new(:rook, :black)
      iex> p2 = Blog.Chess.Plane.with_piece(p, {0, 0}, piece)
      iex> Blog.Chess.Plane.piece_at(p2, {0, 0})
      %Blog.Chess.Piece{type: :rook, color: :black, has_moved: false}
      iex> Blog.Chess.Plane.piece_at(p, {0, 0})
      nil
  """
  @spec with_piece(C.plane(), C.global_square(), Piece.t() | nil) :: C.plane()
  def with_piece(plane, sq, piece) do
    :erlang.setelement(C.cell_index(sq) + 1, plane, piece)
  end

  # ---------------------------------------------------------------------------
  # Bulk writes
  # ---------------------------------------------------------------------------

  @doc """
  Applies several `{square, piece}` writes at once, copy-on-write.

  Each element of `writes` is a `{global_square, piece | nil}` pair. All
  writes are applied to a single copy; the original plane is unchanged.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> wk = Blog.Chess.Piece.new(:king, :white)
      iex> bk = Blog.Chess.Piece.new(:king, :black)
      iex> p2 = Blog.Chess.Plane.with_pieces(p, [{{4, 7}, wk}, {{4, 0}, bk}])
      iex> Blog.Chess.Plane.piece_at(p2, {4, 7})
      %Blog.Chess.Piece{type: :king, color: :white, has_moved: false}
      iex> Blog.Chess.Plane.piece_at(p2, {4, 0})
      %Blog.Chess.Piece{type: :king, color: :black, has_moved: false}
  """
  @spec with_pieces(C.plane(), [{C.global_square(), Piece.t() | nil}]) :: C.plane()
  def with_pieces(plane, writes) do
    Enum.reduce(writes, plane, fn {sq, piece}, acc ->
      with_piece(acc, sq, piece)
    end)
  end

  # ---------------------------------------------------------------------------
  # Queries
  # ---------------------------------------------------------------------------

  @doc """
  Returns a list of `{global_square, piece}` pairs for every piece of `color`
  on the plane.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> wk = Blog.Chess.Piece.new(:king, :white)
      iex> bk = Blog.Chess.Piece.new(:king, :black)
      iex> p = Blog.Chess.Plane.with_pieces(p, [{{4, 7}, wk}, {{4, 0}, bk}])
      iex> [{sq, piece}] = Blog.Chess.Plane.pieces_of(p, :white)
      iex> sq
      {4, 7}
      iex> piece.color
      :white
  """
  @spec pieces_of(C.plane(), C.color()) :: [{C.global_square(), Piece.t()}]
  def pieces_of(plane, color) do
    for idx <- 0..575,
        piece = elem(plane, idx),
        piece != nil,
        piece.color == color do
      {C.square_at(idx), piece}
    end
  end

  @doc """
  Returns a list of `{global_square, piece}` pairs for every piece of `color`
  whose square falls on board `board_index`.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> wk = Blog.Chess.Piece.new(:king, :white)
      iex> p = Blog.Chess.Plane.with_piece(p, {4, 7}, wk)
      iex> [{sq, piece}] = Blog.Chess.Plane.board_pieces(p, :white, 0)
      iex> sq
      {4, 7}
      iex> piece.type
      :king
      iex> Blog.Chess.Plane.board_pieces(p, :white, 1)
      []
  """
  @spec board_pieces(C.plane(), C.color(), C.board_index()) :: [{C.global_square(), Piece.t()}]
  def board_pieces(plane, color, board_index) do
    for {sq, piece} <- pieces_of(plane, color),
        C.board_of(sq) == board_index do
      {sq, piece}
    end
  end

  @doc """
  Returns the global square of the king of `color`, or `nil` if not found.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> wk = Blog.Chess.Piece.new(:king, :white)
      iex> p = Blog.Chess.Plane.with_piece(p, {4, 7}, wk)
      iex> Blog.Chess.Plane.king_square(p, :white)
      {4, 7}
      iex> Blog.Chess.Plane.king_square(p, :black)
      nil
  """
  @spec king_square(C.plane(), C.color()) :: C.global_square() | nil
  def king_square(plane, color) do
    Enum.find_value(0..575, fn idx ->
      piece = elem(plane, idx)

      if piece != nil and piece.color == color and piece.type == :king do
        C.square_at(idx)
      end
    end)
  end

  @doc "O(1) king lookup using the cached positions in State. Falls back to the O(576) scan if cache is nil."
  @spec king_square_fast(Blog.Chess.State.t(), C.color()) :: C.global_square() | nil
  def king_square_fast(%{white_king: sq}, :white) when sq != nil, do: sq
  def king_square_fast(%{black_king: sq}, :black) when sq != nil, do: sq
  def king_square_fast(state, color), do: king_square(state.plane, color)

  @doc """
  Returns a list of `{global_square, piece}` pairs for every occupied cell on
  the plane, regardless of color.

      iex> p = Blog.Chess.Plane.empty_plane()
      iex> wk = Blog.Chess.Piece.new(:king, :white)
      iex> bk = Blog.Chess.Piece.new(:king, :black)
      iex> p = Blog.Chess.Plane.with_pieces(p, [{{4, 7}, wk}, {{4, 0}, bk}])
      iex> length(Blog.Chess.Plane.all_pieces(p))
      2
  """
  @spec all_pieces(C.plane()) :: [{C.global_square(), Piece.t()}]
  def all_pieces(plane) do
    for idx <- 0..575,
        piece = elem(plane, idx),
        piece != nil do
      {C.square_at(idx), piece}
    end
  end
end
