defmodule BlogWeb.TerminalLiveTest do
  use BlogWeb.ConnCase
  import Phoenix.LiveViewTest

  # The desktop only renders after the boot splash is dismissed; without this
  # every assertion below would be made against the splash screen instead.
  defp desktop(conn, path \\ "/") do
    {:ok, live, _} = live(conn, path)
    render_click(live, "skip_splash")
    live
  end

  # The bare class names "leica-warning-overlay" / "leica-viewer-window" are
  # unreliable needles: the component's <style> block is rendered on every
  # page (it's not conditional on @show_leica), and it defines CSS rules for
  # both of those classes. So a bare substring match "passes" whether or not
  # the element is actually on the page. Matching on the opening tag with its
  # id/class attribute avoids the false positive.
  defp warning_open?(html), do: html =~ ~s(class="leica-warning-overlay")
  defp viewer_open?(html), do: html =~ ~s(id="leica-viewer-window")

  describe "leica viewer: warning -> loading -> viewing" do
    test "the desktop icon opens the size warning, not the viewer", %{conn: conn} do
      live = desktop(conn)

      html = render_click(live, "toggle_leica")

      assert warning_open?(html)
      assert html =~ "Large File Warning"
      refute viewer_open?(html)
    end

    test "confirming the warning starts the download shell with the image hidden", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")

      html = render_click(live, "confirm_leica")

      refute warning_open?(html)
      assert viewer_open?(html)
      assert html =~ "Downloading 110 MB..."
      # The full-res image is in the DOM already so the <img> load event can
      # fire, but it stays invisible until the hook shows it.
      assert html =~ ~s(class="leica-img" style="opacity: 0;")
    end

    test "leica_loaded flips the assign to :viewing without unmounting the viewer", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")

      # Note: nothing in assets/js/hooks/leica_viewer.js actually pushes this
      # event back to the server — the hook only flips local DOM/opacity on
      # image load. So :viewing is currently reachable only by firing the
      # event by hand, as below; this test pins the server-side half of the
      # state machine so a future wiring-up doesn't regress it silently.
      html = render_click(live, "leica_loaded")

      assert viewer_open?(html)
    end

    test "?leica=1 skips the warning and lands straight in the loading state", %{conn: conn} do
      live = desktop(conn, "/?leica=1")

      html = render(live)

      refute warning_open?(html)
      assert viewer_open?(html)
      assert html =~ "Downloading 110 MB..."
    end

    test "closing from any state fully resets it, so reopening starts at the warning again", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")
      render_click(live, "leica_loaded")

      html = render_click(live, "close_leica")
      refute warning_open?(html)
      refute viewer_open?(html)

      # Reopening after a full viewing session goes back to the warning step,
      # not straight to the viewer — there's no "remember this session" state.
      html = render_click(live, "toggle_leica")
      assert warning_open?(html)
      refute viewer_open?(html)
    end

    test "a late leica_loaded arriving after close reopens the viewer", %{conn: conn} do
      live = desktop(conn)
      render_click(live, "toggle_leica")
      render_click(live, "confirm_leica")
      render_click(live, "close_leica")

      # handle_event("leica_loaded", ...) sets show_leica: :viewing
      # unconditionally, with no check that a viewer is still open. A stale
      # event (e.g. an <img> load that resolves after the user already
      # closed the window) reopens it straight into :viewing.
      html = render_click(live, "leica_loaded")

      assert viewer_open?(html)
    end
  end

  describe "AIM chat: name dialog and messages" do
    test "a new visitor is prompted to pick a screen name, not welcomed back", %{conn: conn} do
      live = desktop(conn)

      html = render_click(live, "toggle_chat")

      assert html =~ "Enter Screen Name"
      refute html =~ "Welcome Back!"
    end

    test "saving a name confirms the chatter and closes the name dialog", %{conn: conn} do
      live = desktop(conn)
      render_click(live, "toggle_chat")

      html = render_click(live, "save_name", %{"name" => "Zaphod"})

      # The buddy list only picks up the new name once the async presence
      # diff round-trips back through PubSub, so it isn't in this render yet.
      # What *is* synchronous is the dialog closing and the mobile "Name"
      # taskbar button dropping out, since both read @chatter directly.
      refute html =~ "Enter Screen Name"
      refute html =~ "✏️ Name"
    end

    test "saving a blank name is a no-op, so the dialog stays open", %{conn: conn} do
      live = desktop(conn)
      render_click(live, "toggle_chat")

      html = render_click(live, "save_name", %{"name" => "   "})

      assert html =~ "Enter Screen Name"
    end

    test "skipping assigns an anonymous name and unlocks the message form", %{conn: conn} do
      live = desktop(conn)
      render_click(live, "toggle_chat")

      html = render_click(live, "skip_name")

      refute html =~ "Enter Screen Name"
      refute html =~ "✏️ Name"
    end

    test "a message can't be sent before a chatter exists, and can after skipping", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_chat")

      # No chatter yet: the handler is a no-op, so the empty-state banner
      # is still there and nothing crashes.
      html = render_click(live, "send_chat_message", %{"message" => "hello?"})
      assert html =~ "Welcome! Say hello!"
      refute html =~ "hello?"

      render_click(live, "skip_name")
      html = render_click(live, "send_chat_message", %{"message" => "hello!"})

      assert html =~ "hello!"
    end
  end

  describe "museum window and mobile taskbar" do
    setup do
      n = System.unique_integer([:positive])

      {:ok, widget} =
        Blog.Museum.Projects.create_project(%{
          slug: "test-widget-#{n}",
          title: "Test Widget",
          tagline: "A widget for testing",
          description: "It widgets.",
          category: "test-cat-a-#{n}",
          sort_order: 900,
          visible: true
        })

      {:ok, gadget} =
        Blog.Museum.Projects.create_project(%{
          slug: "test-gadget-#{n}",
          title: "Test Gadget",
          tagline: "A gadget for testing",
          category: "test-cat-b-#{n}",
          sort_order: 901,
          visible: true
        })

      %{widget: widget, gadget: gadget}
    end

    # museum-detail-window is also a CSS selector in the unconditional
    # <style> block, so (per the trap already logged in deciduous) we match
    # on the id attribute rather than the bare class name.
    test "selecting a project opens its detail window; closing it clears the selection", %{
      conn: conn,
      widget: widget
    } do
      live = desktop(conn)

      html = render_click(live, "museum_select", %{"slug" => widget.slug})
      assert html =~ ~s(id="museum-detail-window")
      assert html =~ "Test Widget"

      html = render_click(live, "museum_close_detail")
      refute html =~ ~s(id="museum-detail-window")
    end

    # description is not in Project.changeset's validate_required list, so
    # nil is a legitimate value in the DB. The template used to call
    # String.trim/1 on it unconditionally and crash the LiveView process the
    # moment such a project was selected — this pins the fix.
    test "a project with no description doesn't crash the detail view", %{conn: conn} do
      {:ok, undocumented} =
        Blog.Museum.Projects.create_project(%{
          slug: "test-undocumented-#{System.unique_integer([:positive])}",
          title: "Test Undocumented",
          category: "test-cat-c",
          sort_order: 902,
          visible: true
        })

      live = desktop(conn)

      html = render_click(live, "museum_select", %{"slug" => undocumented.slug})

      assert html =~ ~s(id="museum-detail-window")
      assert html =~ "Test Undocumented"
    end

    test "filtering by category narrows the list and marks that tag active", %{
      conn: conn,
      widget: widget,
      gadget: _gadget
    } do
      live = desktop(conn)

      html = render_click(live, "museum_filter", %{"category" => widget.category})

      assert html =~ "Test Widget"
      refute html =~ "Test Gadget"
      assert html =~ ~s(phx-value-category="#{widget.category}" class="museum-filter-tag active")
    end

    test "the \"all\" filter clears the category and restores the full list", %{
      conn: conn,
      widget: widget,
      gadget: _gadget
    } do
      live = desktop(conn)
      render_click(live, "museum_filter", %{"category" => widget.category})

      html = render_click(live, "museum_filter", %{"category" => "all"})

      assert html =~ "Test Widget"
      assert html =~ "Test Gadget"
      assert html =~ ~s(phx-value-category="all" class="museum-filter-tag active")
    end

    # The mobile taskbar buttons build their class with plain string
    # interpolation (not a HEEx class-list), so matching the rendered
    # class="mobile-taskbar-btn active" alongside the button's own
    # phx-value-window is an unambiguous, attribute-qualified needle.
    test "switching to chat on mobile without a chatter redirects to the name dialog instead",
         %{conn: conn} do
      live = desktop(conn)

      html = render_click(live, "switch_mobile_window", %{"window" => "chat"})

      assert html =~
               ~s(class="mobile-taskbar-btn active" phx-click="switch_mobile_window" phx-value-window="name_dialog")

      refute html =~
               ~s(class="mobile-taskbar-btn active" phx-click="switch_mobile_window" phx-value-window="chat")

      assert html =~ ~s(id="name-dialog-window")
    end

    test "switching to chat on mobile with a chatter already set goes straight to chat", %{
      conn: conn
    } do
      live = desktop(conn)
      render_click(live, "toggle_chat")
      render_click(live, "skip_name")

      html = render_click(live, "switch_mobile_window", %{"window" => "chat"})

      assert html =~
               ~s(class="mobile-taskbar-btn active" phx-click="switch_mobile_window" phx-value-window="chat")

      # Once a chatter exists the "Name" taskbar button is dropped entirely,
      # not just deactivated.
      refute html =~ ~s(phx-value-window="name_dialog")
    end
  end
end
