defmodule BlogWeb.WordleLiveInterfaceTest do
  use BlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  # The presentation helpers `color_class/1`, `keyboard_color_class/1` and
  # `keyboard_layout/0` are private functions inside `BlogWeb.WordleLive`
  # (they used to be public). Rather than call them directly, this test
  # exercises them through the only interface that still exposes them: the
  # rendered LiveView. That keeps the assertions honest about real behavior.

  @tag :wordle
  test "keyboard layout renders every required key", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/wordle")

    # Trigger a key press so the game is lazily initialized and the board
    # (with its full on-screen keyboard) is rendered.
    html = render_keypress(view, "a")

    # Enter and Backspace controls are present.
    assert html =~ ~s(phx-value-key="Enter")
    assert html =~ ~s(phx-value-key="Backspace")

    # Every letter a-z is rendered as a keyboard button.
    for letter <- ?a..?z do
      key = <<letter::utf8>>
      assert html =~ ~s(phx-value-key="#{key}"),
             "expected keyboard to include a button for #{inspect(key)}"
    end
  end

  @tag :wordle
  test "unused keyboard keys use the default (gray) color class", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/wordle")

    # Press a non-letter to initialize the game without recording any guesses,
    # so no letters have been used yet.
    html = render_keypress(view, "Enter")

    # keyboard_color_class(nil) -> "bg-gray-200"
    assert html =~ "bg-gray-200"
  end

  @tag :wordle
  test "a submitted guess colors its tiles via color_class/1", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/wordle")

    # "crane" is a valid guess word. The first guess has no hard-mode
    # constraints, so it is always accepted regardless of the random target.
    for <<letter::utf8 <- "crane">> do
      render_keypress(view, <<letter::utf8>>)
    end

    html = render_keypress(view, "Enter")

    # Each of the five tiles is :correct, :present, or :absent, so every tile
    # gets one of the colored classes from color_class/1. Whatever the random
    # target, the rendered guess row must contain at least one of them.
    assert html =~ "bg-green-600 border-green-600" or
             html =~ "bg-yellow-500 border-yellow-500" or
             html =~ "bg-gray-600 border-gray-600",
           "expected the submitted guess row to render a colored tile class"

    # The guess was accepted (not rejected as an invalid word).
    refute html =~ "Not in word list"
  end

  defp render_keypress(view, key) do
    view
    |> element("button[phx-value-key=\"#{key}\"]")
    |> render_click()
  end
end
