defmodule Blog.Chess.SetupTest do
  use ExUnit.Case, async: false

  alias Blog.Chess.Setup
  alias Blog.Chess.Plane
  alias Blog.Chess.Pieces
  alias Blog.Chess.Ledger
  alias Blog.Chess.State

  # Back rank order: [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]
  @back_rank Pieces.back_rank()

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp count_by_color(plane) do
    Enum.reduce(0..575, %{white: 0, black: 0}, fn idx, acc ->
      case elem(plane, idx) do
        nil -> acc
        piece -> Map.update!(acc, piece.color, &(&1 + 1))
      end
    end)
  end

  defp piece_at(plane, gx, gy), do: Plane.piece_at(plane, {gx, gy})

  # Board origin helpers: board N -> {ox, oy}
  defp origin(board_index) do
    {rem(board_index, 3) * 8, div(board_index, 3) * 8}
  end

  # ---------------------------------------------------------------------------
  # initial_plane/0 tests
  # ---------------------------------------------------------------------------

  describe "initial_plane/0" do
    test "returns a 576-element tuple" do
      plane = Setup.initial_plane()
      assert tuple_size(plane) == 576
    end

    test "places exactly 144 white pieces (16 per board × 9 boards)" do
      plane = Setup.initial_plane()
      counts = count_by_color(plane)
      assert counts.white == 144
    end

    test "places exactly 144 black pieces (16 per board × 9 boards)" do
      plane = Setup.initial_plane()
      counts = count_by_color(plane)
      assert counts.black == 144
    end

    test "places exactly 288 total pieces across all 9 boards" do
      plane = Setup.initial_plane()
      total = Enum.count(0..575, fn idx -> elem(plane, idx) != nil end)
      assert total == 288
    end

    test "white back rank for board 0 is at local rank 7 (gy = 7)" do
      plane = Setup.initial_plane()
      {ox, oy} = origin(0)

      for {expected_type, file} <- Enum.with_index(@back_rank, 0) do
        piece = piece_at(plane, ox + file, oy + 7)
        assert piece != nil, "expected a piece at file #{file}, rank 7 on board 0"
        assert piece.color == :white, "piece at file #{file} should be white"
        assert piece.type == expected_type,
               "file #{file}: expected #{expected_type}, got #{piece.type}"
      end
    end

    test "black back rank for board 0 is at local rank 0 (gy = 0)" do
      plane = Setup.initial_plane()
      {ox, oy} = origin(0)

      for {expected_type, file} <- Enum.with_index(@back_rank, 0) do
        piece = piece_at(plane, ox + file, oy + 0)
        assert piece != nil, "expected a piece at file #{file}, rank 0 on board 0"
        assert piece.color == :black, "piece at file #{file} should be black"
        assert piece.type == expected_type,
               "file #{file}: expected #{expected_type}, got #{piece.type}"
      end
    end

    test "white pawns are on local rank 6 for every board" do
      plane = Setup.initial_plane()

      for board <- 0..8 do
        {ox, oy} = origin(board)

        for file <- 0..7 do
          piece = piece_at(plane, ox + file, oy + 6)
          assert piece != nil, "expected white pawn at board #{board}, file #{file}, rank 6"
          assert piece.type == :pawn, "board #{board} file #{file}: expected pawn, got #{piece.type}"
          assert piece.color == :white, "board #{board} file #{file}: expected white"
        end
      end
    end

    test "black pawns are on local rank 1 for every board" do
      plane = Setup.initial_plane()

      for board <- 0..8 do
        {ox, oy} = origin(board)

        for file <- 0..7 do
          piece = piece_at(plane, ox + file, oy + 1)
          assert piece != nil, "expected black pawn at board #{board}, file #{file}, rank 1"
          assert piece.type == :pawn, "board #{board} file #{file}: expected pawn, got #{piece.type}"
          assert piece.color == :black, "board #{board} file #{file}: expected black"
        end
      end
    end

    test "local ranks 2-5 are empty on every board" do
      plane = Setup.initial_plane()

      for board <- 0..8, rank <- 2..5 do
        {ox, oy} = origin(board)

        for file <- 0..7 do
          piece = piece_at(plane, ox + file, oy + rank)
          assert piece == nil,
                 "expected empty square at board #{board}, file #{file}, rank #{rank}"
        end
      end
    end

    test "center board (board 4) has white king at file 4, local rank 7" do
      plane = Setup.initial_plane()
      # Board 4: origin = {8, 8}; king file = 4 → gx=12, gy=15
      piece = piece_at(plane, 12, 15)
      assert piece != nil
      assert piece.type == :king
      assert piece.color == :white
      assert piece.has_moved == false
    end

    test "center board (board 4) has black king at file 4, local rank 0" do
      plane = Setup.initial_plane()
      # Board 4: origin = {8, 8}; king file = 4 → gx=12, gy=8
      piece = piece_at(plane, 12, 8)
      assert piece != nil
      assert piece.type == :king
      assert piece.color == :black
      assert piece.has_moved == false
    end

    test "all pieces start with has_moved == false" do
      plane = Setup.initial_plane()

      for idx <- 0..575 do
        case elem(plane, idx) do
          nil -> :ok
          piece -> assert piece.has_moved == false, "piece at index #{idx} should have has_moved false"
        end
      end
    end

    test "each board has exactly 16 white and 16 black pieces" do
      plane = Setup.initial_plane()

      for board <- 0..8 do
        {ox, oy} = origin(board)

        {w, b} =
          for rank <- 0..7, file <- 0..7, reduce: {0, 0} do
            {w, b} ->
              case piece_at(plane, ox + file, oy + rank) do
                nil -> {w, b}
                %{color: :white} -> {w + 1, b}
                %{color: :black} -> {w, b + 1}
              end
          end

        assert w == 16, "board #{board} should have 16 white pieces, found #{w}"
        assert b == 16, "board #{board} should have 16 black pieces, found #{b}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # initial_state/0 tests
  # ---------------------------------------------------------------------------

  describe "initial_state/0" do
    setup do
      %{state: Setup.initial_state()}
    end

    test "returns a State struct", %{state: state} do
      assert %State{} = state
    end

    test "to_move is :white at the start", %{state: state} do
      assert state.to_move == :white
    end

    test "ply starts at 0", %{state: state} do
      assert state.ply == 0
    end

    test "en_passant is nil at start", %{state: state} do
      assert state.en_passant == nil
    end

    test "ledger is empty (no crossing credits)", %{state: state} do
      assert state.ledger == Ledger.empty_ledger()

      crossing_types = [:pawn, :knight, :bishop, :rook, :queen]

      for board <- 0..8, color <- [:white, :black], type <- crossing_types do
        assert Ledger.credit_count(state.ledger, board, color, type) == 0,
               "expected 0 credits for #{color} #{type} on board #{board}"
      end
    end

    test "status is a 9-element tuple with all boards :active", %{state: state} do
      assert tuple_size(state.status) == 9

      for board <- 0..8 do
        assert elem(state.status, board) == :active,
               "board #{board} should be :active"
      end
    end

    test "clocks is a 9-element tuple with all values 0", %{state: state} do
      assert tuple_size(state.clocks) == 9

      for board <- 0..8 do
        assert elem(state.clocks, board) == 0,
               "board #{board} clock should be 0"
      end
    end

    test "plane contains 288 pieces total", %{state: state} do
      total = Enum.count(0..575, fn idx -> elem(state.plane, idx) != nil end)
      assert total == 288
    end
  end
end
