defmodule Blog.Chess.Bot do
  @moduledoc """
  Alpha-beta negamax search for the chess9 variant.

  ## Functions

  - `best_move/2`  — return the best legal move for the side to move, or nil
  - `negamax/4`    — recursive alpha-beta search (package-private, exposed for testing)
  - `order_moves/2` — static move ordering: captures > crossings > quiet
  - `mulberry32/1` — deterministic 32-bit PRNG used only to break score ties
  """

  import Bitwise

  alias Blog.Chess.{Legal, Eval, Reducer, Scoring, Pieces, Move}
  alias Blog.Chess, as: C

  @interior_beam 30
  @root_width 12
  @tie_eps 1.0

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Choose the best move for `state.to_move` using alpha-beta negamax to `depth`.

  Returns a `Move.t()`, or `nil` when no legal moves exist.

  An RNG seeded from the current microsecond time breaks ties among moves that
  score within `#{@tie_eps}` centipawn of each other.
  """
  @spec best_move(C.State.t(), non_neg_integer()) :: Move.t() | nil
  def best_move(state, depth \\ 3) do
    seed = :erlang.system_time(:microsecond)
    scored = score_root(state, depth)

    case scored do
      [] ->
        nil

      moves ->
        best = Enum.reduce(moves, -:math.pow(10, 15), fn {_m, s}, acc -> max(s, acc) end)
        top = for {m, s} <- moves, s >= best - @tie_eps, do: m
        {rand, _seed2} = mulberry32(seed)
        pick = trunc(rand * length(top))
        Enum.at(top, pick, hd(top))
    end
  end

  @doc """
  Alpha-beta negamax.

  Returns the heuristic score from the perspective of `state.to_move`.
  """
  @spec negamax(C.State.t(), non_neg_integer(), float(), float()) :: float()
  def negamax(state, depth, alpha, beta) do
    if depth <= 0 or Scoring.game_over?(state.status) do
      Eval.leaf_score(state, state.to_move)
    else
      moves = Legal.legal_moves(state)

      if moves == [] do
        Eval.leaf_score(state, state.to_move)
      else
        candidates = order_moves(moves, state) |> Enum.take(@interior_beam)

        {best, _a, _cutoff} =
          Enum.reduce_while(candidates, {-:math.pow(10, 15), alpha, false}, fn move, {best, a, _} ->
            score = -negamax(Reducer.apply_unchecked(state, move), depth - 1, -beta, -a)
            new_best = max(best, score)
            new_a = max(a, new_best)

            if new_a >= beta do
              {:halt, {new_best, new_a, true}}
            else
              {:cont, {new_best, new_a, false}}
            end
          end)

        best
      end
    end
  end

  @doc """
  Order moves for search: captures (highest victim value first) > crossings > quiet.
  """
  @spec order_moves([Move.t()], C.State.t()) :: [Move.t()]
  def order_moves(moves, _state) do
    Enum.sort_by(moves, &move_priority/1, :desc)
  end

  @doc """
  Mulberry32 PRNG. Returns `{float_in_0_to_1, new_seed}`.

  Port of the TypeScript reference implementation in rng.ts.
  """
  @spec mulberry32(non_neg_integer()) :: {float(), non_neg_integer()}
  def mulberry32(seed) do
    a = band(seed + 0x6D2B79F5, 0xFFFFFFFF)

    t0 = band(bxor(a, bsr(a, 15)), 0xFFFFFFFF)
    t1 = band(t0 * bor(1, a), 0xFFFFFFFF)
    t2 = band(t1 + band(band(bxor(t1, bsr(t1, 7)), 0xFFFFFFFF) * bor(61, t1), 0xFFFFFFFF), 0xFFFFFFFF)
    t3 = band(bxor(t2, bsr(t2, 14)), 0xFFFFFFFF)

    {t3 / 4_294_967_296.0, a}
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Score root moves with a shallow depth-1 scan then full-depth search on top N.
  defp score_root(state, depth) do
    moves = Legal.legal_moves(state)

    if moves == [] do
      []
    else
      shallow =
        moves
        |> Enum.map(fn m ->
          next = Reducer.apply_unchecked(state, m)
          {m, Eval.evaluate(next, state.to_move)}
        end)
        |> Enum.sort_by(fn {_m, s} -> s end, :desc)

      if depth <= 1 do
        shallow
      else
        shallow
        |> Enum.take(@root_width)
        |> Enum.map(fn {m, _shallow_score} ->
          next = Reducer.apply_unchecked(state, m)
          score = -negamax(next, depth - 1, -:math.pow(10, 15), :math.pow(10, 15))
          {m, score}
        end)
      end
    end
  end

  # Higher = searched first.
  defp move_priority(%Move{captured: captured, crossing: crossing}) do
    capture_score =
      if captured != nil do
        10 * Pieces.value(captured.type)
      else
        0.0
      end

    crossing_score = if crossing != nil, do: 25.0, else: 0.0

    capture_score + crossing_score
  end
end
