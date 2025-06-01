defmodule Blog.Bookmarks.BookmarkTest do
  use ExUnit.Case, async: true
  alias Blog.Bookmarks.Bookmark

  describe "Bookmark struct" do
    test "has correct default values" do
      bookmark = %Bookmark{}
      
      assert bookmark.id == nil
      assert bookmark.url == nil
      assert bookmark.title == nil
      assert bookmark.description == nil
      assert bookmark.tags == []
      assert bookmark.favicon_url == nil
      assert bookmark.user_id == nil
      assert bookmark.inserted_at == nil
    end

    test "can be created with specific values" do
      now = DateTime.utc_now()
      
      bookmark = %Bookmark{
        id: "123",
        url: "https://example.com",
        title: "Example Site",
        description: "A test website",
        tags: ["test", "example"],
        favicon_url: "https://example.com/favicon.ico",
        user_id: "user123",
        inserted_at: now
      }
      
      assert bookmark.id == "123"
      assert bookmark.url == "https://example.com"
      assert bookmark.title == "Example Site"
      assert bookmark.description == "A test website"
      assert bookmark.tags == ["test", "example"]
      assert bookmark.favicon_url == "https://example.com/favicon.ico"
      assert bookmark.user_id == "user123"
      assert bookmark.inserted_at == now
    end
  end

  describe "new/1" do
    test "creates bookmark with provided attributes" do
      attrs = %{
        url: "https://example.com",
        title: "Example",
        description: "Test description",
        tags: ["tag1", "tag2"],
        user_id: "user123"
      }
      
      bookmark = Bookmark.new(attrs)
      
      assert bookmark.url == "https://example.com"
      assert bookmark.title == "Example"
      assert bookmark.description == "Test description"
      assert bookmark.tags == ["tag1", "tag2"]
      assert bookmark.user_id == "user123"
    end

    test "generates ID automatically if not provided" do
      bookmark = Bookmark.new(%{url: "https://example.com", user_id: "user123"})
      
      assert is_binary(bookmark.id)
      assert bookmark.id != ""
    end

    test "uses provided ID if given" do
      bookmark = Bookmark.new(%{id: "custom-id", url: "https://example.com", user_id: "user123"})
      
      assert bookmark.id == "custom-id"
    end

    test "generates timestamp automatically if not provided" do
      bookmark = Bookmark.new(%{url: "https://example.com", user_id: "user123"})
      
      assert %DateTime{} = bookmark.inserted_at
      # Should be very recent
      assert DateTime.diff(DateTime.utc_now(), bookmark.inserted_at, :second) < 2
    end

    test "uses provided timestamp if given" do
      timestamp = ~U[2025-01-01 12:00:00Z]
      bookmark = Bookmark.new(%{url: "https://example.com", user_id: "user123", inserted_at: timestamp})
      
      assert bookmark.inserted_at == timestamp
    end

    test "defaults empty tags if not provided" do
      bookmark = Bookmark.new(%{url: "https://example.com", user_id: "user123"})
      
      assert bookmark.tags == []
    end

    test "handles keyword list input" do
      bookmark = Bookmark.new(url: "https://example.com", user_id: "user123", title: "Test")
      
      assert bookmark.url == "https://example.com"
      assert bookmark.user_id == "user123"
      assert bookmark.title == "Test"
    end

    test "handles nil attributes gracefully" do
      bookmark = Bookmark.new(%{url: nil, title: nil, description: nil, user_id: nil})
      
      assert bookmark.url == nil
      assert bookmark.title == nil
      assert bookmark.description == nil
      assert bookmark.user_id == nil
      assert bookmark.tags == []
    end

    test "creates bookmark with no arguments" do
      bookmark = Bookmark.new()
      
      assert %Bookmark{} = bookmark
      assert is_binary(bookmark.id)
      assert %DateTime{} = bookmark.inserted_at
      assert bookmark.tags == []
    end
  end

  describe "validate/1" do
    test "returns {:ok, bookmark} for valid bookmark" do
      bookmark = %Bookmark{
        url: "https://example.com",
        user_id: "user123"
      }
      
      assert {:ok, ^bookmark} = Bookmark.validate(bookmark)
    end

    test "returns error when URL is nil" do
      bookmark = %Bookmark{url: nil, user_id: "user123"}
      
      assert {:error, "URL is required"} = Bookmark.validate(bookmark)
    end

    test "returns error when URL is empty string" do
      bookmark = %Bookmark{url: "", user_id: "user123"}
      
      assert {:error, "URL is required"} = Bookmark.validate(bookmark)
    end

    test "returns error when user_id is nil" do
      bookmark = %Bookmark{url: "https://example.com", user_id: nil}
      
      assert {:error, "User ID is required"} = Bookmark.validate(bookmark)
    end

    test "returns error when user_id is empty string" do
      bookmark = %Bookmark{url: "https://example.com", user_id: ""}
      
      assert {:error, "User ID is required"} = Bookmark.validate(bookmark)
    end

    test "validates bookmark with optional fields as nil" do
      bookmark = %Bookmark{
        url: "https://example.com",
        user_id: "user123",
        title: nil,
        description: nil,
        favicon_url: nil
      }
      
      assert {:ok, ^bookmark} = Bookmark.validate(bookmark)
    end

    test "validates bookmark with all fields present" do
      bookmark = %Bookmark{
        id: "123",
        url: "https://example.com",
        title: "Example Site",
        description: "A test website",
        tags: ["test"],
        favicon_url: "https://example.com/favicon.ico",
        user_id: "user123",
        inserted_at: DateTime.utc_now()
      }
      
      assert {:ok, ^bookmark} = Bookmark.validate(bookmark)
    end
  end

  describe "generate_id/1 (private function behavior)" do
    test "generates unique IDs" do
      bookmark1 = Bookmark.new()
      bookmark2 = Bookmark.new()
      
      refute bookmark1.id == bookmark2.id
    end

    test "generates string IDs" do
      bookmark = Bookmark.new()
      
      assert is_binary(bookmark.id)
      assert String.length(bookmark.id) > 0
    end

    test "IDs are monotonic (later ones are larger when converted to integer)" do
      bookmark1 = Bookmark.new()
      Process.sleep(1)  # Ensure time difference
      bookmark2 = Bookmark.new()
      
      id1_int = String.to_integer(bookmark1.id)
      id2_int = String.to_integer(bookmark2.id)
      
      assert id2_int > id1_int
    end
  end

  describe "Jason encoding" do
    test "bookmark can be JSON encoded" do
      bookmark = %Bookmark{
        id: "123",
        url: "https://example.com",
        title: "Example",
        description: "Test",
        tags: ["tag1", "tag2"],
        favicon_url: "https://example.com/favicon.ico",
        user_id: "user123",
        inserted_at: ~U[2025-01-01 12:00:00Z]
      }
      
      {:ok, json} = Jason.encode(bookmark)
      
      assert is_binary(json)
      assert String.contains?(json, "example.com")
      assert String.contains?(json, "user123")
      assert String.contains?(json, "tag1")
    end

    test "only encodes specified fields" do
      bookmark = %Bookmark{
        id: "123",
        url: "https://example.com",
        title: "Example",
        user_id: "user123"
      }
      
      {:ok, json} = Jason.encode(bookmark)
      {:ok, decoded} = Jason.decode(json)
      
      # Should only contain fields specified in @derive
      expected_keys = ["id", "url", "title", "description", "tags", "favicon_url", "user_id", "inserted_at"]
      
      for key <- Map.keys(decoded) do
        assert key in expected_keys
      end
    end
  end

  describe "type specification" do
    test "bookmark matches type specification" do
      bookmark = %Bookmark{
        id: "123",
        url: "https://example.com",
        title: "Example",
        description: "Test description",
        tags: ["tag1", "tag2"],
        favicon_url: "https://example.com/favicon.ico",
        user_id: "user123",
        inserted_at: DateTime.utc_now()
      }
      
      # Test that all fields have correct types
      assert is_binary(bookmark.id)
      assert is_binary(bookmark.url)
      assert is_binary(bookmark.title) or is_nil(bookmark.title)
      assert is_binary(bookmark.description) or is_nil(bookmark.description)
      assert is_list(bookmark.tags)
      assert is_binary(bookmark.favicon_url) or is_nil(bookmark.favicon_url)
      assert is_binary(bookmark.user_id)
      assert %DateTime{} = bookmark.inserted_at
    end
  end
end