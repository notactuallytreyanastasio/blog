defmodule Blog.ChatTest do
  use ExUnit.Case, async: false  # Not async because we're testing ETS tables
  alias Blog.Chat

  setup do
    # Clear any existing tables before each test
    cleanup_tables()
    :ok
  end

  defp cleanup_tables do
    if :ets.info(:blog_chat_messages) != :undefined do
      :ets.delete(:blog_chat_messages)
    end
    if :ets.info(:blog_chat_banned_words) != :undefined do
      :ets.delete(:blog_chat_banned_words)
    end
  end

  describe "ensure_started/0" do
    test "creates ETS tables when they don't exist" do
      assert :ets.info(:blog_chat_messages) == :undefined
      assert :ets.info(:blog_chat_banned_words) == :undefined

      Chat.ensure_started()

      assert :ets.info(:blog_chat_messages) != :undefined
      assert :ets.info(:blog_chat_banned_words) != :undefined
    end

    test "doesn't recreate tables if they already exist" do
      Chat.ensure_started()
      table_id1 = :ets.info(:blog_chat_messages, :id)
      
      Chat.ensure_started()
      table_id2 = :ets.info(:blog_chat_messages, :id)
      
      assert table_id1 == table_id2
    end

    test "initializes rooms with welcome messages" do
      Chat.ensure_started()
      
      # Check that default rooms have welcome messages
      rooms = ["general", "random", "programming", "music"]
      
      for room <- rooms do
        messages = Chat.get_messages(room)
        assert length(messages) >= 1
        
        # First message should be from ChatBot
        welcome_message = hd(messages)
        assert welcome_message.sender_name == "ChatBot"
        assert welcome_message.sender_id == "system"
        assert String.contains?(welcome_message.content, "Welcome")
      end
    end
  end

  describe "banned words functionality" do
    setup do
      Chat.ensure_started()
      :ok
    end

    test "add_banned_word/1 adds word to banned list" do
      assert {:ok, "badword"} = Chat.add_banned_word("badword")
      banned_words = Chat.get_banned_words()
      assert "badword" in banned_words
    end

    test "add_banned_word/1 normalizes word to lowercase" do
      assert {:ok, "badword"} = Chat.add_banned_word("BADWORD")
      banned_words = Chat.get_banned_words()
      assert "badword" in banned_words
      refute "BADWORD" in banned_words
    end

    test "add_banned_word/1 trims whitespace" do
      assert {:ok, "badword"} = Chat.add_banned_word("  badword  ")
      banned_words = Chat.get_banned_words()
      assert "badword" in banned_words
    end

    test "add_banned_word/1 rejects empty words" do
      assert {:error, :empty_word} = Chat.add_banned_word("")
      assert {:error, :empty_word} = Chat.add_banned_word("   ")
    end

    test "get_banned_words/0 returns sorted list" do
      Chat.add_banned_word("zebra")
      Chat.add_banned_word("apple")
      Chat.add_banned_word("banana")
      
      banned_words = Chat.get_banned_words()
      assert banned_words == Enum.sort(banned_words)
      assert "apple" in banned_words
      assert "banana" in banned_words
      assert "zebra" in banned_words
    end

    test "check_for_banned_words/1 allows clean messages" do
      Chat.add_banned_word("badword")
      assert {:ok, "This is a clean message"} = Chat.check_for_banned_words("This is a clean message")
    end

    test "check_for_banned_words/1 rejects messages with banned words" do
      Chat.add_banned_word("badword")
      assert {:error, :contains_banned_words} = Chat.check_for_banned_words("This contains badword")
    end

    test "check_for_banned_words/1 is case insensitive" do
      Chat.add_banned_word("badword")
      assert {:error, :contains_banned_words} = Chat.check_for_banned_words("This contains BADWORD")
      assert {:error, :contains_banned_words} = Chat.check_for_banned_words("This contains BadWord")
    end

    test "check_for_banned_words/1 detects partial matches" do
      Chat.add_banned_word("bad")
      assert {:error, :contains_banned_words} = Chat.check_for_banned_words("This is badword")
    end
  end

  describe "message functionality" do
    setup do
      Chat.ensure_started()
      :ok
    end

    test "save_message/1 stores message correctly" do
      message = %{
        id: 123456789,
        sender_id: "user123", 
        sender_name: "Test User",
        sender_color: "hsl(200, 50%, 50%)",
        content: "Hello world",
        timestamp: DateTime.utc_now(),
        room: "general"
      }

      result = Chat.save_message(message)
      assert result == message
      
      # Verify it's stored
      messages = Chat.get_messages("general")
      saved_message = Enum.find(messages, fn m -> m.id == 123456789 end)
      assert saved_message != nil
      assert saved_message.content == "Hello world"
    end

    test "get_messages/1 returns messages for specific room" do
      # Save messages to different rooms
      general_message = %{
        id: 1,
        sender_id: "user1",
        sender_name: "User One", 
        sender_color: "hsl(0, 50%, 50%)",
        content: "General message",
        timestamp: DateTime.utc_now(),
        room: "general"
      }

      random_message = %{
        id: 2,
        sender_id: "user2",
        sender_name: "User Two",
        sender_color: "hsl(100, 50%, 50%)", 
        content: "Random message",
        timestamp: DateTime.utc_now(),
        room: "random"
      }

      Chat.save_message(general_message)
      Chat.save_message(random_message)

      general_messages = Chat.get_messages("general")
      random_messages = Chat.get_messages("random")

      # Check that messages are in correct rooms
      general_content = Enum.map(general_messages, & &1.content)
      random_content = Enum.map(random_messages, & &1.content)

      assert "General message" in general_content
      refute "Random message" in general_content
      
      assert "Random message" in random_content  
      refute "General message" in random_content
    end

    test "get_messages/1 returns messages in descending order by ID" do
      # Save messages with different IDs
      message1 = create_test_message(1, "First message", "general")
      message2 = create_test_message(3, "Third message", "general") 
      message3 = create_test_message(2, "Second message", "general")

      Chat.save_message(message1)
      Chat.save_message(message2)
      Chat.save_message(message3)

      messages = Chat.get_messages("general")
      message_ids = Enum.map(messages, & &1.id)
      
      # Should be in descending order by ID
      filtered_ids = Enum.filter(message_ids, fn id -> id in [1, 2, 3] end)
      assert filtered_ids == [3, 2, 1]
    end

    test "get_messages/1 limits to 50 messages" do
      # Save 60 messages to test limit
      for i <- 1..60 do
        message = create_test_message(i, "Message #{i}", "general")
        Chat.save_message(message)
      end

      messages = Chat.get_messages("general")
      # Should return at most 50 messages (plus any welcome messages)
      user_messages = Enum.filter(messages, fn m -> m.sender_id != "system" end)
      assert length(user_messages) <= 50
    end

    test "trim_messages automatically removes old messages" do
      # Save more than max messages (100)
      for i <- 1..105 do
        message = create_test_message(i, "Message #{i}", "general")
        Chat.save_message(message)
      end

      messages = Chat.get_messages("general")
      user_messages = Enum.filter(messages, fn m -> m.sender_id != "system" end)
      
      # Should be trimmed to max (100) or less
      assert length(user_messages) <= 100
      
      # Newer messages should be kept
      message_ids = Enum.map(user_messages, & &1.id)
      assert 105 in message_ids
      assert 104 in message_ids
      refute 1 in message_ids  # Oldest should be removed
    end

    test "clear_room/1 removes all messages from specific room" do
      # Add messages to different rooms
      Chat.save_message(create_test_message(1, "General 1", "general"))
      Chat.save_message(create_test_message(2, "Random 1", "random"))
      Chat.save_message(create_test_message(3, "General 2", "general"))

      # Clear general room
      deleted_count = Chat.clear_room("general")
      
      general_messages = Chat.get_messages("general")
      random_messages = Chat.get_messages("random")
      
      # General should be empty (except welcome message)
      user_general = Enum.filter(general_messages, fn m -> m.sender_id != "system" end)
      assert length(user_general) == 0
      
      # Random should still have messages
      user_random = Enum.filter(random_messages, fn m -> m.sender_id != "system" end)
      assert length(user_random) == 1
    end

    test "clear_all/0 removes all messages and reinitializes rooms" do
      # Add messages to multiple rooms
      Chat.save_message(create_test_message(1, "Message 1", "general"))
      Chat.save_message(create_test_message(2, "Message 2", "random"))
      Chat.save_message(create_test_message(3, "Message 3", "programming"))

      Chat.clear_all()

      # Check that rooms are reinitialized with welcome messages
      rooms = ["general", "random", "programming", "music"]
      for room <- rooms do
        messages = Chat.get_messages(room)
        # Should have at least welcome message
        assert length(messages) >= 1
        
        # All messages should be from system (welcome messages)
        user_messages = Enum.filter(messages, fn m -> m.sender_id != "system" end)
        assert length(user_messages) == 0
      end
    end

    test "list_all_messages/0 returns all messages grouped by room" do
      Chat.save_message(create_test_message(1, "General 1", "general"))
      Chat.save_message(create_test_message(2, "Random 1", "random"))
      Chat.save_message(create_test_message(3, "General 2", "general"))

      all_messages = Chat.list_all_messages()
      
      assert is_map(all_messages)
      assert Map.has_key?(all_messages, "general")
      assert Map.has_key?(all_messages, "random")
      
      general_msgs = Map.get(all_messages, "general", [])
      random_msgs = Map.get(all_messages, "random", [])
      
      # Check that messages are in correct groups
      general_content = Enum.map(general_msgs, & &1.content)
      random_content = Enum.map(random_msgs, & &1.content)
      
      assert "General 1" in general_content
      assert "General 2" in general_content
      assert "Random 1" in random_content
    end
  end

  # Helper function to create test messages
  defp create_test_message(id, content, room) do
    %{
      id: id,
      sender_id: "test_user_#{id}",
      sender_name: "Test User #{id}",
      sender_color: "hsl(#{rem(id * 30, 360)}, 50%, 50%)",
      content: content,
      timestamp: DateTime.utc_now(),
      room: room
    }
  end
end