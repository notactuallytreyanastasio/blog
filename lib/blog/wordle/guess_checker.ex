defmodule Blog.Wordle.GuessChecker do
  @doc """
  Checks a guess against the target word in normal mode.
  Returns a list of :correct, :present, or :absent atoms.
  """
  def check_guess(guess, target) do
    do_check_guess(guess, target)
  end

  @doc """
  Checks a guess against the target word in hard mode.
  Returns {:error, message} if the guess doesn't use required letters,
  or {:ok, results} with the list of :correct, :present, or :absent atoms.
  """
  def check_guess(guess, target, previous_results) when is_list(previous_results) do
    required_letters = get_required_letters(previous_results)

    if hard_mode_valid?(guess, required_letters) do
      {:ok, do_check_guess(guess, target)}
    else
      {:error, "Guess must use all discovered letters"}
    end
  end

  defp do_check_guess(guess, target) do
    # Convert strings to character lists
    guess_chars = String.graphemes(guess)
    target_chars = String.graphemes(target)

    # First pass: Find correct letters (green)
    {greens, remaining_target} =
      Enum.zip(guess_chars, target_chars)
      |> Enum.reduce({[], target_chars}, fn {g, t}, {results, target_acc} ->
        case g == t do
          true -> {results ++ [:correct], List.delete(target_acc, t)}
          false -> {results ++ [nil], target_acc}
        end
      end)

    # Second pass: Find present letters (yellow)
    guess_chars
    |> Enum.with_index()
    |> Enum.map(fn {char, i} ->
      case {Enum.at(greens, i), char in remaining_target} do
        {:correct, _} ->
          :correct

        {_, true} ->
          remaining_target = List.delete(remaining_target, char)
          :present

        _ ->
          :absent
      end
    end)
  end

  defp get_required_letters(previous_results) do
    previous_results
    |> Enum.flat_map(fn %{word: word, result: results} ->
      word
      |> String.graphemes()
      |> Enum.zip(results)
      |> Enum.filter(fn {_letter, result} -> result in [:correct, :present] end)
      |> Enum.map(fn {letter, result} -> {letter, result} end)
    end)
    |> Enum.into(%{}, fn {letter, result} -> {letter, result} end)
  end

  defp hard_mode_valid?(guess, required_letters) do
    guess_chars = String.graphemes(guess)

    Enum.all?(required_letters, fn {letter, _status} ->
      letter in guess_chars
    end)
  end
end
