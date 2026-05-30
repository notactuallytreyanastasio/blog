defmodule Blog.Chess.Scoring do
  @moduledoc """
  End-of-game scoring for the chess9 variant.

  Works directly on the 9-element `status` tuple from `Blog.Chess.State`
  and on the 576-element `plane` tuple for material counting.
  """

  alias Blog.Chess, as: C
  alias Blog.Chess.Pieces

  # ---------------------------------------------------------------------------
  # Board-level result counting
  # ---------------------------------------------------------------------------

  @doc """
  Returns the number of boards where `color` has won by checkmate.

  A board contributes to the count when its status is
  `{:checkmate, ^color, _}` — i.e. `color` is the winning side.

      iex> s = {
      ...>   {:checkmate, :white, :black},
      ...>   :active,
      ...>   :stalemate,
      ...>   {:checkmate, :white, :black},
      ...>   {:checkmate, :black, :white},
      ...>   :active,
      ...>   :active,
      ...>   :active,
      ...>   :active
      ...> }
      iex> Blog.Chess.Scoring.boards_won(s, :white)
      2
      iex> Blog.Chess.Scoring.boards_won(s, :black)
      1
  """
  @spec boards_won(tuple(), C.color()) :: non_neg_integer()
  def boards_won(statuses, color) do
    for i <- 0..8,
        elem(statuses, i) == {:checkmate, color, C.opposite(color)},
        reduce: 0 do
      acc -> acc + 1
    end
  end

  # ---------------------------------------------------------------------------
  # Terminal state detection
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` when every board is in a frozen (terminal) state.

  A board is frozen when its status is checkmate, stalemate, or a draw.
  Active and check statuses are not frozen.

      iex> frozen = {
      ...>   {:checkmate, :white, :black},
      ...>   :stalemate,
      ...>   {:draw, :fifty_move},
      ...>   {:checkmate, :black, :white},
      ...>   :stalemate,
      ...>   {:draw, :insufficient_material},
      ...>   {:checkmate, :white, :black},
      ...>   :stalemate,
      ...>   {:checkmate, :black, :white}
      ...> }
      iex> Blog.Chess.Scoring.game_over?(frozen)
      true

      iex> active = {
      ...>   :active,
      ...>   :stalemate,
      ...>   {:draw, :fifty_move},
      ...>   {:checkmate, :black, :white},
      ...>   :stalemate,
      ...>   {:draw, :insufficient_material},
      ...>   {:checkmate, :white, :black},
      ...>   :stalemate,
      ...>   {:checkmate, :black, :white}
      ...> }
      iex> Blog.Chess.Scoring.game_over?(active)
      false
  """
  @spec game_over?(tuple()) :: boolean()
  def game_over?(statuses) do
    Enum.all?(0..8, fn i -> C.frozen?(elem(statuses, i)) end)
  end

  # ---------------------------------------------------------------------------
  # Winner determination
  # ---------------------------------------------------------------------------

  @doc """
  Returns the game result once all boards are frozen.

  Compares the number of boards won by each side. The player who has
  checkmated on more boards wins; equal counts produce a draw.

  Returns `{:winner, color}` or `:draw`.

      iex> s = {
      ...>   {:checkmate, :white, :black},
      ...>   {:checkmate, :white, :black},
      ...>   :stalemate,
      ...>   {:checkmate, :black, :white},
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate
      ...> }
      iex> Blog.Chess.Scoring.winner(s)
      {:winner, :white}

      iex> s = {
      ...>   {:checkmate, :white, :black},
      ...>   {:checkmate, :black, :white},
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate,
      ...>   :stalemate
      ...> }
      iex> Blog.Chess.Scoring.winner(s)
      :draw
  """
  @spec winner(tuple()) :: {:winner, C.color()} | :draw
  def winner(statuses) do
    w = boards_won(statuses, :white)
    b = boards_won(statuses, :black)

    cond do
      w > b -> {:winner, :white}
      b > w -> {:winner, :black}
      true -> :draw
    end
  end

  # ---------------------------------------------------------------------------
  # Material counting
  # ---------------------------------------------------------------------------

  @doc """
  Returns the total material value for `color` across all 576 cells of `plane`.

  Sums `Pieces.value/1` for every piece belonging to `color`. The king
  contributes 0.0 (as per `Pieces.value/1`), so only active fighting pieces
  add to the score.

      iex> plane = Blog.Chess.Setup.initial_plane()
      iex> white = Blog.Chess.Scoring.material_score(plane, :white)
      iex> black = Blog.Chess.Scoring.material_score(plane, :black)
      iex> white == black
      true
      iex> white > 0.0
      true
  """
  @spec material_score(C.plane(), C.color()) :: float()
  def material_score(plane, color) do
    for idx <- 0..575,
        piece = elem(plane, idx),
        piece != nil,
        piece.color == color,
        reduce: 0.0 do
      acc -> acc + Pieces.value(piece.type)
    end
  end
end
