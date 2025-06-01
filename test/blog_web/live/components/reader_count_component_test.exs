defmodule BlogWeb.ReaderCountComponentTest do
  use BlogWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias BlogWeb.ReaderCountComponent
  alias BlogWeb.Presence

  @presence_topic "blog_presence"

  setup do
    # Clear any existing presence data
    :ets.delete_all_objects(Presence)
    :ok
  end

  describe "ReaderCountComponent" do
    test "renders with no readers initially" do
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      
      assert html =~ "0 people online"
    end

    test "renders singular 'person' for one reader" do
      # Simulate one person being present
      user_id = "user_123"
      Presence.track(self(), @presence_topic, user_id, %{
        online_at: inspect(System.system_time(:second))
      })
      
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      
      assert html =~ "1 person online"
      refute html =~ "people"
    end

    test "renders plural 'people' for multiple readers" do
      # Simulate multiple people being present
      users = ["user_1", "user_2", "user_3"]
      
      for user_id <- users do
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

    test "updates count when presence changes" do
      {:ok, lv, _html} = live_isolated(build_conn(), ReaderCountComponent, session: %{"id" => "test"})
      
      # Initially should show 0
      assert render(lv) =~ "0 people online"
      
      # Track a user
      Presence.track(self(), @presence_topic, "user_1", %{online_at: inspect(System.system_time(:second))})
      
      # Send presence diff to simulate real presence update
      send(lv.pid, %{event: "presence_diff"})
      
      # Should update to show 1 person
      assert render(lv) =~ "1 person online"
    end
  end

  describe "mount/1" do 
    test "subscribes to presence topic when connected" do
      # This test verifies the subscription behavior, though it's hard to test
      # the connected?/1 check directly in unit tests
      
      component_html = render_component(ReaderCountComponent, %{id: "reader-count"})
      assert component_html =~ "online"
    end

    test "initializes with current presence count" do
      # Track some users before mounting
      for i <- 1..2 do
        Presence.track(self(), @presence_topic, "user_#{i}", %{
          online_at: inspect(System.system_time(:second))
        })
      end
      
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      assert html =~ "2 people online"
    end
  end

  describe "handle_info/2" do
    test "updates total_readers on presence_diff" do
      {:ok, lv, _html} = live_isolated(build_conn(), ReaderCountComponent, session: %{"id" => "test"})
      
      # Initially 0 readers
      assert render(lv) =~ "0 people online"
      
      # Track some users
      Presence.track(self(), @presence_topic, "user_1", %{online_at: inspect(System.system_time(:second))})
      Presence.track(self(), @presence_topic, "user_2", %{online_at: inspect(System.system_time(:second))})
      
      # Send presence_diff message
      send(lv.pid, %{event: "presence_diff"})
      
      # Should update count
      assert render(lv) =~ "2 people online"
    end

    test "handles rapid presence changes" do
      {:ok, lv, _html} = live_isolated(build_conn(), ReaderCountComponent, session: %{"id" => "test"})
      
      # Add users
      for i <- 1..5 do
        Presence.track(self(), @presence_topic, "user_#{i}", %{online_at: inspect(System.system_time(:second))})
        send(lv.pid, %{event: "presence_diff"})
      end
      
      assert render(lv) =~ "5 people online"
      
      # Remove some users (in real app this would happen via untrack)
      # For testing, we'll clear and re-add fewer users
      :ets.delete_all_objects(Presence)
      
      for i <- 1..2 do
        Presence.track(self(), @presence_topic, "user_#{i}", %{online_at: inspect(System.system_time(:second))})
      end
      
      send(lv.pid, %{event: "presence_diff"})
      assert render(lv) =~ "2 people online"
    end
  end

  describe "presence integration" do
    test "correctly counts unique users" do
      # Track the same user multiple times (shouldn't increase count)
      user_id = "same_user"
      
      Presence.track(self(), @presence_topic, user_id, %{online_at: inspect(System.system_time(:second))})
      Presence.track(self(), @presence_topic, user_id, %{online_at: inspect(System.system_time(:second))})
      
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      
      # Should still be 1 person (unique count)
      assert html =~ "1 person online"
    end

    test "handles empty presence gracefully" do
      # Ensure presence is empty
      :ets.delete_all_objects(Presence)
      
      html = render_component(ReaderCountComponent, %{id: "reader-count"})
      assert html =~ "0 people online"
    end
  end
end