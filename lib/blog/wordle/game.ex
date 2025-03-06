defmodule Blog.Wordle.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Wordle.{WordStore, GuessChecker}

  @primary_key false
  embedded_schema do
    field :target_word, :string
    field :current_guess, :string, default: ""
    field :guesses, {:array, :map}, default: []
    field :game_over, :boolean, default: false
    field :message, :string
    field :used_letters, :map, default: %{}
    field :max_attempts, :integer, default: 6
    field :hard_mode, :boolean, default: false
  end

  @word_length 5
  @max_attempts 6

  @doc """
  Creates a new game with a random target word.
  """
  def new do
    %__MODULE__{
      target_word: WordStore.get_random_word(),
      max_attempts: @max_attempts
    }
  end

  @doc """
  Validates and processes a changeset for the game.
  """
  def changeset(game, attrs) do
    cast(game, attrs, [
      :target_word,
      :current_guess,
      :guesses,
      :game_over,
      :message,
      :used_letters,
      :max_attempts,
      :hard_mode
    ])
  end

  @doc """
  Handles keyboard input based on the current state of the game.
  """
  def handle_key_press(game, key) do
    case {game.game_over, key, String.length(game.current_guess)} do
      {true, _key, _length} ->
        {:ok, game}

      {false, "Enter", @word_length} ->
        submit_guess(game)

      {false, "Backspace", _length} ->
        {:ok, %{game | current_guess: String.slice(game.current_guess, 0..-2)}}

      {false, key, length} when length < @word_length ->
        if key =~ ~r/^[a-zA-Z]$/ do
          {:ok, %{game | current_guess: game.current_guess <> String.downcase(key)}}
        else
          {:ok, game}
        end

      {false, _key, _length} ->
        {:ok, game}
    end
  end

  @doc """
  Submits the current guess and updates the game state.
  """
  def submit_guess(game) do
    guess = game.current_guess

    if WordStore.valid_guess?(guess) do
      check_result =
        if game.hard_mode do
          GuessChecker.check_guess(guess, game.target_word, game.guesses)
        else
          {:ok, GuessChecker.check_guess(guess, game.target_word)}
        end

      case check_result do
        {:ok, result} ->
          used_letters = update_used_letters(game.used_letters, guess, result)
          guesses = game.guesses ++ [%{word: guess, result: result}]

          won = guess == game.target_word
          lost = length(guesses) >= game.max_attempts

          game = %{
            game |
            current_guess: "",
            guesses: guesses,
            used_letters: used_letters,
            game_over: won || lost,
            message:
              case {won, lost} do
                {true, _} -> "Congratulations! You won!"
                {false, true} -> "Game Over! The word was #{game.target_word}"
                {false, false} -> nil
              end
          }

          {:ok, game}

        {:error, message} ->
          {:error, %{game | message: message, current_guess: ""}}
      end
    else
      {:error, %{game | message: "Not in word list"}}
    end
  end

  @doc """
  Toggles hard mode, only allowed if no guesses have been made.
  """
  def toggle_hard_mode(game) do
    if Enum.empty?(game.guesses) do
      {:ok, %{game | hard_mode: !game.hard_mode}}
    else
      {:error, %{game | message: "Can't change difficulty mid-game"}}
    end
  end

  @doc """
  Resets the game with a new target word.
  """
  def reset_game(game) do
    %{game |
      target_word: WordStore.get_random_word(),
      current_guess: "",
      guesses: [],
      game_over: false,
      message: nil,
      used_letters: %{}
    }
  end

  defp update_used_letters(used_letters, guess, results) do
    Enum.zip(String.graphemes(guess), results)
    |> Enum.reduce(used_letters, fn {char, result}, acc ->
      # Only upgrade the status of a letter (absent -> present -> correct)
      current_status = Map.get(acc, char)

      cond do
        current_status == :correct -> acc
        result == :correct -> Map.put(acc, char, :correct)
        current_status == :present -> acc
        result == :present -> Map.put(acc, char, :present)
        is_nil(current_status) -> Map.put(acc, char, result)
        true -> acc
      end
    end)
  end
end
