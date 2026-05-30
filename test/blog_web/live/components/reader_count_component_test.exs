defmodule BlogWeb.ReaderCountComponentTest do
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias BlogWeb.ReaderCountComponent
  alias BlogWeb.Presence

  @presence_topic "blog_presence"

  setup do
    # BlogWeb.Presence is started by the application supervisor. Start it
    # defensively here in case the supervision tree isn't running in this
    # test environment. (Phoenix.Presence is NOT a plain ETS table, so the
    # old `:ets.delete_all_objects(Presence)` reset was invalid and crashed
    # with :ets.internal_delete_all/2.)
    if Process.whereis(Presence) == nil do
      start_supervised!(Presence)
    end

    # Each ExUnit test runs in its own process, and presence entries are keyed
    # by the tracking pid. They are automatically reaped when this test process
    # exits, so no cross-test cleanup (and certainly no raw ETS clearing) is
    # required.
    :ok
  end

  describe "ReaderCountComponent rendering" do
    test "renders with no readers initially" do
      html = render_component(ReaderCountComponent, %{id: "reader-count"})

      assert html =~ "0 people online"
    end

    test "renders singular 'person' for one reader" do
      Presence.track(self(), @presence_topic, "user_123", %{
        online_at: inspect(System.system_time(:second))
      })

      html = render_component(ReaderCountComponent, %{id: "reader-count"})

      assert html =~ "1 person online"
      refute html =~ "people"
    end

    test "renders plural 'people' for multiple readers" do
      for user_id <- ["user_1", "user_2", "user_3"] do
        Presence.track(self(), @presence_topic, user_id, %{
          online_at: inspect(System.system_time(:second))
        })
      end

      html = render_component(ReaderCountComponent, %{id: "reader-count"})

      assert html =~ "3 people online"
      refute html =~ "person online"
    end

    test "has correct CSS classes" do
      html = render_component(ReaderCountComponent, %{id: "reader-count"})

      assert html =~ "text-sm"
      assert html =~ "text-gray-500"
      assert html =~ "mb-6"
    end
  end

  describe "mount/1" do
    test "initializes total_readers from the current presence count" do
      socket = build_socket()

      {:ok, mounted} = ReaderCountComponent.mount(socket)

      assert mounted.assigns.total_readers == 0
    end

    test "reflects already-present readers at mount time" do
      for i <- 1..2 do
        Presence.track(self(), @presence_topic, "user_#{i}", %{
          online_at: inspect(System.system_time(:second))
        })
      end

      # render_component invokes mount/1 internally, so this exercises the
      # mount-time count through the full render path.
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      assert html =~ "2 people online"

      # And directly via mount/1.
      {:ok, mounted} = ReaderCountComponent.mount(build_socket())
      assert mounted.assigns.total_readers == 2
    end
  end

  describe "handle_info/2 (presence_diff)" do
    test "recomputes total_readers when a presence_diff arrives" do
      {:ok, mounted} = ReaderCountComponent.mount(build_socket())
      assert mounted.assigns.total_readers == 0

      Presence.track(self(), @presence_topic, "user_1", %{
        online_at: inspect(System.system_time(:second))
      })

      Presence.track(self(), @presence_topic, "user_2", %{
        online_at: inspect(System.system_time(:second))
      })

      {:noreply, updated} =
        ReaderCountComponent.handle_info(%{event: "presence_diff"}, mounted)

      assert updated.assigns.total_readers == 2
    end

    test "tracks the count up and down across multiple presence_diffs" do
      {:ok, socket} = ReaderCountComponent.mount(build_socket())

      # Track five readers, then drop three via untrack. untrack/3 is a
      # synchronous call to the tracker, so the leave is visible to the very
      # next Presence.list/1 with no timing races.
      for i <- 1..5 do
        Presence.track(self(), @presence_topic, "user_#{i}", %{
          online_at: inspect(System.system_time(:second))
        })
      end

      {:noreply, socket} =
        ReaderCountComponent.handle_info(%{event: "presence_diff"}, socket)

      assert socket.assigns.total_readers == 5

      for i <- 1..3 do
        :ok = Presence.untrack(self(), @presence_topic, "user_#{i}")
      end

      {:noreply, socket} =
        ReaderCountComponent.handle_info(%{event: "presence_diff"}, socket)

      assert socket.assigns.total_readers == 2
    end
  end

  describe "presence integration" do
    test "counts each user key only once" do
      user_id = "same_user"

      Presence.track(self(), @presence_topic, user_id, %{
        online_at: inspect(System.system_time(:second))
      })

      # Tracking the same key again from the same pid would crash (already
      # tracked); instead update its meta, which must not change the count.
      Presence.update(self(), @presence_topic, user_id, %{
        online_at: inspect(System.system_time(:second))
      })

      html = render_component(ReaderCountComponent, %{id: "reader-count"})

      assert html =~ "1 person online"
    end

    test "handles empty presence gracefully" do
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      assert html =~ "0 people online"
    end
  end

  # --- helpers ---------------------------------------------------------------

  defp build_socket do
    # A bare socket has transport_pid: nil, so connected?/1 is false and
    # mount/1 skips the PubSub subscription while still computing the count.
    %Phoenix.LiveView.Socket{}
  end
end
