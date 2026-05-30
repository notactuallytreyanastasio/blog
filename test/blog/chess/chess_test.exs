defmodule Blog.ChessTest do
  use ExUnit.Case, async: false

  alias Blog.Chess
  alias Blog.Chess.{Coords, Plane, Pieces, Setup}

  # ---------------------------------------------------------------------------
  # opposite/1
  # ---------------------------------------------------------------------------

  describe "opposite/1" do
    test "white becomes black" do
      assert Chess.opposite(:white) == :black
    end

    test "black becomes white" do
      assert Chess.opposite(:black) == :white
    end

    test "double inversion is identity" do
      assert Chess.opposite(Chess.opposite(:white)) == :white
      assert Chess.opposite(Chess.opposite(:black)) == :black
    end
  end

  # ---------------------------------------------------------------------------
  # board_of/1
  # ---------------------------------------------------------------------------

  describe "board_of/1" do
    test "top-left corner maps to board 0" do
      assert Chess.board_of({0, 0}) == 0
    end

    test "last cell of board 0 (gx=7, gy=7)" do
      assert Chess.board_of({7, 7}) == 0
    end

    test "first cell of board 1 (gx=8, gy=0)" do
      assert Chess.board_of({8, 0}) == 1
    end

    test "first cell of board 3 (gx=0, gy=8)" do
      assert Chess.board_of({0, 8}) == 3
    end

    test "first cell of center board 4 (gx=8, gy=8)" do
      assert Chess.board_of({8, 8}) == 4
    end

    test "top-right of board 1 shares row with board 0 (gx=8, gy=7)" do
      assert Chess.board_of({8, 7}) == 1
    end

    test "first cell below board 0 (gx=7, gy=8) is board 3" do
      assert Chess.board_of({7, 8}) == 3
    end

    test "bottom-right corner maps to board 8" do
      assert Chess.board_of({23, 23}) == 8
    end

    test "board 5 sample (gx=16, gy=8)" do
      assert Chess.board_of({16, 8}) == 5
    end
  end

  # ---------------------------------------------------------------------------
  # board_origin/1
  # ---------------------------------------------------------------------------

  describe "board_origin/1" do
    test "board 0 origin is {0, 0}" do
      assert Chess.board_origin(0) == {0, 0}
    end

    test "board 1 origin is {8, 0}" do
      assert Chess.board_origin(1) == {8, 0}
    end

    test "board 2 origin is {16, 0}" do
      assert Chess.board_origin(2) == {16, 0}
    end

    test "board 3 origin is {0, 8}" do
      assert Chess.board_origin(3) == {0, 8}
    end

    test "board 4 (center) origin is {8, 8}" do
      assert Chess.board_origin(4) == {8, 8}
    end

    test "board 8 (bottom-right) origin is {16, 16}" do
      assert Chess.board_origin(8) == {16, 16}
    end

    test "board_of(board_origin(bi)) == bi for all 9 boards" do
      for bi <- 0..8 do
        origin = Chess.board_origin(bi)
        assert Chess.board_of(origin) == bi,
               "board_of(board_origin(#{bi})) should equal #{bi}, got #{Chess.board_of(origin)}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # cell_index/1 and square_at/1
  # ---------------------------------------------------------------------------

  describe "cell_index/1" do
    test "origin maps to index 0" do
      assert Chess.cell_index({0, 0}) == 0
    end

    test "gx=1, gy=0 maps to index 1" do
      assert Chess.cell_index({1, 0}) == 1
    end

    test "gx=0, gy=1 maps to index 24" do
      assert Chess.cell_index({0, 1}) == 24
    end

    test "bottom-right corner maps to index 575" do
      assert Chess.cell_index({23, 23}) == 575
    end
  end

  describe "square_at/1" do
    test "index 0 maps to {0, 0}" do
      assert Chess.square_at(0) == {0, 0}
    end

    test "index 24 maps to {0, 1}" do
      assert Chess.square_at(24) == {0, 1}
    end

    test "index 575 maps to {23, 23}" do
      assert Chess.square_at(575) == {23, 23}
    end

    test "cell_index and square_at are mutual inverses for all 576 cells" do
      for idx <- 0..575 do
        sq = Chess.square_at(idx)
        assert Chess.cell_index(sq) == idx,
               "round-trip failed at idx #{idx}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # in_bounds?/2
  # ---------------------------------------------------------------------------

  describe "in_bounds?/2" do
    test "origin {0,0} is in bounds" do
      assert Chess.in_bounds?(0, 0) == true
    end

    test "{23, 23} is in bounds" do
      assert Chess.in_bounds?(23, 23) == true
    end

    test "{24, 0} is out of bounds" do
      assert Chess.in_bounds?(24, 0) == false
    end

    test "{0, -1} is out of bounds" do
      assert Chess.in_bounds?(0, -1) == false
    end

    test "{-1, 0} is out of bounds" do
      assert Chess.in_bounds?(-1, 0) == false
    end

    test "{0, 24} is out of bounds" do
      assert Chess.in_bounds?(0, 24) == false
    end
  end

  # ---------------------------------------------------------------------------
  # offset/3
  # ---------------------------------------------------------------------------

  describe "offset/3" do
    test "step right from origin" do
      assert Chess.offset({0, 0}, 1, 0) == {1, 0}
    end

    test "diagonal step from origin" do
      assert Chess.offset({0, 0}, 1, 1) == {1, 1}
    end

    test "step off the left edge returns nil" do
      assert Chess.offset({0, 0}, -1, 0) == nil
    end

    test "step off the top edge returns nil" do
      assert Chess.offset({0, 0}, 0, -1) == nil
    end

    test "step off the right edge returns nil" do
      assert Chess.offset({23, 23}, 1, 0) == nil
    end

    test "step off the bottom edge returns nil" do
      assert Chess.offset({23, 23}, 0, 1) == nil
    end

    test "crossing board boundary 0->4 lands on board 4" do
      # {7, 7} is last cell of board 0; stepping +1,+1 gives {8, 8} which is board 4
      result = Chess.offset({7, 7}, 1, 1)
      assert result == {8, 8}
      assert result && Chess.board_of(result) == 4
    end

    test "large diagonal stays in bounds" do
      result = Chess.offset({0, 0}, 23, 23)
      assert result == {23, 23}
    end
  end

  # ---------------------------------------------------------------------------
  # frozen?/1
  # ---------------------------------------------------------------------------

  describe "frozen?/1" do
    test ":active is not frozen" do
      assert Chess.frozen?(:active) == false
    end

    test "{:check, :white} is not frozen" do
      assert Chess.frozen?({:check, :white}) == false
    end

    test "{:check, :black} is not frozen" do
      assert Chess.frozen?({:check, :black}) == false
    end

    test "{:checkmate, :white, :black} is frozen" do
      assert Chess.frozen?({:checkmate, :white, :black}) == true
    end

    test "{:checkmate, :black, :white} is frozen" do
      assert Chess.frozen?({:checkmate, :black, :white}) == true
    end

    test ":stalemate is frozen" do
      assert Chess.frozen?(:stalemate) == true
    end

    test "{:draw, :fifty_move} is frozen" do
      assert Chess.frozen?({:draw, :fifty_move}) == true
    end

    test "{:draw, :insufficient_material} is frozen" do
      assert Chess.frozen?({:draw, :insufficient_material}) == true
    end
  end

  # ---------------------------------------------------------------------------
  # Setup / initial_plane — integration
  # ---------------------------------------------------------------------------

  describe "initial_plane (setup_test invariants)" do
    setup do
      %{plane: Setup.initial_plane()}
    end

    test "total piece count is 288", %{plane: plane} do
      total = Plane.all_pieces(plane) |> length()
      assert total == 288
    end

    test "144 white pieces and 144 black pieces", %{plane: plane} do
      white = Plane.pieces_of(plane, :white) |> length()
      black = Plane.pieces_of(plane, :black) |> length()
      assert white == 144
      assert black == 144
    end

    test "each board has exactly 32 pieces", %{plane: plane} do
      for bi <- 0..8 do
        white = Plane.board_pieces(plane, :white, bi) |> length()
        black = Plane.board_pieces(plane, :black, bi) |> length()
        assert white + black == 32,
               "board #{bi} should have 32 pieces, got #{white + black}"
      end
    end

    test "white pieces are on local ranks 6 and 7 of every board", %{plane: plane} do
      white_squares = for {sq, _} <- Plane.pieces_of(plane, :white), do: sq

      for {gx, gy} <- white_squares do
        local_rank = rem(gy, 8)

        assert local_rank in [6, 7],
               "white piece at {#{gx}, #{gy}} has local rank #{local_rank}, expected 6 or 7"
      end
    end

    test "black pieces are on local ranks 0 and 1 of every board", %{plane: plane} do
      black_squares = for {sq, _} <- Plane.pieces_of(plane, :black), do: sq

      for {gx, gy} <- black_squares do
        local_rank = rem(gy, 8)

        assert local_rank in [0, 1],
               "black piece at {#{gx}, #{gy}} has local rank #{local_rank}, expected 0 or 1"
      end
    end

    test "back rank order is correct for board 0 white", %{plane: plane} do
      expected = Pieces.back_rank()

      actual =
        for file <- 0..7 do
          piece = Plane.piece_at(plane, {file, 7})
          piece.type
        end

      assert actual == expected
    end

    test "back rank order is correct for board 0 black", %{plane: plane} do
      expected = Pieces.back_rank()

      actual =
        for file <- 0..7 do
          piece = Plane.piece_at(plane, {file, 0})
          piece.type
        end

      assert actual == expected
    end

    test "each board has exactly one white king", %{plane: plane} do
      for bi <- 0..8 do
        kings =
          Plane.board_pieces(plane, :white, bi)
          |> Enum.filter(fn {_, p} -> p.type == :king end)
          |> length()

        assert kings == 1, "board #{bi} should have 1 white king, got #{kings}"
      end
    end

    test "each board has exactly one black king", %{plane: plane} do
      for bi <- 0..8 do
        kings =
          Plane.board_pieces(plane, :black, bi)
          |> Enum.filter(fn {_, p} -> p.type == :king end)
          |> length()

        assert kings == 1, "board #{bi} should have 1 black king, got #{kings}"
      end
    end

    test "no piece has has_moved set to true initially", %{plane: plane} do
      moved =
        Plane.all_pieces(plane)
        |> Enum.filter(fn {_, p} -> p.has_moved end)
        |> length()

      assert moved == 0
    end
  end

  # ---------------------------------------------------------------------------
  # Coords module delegates
  # ---------------------------------------------------------------------------

  describe "Coords module board_of/1 and board_origin/1" do
    test "Coords.board_of delegates correctly" do
      assert Coords.board_of({0, 0}) == Chess.board_of({0, 0})
      assert Coords.board_of({23, 23}) == Chess.board_of({23, 23})
    end

    test "Coords.board_origin delegates correctly" do
      assert Coords.board_origin(0) == Chess.board_origin(0)
      assert Coords.board_origin(4) == Chess.board_origin(4)
    end

    test "Coords.in_bounds? delegates correctly" do
      assert Coords.in_bounds?(0, 0) == true
      assert Coords.in_bounds?(24, 0) == false
    end

    test "Coords.offset delegates correctly" do
      assert Coords.offset({0, 0}, 1, 1) == {1, 1}
      assert Coords.offset({0, 0}, -1, 0) == nil
    end
  end
end
