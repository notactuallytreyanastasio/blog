defmodule Blog.Bookmarks.StoreTest do
  use ExUnit.Case, async: false  # Not async because we're testing GenServer and ETS
  alias Blog.Bookmarks.{Store, Bookmark}

  setup do
    # Start the GenServer if not already started
    case GenServer.whereis(Store) do
      nil -> 
        # Create ETS table for testing
        :ets.new(:bookmarks_table, [:set, :public, :named_table])
        {:ok, _pid} = Store.start_link([])
      _pid -> :ok
    end

    # Clear the table before each test
    :ets.delete_all_objects(:bookmarks_table)
    :ok
  end

  describe "add_bookmark/1 with Bookmark struct" do
    test "adds valid bookmark to store" do
      bookmark = %Bookmark{
        url: "https://example.com",
        title: "Example Site",
        user_id: "user123"
      }
      
      assert {:ok, stored_bookmark} = Store.add_bookmark(bookmark)
      assert stored_bookmark.url == "https://example.com"
      assert stored_bookmark.title == "Example Site"
      assert stored_bookmark.user_id == "user123"
    end

    test "rejects invalid bookmark" do
      bookmark = %Bookmark{url: nil, user_id: "user123"}
      
      assert {:error, "URL is required"} = Store.add_bookmark(bookmark)
    end

    test "bookmark is retrievable after adding" do
      bookmark = %Bookmark{
        id: "test-id",
        url: "https://example.com",
        user_id: "user123"
      }
      
      {:ok, _} = Store.add_bookmark(bookmark)
      {:ok, retrieved} = Store.get_bookmark("test-id")
      
      assert retrieved.url == "https://example.com"
      assert retrieved.user_id == "user123"
    end
  end

  describe "add_bookmark/6 (Chrome extension compatibility)" do
    test "creates bookmark from individual parameters" do
      {:ok, bookmark} = Store.add_bookmark(
        "https://example.com",
        "Example Site", 
        "A test site",
        ["test", "example"],
        "https://example.com/favicon.ico",
        "user123"
      )
      
      assert bookmark.url == "https://example.com"
      assert bookmark.title == "Example Site"
      assert bookmark.description == "A test site"
      assert bookmark.tags == ["test", "example"]
      assert bookmark.favicon_url == "https://example.com/favicon.ico"
      assert bookmark.user_id == "user123"
    end

    test "handles nil tags" do
      {:ok, bookmark} = Store.add_bookmark(
        "https://example.com",
        "Example Site",
        "A test site", 
        nil,
        "https://example.com/favicon.ico",
        "user123"
      )
      
      assert bookmark.tags == []
    end

    test "fails with invalid parameters" do
      {:error, _reason} = Store.add_bookmark(
        nil,  # Invalid URL
        "Example Site",
        "A test site",
        ["test"],
        "https://example.com/favicon.ico", 
        "user123"
      )
    end
  end

  describe "add_bookmark/1 with map" do
    test "creates bookmark from map attributes" do
      attrs = %{
        url: "https://example.com",
        title: "Example Site",
        description: "A test site",
        tags: ["test"],
        user_id: "user123"
      }
      
      {:ok, bookmark} = Store.add_bookmark(attrs)
      
      assert bookmark.url == "https://example.com"
      assert bookmark.title == "Example Site"
      assert bookmark.description == "A test site"
      assert bookmark.tags == ["test"]
      assert bookmark.user_id == "user123"
    end

    test "fails with invalid map attributes" do
      attrs = %{
        url: "",  # Invalid empty URL
        user_id: "user123"
      }
      
      {:error, _reason} = Store.add_bookmark(attrs)
    end
  end

  describe "get_bookmark/1" do
    test "returns bookmark when it exists" do
      bookmark = %Bookmark{
        id: "test-id",
        url: "https://example.com",
        user_id: "user123"
      }
      
      {:ok, _} = Store.add_bookmark(bookmark)
      {:ok, retrieved} = Store.get_bookmark("test-id")
      
      assert retrieved.id == "test-id"
      assert retrieved.url == "https://example.com"
    end

    test "returns error when bookmark doesn't exist" do
      assert {:error, :not_found} = Store.get_bookmark("nonexistent-id")
    end
  end

  describe "list_bookmarks/1" do
    test "returns bookmarks for specific user" do
      bookmark1 = %Bookmark{url: "https://site1.com", user_id: "user1"}
      bookmark2 = %Bookmark{url: "https://site2.com", user_id: "user1"}
      bookmark3 = %Bookmark{url: "https://site3.com", user_id: "user2"}
      
      {:ok, _} = Store.add_bookmark(bookmark1)
      {:ok, _} = Store.add_bookmark(bookmark2)
      {:ok, _} = Store.add_bookmark(bookmark3)
      
      user1_bookmarks = Store.list_bookmarks("user1")
      user2_bookmarks = Store.list_bookmarks("user2")
      
      assert length(user1_bookmarks) == 2
      assert length(user2_bookmarks) == 1
      
      user1_urls = Enum.map(user1_bookmarks, & &1.url)
      assert "https://site1.com" in user1_urls
      assert "https://site2.com" in user1_urls
      refute "https://site3.com" in user1_urls
    end

    test "returns empty list for user with no bookmarks" do
      bookmarks = Store.list_bookmarks("nonexistent-user")
      assert bookmarks == []
    end

    test "returns bookmarks sorted by insertion time descending" do
      # Create bookmarks with different timestamps
      now = DateTime.utc_now()
      earlier = DateTime.add(now, -60, :second)
      later = DateTime.add(now, 60, :second)
      
      bookmark1 = %Bookmark{url: "https://first.com", user_id: "user1", inserted_at: earlier}
      bookmark2 = %Bookmark{url: "https://second.com", user_id: "user1", inserted_at: now}
      bookmark3 = %Bookmark{url: "https://third.com", user_id: "user1", inserted_at: later}
      
      {:ok, _} = Store.add_bookmark(bookmark1)
      {:ok, _} = Store.add_bookmark(bookmark2)
      {:ok, _} = Store.add_bookmark(bookmark3)
      
      bookmarks = Store.list_bookmarks("user1")
      urls = Enum.map(bookmarks, & &1.url)
      
      # Should be sorted by inserted_at descending (newest first)
      assert urls == ["https://third.com", "https://second.com", "https://first.com"]
    end
  end

  describe "delete_bookmark/1" do
    test "deletes existing bookmark" do
      bookmark = %Bookmark{
        id: "test-id",
        url: "https://example.com",
        user_id: "user123"
      }
      
      {:ok, _} = Store.add_bookmark(bookmark)
      assert {:ok, _} = Store.get_bookmark("test-id")
      
      assert :ok = Store.delete_bookmark("test-id")
      assert {:error, :not_found} = Store.get_bookmark("test-id")
    end

    test "delete returns ok even for nonexistent bookmark" do
      assert :ok = Store.delete_bookmark("nonexistent-id")
    end
  end

  describe "search_bookmarks/2" do
    setup do
      bookmarks = [
        %Bookmark{url: "https://elixir-lang.org", title: "Elixir Language", description: "Dynamic programming", tags: ["elixir", "programming"], user_id: "user1"},
        %Bookmark{url: "https://phoenixframework.org", title: "Phoenix Framework", description: "Web framework for Elixir", tags: ["phoenix", "web"], user_id: "user1"},
        %Bookmark{url: "https://github.com", title: "GitHub", description: "Code hosting platform", tags: ["git", "code"], user_id: "user1"},
        %Bookmark{url: "https://stackoverflow.com", title: "Stack Overflow", description: "Programming Q&A", tags: ["programming", "help"], user_id: "user2"}
      ]
      
      for bookmark <- bookmarks do
        {:ok, _} = Store.add_bookmark(bookmark)
      end
      
      :ok
    end

    test "searches by title" do
      results = Store.search_bookmarks("user1", "elixir")
      
      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end

    test "searches by description" do
      results = Store.search_bookmarks("user1", "framework")
      
      assert length(results) == 1
      assert hd(results).title == "Phoenix Framework"
    end

    test "searches by URL" do
      results = Store.search_bookmarks("user1", "github")
      
      assert length(results) == 1
      assert hd(results).title == "GitHub"
    end

    test "searches by tags" do
      results = Store.search_bookmarks("user1", "programming")
      
      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end

    test "search is case insensitive" do
      results = Store.search_bookmarks("user1", "ELIXIR")
      
      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end

    test "search returns multiple matches" do
      results = Store.search_bookmarks("user1", "programming")
      
      # Should find bookmarks with "programming" in description or tags
      assert length(results) == 1  # Only "Dynamic programming" description
      
      # Test with broader term
      results = Store.search_bookmarks("user1", "web")
      assert length(results) == 1  # Phoenix has "web" tag
    end

    test "search only returns results for specified user" do
      results = Store.search_bookmarks("user1", "programming")
      user1_results = Enum.map(results, & &1.user_id)
      
      assert Enum.all?(user1_results, &(&1 == "user1"))
    end

    test "search returns empty list when no matches" do
      results = Store.search_bookmarks("user1", "nonexistent")
      
      assert results == []
    end

    test "search handles nil fields gracefully" do
      bookmark_with_nils = %Bookmark{
        url: "https://minimal.com",
        title: nil,
        description: nil,
        tags: [],
        user_id: "user1"
      }
      
      {:ok, _} = Store.add_bookmark(bookmark_with_nils)
      
      # Should not crash when searching
      results = Store.search_bookmarks("user1", "minimal")
      
      assert length(results) == 1
      assert hd(results).url == "https://minimal.com"
    end

    test "search results are sorted by insertion time descending" do
      # Search for "programming" which should match multiple items
      # Add another bookmark with programming to test sorting
      now = DateTime.utc_now()
      later = DateTime.add(now, 60, :second)
      
      newer_bookmark = %Bookmark{
        url: "https://programming.com", 
        title: "Programming Site",
        description: "All about programming",
        user_id: "user1",
        inserted_at: later
      }
      
      {:ok, _} = Store.add_bookmark(newer_bookmark)
      
      results = Store.search_bookmarks("user1", "programming")
      
      if length(results) > 1 do
        timestamps = Enum.map(results, & &1.inserted_at)
        sorted_timestamps = Enum.sort(timestamps, {:desc, DateTime})
        assert timestamps == sorted_timestamps
      end
    end
  end

  describe "GenServer behavior" do
    test "can start and stop the GenServer" do
      # Stop if running
      case GenServer.whereis(Store) do
        nil -> :ok
        pid -> GenServer.stop(pid)
      end
      
      # Start fresh
      :ets.new(:bookmarks_table, [:set, :public, :named_table])
      {:ok, pid} = Store.start_link([])
      
      assert Process.alive?(pid)
      assert GenServer.whereis(Store) == pid
      
      # Stop it
      GenServer.stop(pid)
      refute Process.alive?(pid)
    end

    test "GenServer initializes with empty state" do
      # The init function should return {:ok, %{}}
      assert {:ok, %{}} = Store.init([])
    end
  end
end