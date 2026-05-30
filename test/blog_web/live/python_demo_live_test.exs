defmodule BlogWeb.PythonDemoLiveTest do
  # async: false because :meck replaces Blog.PythonRunner globally.
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  alias Blog.PythonRunner

  describe "PythonDemoLive" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, ~p"/python-demo")

      assert disconnected_html =~ "Python.exe - Elixir Integration"
      assert render(page_live) =~ "Python.exe - Elixir Integration"
    end

    test "displays initial form elements", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      assert html =~ "Execute Python Code"
      assert html =~ "Write your Python code below"
      assert html =~ "Python Code:"
      assert html =~ "<textarea"
      assert html =~ "name=\"code\""
      assert html =~ "Execute Code"
    end

    test "form has correct attributes", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      assert html =~ "phx-submit=\"run-code\""
      assert html =~ "rows=\"8\""
      assert html =~ "spellcheck=\"false\""
      assert html =~ "font-mono"
    end

    test "renders the Win98 desktop chrome", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      # Window chrome / menubar specific to the current desktop-style UI
      assert html =~ "os-window"
      assert html =~ "os-titlebar"
      assert html =~ "os-menubar"
      assert html =~ "os-statusbar"
      # Status bar reports the idle state on mount
      assert html =~ "Ready"
    end

    test "shows result and clears executing state after a successful run", %{conn: conn} do
      :meck.new(PythonRunner, [:passthrough, :no_link])
      :meck.expect(PythonRunner, :run_python_code, fn _code -> {:ok, "hello world\n"} end)
      on_exit(fn -> :meck.unload(PythonRunner) end)

      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      # Submit code; the run-code event sends an async :execute_python message
      # which LiveViewTest drains synchronously before returning the render.
      page_live
      |> element("form")
      |> render_submit(%{code: "print('hello world')"})

      html = render(page_live)

      # Result block renders the stubbed output, executing state has cleared.
      assert html =~ "Result:"
      assert html =~ "hello world"
      refute html =~ "Executing..."
      assert called_with_code?("print('hello world')")
    end

    test "shows error block and clears executing state after a failed run", %{conn: conn} do
      :meck.new(PythonRunner, [:passthrough, :no_link])
      :meck.expect(PythonRunner, :run_python_code, fn _code -> {:error, "boom: NameError"} end)
      on_exit(fn -> :meck.unload(PythonRunner) end)

      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      page_live
      |> element("form")
      |> render_submit(%{code: "undefined_name"})

      html = render(page_live)

      assert html =~ "Error:"
      assert html =~ "boom: NameError"
      refute html =~ "Result:"
      refute html =~ "Executing..."
    end

    test "handles empty code submission", %{conn: conn} do
      :meck.new(PythonRunner, [:passthrough, :no_link])
      :meck.expect(PythonRunner, :run_python_code, fn _code -> {:ok, ""} end)
      on_exit(fn -> :meck.unload(PythonRunner) end)

      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      page_live
      |> element("form")
      |> render_submit(%{code: ""})

      # Empty code is forwarded to the runner without crashing the LiveView.
      assert called_with_code?("")
      assert render(page_live) =~ "Execute Python Code"
    end

    test "renders with correct CSS classes", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      # Content padding wrapper
      assert html =~ "os-content"

      # Form card container
      assert html =~ "bg-white border-2 inset p-4 mb-4"

      # Textarea styles
      assert html =~ "w-full p-2 border-2 inset font-mono text-sm bg-white"

      # Button styles (Win98 outset button)
      assert html =~ "px-4 py-2 border-2 outset"
    end

    test "initial socket assigns are correct", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      # executing: false -> the submit button shows the idle label, no spinner
      assert render(page_live) =~ "Execute Code"
      # result: nil
      refute render(page_live) =~ "Result:"
      # error: nil
      refute render(page_live) =~ "Error:"
    end

    test "mount sets correct initial state", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      html = render(page_live)

      # Should not show any results initially
      refute html =~ "Result:"
      refute html =~ "Error:"
      refute html =~ "Executing..."

      # Textarea should be empty (no @code content between the tags)
      assert html =~ "></textarea>"
    end

    test "has accessible form elements", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      # Label should be associated with textarea
      assert html =~ "for=\"code\""
      assert html =~ "id=\"code\""

      # Form should have proper structure
      assert html =~ "<form"
      assert html =~ "<label"
      assert html =~ "<textarea"
      assert html =~ "<button"
    end

    test "reset button restores the example code", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      html =
        page_live
        |> element("button[phx-click=\"reset\"]")
        |> render_click()

      # The reset event seeds the textarea with the example program.
      assert html =~ "def hello_world"
      assert html =~ "Hello from Python"
    end

    test "textarea preserves the @code assign value after reset", %{conn: conn} do
      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      # Initially empty
      assert render(page_live) =~ "></textarea>"

      # After reset the @code assign is reflected back into the textarea
      page_live
      |> element("button[phx-click=\"reset\"]")
      |> render_click()

      assert render(page_live) =~ "def hello_world"
    end

    test "examples section lists sample snippets", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      assert html =~ "Examples to Try"
      assert html =~ "import math"
      assert html =~ "sum_of_squares"
    end
  end

  describe "handle_event run-code" do
    test "forwards the submitted code to PythonRunner", %{conn: conn} do
      :meck.new(PythonRunner, [:passthrough, :no_link])
      :meck.expect(PythonRunner, :run_python_code, fn _code -> {:ok, "ok"} end)
      on_exit(fn -> :meck.unload(PythonRunner) end)

      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      page_live
      |> element("form")
      |> render_submit(%{code: "print('hello world')"})

      assert called_with_code?("print('hello world')")
    end

    test "handles code parameter correctly", %{conn: conn} do
      :meck.new(PythonRunner, [:passthrough, :no_link])
      :meck.expect(PythonRunner, :run_python_code, fn _code -> {:ok, "2"} end)
      on_exit(fn -> :meck.unload(PythonRunner) end)

      {:ok, page_live, _html} = live(conn, ~p"/python-demo")

      test_code = "x = 1 + 1\nprint(x)"

      page_live
      |> element("form")
      |> render_submit(%{code: test_code})

      assert called_with_code?(test_code)
      assert render(page_live) =~ "Result:"
    end
  end

  describe "UI responsiveness" do
    test "form is responsive on different screen sizes", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      # Window stretches to full viewport width
      assert html =~ "width: 100%"
      # Textarea is full width within the card
      assert html =~ "w-full"
    end

    test "textarea has proper styling", %{conn: conn} do
      {:ok, _page_live, html} = live(conn, ~p"/python-demo")

      assert html =~ "border-2 inset"
      assert html =~ "font-mono text-sm"
      assert html =~ "bg-white"
    end
  end

  # Returns true if PythonRunner.run_python_code was called with the given code.
  defp called_with_code?(code) do
    :meck.called(PythonRunner, :run_python_code, [code])
  end
end
