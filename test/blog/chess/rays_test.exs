defmodule Blog.Chess.RaysTest do
  use ExUnit.Case, async: false

  alias Blog.Chess.{Rays, Plane, Piece, Setup}

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp empty_plane, do: Plane.empty_plane()

  defp place(plane, sq, type, color) do
    Plane.with_piece(plane, sq, Piece.new(type, color))
  end

  # ---------------------------------------------------------------------------
  # ray/3 — stops at plane edge
  # ---------------------------------------------------------------------------

  describe "ray/3 stops at plane edge" do
    test "rightward ray from origin traverses the entire top row" do
      plane = empty_plane()
      result = Rays.ray({0, 0}, {1, 0}, plane)
      assert length(result) == 23
      assert List.last(result) == {23, 0}
    end

    test "leftward ray from left edge returns empty list" do
      plane = empty_plane()
      assert Rays.ray({0, 0}, {-1, 0}, plane) == []
    end

    test "upward ray from top edge returns empty list" do
      plane = empty_plane()
      assert Rays.ray({5, 0}, {0, -1}, plane) == []
    end

    test "downward ray from bottom-right corner returns empty list" do
      plane = empty_plane()
      assert Rays.ray({23, 23}, {0, 1}, plane) == []
    end

    test "rightward ray from second-to-last column reaches the wall in one step" do
      plane = empty_plane()
      result = Rays.ray({22, 0}, {1, 0}, plane)
      assert result == [{23, 0}]
    end

    test "diagonal ray from top-right corner stops immediately going right-up" do
      plane = empty_plane()
      assert Rays.ray({23, 0}, {1, 1}, plane) == []
    end

    test "ray from near the far wall stops exactly at wall" do
      plane = empty_plane()
      # From {21, 0} going right: should reach {22, 0} and {23, 0}
      result = Rays.ray({21, 0}, {1, 0}, plane)
      assert result == [{22, 0}, {23, 0}]
    end
  end

  # ---------------------------------------------------------------------------
  # ray/3 — stops at piece (includes capture square)
  # ---------------------------------------------------------------------------

  describe "ray/3 stops at piece and includes capture square" do
    test "ray stops at the first occupant and includes it" do
      plane =
        empty_plane()
        |> place({3, 0}, :pawn, :black)

      result = Rays.ray({0, 0}, {1, 0}, plane)
      assert result == [{1, 0}, {2, 0}, {3, 0}]
      # The capture square is the last element
      assert List.last(result) == {3, 0}
    end

    test "ray blocked immediately one step ahead includes only that square" do
      plane =
        empty_plane()
        |> place({1, 0}, :rook, :white)

      result = Rays.ray({0, 0}, {1, 0}, plane)
      assert result == [{1, 0}]
    end

    test "ray includes the capture square when piece is the very next step" do
      plane =
        empty_plane()
        |> place({5, 5}, :bishop, :black)

      result = Rays.ray({4, 5}, {1, 0}, plane)
      assert result == [{5, 5}]
      assert Plane.piece_at(plane, {5, 5}) != nil
    end

    test "ray stops before a second piece, including only the first" do
      plane =
        empty_plane()
        |> place({3, 0}, :pawn, :black)
        |> place({6, 0}, :pawn, :white)

      result = Rays.ray({0, 0}, {1, 0}, plane)
      # Should stop at {3,0} (first blocker), not reach {6,0}
      assert result == [{1, 0}, {2, 0}, {3, 0}]
      refute {6, 0} in result
    end
  end

  # ---------------------------------------------------------------------------
  # ray_clear/3 — stops BEFORE the first piece
  # ---------------------------------------------------------------------------

  describe "ray_clear/3 stops before the first piece" do
    test "ray_clear excludes the blocking piece square" do
      plane =
        empty_plane()
        |> place({3, 0}, :pawn, :black)

      result = Rays.ray_clear({0, 0}, {1, 0}, plane)
      assert result == [{1, 0}, {2, 0}]
      refute {3, 0} in result
    end

    test "ray_clear returns empty list when blocker is immediately adjacent" do
      plane =
        empty_plane()
        |> place({1, 0}, :rook, :white)

      result = Rays.ray_clear({0, 0}, {1, 0}, plane)
      assert result == []
    end

    test "ray_clear on empty plane returns all squares to the wall" do
      plane = empty_plane()
      result = Rays.ray_clear({0, 0}, {1, 0}, plane)
      assert length(result) == 23
      assert List.last(result) == {23, 0}
    end

    test "ray_clear in blocked direction returns empty list when out of bounds" do
      plane = empty_plane()
      assert Rays.ray_clear({0, 0}, {-1, 0}, plane) == []
    end
  end

  # ---------------------------------------------------------------------------
  # Setup / initial plane invariants
  # ---------------------------------------------------------------------------

  describe "initial plane setup" do
    setup do
      %{plane: Setup.initial_plane()}
    end

    test "288 total pieces on the initial plane", %{plane: plane} do
      all = Plane.all_pieces(plane)
      assert length(all) == 288
    end

    test "144 white pieces and 144 black pieces", %{plane: plane} do
      white = Plane.pieces_of(plane, :white)
      black = Plane.pieces_of(plane, :black)
      assert length(white) == 144
      assert length(black) == 144
    end

    test "white back rank on local rank 7 of board 0 matches standard order", %{plane: plane} do
      back_rank = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

      # Board 0 origin is {0, 0}; white back rank is at gy = 0 + 7 = 7
      for {expected_type, file} <- Enum.with_index(back_rank) do
        piece = Plane.piece_at(plane, {file, 7})
        assert piece != nil, "Expected piece at file #{file}, rank 7"
        assert piece.type == expected_type,
               "Expected #{expected_type} at file #{file}, got #{piece.type}"
        assert piece.color == :white
      end
    end

    test "white pieces on board 0 occupy local ranks 6 and 7 (gy 6 and 7)", %{plane: plane} do
      white_on_board_0 = Plane.board_pieces(plane, :white, 0)
      assert length(white_on_board_0) == 16

      for {sq, _piece} <- white_on_board_0 do
        {_gx, gy} = sq
        assert gy in [6, 7], "White piece found at unexpected gy=#{gy}"
      end
    end

    test "black pieces on board 0 occupy local ranks 0 and 1 (gy 0 and 1)", %{plane: plane} do
      black_on_board_0 = Plane.board_pieces(plane, :black, 0)
      assert length(black_on_board_0) == 16

      for {sq, _piece} <- black_on_board_0 do
        {_gx, gy} = sq
        assert gy in [0, 1], "Black piece found at unexpected gy=#{gy}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Diagonal and multi-direction rays
  # ---------------------------------------------------------------------------

  describe "diagonal rays" do
    test "diagonal ray from center of empty plane is bounded by the plane" do
      plane = empty_plane()
      # From {12, 12} going {1, 1}: should reach {23, 23} (11 steps)
      result = Rays.ray({12, 12}, {1, 1}, plane)
      assert length(result) == 11
      assert List.last(result) == {23, 23}
    end

    test "diagonal ray stops at a piece on the diagonal" do
      plane =
        empty_plane()
        |> place({15, 15}, :bishop, :black)

      result = Rays.ray({12, 12}, {1, 1}, plane)
      assert List.last(result) == {15, 15}
      assert length(result) == 3
    end
  end

  # ---------------------------------------------------------------------------
  # sliding_destinations/3
  # ---------------------------------------------------------------------------

  describe "sliding_destinations/3" do
    test "rook from center of empty plane reaches 46 squares" do
      plane = empty_plane()
      squares = Rays.sliding_destinations({12, 12}, Rays.rook_dirs(), plane)
      assert length(squares) == 46
    end

    test "sliding_destinations with empty dir list returns empty list" do
      plane = empty_plane()
      assert Rays.sliding_destinations({0, 0}, [], plane) == []
    end
  end
end
