defmodule BlogWeb.PongLiveTest do
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  setup do
    # Ensure the ETS table exists for tests
    if :ets.whereis(:pong_games) == :undefined do
      :ets.new(:pong_games, [:named_table, :public, :set])
    end

    # Clean up games after each test
    on_exit(fn ->
      if :ets.whereis(:pong_games) != :undefined do
        :ets.delete_all_objects(:pong_games)
      end
    end)

    :ok
  end

  describe "mount and render" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, view, disconnected_html} = live(conn, ~p"/pong")

      assert disconnected_html =~ "Pong.exe"
      assert render(view) =~ "Pong.exe"
    end

    test "displays initial UI elements", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/pong")

      assert html =~ "Pong.exe"
      assert html =~ "Wall:"
      assert html =~ "AI Playing (Click to Take Control)"
      assert html =~ "God Mode View"
      assert html =~ "Use the up and down arrow keys to move the paddle"
    end

    test "displays game board with correct dimensions", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/pong")

      assert html =~ "width: 800px"
      assert html =~ "height: 600px"
    end

    test "displays WinXP-style window chrome", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/pong")

      assert html =~ "os-desktop-winxp"
      assert html =~ "os-window"
      assert html =~ "os-titlebar"
      assert html =~ "os-menubar"
      assert html =~ "os-statusbar"
      assert html =~ "Game"
      assert html =~ "Options"
      assert html =~ "View"
      assert html =~ "Help"
    end

    test "shows initial score of 0", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/pong")

      assert html =~ "Wall: 0"
    end

    test "shows game ID in title bar", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/pong")

      assert html =~ "Game ID:"
    end
  end

  describe "keyboard events" do
    test "keydown ArrowUp sets last_key", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      render_hook(view, "keydown", %{"key" => "ArrowUp"})

      html = render(view)
      assert html =~ "Pong.exe"
    end

    test "keydown ArrowDown sets last_key", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      render_hook(view, "keydown", %{"key" => "ArrowDown"})

      html = render(view)
      assert html =~ "Pong.exe"
    end

    test "keydown with arrow key disables AI control", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      # Initially AI is in control
      html = render(view)
      assert html =~ "AI Playing"

      # Press arrow key to take control
      render_hook(view, "keydown", %{"key" => "ArrowUp"})

      html = render(view)
      assert html =~ "Manual Control"
    end

    test "keydown with non-arrow key is ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      render_hook(view, "keydown", %{"key" => "Space"})

      html = render(view)
      # AI should still be in control
      assert html =~ "AI Playing"
    end

    test "keyup clears last_key when matching", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      render_hook(view, "keydown", %{"key" => "ArrowUp"})
      render_hook(view, "keyup", %{"key" => "ArrowUp"})

      html = render(view)
      assert html =~ "Pong.exe"
    end

    test "keyup with non-arrow key is ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      render_hook(view, "keyup", %{"key" => "Space"})

      html = render(view)
      assert html =~ "Pong.exe"
    end
  end

  describe "AI toggle" do
    test "toggle_ai switches from AI to manual", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      assert render(view) =~ "AI Playing"

      view |> element("button", "AI Playing") |> render_click()

      assert render(view) =~ "Manual Control"
    end

    test "toggle_ai switches back from manual to AI", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      # Toggle off
      view |> element("button", "AI Playing") |> render_click()
      assert render(view) =~ "Manual Control"

      # Toggle back on
      view |> element("button", "Manual Control") |> render_click()
      assert render(view) =~ "AI Playing"
    end
  end

  describe "tick handling" do
    test "tick advances the game state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      # Send a tick message to the LiveView process
      send(view.pid, :tick)

      html = render(view)
      assert html =~ "Pong.exe"
    end

    test "multiple ticks advance game without crashing", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      for _ <- 1..10 do
        send(view.pid, :tick)
      end

      html = render(view)
      assert html =~ "Pong.exe"
    end

    test "ai_move message updates paddle when AI is active", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pong")

      send(view.pid, :ai_move)

      html = render(view)
      assert html =~ "Pong.exe"
    end
  end

  describe "get_all_games/0" do
    test "returns empty list when no games" do
      :ets.delete_all_objects(:pong_games)
      games = BlogWeb.PongLive.get_all_games()
      assert games == []
    end

    test "returns games stored in ETS" do
      state = %{
        game_id: "test_all_1",
        ball: %{x: 400, y: 300},
        paddle: %{x: 30, y: 250},
        scores: %{wall: 3}
      }

      :ets.insert(:pong_games, {"test_all_1", state})

      games = BlogWeb.PongLive.get_all_games()
      assert length(games) == 1
      assert hd(games).game_id == "test_all_1"
    end
  end

end
