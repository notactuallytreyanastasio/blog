defmodule Blog.Chess.MoveGenTest do
  use ExUnit.Case, async: false

  alias Blog.Chess
  alias Blog.Chess.{MoveGen, Setup, Plane, Piece, Ledger, State}

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Build a minimal State with only the given pieces on board 0, all boards active.
  defp state_with(piece_list, opts \\ []) do
    plane =
      Enum.reduce(piece_list, Plane.empty_plane(), fn {sq, piece}, acc ->
        Plane.with_piece(acc, sq, piece)
      end)

    ledger = Keyword.get(opts, :ledger, Ledger.empty_ledger())
    to_move = Keyword.get(opts, :to_move, :white)
    status = Keyword.get(opts, :status, :erlang.make_tuple(9, :active))

    %State{
      plane: plane,
      to_move: to_move,
      ledger: ledger,
      status: status,
      clocks: :erlang.make_tuple(9, 0),
      en_passant: nil,
      ply: 0
    }
  end

  defp crossings(moves), do: Enum.filter(moves, fn m -> m.crossing != nil end)

  defp frozen_status(board_idx) do
    :erlang.setelement(board_idx + 1, :erlang.make_tuple(9, :active), {:checkmate, :white, :black})
  end

  # ---------------------------------------------------------------------------
  # setup_test: verify initial plane invariants
  # ---------------------------------------------------------------------------

  describe "initial plane setup" do
    test "has exactly 288 total pieces across all 9 boards" do
      plane = Setup.initial_plane()
      all = Plane.all_pieces(plane)
      assert length(all) == 288
    end

    test "white and black each have 144 pieces" do
      plane = Setup.initial_plane()
      white = Plane.pieces_of(plane, :white)
      black = Plane.pieces_of(plane, :black)
      assert length(white) == 144
      assert length(black) == 144
    end

    test "back rank of board 0 is the standard order for white" do
      plane = Setup.initial_plane()
      back_rank_types = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

      for {expected_type, file} <- Enum.with_index(back_rank_types) do
        piece = Plane.piece_at(plane, {file, 7})
        assert piece != nil, "expected piece at file #{file}, rank 7 (white back rank)"
        assert piece.color == :white
        assert piece.type == expected_type
      end
    end

    test "white pieces on board 0 occupy only local ranks 6 and 7 (gy 6 and 7)" do
      plane = Setup.initial_plane()

      white_board0 = Plane.board_pieces(plane, :white, 0)

      for {sq, _piece} <- white_board0 do
        {_gx, gy} = sq
        assert gy in [6, 7], "expected white piece at gy 6 or 7, got gy=#{gy}"
      end
    end

    test "each board has 32 pieces (16 per side)" do
      plane = Setup.initial_plane()

      for board <- 0..8 do
        white_count = length(Plane.board_pieces(plane, :white, board))
        black_count = length(Plane.board_pieces(plane, :black, board))
        assert white_count == 16, "board #{board}: expected 16 white, got #{white_count}"
        assert black_count == 16, "board #{board}: expected 16 black, got #{black_count}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Pawn pushes
  # ---------------------------------------------------------------------------

  describe "pawn pushes" do
    test "white pawn on home rank emits a single push and a double push" do
      # Board 0: white pawn at {4, 6} (local rank 6 = home rank)
      pawn = Piece.new(:pawn, :white, false)
      state = state_with([{{4, 6}, pawn}])

      moves = MoveGen.pseudo_legal_moves(state)

      single = Enum.find(moves, fn m -> m.kind == :normal and m.to == {4, 5} end)
      double = Enum.find(moves, fn m -> m.kind == :double_pawn and m.to == {4, 4} end)

      assert single != nil, "expected a single push to {4,5}"
      assert double != nil, "expected a double push to {4,4}"
    end

    test "white pawn that has already moved does not get a double push" do
      pawn = Piece.new(:pawn, :white, true)
      state = state_with([{{4, 6}, pawn}])

      moves = MoveGen.pseudo_legal_moves(state)

      assert Enum.all?(moves, fn m -> m.kind != :double_pawn end),
             "moved pawn should not generate a double push"
    end

    test "white pawn one step from promotion emits four promotion moves" do
      # Rank 1 local on board 0 is gy=1; pushing forward lands at gy=0 (local rank 0 — promotion)
      pawn = Piece.new(:pawn, :white, true)
      state = state_with([{{4, 1}, pawn}])

      moves = MoveGen.pseudo_legal_moves(state)
      promos = Enum.filter(moves, fn m -> m.kind == :promotion end)

      assert length(promos) == 4, "expected 4 promotion moves, got #{length(promos)}"

      promote_to_types = MapSet.new(promos, fn m -> m.promote_to end)
      assert promote_to_types == MapSet.new([:queen, :rook, :bishop, :knight])
    end

    test "white pawn is blocked by a piece directly in front" do
      pawn = Piece.new(:pawn, :white, false)
      blocker = Piece.new(:rook, :black)
      state = state_with([{{4, 6}, pawn}, {{4, 5}, blocker}])

      moves = MoveGen.pseudo_legal_moves(state)

      refute Enum.any?(moves, fn m -> m.to == {4, 5} end),
             "pawn should not push into a blocker"
    end

    test "white pawn cannot push forward across a board boundary" do
      # Board 4: origin (8,8). A pawn at {8, 8} (local rank 0 of board 4) pushing
      # forward would move to {8,7} which belongs to board 1 — that is a seam crossing.
      pawn = Piece.new(:pawn, :white, true)
      state = state_with([{{8, 8}, pawn}])

      moves = MoveGen.pseudo_legal_moves(state)

      assert Enum.all?(moves, fn m -> m.kind != :normal or m.crossing == nil or
               Blog.Chess.board_of(m.to) == Blog.Chess.board_of(m.from) end),
             "pawn forward push should never cross a board seam"

      # More directly: no push at all since {8,7} is board 1
      assert Enum.filter(moves, fn m -> m.kind in [:normal, :double_pawn] end) == [],
             "pawn at top edge of board 4 should have no forward pushes"
    end
  end

  # ---------------------------------------------------------------------------
  # Pawn diagonal captures
  # ---------------------------------------------------------------------------

  describe "pawn diagonal captures" do
    test "white pawn captures diagonally into an enemy piece on the same board" do
      pawn = Piece.new(:pawn, :white, true)
      enemy = Piece.new(:rook, :black)
      state = state_with([{{4, 4}, pawn}, {{5, 3}, enemy}])

      moves = MoveGen.pseudo_legal_moves(state)
      capture = Enum.find(moves, fn m -> m.to == {5, 3} end)

      assert capture != nil
      assert capture.captured.type == :rook
    end

    test "white pawn does not capture a friendly piece diagonally" do
      pawn = Piece.new(:pawn, :white, true)
      friendly = Piece.new(:rook, :white)
      state = state_with([{{4, 4}, pawn}, {{5, 3}, friendly}])

      moves = MoveGen.pseudo_legal_moves(state)
      refute Enum.any?(moves, fn m -> m.to == {5, 3} end)
    end
  end

  # ---------------------------------------------------------------------------
  # Knight L-shapes
  # ---------------------------------------------------------------------------

  describe "knight L-shapes" do
    test "knight in the center of a board generates up to 8 candidate squares" do
      # {11, 11} = center of board 4, all 8 L-jumps stay within board 4
      knight = Piece.new(:knight, :white)
      state = state_with([{{11, 11}, knight}])

      moves = MoveGen.pseudo_legal_moves(state)

      assert length(moves) == 8, "central knight should have 8 moves, got #{length(moves)}"
    end

    test "knight at a corner only generates 2 moves within the same board" do
      # {0,0} corner of board 0: only {1,2} and {2,1} are in-bounds
      knight = Piece.new(:knight, :white)
      state = state_with([{{0, 0}, knight}])

      moves = MoveGen.pseudo_legal_moves(state)
      # No crossing credit, so cross-board L-jumps are blocked
      same_board_moves = Enum.filter(moves, fn m -> m.crossing == nil end)
      assert length(same_board_moves) == 2
    end

    test "knight at board 0 corner emits no crossing moves without a credit" do
      # {7,7} is the corner shared by boards 0/1/3/4.
      # L-jumps {9,8} and {8,9} would cross to other boards.
      knight = Piece.new(:knight, :white)
      state = state_with([{{7, 7}, knight}])

      moves = MoveGen.pseudo_legal_moves(state)
      assert crossings(moves) == [], "knight should not cross without a credit"
    end

    test "knight at board corner generates crossing moves only for boards with credit" do
      # {7,7} is a corner of board 0. From this square, L-jumps reach boards 1, 3, and 4.
      # Grant a credit only for board 1; only those L-jump destinations on board 1 should appear.
      knight = Piece.new(:knight, :white)

      ledger = Ledger.add_credit(Ledger.empty_ledger(), 1, :white, :knight)

      state = state_with([{{7, 7}, knight}], ledger: ledger)

      moves = MoveGen.pseudo_legal_moves(state)
      crossed = crossings(moves)

      # {9,6} and {8,5} both land on board 1
      assert length(crossed) == 2, "expected 2 crossing L-jumps to board 1, got #{length(crossed)}"
      assert Enum.all?(crossed, fn m -> Chess.board_of(m.to) == 1 end)
    end
  end

  # ---------------------------------------------------------------------------
  # King is board-bound
  # ---------------------------------------------------------------------------

  describe "king moves" do
    test "king never emits a move onto another board" do
      # Place king at {7,7}, corner of board 0
      king = Piece.new(:king, :white, true)
      state = state_with([{{7, 7}, king}])

      moves = MoveGen.pseudo_legal_moves(state)
      from_board = Chess.board_of({7, 7})

      assert Enum.all?(moves, fn m -> Chess.board_of(m.to) == from_board end),
             "king should never move to a different board"
    end

    test "king has no crossing field on any of its moves" do
      king = Piece.new(:king, :white, true)
      state = state_with([{{3, 3}, king}])

      moves = MoveGen.pseudo_legal_moves(state)
      assert Enum.all?(moves, fn m -> m.crossing == nil end)
    end
  end

  # ---------------------------------------------------------------------------
  # Castling — happy path
  # ---------------------------------------------------------------------------

  describe "castling" do
    test "white king can castle kingside when path is clear and neither piece has moved" do
      king = Piece.new(:king, :white, false)
      rook = Piece.new(:rook, :white, false)
      # board 0: king at {4,7}, kingside rook at {7,7}
      state = state_with([{{4, 7}, king}, {{7, 7}, rook}])

      moves = MoveGen.pseudo_legal_moves(state)
      castle = Enum.find(moves, fn m -> m.kind == :castle_kingside end)

      assert castle != nil, "expected a kingside castle move"
      assert castle.to == {6, 7}
      assert castle.rook_from == {7, 7}
      assert castle.rook_to == {5, 7}
    end

    test "white king can castle queenside when path is clear and neither piece has moved" do
      king = Piece.new(:king, :white, false)
      rook = Piece.new(:rook, :white, false)
      state = state_with([{{4, 7}, king}, {{0, 7}, rook}])

      moves = MoveGen.pseudo_legal_moves(state)
      castle = Enum.find(moves, fn m -> m.kind == :castle_queenside end)

      assert castle != nil, "expected a queenside castle move"
      assert castle.to == {2, 7}
      assert castle.rook_from == {0, 7}
      assert castle.rook_to == {3, 7}
    end

    test "king that has moved cannot castle" do
      king = Piece.new(:king, :white, true)
      rook = Piece.new(:rook, :white, false)
      state = state_with([{{4, 7}, king}, {{7, 7}, rook}])

      moves = MoveGen.pseudo_legal_moves(state)
      refute Enum.any?(moves, fn m -> m.kind in [:castle_kingside, :castle_queenside] end)
    end

    test "castling is blocked when a piece stands between king and rook" do
      king = Piece.new(:king, :white, false)
      rook = Piece.new(:rook, :white, false)
      blocker = Piece.new(:bishop, :white)
      state = state_with([{{4, 7}, king}, {{7, 7}, rook}, {{6, 7}, blocker}])

      moves = MoveGen.pseudo_legal_moves(state)
      refute Enum.any?(moves, fn m -> m.kind == :castle_kingside end)
    end
  end

  # ---------------------------------------------------------------------------
  # Frozen boards
  # ---------------------------------------------------------------------------

  describe "frozen boards" do
    test "pieces on a frozen board generate no moves" do
      rook = Piece.new(:rook, :white)
      # board 0 is board index 0, and we freeze it
      state = state_with([{{3, 3}, rook}], status: frozen_status(0))

      moves = MoveGen.pseudo_legal_moves(state)
      assert moves == [], "pieces on frozen board should generate no moves"
    end

    test "pieces can still move when a different board is frozen" do
      rook = Piece.new(:rook, :white)
      # rook on board 4 (center), freeze board 0
      state = state_with([{{11, 11}, rook}], status: frozen_status(0))

      moves = MoveGen.pseudo_legal_moves(state)
      assert length(moves) > 0, "rook on active board 4 should still have moves"
    end

    test "crossing into a frozen board is blocked even with a credit" do
      # Rook on board 1 ({8,7}) — can slide left toward {7,7} which is board 0
      rook = Piece.new(:rook, :white)
      ledger = Ledger.add_credit(Ledger.empty_ledger(), 0, :white, :rook)
      state = state_with([{{8, 7}, rook}], ledger: ledger, status: frozen_status(0))

      moves = MoveGen.pseudo_legal_moves(state)
      assert Enum.all?(moves, fn m -> Chess.board_of(m.to) != 0 end),
             "should not be able to cross into a frozen board"
    end
  end
end
