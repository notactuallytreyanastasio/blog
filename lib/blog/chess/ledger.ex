defmodule Blog.Chess.Ledger do
  @moduledoc """
  Credit ledger for chess9 board crossings.

  A ledger is a plain map keyed by `{board_index, color, piece_type}` tuples,
  where the value is a non-negative integer credit count. Absent keys are
  treated as zero.

  Credits are granted when a piece is captured on a board (allowing that
  piece type for the capturing color to cross onto that board), and spent
  when a piece actually makes the crossing.
  """

  alias Blog.Chess, as: C

  # ---------------------------------------------------------------------------
  # Types
  # ---------------------------------------------------------------------------

  @type t :: C.Types.ledger()
  @type board_index :: C.Types.board_index()
  @type color :: C.Types.color()
  @type crossing_type :: C.Types.piece_type()
  @type crossing :: C.Types.crossing()

  # ---------------------------------------------------------------------------
  # API
  # ---------------------------------------------------------------------------

  @doc """
  Returns an empty ledger (no credits on any board).

      iex> Blog.Chess.Ledger.empty_ledger()
      %{}
  """
  @spec empty_ledger() :: t()
  def empty_ledger(), do: %{}

  @doc """
  Returns the credit count for `{board, color, crossing_type}`.
  Returns `0` when the key is absent.

      iex> ledger = Blog.Chess.Ledger.empty_ledger()
      iex> Blog.Chess.Ledger.credit_count(ledger, 0, :white, :pawn)
      0
  """
  @spec credit_count(t(), board_index(), color(), crossing_type()) :: non_neg_integer()
  def credit_count(ledger, board, color, crossing_type),
    do: Map.get(ledger, {board, color, crossing_type}, 0)

  @doc """
  Returns `true` when there is at least one credit for the given key.

      iex> ledger = Blog.Chess.Ledger.add_credit(Blog.Chess.Ledger.empty_ledger(), 2, :black, :rook)
      iex> Blog.Chess.Ledger.has_credit?(ledger, 2, :black, :rook)
      true
      iex> Blog.Chess.Ledger.has_credit?(ledger, 2, :black, :queen)
      false
  """
  @spec has_credit?(t(), board_index(), color(), crossing_type()) :: boolean()
  def has_credit?(ledger, board, color, crossing_type),
    do: credit_count(ledger, board, color, crossing_type) > 0

  @doc """
  Grants one credit for `{board, color, crossing_type}` and returns the
  updated ledger.
  """
  @spec add_credit(t(), board_index(), color(), crossing_type()) :: t()
  def add_credit(ledger, board, color, crossing_type) do
    key = {board, color, crossing_type}
    Map.update(ledger, key, 1, &(&1 + 1))
  end

  @doc """
  Spends one credit for `{board, color, crossing_type}`.

  Returns `{:ok, updated_ledger}` on success, or `{:error, :no_credit}` when
  the count is already zero.
  """
  @spec spend_credit(t(), board_index(), color(), crossing_type()) ::
          {:ok, t()} | {:error, :no_credit}
  def spend_credit(ledger, board, color, crossing_type) do
    key = {board, color, crossing_type}
    current = Map.get(ledger, key, 0)

    if current <= 0 do
      {:error, :no_credit}
    else
      {:ok, Map.put(ledger, key, current - 1)}
    end
  end

  @doc """
  Spends one crossing credit described by `crossing`.

  The credit spent is: `{crossing.to_board, color, crossing.credit_type}`.
  Returns `{:ok, updated_ledger}` or `{:error, :no_credit}`.
  """
  @spec spend_crossing_credits(t(), crossing(), color()) ::
          {:ok, t()} | {:error, :no_credit}
  def spend_crossing_credits(ledger, crossing, color),
    do: spend_credit(ledger, crossing.to_board, color, crossing.credit_type)
end
