defmodule Blog.Integration.BookmarkFlowTest do
  @moduledoc """
  Integration tests for the complete bookmark workflow.
  Tests the full user journey from adding bookmarks to searching and managing them.
  """
  
  use BlogWeb.ChannelCase, async: false
  use BlogWeb.ConnCase, async: false
  
  import Phoenix.LiveViewTest
  import Phoenix.ChannelTest
  import Blog.TestHelpers
  
  alias BlogWeb.BookmarkChannel
  alias Blog.Bookmarks.Store

  setup do
    # Ensure clean state
    clear_all_ets_tables()
    setup_ets_tables()
    
    # Start the bookmark store
    case GenServer.whereis(Store) do
      nil -> 
        {:ok, _pid} = Store.start_link([])
      _pid -> :ok
    end
    
    user_id = random_user_id()
    {:ok, user_id: user_id}
  end

  describe "Complete bookmark workflow via channels" do
    test "user can add, search, and delete bookmarks", %{user_id: user_id} do
      # Step 1: Join the bookmark channel
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Step 2: Add a bookmark
      bookmark_params = %{
        "url" => "https://elixir-lang.org",
        "title" => "Elixir Programming Language",
        "description" => "Dynamic functional programming language",
        "tags" => ["elixir", "programming", "functional"],
        "favicon_url" => "https://elixir-lang.org/favicon.ico"
      }
      
      ref = Phoenix.ChannelTest.push(socket, "add_bookmark", bookmark_params)
      assert_reply ref, :ok, bookmark
      assert bookmark.url == "https://elixir-lang.org"
      assert bookmark.title == "Elixir Programming Language"
      
      # Verify broadcast
      assert_broadcast "bookmark_added", ^bookmark
      
      # Step 3: Add another bookmark
      bookmark_params_2 = %{
        "url" => "https://phoenixframework.org",
        "title" => "Phoenix Framework",
        "description" => "Web framework for Elixir",
        "tags" => ["phoenix", "web", "elixir"],
        "favicon_url" => "https://phoenixframework.org/favicon.ico"
      }
      
      ref = Phoenix.ChannelTest.push(socket, "add_bookmark", bookmark_params_2)
      assert_reply ref, :ok, bookmark2
      assert bookmark2.url == "https://phoenixframework.org"
      
      # Step 4: Search bookmarks by tag
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => "elixir"})
      assert_reply ref, :ok, %{bookmarks: search_results}
      
      # Should find both bookmarks (both have "elixir" tag)
      assert length(search_results) == 2
      urls = Enum.map(search_results, & &1.url)
      assert "https://elixir-lang.org" in urls
      assert "https://phoenixframework.org" in urls
      
      # Step 5: Search by specific term
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => "programming"})
      assert_reply ref, :ok, %{bookmarks: search_results}
      
      # Should find only the first bookmark
      assert length(search_results) == 1
      assert hd(search_results).url == "https://elixir-lang.org"
      
      # Step 6: Delete a bookmark
      ref = Phoenix.ChannelTest.push(socket, "delete_bookmark", %{"id" => bookmark.id})
      assert_reply ref, :ok
      
      # Verify deletion broadcast
      assert_broadcast "bookmark_deleted", %{id: bookmark_id}
      assert bookmark_id == bookmark.id
      
      # Step 7: Verify bookmark was deleted
      assert {:error, :not_found} = Store.get_bookmark(bookmark.id)
      
      # Step 8: Search again should only return the remaining bookmark
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => "elixir"})
      assert_reply ref, :ok, %{bookmarks: final_results}
      
      assert length(final_results) == 1
      assert hd(final_results).url == "https://phoenixframework.org"
    end

    test "Chrome extension bookmark creation workflow", %{user_id: user_id} do
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Test Chrome extension format
      chrome_params = %{
        "url" => "https://github.com",
        "title" => "GitHub"
        # Minimal data as Chrome extension might send
      }
      
      ref = Phoenix.ChannelTest.push(socket, "bookmark:create", chrome_params)
      assert_reply ref, :ok, bookmark
      
      assert bookmark.url == "https://github.com"
      assert bookmark.title == "GitHub"
      assert bookmark.description == ""
      assert bookmark.tags == []
      assert bookmark.favicon_url == nil
    end

    test "firehose broadcasts work across multiple users", %{user_id: user_id} do
      # Subscribe to firehose
      subscribe_to_topic("bookmark:firehose")
      
      # Join as first user
      {:ok, _reply, socket1} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Join as second user
      user_id_2 = random_user_id()
      {:ok, _reply, socket2} = join(create_test_socket(user_id_2), BookmarkChannel, "bookmark:client:#{user_id_2}")
      
      # First user adds bookmark
      bookmark_params = %{
        "url" => "https://test.com",
        "title" => "Test Site",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }
      
      ref = Phoenix.ChannelTest.push(socket1, "add_bookmark", bookmark_params)
      assert_reply ref, :ok, bookmark
      
      # Both users should receive the broadcast on their channel
      assert_broadcast "bookmark_added", ^bookmark
      
      # Firehose should also receive the broadcast
      assert_broadcast_received("bookmark:firehose", "bookmark_added", bookmark)
      
      # Second user deletes their own bookmark (add one first)
      ref = Phoenix.ChannelTest.push(socket2, "add_bookmark", %{
        "url" => "https://delete-me.com",
        "title" => "Delete Me",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      })
      assert_reply ref, :ok, bookmark_to_delete
      
      ref = Phoenix.ChannelTest.push(socket2, "delete_bookmark", %{"id" => bookmark_to_delete.id})
      assert_reply ref, :ok
      
      # Firehose should receive deletion broadcast
      assert_broadcast_received("bookmark:firehose", "bookmark_deleted", %{id: bookmark_to_delete.id})
    end
  end

  describe "Multi-user bookmark isolation" do
    test "users only see their own bookmarks", %{user_id: user_id} do
      user_id_2 = random_user_id()
      
      # User 1 joins and adds bookmark
      {:ok, reply1, socket1} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      assert %{bookmarks: []} = reply1  # Initially empty
      
      ref = Phoenix.ChannelTest.push(socket1, "add_bookmark", %{
        "url" => "https://user1.com",
        "title" => "User 1 Site",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      })
      assert_reply ref, :ok, user1_bookmark
      
      # User 2 joins
      {:ok, reply2, socket2} = join(create_test_socket(user_id_2), BookmarkChannel, "bookmark:client:#{user_id_2}")
      assert %{bookmarks: []} = reply2  # Should not see user 1's bookmark
      
      # User 2 adds their own bookmark
      ref = Phoenix.ChannelTest.push(socket2, "add_bookmark", %{
        "url" => "https://user2.com",
        "title" => "User 2 Site",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      })
      assert_reply ref, :ok, user2_bookmark
      
      # User 1 searches - should only see their bookmark
      ref = Phoenix.ChannelTest.push(socket1, "search_bookmarks", %{"query" => "user"})
      assert_reply ref, :ok, %{bookmarks: user1_results}
      
      assert length(user1_results) == 1
      assert hd(user1_results).url == "https://user1.com"
      
      # User 2 searches - should only see their bookmark
      ref = Phoenix.ChannelTest.push(socket2, "search_bookmarks", %{"query" => "user"})
      assert_reply ref, :ok, %{bookmarks: user2_results}
      
      assert length(user2_results) == 1
      assert hd(user2_results).url == "https://user2.com"
    end
  end

  describe "Error handling and edge cases" do
    test "handles invalid bookmark data gracefully", %{user_id: user_id} do
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Try to add bookmark with invalid URL
      invalid_params = %{
        "url" => "",  # Empty URL
        "title" => "Invalid Bookmark",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }
      
      ref = Phoenix.ChannelTest.push(socket, "add_bookmark", invalid_params)
      assert_reply ref, :error, %{reason: "failed to add bookmark"}
      
      # Try to add bookmark with missing URL
      missing_url_params = %{
        "title" => "No URL Bookmark",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }
      
      ref = Phoenix.ChannelTest.push(socket, "add_bookmark", missing_url_params)
      assert_reply ref, :error, %{reason: "failed to add bookmark"}
    end

    test "handles searching with empty query", %{user_id: user_id} do
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Add a bookmark first
      ref = Phoenix.ChannelTest.push(socket, "add_bookmark", %{
        "url" => "https://test.com",
        "title" => "Test",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      })
      assert_reply ref, :ok, _bookmark
      
      # Search with empty query
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => ""})
      assert_reply ref, :ok, %{bookmarks: results}
      
      # Should return all bookmarks (empty query matches everything)
      assert length(results) == 1
    end

    test "handles deletion of non-existent bookmark", %{user_id: user_id} do
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Try to delete non-existent bookmark
      ref = Phoenix.ChannelTest.push(socket, "delete_bookmark", %{"id" => "non-existent-id"})
      assert_reply ref, :ok  # Should succeed (idempotent operation)
    end
  end

  describe "Performance and scalability" do
    test "handles large number of bookmarks efficiently", %{user_id: user_id} do
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      
      # Add 100 bookmarks
      bookmark_count = 100
      
      for i <- 1..bookmark_count do
        ref = Phoenix.ChannelTest.push(socket, "add_bookmark", %{
          "url" => "https://site#{i}.com",
          "title" => "Site #{i}",
          "description" => "Description #{i}",
          "tags" => ["tag#{rem(i, 10)}", "test"],
          "favicon_url" => nil
        })
        assert_reply ref, :ok, _bookmark
      end
      
      # Search should still be fast
      start_time = System.monotonic_time(:millisecond)
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => "tag5"})
      assert_reply ref, :ok, %{bookmarks: results}
      end_time = System.monotonic_time(:millisecond)
      
      # Should find exactly 10 bookmarks (tag5, tag15, tag25, etc.)
      assert length(results) == 10
      
      # Search should complete in reasonable time (< 100ms)
      search_time = end_time - start_time
      assert search_time < 100
    end

    test "handles concurrent bookmark operations", %{user_id: user_id} do
      # Start multiple channel connections for the same user
      tasks = for i <- 1..5 do
        Task.async(fn ->
          {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
          
          # Each task adds a bookmark
          ref = Phoenix.ChannelTest.push(socket, "add_bookmark", %{
            "url" => "https://concurrent#{i}.com",
            "title" => "Concurrent #{i}",
            "description" => "",
            "tags" => ["concurrent"],
            "favicon_url" => nil
          })
          assert_reply ref, :ok, bookmark
          bookmark
        end)
      end
      
      # Wait for all tasks to complete
      bookmarks = Enum.map(tasks, &Task.await/1)
      
      # Should have 5 unique bookmarks
      assert length(bookmarks) == 5
      urls = Enum.map(bookmarks, & &1.url)
      assert length(Enum.uniq(urls)) == 5
      
      # All bookmarks should be searchable
      {:ok, _reply, socket} = join(create_test_socket(user_id), BookmarkChannel, "bookmark:client:#{user_id}")
      ref = Phoenix.ChannelTest.push(socket, "search_bookmarks", %{"query" => "concurrent"})
      assert_reply ref, :ok, %{bookmarks: search_results}
      
      assert length(search_results) == 5
    end
  end
end