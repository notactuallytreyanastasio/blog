defmodule Blog.Wordle.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Wordle.{WordStore, GuessChecker, GameStore}

  @primary_key false
  embedded_schema do
    field(:session_id, :string)
    field(:player_id, :string)
    field(:target_word, :string)
    field(:current_guess, :string, default: "")
    field(:guesses, {:array, :map}, default: [])
    field(:game_over, :boolean, default: false)
    field(:message, :string)
    field(:used_letters, :map, default: %{})
    field(:max_attempts, :integer, default: 6)
    field(:hard_mode, :boolean, default: true)
    # Changed to string to avoid serialization issues
    field(:last_activity, :string, default: nil)
  end

  @word_length 5
  @max_attempts 6
  @topic "wordle:games"

  @doc """
  Creates a new game with a random target word.
  """
  def new(player_id \\ nil) do
    session_id = generate_session_id()
    player_id = player_id || "player-#{:rand.uniform(10000)}"

    game = %__MODULE__{
      session_id: session_id,
      player_id: player_id,
      target_word: WordStore.get_random_word(),
      max_attempts: @max_attempts,
      last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    # Save to ETS storage
    game = GameStore.save_game(game)

    # Broadcast that a new game has been created
    broadcast_update(game)

    game
  end

  @doc """
  Validates and processes a changeset for the game.
  """
  def changeset(game, attrs) do
    cast(game, attrs, [
      :session_id,
      :player_id,
      :target_word,
      :current_guess,
      :guesses,
      :game_over,
      :message,
      :used_letters,
      :max_attempts,
      :hard_mode,
      :last_activity
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
        game = %{
          game
          | current_guess: String.slice(game.current_guess, 0..-2),
            last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
        }

        broadcast_update(game)
        {:ok, game}

      {false, key, length} when length < @word_length ->
        if key =~ ~r/^[a-zA-Z]$/ do
          game = %{
            game
            | current_guess: game.current_guess <> String.downcase(key),
              last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
          }

          broadcast_update(game)
          {:ok, game}
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
            game
            | current_guess: "",
              guesses: guesses,
              used_letters: used_letters,
              game_over: won || lost,
              last_activity: DateTime.utc_now() |> DateTime.to_iso8601(),
              message:
                case {won, lost} do
                  {true, _} -> "Congratulations! You won!"
                  {false, true} -> "Game Over! The word was #{game.target_word}"
                  {false, false} -> nil
                end
          }

          broadcast_update(game)
          {:ok, game}

        {:error, message} ->
          game = %{
            game
            | message: message,
              current_guess: "",
              last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
          }

          broadcast_update(game)
          {:error, game}
      end
    else
      game = %{
        game
        | message: "Not in word list",
          last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
      }

      broadcast_update(game)
      {:error, game}
    end
  end

  @doc """
  Toggles hard mode, only allowed if no guesses have been made.
  """
  def toggle_hard_mode(game) do
    if Enum.empty?(game.guesses) do
      game = %{
        game
        | hard_mode: !game.hard_mode,
          last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
      }

      broadcast_update(game)
      {:ok, game}
    else
      game = %{
        game
        | message: "Can't change difficulty mid-game",
          last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
      }

      broadcast_update(game)
      {:error, game}
    end
  end

  @doc """
  Resets the game with a new target word.
  """
  def reset_game(game) do
    game = %{
      game
      | target_word: WordStore.get_random_word(),
        current_guess: "",
        guesses: [],
        game_over: false,
        message: nil,
        used_letters: %{},
        last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    broadcast_update(game)
    game
  end

  @doc """
  Returns the PubSub topic for wordle games
  """
  def topic, do: @topic

  @doc """
  Returns the specific topic for a single game
  """
  def game_topic(session_id), do: "#{@topic}:#{session_id}"

  defp broadcast_update(game) do
    # Debug broadcast
    IO.puts("Broadcasting update for game #{game.session_id}, player: #{game.player_id}")

    # Save to ETS storage before broadcasting
    GameStore.save_game(game)

    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:game_updated, game}
    )

    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      game_topic(game.session_id),
      {:game_updated, game}
    )
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
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
