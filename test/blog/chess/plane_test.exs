defmodule Blog.Chess.PlaneTest do
  use ExUnit.Case, async: false

  alias Blog.Chess
  alias Blog.Chess.{Plane, Piece, Setup, Pieces}

  # ---------------------------------------------------------------------------
  # empty_plane
  # ---------------------------------------------------------------------------

  describe "empty_plane/0" do
    test "returns a tuple with 576 elements" do
      p = Plane.empty_plane()
      assert tuple_size(p) == 576
    end

    test "every cell is nil" do
      p = Plane.empty_plane()
      assert Enum.all?(0..575, fn i -> elem(p, i) == nil end)
    end
  end

  # ---------------------------------------------------------------------------
  # piece_at
  # ---------------------------------------------------------------------------

  describe "piece_at/2" do
    test "returns nil on an empty plane" do
      p = Plane.empty_plane()
      assert Plane.piece_at(p, {0, 0}) == nil
      assert Plane.piece_at(p, {12, 12}) == nil
      assert Plane.piece_at(p, {23, 23}) == nil
    end

    test "reads back a piece written with with_piece" do
      wk = Piece.new(:king, :white)
      p = Plane.with_piece(Plane.empty_plane(), {5, 5}, wk)
      assert Plane.piece_at(p, {5, 5}) == wk
    end

    test "returns nil for a square that was not written" do
      wk = Piece.new(:king, :white)
      p = Plane.with_piece(Plane.empty_plane(), {5, 5}, wk)
      assert Plane.piece_at(p, {6, 5}) == nil
    end
  end

  # ---------------------------------------------------------------------------
  # with_piece
  # ---------------------------------------------------------------------------

  describe "with_piece/3" do
    test "is copy-on-write: the original plane is unchanged" do
      base = Plane.empty_plane()
      wk = Piece.new(:king, :white)
      _next = Plane.with_piece(base, {0, 0}, wk)
      assert Plane.piece_at(base, {0, 0}) == nil
    end

    test "the returned plane reflects the write" do
      wk = Piece.new(:king, :white)
      next = Plane.with_piece(Plane.empty_plane(), {0, 0}, wk)
      assert Plane.piece_at(next, {0, 0}) == wk
    end

    test "passing nil clears an occupied cell" do
      wk = Piece.new(:king, :white)
      p = Plane.with_piece(Plane.empty_plane(), {3, 3}, wk)
      cleared = Plane.with_piece(p, {3, 3}, nil)
      assert Plane.piece_at(cleared, {3, 3}) == nil
    end

    test "handles corner squares: {0, 0} and {23, 23}" do
      bn = Piece.new(:knight, :black, true)
      p0 = Plane.with_piece(Plane.empty_plane(), {0, 0}, bn)
      p1 = Plane.with_piece(Plane.empty_plane(), {23, 23}, bn)
      assert Plane.piece_at(p0, {0, 0}) == bn
      assert Plane.piece_at(p1, {23, 23}) == bn
    end
  end

  # ---------------------------------------------------------------------------
  # with_pieces
  # ---------------------------------------------------------------------------

  describe "with_pieces/2" do
    test "applies a batch of writes in order" do
      wk = Piece.new(:king, :white)
      bn = Piece.new(:knight, :black, true)

      p =
        Plane.with_pieces(Plane.empty_plane(), [
          {{1, 1}, wk},
          {{2, 2}, bn}
        ])

      assert Plane.piece_at(p, {1, 1}) == wk
      assert Plane.piece_at(p, {2, 2}) == bn
    end

    test "later writes in the batch override earlier ones" do
      wk = Piece.new(:king, :white)
      bn = Piece.new(:knight, :black, true)

      p =
        Plane.with_pieces(Plane.empty_plane(), [
          {{1, 1}, wk},
          {{2, 2}, bn},
          # overwrite {1,1} with nil
          {{1, 1}, nil}
        ])

      assert Plane.piece_at(p, {1, 1}) == nil
      assert Plane.piece_at(p, {2, 2}) == bn
    end

    test "empty write list leaves the plane unchanged" do
      base = Plane.empty_plane()
      result = Plane.with_pieces(base, [])
      assert result == base
    end
  end

  # ---------------------------------------------------------------------------
  # pieces_of
  # ---------------------------------------------------------------------------

  describe "pieces_of/2" do
    test "returns empty list on an empty plane" do
      assert Plane.pieces_of(Plane.empty_plane(), :white) == []
      assert Plane.pieces_of(Plane.empty_plane(), :black) == []
    end

    test "returns only pieces of the requested color" do
      wk = Piece.new(:king, :white)
      bk = Piece.new(:king, :black)

      p =
        Plane.with_pieces(Plane.empty_plane(), [
          {{4, 7}, wk},
          {{4, 0}, bk}
        ])

      white_pieces = Plane.pieces_of(p, :white)
      black_pieces = Plane.pieces_of(p, :black)

      assert length(white_pieces) == 1
      assert length(black_pieces) == 1

      [{sq, piece}] = white_pieces
      assert sq == {4, 7}
      assert piece.color == :white

      [{sq2, piece2}] = black_pieces
      assert sq2 == {4, 0}
      assert piece2.color == :black
    end

    test "each returned entry pairs the correct square with its piece" do
      wr = Piece.new(:rook, :white)
      wn = Piece.new(:knight, :white)

      p =
        Plane.with_pieces(Plane.empty_plane(), [
          {{0, 7}, wr},
          {{1, 7}, wn}
        ])

      results = Plane.pieces_of(p, :white) |> Enum.sort_by(&elem(&1, 0))
      assert [{sq1, ^wr}, {sq2, ^wn}] = results
      assert sq1 == {0, 7}
      assert sq2 == {1, 7}
    end
  end

  # ---------------------------------------------------------------------------
  # king_square
  # ---------------------------------------------------------------------------

  describe "king_square/2" do
    test "returns nil when no king of that color exists" do
      assert Plane.king_square(Plane.empty_plane(), :white) == nil
      assert Plane.king_square(Plane.empty_plane(), :black) == nil
    end

    test "returns the square of the white king" do
      wk = Piece.new(:king, :white)
      p = Plane.with_piece(Plane.empty_plane(), {4, 7}, wk)
      assert Plane.king_square(p, :white) == {4, 7}
    end

    test "returns the square of the black king" do
      bk = Piece.new(:king, :black)
      p = Plane.with_piece(Plane.empty_plane(), {4, 0}, bk)
      assert Plane.king_square(p, :black) == {4, 0}
    end

    test "returns nil for the other color when only one king is placed" do
      wk = Piece.new(:king, :white)
      p = Plane.with_piece(Plane.empty_plane(), {4, 7}, wk)
      assert Plane.king_square(p, :black) == nil
    end

    test "finds both kings independently when both are present" do
      wk = Piece.new(:king, :white)
      bk = Piece.new(:king, :black)

      p =
        Plane.with_pieces(Plane.empty_plane(), [
          {{4, 7}, wk},
          {{4, 0}, bk}
        ])

      assert Plane.king_square(p, :white) == {4, 7}
      assert Plane.king_square(p, :black) == {4, 0}
    end
  end

  # ---------------------------------------------------------------------------
  # setup_test: initial_plane/0 invariants
  # ---------------------------------------------------------------------------

  describe "Setup.initial_plane/0" do
    setup do
      %{plane: Setup.initial_plane()}
    end

    test "total piece count is 288 (32 pieces × 9 boards)", %{plane: plane} do
      count =
        Enum.count(0..575, fn i -> elem(plane, i) != nil end)

      assert count == 288
    end

    test "144 white pieces and 144 black pieces", %{plane: plane} do
      white = Plane.pieces_of(plane, :white)
      black = Plane.pieces_of(plane, :black)
      assert length(white) == 144
      assert length(black) == 144
    end

    test "back rank order on board 0: files 0..7 are R N B Q K B N R", %{plane: plane} do
      expected = Pieces.back_rank()

      for {type, file} <- Enum.with_index(expected) do
        sq = {file, 0}
        piece = Plane.piece_at(plane, sq)
        assert piece != nil, "expected piece at #{inspect(sq)}"
        assert piece.type == type, "file #{file}: expected #{type}, got #{piece.type}"
        assert piece.color == :black
      end
    end

    test "white back rank on board 0 is at local rank 7 (gy=7)", %{plane: plane} do
      expected = Pieces.back_rank()

      for {type, file} <- Enum.with_index(expected) do
        sq = {file, 7}
        piece = Plane.piece_at(plane, sq)
        assert piece != nil, "expected white piece at #{inspect(sq)}"
        assert piece.type == type
        assert piece.color == :white
      end
    end

    test "white pawns on board 0 are at gy=6 (local rank 6)", %{plane: plane} do
      for file <- 0..7 do
        sq = {file, 6}
        piece = Plane.piece_at(plane, sq)
        assert piece != nil, "expected white pawn at #{inspect(sq)}"
        assert piece.type == :pawn
        assert piece.color == :white
      end
    end

    test "black pawns on board 0 are at gy=1 (local rank 1)", %{plane: plane} do
      for file <- 0..7 do
        sq = {file, 1}
        piece = Plane.piece_at(plane, sq)
        assert piece != nil, "expected black pawn at #{inspect(sq)}"
        assert piece.type == :pawn
        assert piece.color == :black
      end
    end

    test "white pieces occupy only local ranks 6 and 7 on each board", %{plane: plane} do
      white_squares = Plane.pieces_of(plane, :white) |> Enum.map(&elem(&1, 0))

      for {gx, gy} <- white_squares do
        local_gy = rem(gy, 8)

        assert local_gy in [6, 7],
               "white piece at {#{gx}, #{gy}} has unexpected local rank #{local_gy}"
      end
    end

    test "black pieces occupy only local ranks 0 and 1 on each board", %{plane: plane} do
      black_squares = Plane.pieces_of(plane, :black) |> Enum.map(&elem(&1, 0))

      for {gx, gy} <- black_squares do
        local_gy = rem(gy, 8)

        assert local_gy in [0, 1],
               "black piece at {#{gx}, #{gy}} has unexpected local rank #{local_gy}"
      end
    end

    test "white king on board 0 is at {4, 7}", %{plane: plane} do
      assert Plane.king_square(plane, :white) in [
               {4, 7},
               {4, 15},
               {4, 23},
               {12, 7},
               {12, 15},
               {12, 23},
               {20, 7},
               {20, 15},
               {20, 23}
             ]

      # Specifically check board 0's white king position
      piece = Plane.piece_at(plane, {4, 7})
      assert piece != nil
      assert piece.type == :king
      assert piece.color == :white
    end

    test "each of the 9 boards has exactly 32 pieces", %{plane: plane} do
      for board <- 0..8 do
        {ox, oy} = Chess.board_origin(board)

        count =
          for file <- 0..7,
              rank <- 0..7,
              piece = Plane.piece_at(plane, {ox + file, oy + rank}),
              piece != nil do
            piece
          end
          |> length()

        assert count == 32, "board #{board} has #{count} pieces, expected 32"
      end
    end
  end
end
