defmodule Blog.Games.Twenty48 do
  @moduledoc false

  def new(size \\ 4) do
    %{
      board: blank_board(size),
      size: size,
      score: 0,
      game_over: false,
      won: false,
      new_tile: nil,
      merged_tiles: MapSet.new()
    }
    |> add_random_tile()
    |> add_random_tile()
  end

  def move(game, _dir) when game.game_over, do: game

  def move(game, direction) when direction in [:left, :right, :up, :down] do
    {new_board, score_gained, merged_positions} = shift(game.board, game.size, direction)

    if new_board == game.board do
      # Board didn't change — check if ANY direction works, otherwise game over
      if any_moves_left?(game) do
        game
      else
        %{game | game_over: true}
      end
    else
      %{game | board: new_board, score: game.score + score_gained, merged_tiles: merged_positions}
      |> add_random_tile()
      |> check_won()
      |> check_game_over()
    end
  end

  defp any_moves_left?(game) do
    Enum.any?([:left, :right, :up, :down], fn dir ->
      {new_board, _, _} = shift(game.board, game.size, dir)
      new_board != game.board
    end)
  end

  defp blank_board(size) do
    for r <- 0..(size - 1), c <- 0..(size - 1), into: %{}, do: {{r, c}, 0}
  end

  defp add_random_tile(game) do
    empty =
      for r <- 0..(game.size - 1),
          c <- 0..(game.size - 1),
          game.board[{r, c}] == 0,
          do: {r, c}

    case empty do
      [] -> %{game | new_tile: nil}
      cells ->
        pos = Enum.random(cells)
        val = if :rand.uniform(10) == 1, do: 4, else: 2
        %{game | board: Map.put(game.board, pos, val), new_tile: pos}
    end
  end

  defp check_won(game) do
    has_2048 =
      Enum.any?(0..(game.size - 1), fn r ->
        Enum.any?(0..(game.size - 1), fn c ->
          game.board[{r, c}] >= 2048
        end)
      end)

    %{game | won: has_2048}
  end

  defp check_game_over(game) do
    has_empty =
      Enum.any?(0..(game.size - 1), fn r ->
        Enum.any?(0..(game.size - 1), fn c ->
          game.board[{r, c}] == 0
        end)
      end)

    if has_empty do
      game
    else
      has_merge = has_adjacent_merge?(game.board, game.size)
      %{game | game_over: not has_merge}
    end
  end

  defp has_adjacent_merge?(board, size) do
    Enum.any?(0..(size - 1), fn r ->
      Enum.any?(0..(size - 1), fn c ->
        val = board[{r, c}]

        (c + 1 < size and board[{r, c + 1}] == val) or
          (r + 1 < size and board[{r + 1, c}] == val)
      end)
    end)
  end

  # -- Shift logic (now returns merged positions too) --

  defp shift(board, size, :left) do
    Enum.reduce(0..(size - 1), {board, 0, MapSet.new()}, fn row, {b, total, merged} ->
      tiles = for c <- 0..(size - 1), do: b[{row, c}]
      {result, score, merge_indices} = slide_and_merge(tiles, size)

      new_b =
        result
        |> Enum.with_index()
        |> Enum.reduce(b, fn {v, c}, acc -> Map.put(acc, {row, c}, v) end)

      new_merged = Enum.reduce(merge_indices, merged, fn i, acc -> MapSet.put(acc, {row, i}) end)
      {new_b, total + score, new_merged}
    end)
  end

  defp shift(board, size, :right) do
    Enum.reduce(0..(size - 1), {board, 0, MapSet.new()}, fn row, {b, total, merged} ->
      tiles = for c <- (size - 1)..0//-1, do: b[{row, c}]
      {result, score, merge_indices} = slide_and_merge(tiles, size)

      new_b =
        result
        |> Enum.with_index()
        |> Enum.reduce(b, fn {v, i}, acc -> Map.put(acc, {row, size - 1 - i}, v) end)

      new_merged = Enum.reduce(merge_indices, merged, fn i, acc -> MapSet.put(acc, {row, size - 1 - i}) end)
      {new_b, total + score, new_merged}
    end)
  end

  defp shift(board, size, :up) do
    Enum.reduce(0..(size - 1), {board, 0, MapSet.new()}, fn col, {b, total, merged} ->
      tiles = for r <- 0..(size - 1), do: b[{r, col}]
      {result, score, merge_indices} = slide_and_merge(tiles, size)

      new_b =
        result
        |> Enum.with_index()
        |> Enum.reduce(b, fn {v, r}, acc -> Map.put(acc, {r, col}, v) end)

      new_merged = Enum.reduce(merge_indices, merged, fn i, acc -> MapSet.put(acc, {i, col}) end)
      {new_b, total + score, new_merged}
    end)
  end

  defp shift(board, size, :down) do
    Enum.reduce(0..(size - 1), {board, 0, MapSet.new()}, fn col, {b, total, merged} ->
      tiles = for r <- (size - 1)..0//-1, do: b[{r, col}]
      {result, score, merge_indices} = slide_and_merge(tiles, size)

      new_b =
        result
        |> Enum.with_index()
        |> Enum.reduce(b, fn {v, i}, acc -> Map.put(acc, {size - 1 - i, col}, v) end)

      new_merged = Enum.reduce(merge_indices, merged, fn i, acc -> MapSet.put(acc, {size - 1 - i, col}) end)
      {new_b, total + score, new_merged}
    end)
  end

  defp slide_and_merge(tiles, size) do
    non_zero = Enum.filter(tiles, &(&1 != 0))
    {merged, score, merge_indices} = do_merge(non_zero, 0)
    padded = merged ++ List.duplicate(0, size - length(merged))
    {padded, score, merge_indices}
  end

  defp do_merge([x, x | rest], idx) do
    {rest_merged, rest_score, rest_indices} = do_merge(rest, idx + 1)
    {[x * 2 | rest_merged], x * 2 + rest_score, [idx | rest_indices]}
  end

  defp do_merge([x | rest], idx) do
    {rest_merged, rest_score, rest_indices} = do_merge(rest, idx + 1)
    {[x | rest_merged], rest_score, rest_indices}
  end

  defp do_merge([], _idx), do: {[], 0, []}
end
