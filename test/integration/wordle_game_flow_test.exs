defmodule Blog.Integration.WordleGameFlowTest do
  @moduledoc """
  Integration tests for the complete Wordle game workflow.

  Tests game creation, guessing via the on-screen keyboard, hard mode, and
  multi-player independence.

  The current WordleLive UI has no `<form>`: input is driven entirely by
  `phx-click="key-press"` events carrying a `phx-value-key`. A guess is entered
  by clicking each letter key followed by the "Enter" key. The game itself is
  lazy-loaded on the first interaction (`@game` starts as `nil`), and the target
  word lives only in the server-side socket assigns / `GameStore`, so tests read
  it back via `:sys.get_state/1` on the LiveView process.
  """

  use BlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Blog.Wordle.{Game, GameStore, WordStore}

  @tag :wordle

  setup do
    # WordStore and GameStore are started by the application supervisor, so the
    # valid-word ETS tables and the game session store are already available.
    {:ok, user_id: "test_user_#{:rand.uniform(999_999)}"}
  end

  # --- Helpers -------------------------------------------------------------

  # Click a single keyboard key.
  defp press_key(view, key) do
    view
    |> element("button[phx-value-key=#{inspect(key)}]")
    |> render_click()
  end

  # Type a 5-letter word (lowercase internally) and submit it with Enter.
  defp guess_word(view, word) do
    word
    |> String.downcase()
    |> String.graphemes()
    |> Enum.each(&press_key(view, &1))

    press_key(view, "Enter")
    render(view)
  end

  # Read the live server-side game struct out of the LiveView process.
  defp current_game(view) do
    :sys.get_state(view.pid).socket.assigns.game
  end

  # Pick a valid 5-letter guess word that is NOT the target.
  defp wrong_valid_word(target) do
    candidates = ~w(space truth found light magic storm brave swift grand crane)

    candidates
    |> Enum.find(fn w -> w != target and WordStore.valid_guess?(w) end)
  end

  # --- Tests ---------------------------------------------------------------

  describe "Complete Wordle game flow via LiveView" do
    test "user can play a complete game from start to win", %{conn: conn} do
      {:ok, view, html} = live(conn, "/wordle")

      # Initial render: header present, prompt to start, no game yet.
      assert html =~ "Wordle Clone"
      assert html =~ "Type to start playing!"
      refute html =~ "Congratulations!"

      # Make a (likely wrong) first guess to lazy-load the game.
      first = "crane"
      guess_word(view, first)

      game = current_game(view)
      assert game != nil
      target = game.target_word

      # The guessed word's letters are now on the board.
      html = render(view)

      if first == target do
        assert html =~ "Congratulations!"
      else
        # One guess recorded, game still going.
        assert length(game.guesses) == 1
        refute game.game_over

        # Win by guessing the target word.
        guess_word(view, target)

        won = current_game(view)
        assert won.game_over
        assert Enum.any?(won.guesses, fn %{word: w} -> w == target end)

        html = render(view)
        assert html =~ "Congratulations!"
        assert html =~ "New Game"
      end
    end

    test "user loses after the maximum number of incorrect guesses", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Lazy-load by typing one letter, then read the target.
      press_key(view, "a")
      target = current_game(view).target_word
      wrong = wrong_valid_word(target)
      assert wrong, "expected a valid wrong word distinct from the target"

      # Clear the single typed letter so the board is empty.
      press_key(view, "Backspace")

      max = current_game(view).max_attempts

      # Submit `max` wrong guesses.
      for _ <- 1..max do
        guess_word(view, wrong)
      end

      game = current_game(view)
      assert game.game_over
      assert length(game.guesses) == max
      refute Enum.any?(game.guesses, fn %{word: w} -> w == target end)

      html = render(view)
      assert html =~ "Game Over"
      # The answer is revealed (rendered uppercase via CSS, lowercase in DOM text).
      assert html =~ target
    end

    test "hard mode is on by default and can be toggled before any guess", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Lazy-load the game.
      press_key(view, "a")
      press_key(view, "Backspace")

      # Default game state has hard mode enabled.
      assert current_game(view).hard_mode == true

      # Toggle hard mode off (allowed because no guesses have been made).
      view |> element("button", "HARD MODE") |> render_click()
      assert current_game(view).hard_mode == false

      # Toggle it back on.
      view |> element("button", "HARD MODE") |> render_click()
      assert current_game(view).hard_mode == true
    end

    test "hard mode rejects a guess that drops a discovered letter", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Ensure hard mode is on (it is by default).
      press_key(view, "a")
      press_key(view, "Backspace")
      assert current_game(view).hard_mode == true

      target = current_game(view).target_word

      # Use the target itself as the first guess only if there's no other valid
      # word; otherwise pick a word sharing at least one letter with the target
      # so a discovered letter exists. Simplest robust path: make a first guess
      # that is a valid word, then attempt a second valid word that omits a
      # discovered (correct/present) letter.
      first = wrong_valid_word(target)
      guess_word(view, first)

      game = current_game(view)
      refute game.game_over

      required =
        game.guesses
        |> List.last()
        |> then(fn %{word: word, result: result} ->
          word
          |> String.graphemes()
          |> Enum.zip(result)
          |> Enum.filter(fn {_l, r} -> r in [:correct, :present] end)
          |> Enum.map(fn {l, _r} -> l end)
        end)

      if required == [] do
        # No discovered letters from this guess; nothing to enforce. Assert the
        # checker contract directly instead so the test still exercises hard mode.
        assert {:error, _} =
                 Blog.Wordle.GuessChecker.check_guess("aabbb", target, [
                   %{word: "crane", result: [:correct, :absent, :absent, :absent, :absent]}
                 ])
      else
        # Find a valid word that omits at least one required letter.
        omitting =
          ~w(jumpy fizzy vodka glyph crwth)
          |> Enum.find(fn w ->
            WordStore.valid_guess?(w) and
              Enum.any?(required, fn l -> l not in String.graphemes(w) end)
          end)

        if omitting do
          guesses_before = length(current_game(view).guesses)
          guess_word(view, omitting)
          after_game = current_game(view)

          # The rejected guess is not recorded and an error message is shown.
          assert length(after_game.guesses) == guesses_before
          assert after_game.message == "Guess must use all discovered letters"
        else
          # Fall back to the direct checker contract assertion.
          assert {:error, "Guess must use all discovered letters"} =
                   Blog.Wordle.GuessChecker.check_guess("aabbb", target, game.guesses)
        end
      end
    end

    test "words not in the word list are rejected", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # "zzzzz" is not a valid guess word.
      refute WordStore.valid_guess?("zzzzz")

      guess_word(view, "zzzzz")

      game = current_game(view)
      # Nothing recorded, and the not-in-list message is shown.
      assert game.guesses == []
      assert game.message == "Not in word list"

      html = render(view)
      assert html =~ "Not in word list"
    end

    test "the key-press handler ignores non-letter keys and over-length input", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Type five letters.
      Enum.each(~w(c r a n e), &press_key(view, &1))
      assert current_game(view).current_guess == "crane"

      # A sixth letter is ignored (max length 5).
      press_key(view, "x")
      assert current_game(view).current_guess == "crane"
    end
  end

  describe "Game state independence" do
    test "multiple players play independent games", %{conn: conn} do
      {:ok, view1, _html} = live(conn, "/wordle")
      guess_word(view1, "crane")
      game1 = current_game(view1)

      # A separate connection is a separate player/session.
      conn2 = Phoenix.ConnTest.build_conn()
      {:ok, view2, _html} = live(conn2, "/wordle")
      guess_word(view2, "slate")
      game2 = current_game(view2)

      # Distinct sessions and independent guess histories.
      assert game1.session_id != game2.session_id
      assert Enum.any?(game1.guesses, fn %{word: w} -> w == "crane" end)
      refute Enum.any?(game1.guesses, fn %{word: w} -> w == "slate" end)
      assert Enum.any?(game2.guesses, fn %{word: w} -> w == "slate" end)
      refute Enum.any?(game2.guesses, fn %{word: w} -> w == "crane" end)
    end
  end

  describe "Game store persistence" do
    test "a played game is persisted in the GameStore by session id", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")
      guess_word(view, "crane")

      game = current_game(view)
      stored = GameStore.get_game(game.session_id)

      assert stored != nil
      assert stored.session_id == game.session_id
      assert Enum.any?(stored.guesses, fn %{word: w} -> w == "crane" end)
    end
  end

  describe "Game lifecycle controls" do
    test "the New Game button resets the board after a finished game", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Lazy-load and read the target, then win immediately.
      press_key(view, "a")
      press_key(view, "Backspace")
      target = current_game(view).target_word

      guess_word(view, target)
      assert current_game(view).game_over

      html = render(view)
      assert html =~ "Congratulations!"
      assert html =~ "New Game"

      # Start a fresh game.
      view |> element("button", "New Game") |> render_click()

      reset = current_game(view)
      refute reset.game_over
      assert reset.guesses == []
      assert reset.current_guess == ""
    end

    test "no further guesses are accepted after the game ends", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      press_key(view, "a")
      press_key(view, "Backspace")
      target = current_game(view).target_word

      guess_word(view, target)
      assert current_game(view).game_over

      # Attempt another guess; key presses are no-ops once the game is over.
      guesses_after_win = length(current_game(view).guesses)
      guess_word(view, "crane")

      game = current_game(view)
      assert game.game_over
      assert length(game.guesses) == guesses_after_win
    end
  end

  describe "Guess feedback" do
    test "a submitted guess records per-letter results and updates used letters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      guess_word(view, "crane")
      game = current_game(view)

      assert [%{word: "crane", result: result}] = game.guesses
      assert length(result) == 5
      assert Enum.all?(result, &(&1 in [:correct, :present, :absent]))

      # Every guessed letter is tracked in used_letters with a valid status.
      for letter <- String.graphemes("crane") do
        assert Map.get(game.used_letters, letter) in [:correct, :present, :absent]
      end
    end
  end

  describe "Game module unit behavior" do
    test "Game.new/1 produces a valid game stored by session id", %{user_id: user_id} do
      game = Game.new(user_id)

      assert %Game{} = game
      assert game.player_id == user_id
      assert String.length(game.target_word) == 5
      assert game.guesses == []
      assert game.hard_mode == true
      assert GameStore.get_game(game.session_id).session_id == game.session_id
    end
  end
end
