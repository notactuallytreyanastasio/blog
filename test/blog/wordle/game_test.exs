defmodule Blog.Wordle.GameTest do
  use ExUnit.Case, async: true
  alias Blog.Wordle.Game

  @tag :wordle
  setup do
    # Create a test game instance
    game = %Game{
      player_id: "test-player",
      session_id: "test-session",
      target_word: "tests",
      guesses: [],
      current_guess: "",
      max_attempts: 6,
      game_over: false,
      win: false,
      hard_mode: false,
      used_letters: %{},
      message: nil
    }

    {:ok, %{game: game}}
  end

  @tag :wordle
  test "new game initializes with correct values", %{game: game} do
    assert game.player_id == "test-player"
    assert game.current_guess == ""
    assert game.guesses == []
    assert game.max_attempts == 6
    assert game.game_over == false
    assert game.hard_mode == false
  end

  @tag :wordle
  test "handle_key_press adds letter to current guess", %{game: game} do
    {:ok, updated_game} = Game.handle_key_press(game, "a")
    assert updated_game.current_guess == "a"

    # Add more letters
    {:ok, game2} = Game.handle_key_press(updated_game, "b")
    assert game2.current_guess == "ab"

    {:ok, game3} = Game.handle_key_press(game2, "c")
    assert game3.current_guess == "abc"
  end

  @tag :wordle
  test "handle_key_press handles backspace", %{game: game} do
    # Add some letters first
    {:ok, game1} = Game.handle_key_press(game, "a")
    {:ok, game2} = Game.handle_key_press(game1, "b")
    assert game2.current_guess == "ab"

    # Test backspace removes last letter
    {:ok, game3} = Game.handle_key_press(game2, "Backspace")
    assert game3.current_guess == "a"

    # Backspace on empty string should be harmless
    {:ok, game4} = Game.handle_key_press(%{game | current_guess: ""}, "Backspace")
    assert game4.current_guess == ""
  end

  @tag :wordle
  test "toggle_hard_mode switches hard mode setting", %{game: game} do
    # Initially hard mode is false
    assert game.hard_mode == false

    # Toggle it on
    {:ok, updated_game} = Game.toggle_hard_mode(game)
    assert updated_game.hard_mode == true

    # Toggle it off again
    {:ok, game2} = Game.toggle_hard_mode(updated_game)
    assert game2.hard_mode == false
  end

  @tag :wordle
  test "reset_game resets the game state", %{game: game} do
    # First modify the game state
    {:ok, game1} = Game.handle_key_press(game, "a")

    game_with_guesses = %{
      game1
      | guesses: [%{word: "guess", result: [:absent, :absent, :absent, :absent, :absent]}],
        game_over: true,
        win: true
    }

    # Now reset it
    reset_game = Game.reset_game(game_with_guesses)

    # Check that it's reset but preserves player and settings
    assert reset_game.player_id == "test-player"
    assert reset_game.current_guess == ""
    assert reset_game.guesses == []
    assert reset_game.game_over == false
    assert reset_game.win == false

    # Hard mode setting should be preserved
    hard_mode_game = %{game | hard_mode: true}
    reset_hard_mode_game = Game.reset_game(hard_mode_game)
    assert reset_hard_mode_game.hard_mode == true
  end
end
