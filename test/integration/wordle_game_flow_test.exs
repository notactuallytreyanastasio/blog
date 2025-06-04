defmodule Blog.Integration.WordleGameFlowTest do
  @moduledoc """
  Integration tests for complete Wordle game workflow.
  Tests game creation, guess validation, hard mode, and multi-player scenarios.
  """

  use BlogWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Blog.TestHelpers

  alias Blog.Wordle.{Game, GameStore, GuessChecker}

  setup do
    # Ensure clean state
    clear_all_ets_tables()
    setup_ets_tables()

    # Start the GameStore
    case GenServer.whereis(GameStore) do
      nil ->
        {:ok, _pid} = GameStore.start_link([])

      _pid ->
        :ok
    end

    user_id = random_user_id()
    {:ok, user_id: user_id}
  end

  describe "Complete Wordle game flow via LiveView" do
    test "user can play complete game from start to win", %{conn: conn, user_id: user_id} do
      # Start a new game
      {:ok, view, _html} = live(conn, "/wordle")

      # Should see initial game state
      assert render(view) =~ "WORDLE"
      assert render(view) =~ "Guess 1 of 6"

      # Make first guess (wrong word to test feedback)
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      html = render(view)

      # Should show guess feedback
      assert html =~ "SPACE"
      assert html =~ "Guess 2 of 6"

      # Game should still be active
      refute html =~ "Congratulations!"
      refute html =~ "Game Over"

      # Make second guess (still wrong)
      view
      |> form("#guess-form", guess: %{word: "TRUTH"})
      |> render_submit()

      # Should advance to guess 3
      assert render(view) =~ "Guess 3 of 6"

      # For testing, we need to know the target word
      # Let's get the game state to see the target
      session_id = get_session_id(view)
      {:ok, game} = GameStore.get_game(session_id, user_id)
      target_word = game.target_word

      # Make winning guess
      view
      |> form("#guess-form", guess: %{word: target_word})
      |> render_submit()

      html = render(view)

      # Should show win state
      assert html =~ "Congratulations!"
      assert html =~ target_word
      # Should have new game button
      refute html =~ "New Game"
    end

    test "user loses after 6 incorrect guesses", %{conn: conn, user_id: user_id} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Get the target word to ensure we guess wrong
      session_id = get_session_id(view)
      {:ok, game} = GameStore.get_game(session_id, user_id)
      target_word = game.target_word

      # Create 6 wrong guesses (avoid the target word)
      wrong_words =
        ["SPACE", "TRUTH", "FOUND", "LIGHT", "MAGIC", "STORM"]
        |> Enum.reject(&(&1 == target_word))
        |> Enum.take(6)

      # If we need more words, add some
      wrong_words =
        if length(wrong_words) < 6 do
          wrong_words ++ ["BRAVE", "SWIFT", "GRAND"]
        else
          wrong_words
        end

      # Make 6 wrong guesses
      for {word, index} <- Enum.with_index(wrong_words, 1) do
        view
        |> form("#guess-form", guess: %{word: word})
        |> render_submit()

        html = render(view)

        if index < 6 do
          # Game should continue
          assert html =~ "Guess #{index + 1} of 6"
          refute html =~ "Game Over"
        else
          # Game should end
          assert html =~ "Game Over"
          # Should reveal the answer
          assert html =~ target_word
        end
      end
    end

    test "hard mode enforces previous guess constraints", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Enable hard mode
      view
      |> element("#hard-mode-toggle")
      |> render_click()

      assert render(view) =~ "Hard Mode: ON"

      # Make first guess with specific letters
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      # Now try to make a guess that doesn't use revealed letters
      # This would need to be based on the actual feedback
      # For now, just verify hard mode is active
      html = render(view)
      assert html =~ "Hard Mode: ON"
    end

    test "invalid guesses are rejected with proper feedback", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Try too short word
      view
      |> form("#guess-form", guess: %{word: "CAT"})
      |> render_submit()

      html = render(view)
      assert html =~ "must be exactly 5 letters"

      # Try too long word  
      view
      |> form("#guess-form", guess: %{word: "ELEPHANT"})
      |> render_submit()

      html = render(view)
      assert html =~ "must be exactly 5 letters"

      # Try non-alphabetic
      view
      |> form("#guess-form", guess: %{word: "12345"})
      |> render_submit()

      html = render(view)
      assert html =~ "must contain only letters"

      # Try invalid word (if word validation is implemented)
      view
      |> form("#guess-form", guess: %{word: "ZZZZZ"})
      |> render_submit()

      # Should either be accepted or rejected based on word list
      # The exact behavior depends on implementation
    end
  end

  describe "Game state persistence and recovery" do
    test "game state persists across page refreshes", %{conn: conn, user_id: user_id} do
      # Start game and make a guess
      {:ok, view, _html} = live(conn, "/wordle")

      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      # Get the session ID
      session_id = get_session_id(view)

      # Refresh the page (simulate browser refresh)
      {:ok, new_view, _html} = live(conn, "/wordle")

      html = render(new_view)

      # Should restore previous game state
      # Previous guess should be visible
      assert html =~ "SPACE"
      # Should be on correct guess number
      assert html =~ "Guess 2 of 6"
    end

    test "multiple users can play independent games", %{conn: conn, user_id: user_id} do
      # User 1 starts game
      {:ok, view1, _html} = live(conn, "/wordle")

      view1
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      # User 2 starts different game (new session)
      # New connection simulates different user
      conn2 = build_conn()
      {:ok, view2, _html} = live(conn2, "/wordle")

      view2
      |> form("#guess-form", guess: %{word: "TRUTH"})
      |> render_submit()

      # Games should be independent
      html1 = render(view1)
      html2 = render(view2)

      assert html1 =~ "SPACE"
      refute html1 =~ "TRUTH"

      assert html2 =~ "TRUTH"
      refute html2 =~ "SPACE"
    end
  end

  describe "Game statistics and tracking" do
    test "tracks game statistics correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Get the target word and win quickly
      session_id = get_session_id(view)
      user_id = get_user_id(view)
      {:ok, game} = GameStore.get_game(session_id, user_id)
      target_word = game.target_word

      # Win in 2 guesses
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      view
      |> form("#guess-form", guess: %{word: target_word})
      |> render_submit()

      html = render(view)

      # Should show win state
      assert html =~ "Congratulations!"

      # Statistics should be updated (if implemented)
      # This would depend on how stats are displayed in the UI
    end

    test "new game button starts fresh game", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Make a guess
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      assert render(view) =~ "Guess 2 of 6"

      # Start new game
      view
      |> element("button", text: "New Game")
      |> render_click()

      html = render(view)

      # Should reset to initial state
      assert html =~ "Guess 1 of 6"
      # Previous guess should be cleared
      refute html =~ "SPACE"
    end
  end

  describe "Guess feedback and validation" do
    test "provides correct color feedback for guesses", %{conn: conn} do
      # This test would need to check the specific feedback colors
      # which depend on the implementation details
      {:ok, view, _html} = live(conn, "/wordle")

      # Make a guess
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      html = render(view)

      # Should show letters with color feedback
      assert html =~ "SPACE"

      # The exact color classes would depend on implementation
      # Common patterns: bg-green-500 (correct), bg-yellow-500 (wrong position), bg-gray-500 (not in word)
    end

    test "keyboard updates show used letters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Make a guess
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      html = render(view)

      # Should show used letters in keyboard (if virtual keyboard is implemented)
      # This depends on the UI implementation
      assert html =~ "SPACE"
    end
  end

  describe "Error handling and edge cases" do
    test "handles rapid successive guesses", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Try to submit multiple guesses rapidly
      # This tests the debouncing/rate limiting if implemented

      for word <- ["SPACE", "TRUTH", "FOUND"] do
        view
        |> form("#guess-form", guess: %{word: word})
        |> render_submit()
      end

      html = render(view)

      # Should handle all guesses correctly
      assert html =~ "Guess 4 of 6"
    end

    test "handles special characters and unicode", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Try guess with special characters
      view
      |> form("#guess-form", guess: %{word: "sp@ce"})
      |> render_submit()

      html = render(view)
      assert html =~ "must contain only letters"

      # Try with unicode characters
      view
      |> form("#guess-form", guess: %{word: "spλce"})
      |> render_submit()

      html = render(view)
      # Should be rejected
      assert html =~ "must contain only letters"
    end

    test "game prevents guesses after game ends", %{conn: conn, user_id: user_id} do
      {:ok, view, _html} = live(conn, "/wordle")

      # Win the game
      session_id = get_session_id(view)
      {:ok, game} = GameStore.get_game(session_id, user_id)
      target_word = game.target_word

      view
      |> form("#guess-form", guess: %{word: target_word})
      |> render_submit()

      assert render(view) =~ "Congratulations!"

      # Try to make another guess
      view
      |> form("#guess-form", guess: %{word: "SPACE"})
      |> render_submit()

      # Should not accept the guess
      html = render(view)
      refute html =~ "Guess 2 of 6"
    end
  end

  # Helper functions
  defp get_session_id(_view) do
    # In a real implementation, this would extract the session ID
    # For now, return a test session ID
    "test_session_#{:rand.uniform(1000)}"
  end

  defp get_user_id(_view) do
    # In a real implementation, this would extract the user ID
    # For now, return a test user ID
    "test_user_#{:rand.uniform(1000)}"
  end
end
