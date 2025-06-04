defmodule BlogWeb.BookmarkChannelTest do
  use BlogWeb.ChannelCase, async: false
  alias BlogWeb.BookmarkChannel
  alias Blog.Bookmarks.Store

  setup do
    # Ensure the bookmark store is running and clear any existing data
    case GenServer.whereis(Store) do
      nil ->
        :ets.new(:bookmarks_table, [:set, :public, :named_table])
        {:ok, _pid} = Store.start_link([])

      _pid ->
        :ok
    end

    :ets.delete_all_objects(:bookmarks_table)
    :ok
  end

  describe "join bookmark:client:<user_id>" do
    test "joins successfully and returns user's bookmarks" do
      user_id = "test_user_123"

      # Add some test bookmarks for the user
      {:ok, bookmark1} =
        Store.add_bookmark("https://example.com", "Example", "Test site", [], nil, user_id)

      {:ok, bookmark2} =
        Store.add_bookmark("https://test.com", "Test", "Another test", ["test"], nil, user_id)

      # Join the channel
      {:ok, reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      # Should receive bookmarks in reply
      assert %{bookmarks: bookmarks} = reply
      assert length(bookmarks) == 2

      # Check that user_id is assigned to socket
      assert socket.assigns.user_id == user_id

      # Check that bookmarks contain expected data
      urls = Enum.map(bookmarks, & &1.url)
      assert "https://example.com" in urls
      assert "https://test.com" in urls
    end

    test "joins successfully with no existing bookmarks" do
      user_id = "new_user_456"

      {:ok, reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      assert %{bookmarks: []} = reply
      assert socket.assigns.user_id == user_id
    end

    test "different users get their own bookmarks" do
      user1 = "user_one"
      user2 = "user_two"

      # Add bookmark for user1
      {:ok, _} = Store.add_bookmark("https://user1.com", "User 1 Site", "", [], nil, user1)

      # Join as user1
      {:ok, reply1, _} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user1}),
          BookmarkChannel,
          "bookmark:client:#{user1}"
        )

      # Join as user2
      {:ok, reply2, _} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user2}),
          BookmarkChannel,
          "bookmark:client:#{user2}"
        )

      # User1 should see their bookmark
      assert %{bookmarks: [bookmark]} = reply1
      assert bookmark.url == "https://user1.com"

      # User2 should see no bookmarks
      assert %{bookmarks: []} = reply2
    end
  end

  describe "handle_in add_bookmark" do
    setup do
      user_id = "test_user"

      {:ok, _reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      {:ok, socket: socket, user_id: user_id}
    end

    test "adds bookmark successfully", %{socket: socket} do
      params = %{
        "url" => "https://elixir-lang.org",
        "title" => "Elixir",
        "description" => "Dynamic programming language",
        "tags" => ["elixir", "programming"],
        "favicon_url" => "https://elixir-lang.org/favicon.ico"
      }

      ref = push(socket, "add_bookmark", params)

      assert_reply ref, :ok, bookmark
      assert bookmark.url == "https://elixir-lang.org"
      assert bookmark.title == "Elixir"
      assert bookmark.description == "Dynamic programming language"
      assert bookmark.tags == ["elixir", "programming"]
      assert bookmark.favicon_url == "https://elixir-lang.org/favicon.ico"

      # Should broadcast to the channel
      assert_broadcast "bookmark_added", ^bookmark
    end

    test "handles missing optional fields", %{socket: socket} do
      params = %{
        "url" => "https://example.com",
        "title" => "Example",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }

      ref = push(socket, "add_bookmark", params)
      assert_reply ref, :ok, bookmark

      assert bookmark.url == "https://example.com"
      assert bookmark.tags == []
      assert bookmark.favicon_url == nil
    end

    test "returns error for invalid bookmark", %{socket: socket} do
      params = %{
        # Invalid empty URL
        "url" => "",
        "title" => "Test",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }

      ref = push(socket, "add_bookmark", params)
      assert_reply ref, :error, %{reason: "failed to add bookmark"}
    end

    test "broadcasts to firehose channel", %{socket: socket} do
      # Subscribe to the firehose channel to verify broadcast
      BlogWeb.Endpoint.subscribe("bookmark:firehose")

      params = %{
        "url" => "https://test.com",
        "title" => "Test",
        "description" => "",
        "tags" => [],
        "favicon_url" => nil
      }

      ref = push(socket, "add_bookmark", params)
      assert_reply ref, :ok, bookmark

      # Should receive firehose broadcast
      assert_receive %Phoenix.Socket.Broadcast{
        topic: "bookmark:firehose",
        event: "bookmark_added",
        payload: ^bookmark
      }
    end
  end

  describe "handle_in delete_bookmark" do
    setup do
      user_id = "test_user"

      {:ok, _reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      # Add a test bookmark
      {:ok, bookmark} =
        Store.add_bookmark("https://delete-me.com", "Delete Me", "", [], nil, user_id)

      {:ok, socket: socket, user_id: user_id, bookmark: bookmark}
    end

    test "deletes bookmark successfully", %{socket: socket, bookmark: bookmark} do
      ref = push(socket, "delete_bookmark", %{"id" => bookmark.id})
      assert_reply ref, :ok

      # Should broadcast deletion
      assert_broadcast "bookmark_deleted", %{id: bookmark_id}
      assert bookmark_id == bookmark.id

      # Bookmark should be gone from store
      assert {:error, :not_found} = Store.get_bookmark(bookmark.id)
    end

    test "broadcasts deletion to firehose", %{socket: socket, bookmark: bookmark} do
      BlogWeb.Endpoint.subscribe("bookmark:firehose")

      ref = push(socket, "delete_bookmark", %{"id" => bookmark.id})
      assert_reply ref, :ok

      # Should receive firehose broadcast
      assert_receive %Phoenix.Socket.Broadcast{
        topic: "bookmark:firehose",
        event: "bookmark_deleted",
        payload: %{id: bookmark_id}
      }

      assert bookmark_id == bookmark.id
    end

    test "handles deletion of nonexistent bookmark", %{socket: socket} do
      ref = push(socket, "delete_bookmark", %{"id" => "nonexistent"})
      # Delete operations are idempotent
      assert_reply ref, :ok
    end
  end

  describe "handle_in search_bookmarks" do
    setup do
      user_id = "search_user"

      {:ok, _reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      # Add test bookmarks
      {:ok, _} =
        Store.add_bookmark(
          "https://elixir-lang.org",
          "Elixir Language",
          "Programming language",
          ["elixir", "programming"],
          nil,
          user_id
        )

      {:ok, _} =
        Store.add_bookmark(
          "https://phoenixframework.org",
          "Phoenix Framework",
          "Web framework",
          ["phoenix", "web"],
          nil,
          user_id
        )

      {:ok, _} =
        Store.add_bookmark(
          "https://github.com",
          "GitHub",
          "Code repository",
          ["git", "code"],
          nil,
          user_id
        )

      {:ok, socket: socket, user_id: user_id}
    end

    test "searches bookmarks by title", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "elixir"})
      assert_reply ref, :ok, %{bookmarks: results}

      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end

    test "searches bookmarks by description", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "framework"})
      assert_reply ref, :ok, %{bookmarks: results}

      assert length(results) == 1
      assert hd(results).title == "Phoenix Framework"
    end

    test "searches bookmarks by URL", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "github"})
      assert_reply ref, :ok, %{bookmarks: results}

      assert length(results) == 1
      assert hd(results).title == "GitHub"
    end

    test "searches bookmarks by tags", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "programming"})
      assert_reply ref, :ok, %{bookmarks: results}

      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end

    test "returns empty results for no matches", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "nonexistent"})
      assert_reply ref, :ok, %{bookmarks: []}
    end

    test "search is case insensitive", %{socket: socket} do
      ref = push(socket, "search_bookmarks", %{"query" => "ELIXIR"})
      assert_reply ref, :ok, %{bookmarks: results}

      assert length(results) == 1
      assert hd(results).title == "Elixir Language"
    end
  end

  describe "handle_in bookmark:create (Chrome extension format)" do
    setup do
      user_id = "chrome_user"

      {:ok, _reply, socket} =
        join(
          socket(BlogWeb.UserSocket, "user_id", %{user_id: user_id}),
          BookmarkChannel,
          "bookmark:client:#{user_id}"
        )

      {:ok, socket: socket, user_id: user_id}
    end

    test "creates bookmark with full data", %{socket: socket} do
      params = %{
        "url" => "https://news.ycombinator.com",
        "title" => "Hacker News",
        "description" => "Social news website",
        "tags" => ["news", "tech"],
        "favicon_url" => "https://news.ycombinator.com/favicon.ico"
      }

      ref = push(socket, "bookmark:create", params)
      assert_reply ref, :ok, bookmark

      assert bookmark.url == "https://news.ycombinator.com"
      assert bookmark.title == "Hacker News"
      assert bookmark.description == "Social news website"
      assert bookmark.tags == ["news", "tech"]
      assert bookmark.favicon_url == "https://news.ycombinator.com/favicon.ico"
    end

    test "creates bookmark with minimal data", %{socket: socket} do
      params = %{
        "url" => "https://minimal.com"
      }

      ref = push(socket, "bookmark:create", params)
      assert_reply ref, :ok, bookmark

      assert bookmark.url == "https://minimal.com"
      # Default to URL
      assert bookmark.title == "https://minimal.com"
      assert bookmark.description == ""
      assert bookmark.tags == []
      assert bookmark.favicon_url == nil
    end

    test "handles missing optional fields gracefully", %{socket: socket} do
      params = %{
        "url" => "https://example.org",
        "title" => "Example Org"
        # Missing description, tags, favicon_url
      }

      ref = push(socket, "bookmark:create", params)
      assert_reply ref, :ok, bookmark

      assert bookmark.url == "https://example.org"
      assert bookmark.title == "Example Org"
      assert bookmark.description == ""
      assert bookmark.tags == []
      assert bookmark.favicon_url == nil
    end

    test "returns error for invalid data", %{socket: socket} do
      params = %{
        # Invalid empty URL
        "url" => ""
      }

      ref = push(socket, "bookmark:create", params)
      assert_reply ref, :error, %{reason: "failed to add bookmark"}
    end

    test "broadcasts created bookmark", %{socket: socket} do
      BlogWeb.Endpoint.subscribe("bookmark:firehose")

      params = %{
        "url" => "https://broadcast-test.com",
        "title" => "Broadcast Test"
      }

      ref = push(socket, "bookmark:create", params)
      assert_reply ref, :ok, bookmark

      # Should broadcast to channel
      assert_broadcast "bookmark_added", ^bookmark

      # Should broadcast to firehose
      assert_receive %Phoenix.Socket.Broadcast{
        topic: "bookmark:firehose",
        event: "bookmark_added",
        payload: ^bookmark
      }
    end
  end
end
