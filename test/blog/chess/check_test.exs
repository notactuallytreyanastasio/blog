defmodule Blog.Chess.CheckTest do
  use ExUnit.Case, async: false

  alias Blog.Chess.{Check, Plane, Piece, Setup, Ledger}

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Build a minimal state from a plane, defaulting to white to move.
  defp state(plane, to_move \\ :white) do
    %Blog.Chess.State{
      plane: plane,
      to_move: to_move,
      ledger: Ledger.empty_ledger(),
      status: :erlang.make_tuple(9, :active),
      clocks: :erlang.make_tuple(9, 0),
      en_passant: nil,
      ply: 0
    }
  end

  # Place pieces onto an empty plane from a keyword list of {sq, piece}.
  defp plane_with(pairs) do
    Plane.with_pieces(Plane.empty_plane(), pairs)
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — rook attacks"
  # ---------------------------------------------------------------------------

  describe "in_check? with rook attacks" do
    test "rook on same rank checks the king" do
      # White king at (0,7), black rook at (7,7) — same local rank on board 0
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{7, 7}, Piece.new(:rook, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "rook on same file checks the king" do
      # White king at (3,0), black rook at (3,7) — same file on board 0
      plane =
        plane_with([
          {{3, 0}, Piece.new(:king, :white)},
          {{3, 7}, Piece.new(:rook, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "rook blocked by an intervening piece does NOT check the king" do
      # White king at (0,7), white pawn at (3,7) blocks the black rook at (7,7)
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{3, 7}, Piece.new(:pawn, :white)},
          {{7, 7}, Piece.new(:rook, :black)}
        ])

      refute Check.in_check?(state(plane), :white, 0)
    end

    test "rook on a different board does NOT check the king" do
      # White king at (0,7) on board 0, black rook at (0,15) on board 3 —
      # attack is clipped at the board boundary.
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{0, 15}, Piece.new(:rook, :black)}
        ])

      refute Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — bishop attacks"
  # ---------------------------------------------------------------------------

  describe "in_check? with bishop attacks" do
    test "bishop on a diagonal checks the king" do
      # White king at (0,7), black bishop at (7,0) — main diagonal, board 0
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{7, 0}, Piece.new(:bishop, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "bishop blocked by a piece does NOT check the king" do
      # Blocker at (3,4) breaks the diagonal
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{3, 4}, Piece.new(:pawn, :white)},
          {{7, 0}, Piece.new(:bishop, :black)}
        ])

      refute Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — queen attacks"
  # ---------------------------------------------------------------------------

  describe "in_check? with queen attacks" do
    test "queen on same rank checks the king (rook-like)" do
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{7, 7}, Piece.new(:queen, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "queen on a diagonal checks the king (bishop-like)" do
      # White king at (4,7), black queen at (7,4)
      plane =
        plane_with([
          {{4, 7}, Piece.new(:king, :white)},
          {{7, 4}, Piece.new(:queen, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — knight attacks"
  # ---------------------------------------------------------------------------

  describe "in_check? with knight attacks" do
    test "knight checks the king with an L-move" do
      # White king at (4,4), black knight at (6,5) — offset (+2, +1)
      plane =
        plane_with([
          {{4, 4}, Piece.new(:king, :white)},
          {{6, 5}, Piece.new(:knight, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "knight on wrong offset does NOT check the king" do
      # Black knight at (6,6) — offset (+2, +2), not a valid knight move
      plane =
        plane_with([
          {{4, 4}, Piece.new(:king, :white)},
          {{6, 6}, Piece.new(:knight, :black)}
        ])

      refute Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — pawn attacks"
  # ---------------------------------------------------------------------------

  describe "in_check? with pawn attacks" do
    test "black pawn diagonally forward checks the white king" do
      # A black pawn advances toward larger gy, so it attacks diagonally
      # downward (+dy). White king at (3,4), black pawn at (2,3) — the pawn
      # at (2,3) attacks (1,4) and (3,4).
      plane =
        plane_with([
          {{3, 4}, Piece.new(:king, :white)},
          {{2, 3}, Piece.new(:pawn, :black)}
        ])

      assert Check.in_check?(state(plane), :white, 0)
    end

    test "white pawn diagonally forward checks the black king" do
      # White advances toward smaller gy, attacks upward diagonals.
      # Black king at (3,4), white pawn at (2,5).
      plane =
        plane_with([
          {{3, 4}, Piece.new(:king, :black)},
          {{2, 5}, Piece.new(:pawn, :white)}
        ])

      assert Check.in_check?(state(plane, :black), :black, 0)
    end

    test "pawn directly in front does NOT check the king" do
      # A pawn directly in front (no diagonal offset) is not an attack.
      plane =
        plane_with([
          {{3, 4}, Piece.new(:king, :white)},
          {{3, 3}, Piece.new(:pawn, :black)}
        ])

      refute Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "in_check? — no king"
  # ---------------------------------------------------------------------------

  describe "in_check? with no king present" do
    test "returns false when the color has no king on the board" do
      # Plane has only a black rook — no white king.
      plane = plane_with([{{0, 7}, Piece.new(:rook, :black)}])
      refute Check.in_check?(state(plane), :white, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "any_check?"
  # ---------------------------------------------------------------------------

  describe "any_check?" do
    test "returns true when the king is in check on at least one board" do
      # White king on board 0, black rook on same rank
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{7, 7}, Piece.new(:rook, :black)}
        ])

      assert Check.any_check?(state(plane), :white)
    end

    test "returns false when the king is safe on all boards" do
      # White king alone — no attackers
      plane = plane_with([{{4, 7}, Piece.new(:king, :white)}])
      refute Check.any_check?(state(plane), :white)
    end

    test "skips frozen boards when checking any_check?" do
      # White king in check on board 0, but board 0 is frozen (checkmate).
      # any_check? should skip it and return false.
      plane =
        plane_with([
          {{0, 7}, Piece.new(:king, :white)},
          {{7, 7}, Piece.new(:rook, :black)}
        ])

      frozen_status =
        :erlang.setelement(1, :erlang.make_tuple(9, :active), {:checkmate, :black, :white})

      frozen_state = %Blog.Chess.State{
        plane: plane,
        to_move: :white,
        ledger: Ledger.empty_ledger(),
        status: frozen_status,
        clocks: :erlang.make_tuple(9, 0),
        en_passant: nil,
        ply: 0
      }

      refute Check.any_check?(frozen_state, :white)
    end
  end

  # ---------------------------------------------------------------------------
  # describe "initial setup invariants"
  # ---------------------------------------------------------------------------

  describe "initial setup" do
    setup do
      {:ok, state: Setup.initial_state()}
    end

    test "initial plane has 288 total pieces", %{state: s} do
      count = Plane.all_pieces(s.plane) |> length()
      assert count == 288
    end

    test "initial plane has 144 white pieces", %{state: s} do
      count = Plane.pieces_of(s.plane, :white) |> length()
      assert count == 144
    end

    test "initial plane has 144 black pieces", %{state: s} do
      count = Plane.pieces_of(s.plane, :black) |> length()
      assert count == 144
    end

    test "white back-rank on board 0 is in standard order", %{state: s} do
      # Board 0: origin (0,0). White back rank is local rank 7 → gy=7.
      back_rank = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

      actual =
        for file <- 0..7 do
          piece = Plane.piece_at(s.plane, {file, 7})
          assert piece != nil
          assert piece.color == :white
          piece.type
        end

      assert actual == back_rank
    end

    test "black back-rank on board 0 is in standard order", %{state: s} do
      # Board 0: black back rank is local rank 0 → gy=0.
      back_rank = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

      actual =
        for file <- 0..7 do
          piece = Plane.piece_at(s.plane, {file, 0})
          assert piece != nil
          assert piece.color == :black
          piece.type
        end

      assert actual == back_rank
    end

    test "white pawns are on local rank 6 for board 0", %{state: s} do
      # Board 0: gy = 0 + 6 = 6
      for file <- 0..7 do
        piece = Plane.piece_at(s.plane, {file, 6})
        assert piece != nil
        assert piece.color == :white
        assert piece.type == :pawn
      end
    end

    test "neither color is in check at game start", %{state: s} do
      refute Check.any_check?(s, :white)
      refute Check.any_check?(s, :black)
    end
  end
end
