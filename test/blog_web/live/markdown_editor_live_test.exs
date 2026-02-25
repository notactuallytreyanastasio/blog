defmodule BlogWeb.MarkdownEditorLiveTest do
  use BlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders the markdown editor page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/markdown-editor")

      assert html =~ "Markdown Editor"
      assert html =~ "Markdown Mode"
      assert has_element?(view, "#markdown-editor")
    end

    test "shows character count starting at zero", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/markdown-editor")

      assert html =~ "Characters: 0"
    end

    test "renders the window chrome elements", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      assert has_element?(view, ".os-titlebar")
      assert has_element?(view, ".os-menubar")
      assert has_element?(view, ".os-statusbar")
    end
  end

  describe "handle_event update_markdown" do
    test "updates markdown and renders HTML preview", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      html = render_change(view, "update_markdown", %{"markdown" => "# Hello World"})

      assert html =~ "Characters: 13"
    end

    test "handles empty markdown", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      html = render_change(view, "update_markdown", %{"markdown" => ""})

      assert html =~ "Characters: 0"
    end
  end

  describe "handle_event save_selection_info" do
    test "stores selection info in assigns", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      render_click(view, "save_selection_info", %{
        "position" => "5",
        "selection_start" => "2",
        "selection_end" => "8",
        "selected_text" => "hello"
      })

      # Verify the view is still alive and responsive
      assert has_element?(view, ".os-statusbar")
    end
  end

  describe "handle_event save_cursor_position" do
    test "stores cursor position", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      render_click(view, "save_cursor_position", %{"position" => "42"})

      assert has_element?(view, ".os-statusbar")
    end
  end

  describe "handle_info markdown_updated" do
    test "updates state when component sends markdown_updated message", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/markdown-editor")

      send(view.pid, {:markdown_updated, %{markdown: "# Test", html: "<h1>Test</h1>"}})

      html = render(view)
      assert html =~ "Characters: 6"
    end
  end
end
