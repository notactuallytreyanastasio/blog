defmodule BlogWeb.WordleLiveHelpersTest do
  use BlogWeb.LiveCase, async: true

  alias Blog.Wordle.Game

  # The presentation helpers in BlogWeb.WordleLive (color_class/1,
  # keyboard_color_class/1, keyboard_layout/0) are private implementation
  # details of the LiveView. They are no longer callable as public functions,
  # so we exercise them through the rendered markup of the live view itself.
  #
  # The board renders one tile per letter with the class produced by
  # color_class/1, and the on-screen keyboard renders one button per key from
  # keyboard_layout/0 with the class produced by keyboard_color_class/1.

  @tag :wordle
  test "keyboard_layout renders all required keys", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wordle")

    # Each letter key is rendered as a button carrying phx-value-key. The
    # layout downcases letters, so the values are the lowercase letters.
    for letter <- ?a..?z do
      key = <<letter::utf8>>
      assert html =~ ~s(phx-value-key="#{key}"),
             "expected keyboard to contain key #{key}"
    end

    # The action keys come from the layout too.
    assert html =~ ~s(phx-value-key="Enter")
    assert html =~ ~s(phx-value-key="Backspace")

    # Enter is shown verbatim; Backspace renders as the erase glyph.
    assert html =~ "Enter"
    assert html =~ "⌫"
  end

  @tag :wordle
  test "keyboard_color_class renders neutral class before any guesses", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wordle")

    # With no used letters, every key falls through to the nil clause.
    assert html =~ "bg-gray-200"
    # Colored keyboard classes only appear once letters have a status.
    refute html =~ "bg-green-600 text-white"
    refute html =~ "bg-yellow-500 text-white"
  end

  @tag :wordle
  test "color_class and keyboard_color_class render colored classes for a played game",
       %{conn: conn} do
    player_id = "test-player-#{System.unique_integer([:positive])}"

    {:ok, view, html} =
      conn
      |> put_connect_params(%{"player_id" => player_id})
      |> live("/wordle")

    # Sanity check: the live view adopted our player id.
    assert html =~ player_id

    # Craft a game state owned by this player whose single guess covers all
    # three letter statuses, plus matching used_letters so the keyboard keys
    # pick up colored classes too.
    game = %Game{
      session_id: player_id,
      player_id: player_id,
      target_word: "crane",
      current_guess: "",
      guesses: [%{word: "cabin", result: [:correct, :present, :absent, :absent, :present]}],
      used_letters: %{"c" => :correct, "a" => :present, "b" => :absent},
      game_over: false,
      max_attempts: 6,
      hard_mode: false,
      message: nil,
      last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    # The live view subscribes to the global games topic at mount and updates
    # its own board when it sees a broadcast for its session id.
    Phoenix.PubSub.broadcast(Blog.PubSub, Game.topic(), {:game_updated, game})

    rendered = render(view)

    # Tile classes from color_class/1 for each status branch.
    assert rendered =~ "bg-green-600 border-green-600"
    assert rendered =~ "bg-yellow-500 border-yellow-500"
    assert rendered =~ "bg-gray-600 border-gray-600"

    # Keyboard classes from keyboard_color_class/1 for each status branch.
    assert rendered =~ "bg-green-600 text-white"
    assert rendered =~ "bg-yellow-500 text-white"
    assert rendered =~ "bg-gray-600 text-white"
  end
end
