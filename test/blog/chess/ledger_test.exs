defmodule Blog.Chess.LedgerTest do
  use ExUnit.Case, async: false

  alias Blog.Chess.Ledger
  alias Blog.Chess.Setup
  alias Blog.Chess.Pieces

  # ---------------------------------------------------------------------------
  # empty_ledger / credit_count baseline
  # ---------------------------------------------------------------------------

  describe "empty_ledger/0" do
    test "starts with no credits for any board/color/type combination" do
      l = Ledger.empty_ledger()
      assert Ledger.has_credit?(l, 0, :white, :bishop) == false
      assert Ledger.credit_count(l, 4, :black, :queen) == 0
    end

    test "returns an empty map" do
      assert Ledger.empty_ledger() == %{}
    end
  end

  # ---------------------------------------------------------------------------
  # add_credit
  # ---------------------------------------------------------------------------

  describe "add_credit/4" do
    test "grants exactly the targeted [board][color][type] slot" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 4, :white, :bishop)
      assert Ledger.credit_count(l, 4, :white, :bishop) == 1
    end

    test "adding credit does not affect other piece types on the same board/color" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 4, :white, :bishop)
      assert Ledger.credit_count(l, 4, :white, :knight) == 0
    end

    test "adding credit does not affect the opposite color" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 4, :white, :bishop)
      assert Ledger.credit_count(l, 4, :black, :bishop) == 0
    end

    test "adding credit does not affect the same type on a different board" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 4, :white, :bishop)
      assert Ledger.credit_count(l, 3, :white, :bishop) == 0
    end

    test "stacks: two add_credit calls produce count of 2" do
      l =
        Ledger.empty_ledger()
        |> Ledger.add_credit(2, :black, :rook)
        |> Ledger.add_credit(2, :black, :rook)

      assert Ledger.credit_count(l, 2, :black, :rook) == 2
    end

    test "does not mutate the input ledger" do
      original = Ledger.empty_ledger()
      _updated = Ledger.add_credit(original, 0, :white, :queen)
      # original must still be empty
      assert Ledger.credit_count(original, 0, :white, :queen) == 0
    end

    test "independent slots for all 9 boards" do
      l =
        Enum.reduce(0..8, Ledger.empty_ledger(), fn board, acc ->
          Ledger.add_credit(acc, board, :white, :pawn)
        end)

      for board <- 0..8 do
        assert Ledger.credit_count(l, board, :white, :pawn) == 1
      end
    end
  end

  # ---------------------------------------------------------------------------
  # has_credit?
  # ---------------------------------------------------------------------------

  describe "has_credit?/4" do
    test "returns false when ledger is empty" do
      l = Ledger.empty_ledger()
      assert Ledger.has_credit?(l, 0, :black, :knight) == false
    end

    test "returns true after a credit is granted" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 2, :black, :rook)
      assert Ledger.has_credit?(l, 2, :black, :rook) == true
    end

    test "returns false for a different type on the same board" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 2, :black, :rook)
      assert Ledger.has_credit?(l, 2, :black, :queen) == false
    end
  end

  # ---------------------------------------------------------------------------
  # spend_credit
  # ---------------------------------------------------------------------------

  describe "spend_credit/4" do
    test "debits down to a real zero" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 2, :black, :rook)
      assert {:ok, after_debit} = Ledger.spend_credit(l, 2, :black, :rook)
      assert Ledger.credit_count(after_debit, 2, :black, :rook) == 0
    end

    test "refuses to debit when empty — returns {:error, :no_credit}" do
      result = Ledger.spend_credit(Ledger.empty_ledger(), 0, :white, :pawn)
      assert result == {:error, :no_credit}
    end

    test "reduces count by exactly one when count > 1" do
      l =
        Ledger.empty_ledger()
        |> Ledger.add_credit(1, :white, :knight)
        |> Ledger.add_credit(1, :white, :knight)

      assert {:ok, after_one_spend} = Ledger.spend_credit(l, 1, :white, :knight)
      assert Ledger.credit_count(after_one_spend, 1, :white, :knight) == 1
    end

    test "second spend after balance hits zero returns {:error, :no_credit}" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 3, :white, :queen)
      {:ok, after_first} = Ledger.spend_credit(l, 3, :white, :queen)
      assert {:error, :no_credit} = Ledger.spend_credit(after_first, 3, :white, :queen)
    end

    test "spending does not mutate the input ledger" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 5, :black, :bishop)
      {:ok, _after} = Ledger.spend_credit(l, 5, :black, :bishop)
      # original must still hold the credit
      assert Ledger.credit_count(l, 5, :black, :bishop) == 1
    end

    test "spending one slot does not affect an independent slot" do
      l =
        Ledger.empty_ledger()
        |> Ledger.add_credit(0, :white, :rook)
        |> Ledger.add_credit(0, :black, :rook)

      {:ok, after_spend} = Ledger.spend_credit(l, 0, :white, :rook)
      assert Ledger.credit_count(after_spend, 0, :black, :rook) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # spend_crossing_credits/3
  # ---------------------------------------------------------------------------

  describe "spend_crossing_credits/3" do
    test "spends using to_board and credit_type from the crossing struct" do
      l = Ledger.add_credit(Ledger.empty_ledger(), 7, :white, :bishop)
      crossing = %{from_board: 4, to_board: 7, credit_type: :bishop}
      assert {:ok, after_spend} = Ledger.spend_crossing_credits(l, crossing, :white)
      assert Ledger.credit_count(after_spend, 7, :white, :bishop) == 0
    end

    test "returns {:error, :no_credit} when crossing has no credit" do
      crossing = %{from_board: 0, to_board: 1, credit_type: :queen}
      assert {:error, :no_credit} = Ledger.spend_crossing_credits(Ledger.empty_ledger(), crossing, :black)
    end
  end

  # ---------------------------------------------------------------------------
  # Setup integration — initial plane invariants
  # ---------------------------------------------------------------------------

  describe "initial plane setup" do
    setup do
      %{plane: Setup.initial_plane()}
    end

    test "288 total pieces on the initial plane", %{plane: plane} do
      count =
        0..575
        |> Enum.count(fn idx -> elem(plane, idx) != nil end)

      assert count == 288
    end

    test "144 white pieces and 144 black pieces", %{plane: plane} do
      all =
        for idx <- 0..575,
            piece = elem(plane, idx),
            piece != nil,
            do: piece.color

      whites = Enum.count(all, &(&1 == :white))
      blacks = Enum.count(all, &(&1 == :black))
      assert whites == 144
      assert blacks == 144
    end

    test "back rank order is [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]",
         %{plane: plane} do
      expected = Pieces.back_rank()

      # Check board 0 (top-left), white back rank at local rank 7 (gy = 7)
      actual =
        for file <- 0..7 do
          piece = elem(plane, Blog.Chess.cell_index({file, 7}))
          piece.type
        end

      assert actual == expected
    end

    test "white pieces sit on local ranks 6 and 7 within each board", %{plane: plane} do
      # For board 0: origin gy = 0, white rows are gy = 6 and gy = 7
      for board <- 0..8 do
        by = div(board, 3)
        origin_gy = by * 8
        origin_gx = rem(board, 3) * 8

        white_rows =
          for file <- 0..7, local_rank <- [6, 7] do
            sq = {origin_gx + file, origin_gy + local_rank}
            piece = elem(plane, Blog.Chess.cell_index(sq))
            piece && piece.color
          end

        assert Enum.all?(white_rows, &(&1 == :white)),
               "Board #{board}: expected white on local ranks 6-7"
      end
    end

    test "black pieces sit on local ranks 0 and 1 within each board", %{plane: plane} do
      for board <- 0..8 do
        by = div(board, 3)
        origin_gy = by * 8
        origin_gx = rem(board, 3) * 8

        black_rows =
          for file <- 0..7, local_rank <- [0, 1] do
            sq = {origin_gx + file, origin_gy + local_rank}
            piece = elem(plane, Blog.Chess.cell_index(sq))
            piece && piece.color
          end

        assert Enum.all?(black_rows, &(&1 == :black)),
               "Board #{board}: expected black on local ranks 0-1"
      end
    end

    test "initial ledger in game state is empty" do
      state = Setup.initial_state()
      assert state.ledger == Ledger.empty_ledger()
    end
  end
end
