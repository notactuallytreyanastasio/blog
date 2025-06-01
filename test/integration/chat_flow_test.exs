defmodule Blog.Integration.ChatFlowTest do
  @moduledoc """
  Integration tests for the complete chat system workflow.
  Tests multi-room chat, banned word filtering, and real-time messaging.
  """
  
  use BlogWeb.ConnCase, async: false
  use BlogWeb.ChannelCase, async: false
  
  import Phoenix.ChannelTest
  import Blog.TestHelpers
  
  alias Blog.Chat
  alias BlogWeb.UserSocket

  setup do
    # Ensure clean state
    clear_all_ets_tables()
    setup_ets_tables()
    
    # Start the chat system
    case GenServer.whereis(Chat) do
      nil -> 
        {:ok, _pid} = Chat.start_link([])
      _pid -> :ok
    end
    
    user_id_1 = random_user_id()
    user_id_2 = random_user_id()
    {:ok, user_id_1: user_id_1, user_id_2: user_id_2}
  end

  describe "Complete chat workflow" do
    test "users can join rooms and send messages", %{user_id_1: user_id_1, user_id_2: user_id_2} do
      # User 1 joins general room
      socket1 = create_test_socket(user_id_1)
      {:ok, _reply, socket1} = join(socket1, "chat:general")
      
      # User 2 joins general room
      socket2 = create_test_socket(user_id_2)
      {:ok, _reply, socket2} = join(socket2, "chat:general")
      
      # User 1 sends a message
      message_content = "Hello everyone!"
      ref = push(socket1, "new_message", %{
        "content" => message_content,
        "sender_name" => "TestUser1"
      })
      
      # Should get confirmation
      assert_reply ref, :ok
      
      # Both users should receive the broadcast
      assert_broadcast "new_message", %{
        content: ^message_content,
        sender_id: ^user_id_1,
        sender_name: "TestUser1",
        room: "general"
      }
      
      # User 2 responds
      response_content = "Hi there!"
      ref = push(socket2, "new_message", %{
        "content" => response_content,
        "sender_name" => "TestUser2"
      })
      
      assert_reply ref, :ok
      assert_broadcast "new_message", %{
        content: ^response_content,
        sender_id: ^user_id_2,
        sender_name: "TestUser2",
        room: "general"
      }
      
      # Verify messages are stored
      messages = Chat.get_messages("general")
      assert length(messages) == 2
      
      # Check message order (newest first)
      [latest_msg, first_msg] = messages
      assert latest_msg.content == response_content
      assert first_msg.content == message_content
    end

    test "banned word filtering prevents inappropriate messages", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Add a banned word
      Chat.add_banned_word("badword")
      
      # Try to send message with banned word
      ref = push(socket, "new_message", %{
        "content" => "This contains a badword in it",
        "sender_name" => "TestUser"
      })
      
      # Should be rejected
      assert_reply ref, :error, %{reason: "Message contains banned words"}
      
      # No broadcast should occur
      refute_broadcast "new_message", _
      
      # No message should be stored
      messages = Chat.get_messages("general")
      assert length(messages) == 0
      
      # Send a clean message
      ref = push(socket, "new_message", %{
        "content" => "This is a clean message",
        "sender_name" => "TestUser"
      })
      
      assert_reply ref, :ok
      assert_broadcast "new_message", %{content: "This is a clean message"}
    end

    test "users can join multiple rooms independently", %{user_id_1: user_id_1, user_id_2: user_id_2} do
      # User 1 joins general and tech rooms
      socket1_general = create_test_socket(user_id_1)
      {:ok, _reply, socket1_general} = join(socket1_general, "chat:general")
      
      socket1_tech = create_test_socket(user_id_1)
      {:ok, _reply, socket1_tech} = join(socket1_tech, "chat:tech")
      
      # User 2 joins only tech room
      socket2_tech = create_test_socket(user_id_2)
      {:ok, _reply, socket2_tech} = join(socket2_tech, "chat:tech")
      
      # Send message in general room
      ref = push(socket1_general, "new_message", %{
        "content" => "Hello general!",
        "sender_name" => "User1"
      })
      assert_reply ref, :ok
      
      # Send message in tech room
      ref = push(socket1_tech, "new_message", %{
        "content" => "Hello tech!",
        "sender_name" => "User1"
      })
      assert_reply ref, :ok
      
      # Verify room isolation
      general_messages = Chat.get_messages("general")
      tech_messages = Chat.get_messages("tech")
      
      assert length(general_messages) == 1
      assert length(tech_messages) == 1
      
      assert hd(general_messages).content == "Hello general!"
      assert hd(tech_messages).content == "Hello tech!"
    end
  end

  describe "Message history and persistence" do
    test "joining room returns recent message history", %{user_id_1: user_id_1, user_id_2: user_id_2} do
      # User 1 sends messages before User 2 joins
      socket1 = create_test_socket(user_id_1)
      {:ok, _reply, socket1} = join(socket1, "chat:general")
      
      # Send several messages
      for i <- 1..5 do
        ref = push(socket1, "new_message", %{
          "content" => "Message #{i}",
          "sender_name" => "User1"
        })
        assert_reply ref, :ok
      end
      
      # User 2 joins and should receive message history
      socket2 = create_test_socket(user_id_2)
      {:ok, reply, _socket2} = join(socket2, "chat:general")
      
      # Should get recent messages in join reply
      assert %{messages: messages} = reply
      assert length(messages) <= 10  # Chat typically limits to recent messages
      
      # Messages should be in reverse chronological order (newest first)
      message_contents = Enum.map(messages, & &1.content)
      assert "Message 5" in message_contents
      assert "Message 1" in message_contents
    end

    test "message limit prevents memory overflow", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Send many messages (more than typical limit)
      message_count = 25
      for i <- 1..message_count do
        ref = push(socket, "new_message", %{
          "content" => "Message #{i}",
          "sender_name" => "User1"
        })
        assert_reply ref, :ok
      end
      
      # Should have reasonable number of messages stored
      messages = Chat.get_messages("general")
      assert length(messages) <= 20  # Reasonable limit
      
      # Should keep most recent messages
      latest_message = hd(messages)
      assert latest_message.content == "Message #{message_count}"
    end
  end

  describe "Real-time features and presence" do
    test "typing indicators work across users", %{user_id_1: user_id_1, user_id_2: user_id_2} do
      socket1 = create_test_socket(user_id_1)
      {:ok, _reply, socket1} = join(socket1, "chat:general")
      
      socket2 = create_test_socket(user_id_2)
      {:ok, _reply, socket2} = join(socket2, "chat:general")
      
      # User 1 starts typing
      ref = push(socket1, "typing", %{"sender_name" => "User1"})
      assert_reply ref, :ok
      
      # User 2 should receive typing notification
      assert_broadcast "user_typing", %{
        sender_id: ^user_id_1,
        sender_name: "User1",
        room: "general"
      }
      
      # User 1 stops typing
      ref = push(socket1, "stop_typing", %{"sender_name" => "User1"})
      assert_reply ref, :ok
      
      # User 2 should receive stop typing notification
      assert_broadcast "user_stop_typing", %{
        sender_id: ^user_id_1,
        sender_name: "User1",
        room: "general"
      }
    end

    test "user join/leave notifications", %{user_id_1: user_id_1, user_id_2: user_id_2} do
      # User 1 joins
      socket1 = create_test_socket(user_id_1)
      {:ok, _reply, socket1} = join(socket1, "chat:general")
      
      # User 2 joins (should notify User 1)
      socket2 = create_test_socket(user_id_2)
      {:ok, _reply, socket2} = join(socket2, "chat:general")
      
      # Both should be notified of presence changes
      assert_broadcast "presence_diff", _
      
      # User 2 leaves
      leave(socket2)
      
      # User 1 should be notified
      assert_broadcast "presence_diff", _
    end
  end

  describe "Error handling and edge cases" do
    test "handles empty messages gracefully", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Try to send empty message
      ref = push(socket, "new_message", %{
        "content" => "",
        "sender_name" => "User1"
      })
      
      # Should be rejected
      assert_reply ref, :error, %{reason: "Message cannot be empty"}
      
      # Try to send only whitespace
      ref = push(socket, "new_message", %{
        "content" => "   \n\t  ",
        "sender_name" => "User1"
      })
      
      assert_reply ref, :error, %{reason: "Message cannot be empty"}
    end

    test "handles very long messages", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Create a very long message
      long_message = String.duplicate("a", 1000)
      
      ref = push(socket, "new_message", %{
        "content" => long_message,
        "sender_name" => "User1"
      })
      
      # Should either succeed with truncation or be rejected
      assert_reply ref, result when result in [:ok, :error]
    end

    test "handles malformed message data", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Send message without content
      ref = push(socket, "new_message", %{"sender_name" => "User1"})
      assert_reply ref, :error, _
      
      # Send message without sender_name
      ref = push(socket, "new_message", %{"content" => "Hello"})
      assert_reply ref, :error, _
    end

    test "handles concurrent message sending", %{user_id_1: user_id_1} do
      # Create multiple connections for the same user
      sockets = for i <- 1..3 do
        socket = create_test_socket(user_id_1)
        {:ok, _reply, socket} = join(socket, "chat:general")
        socket
      end
      
      # Send messages concurrently
      tasks = for {socket, i} <- Enum.with_index(sockets, 1) do
        Task.async(fn ->
          ref = push(socket, "new_message", %{
            "content" => "Concurrent message #{i}",
            "sender_name" => "User1"
          })
          assert_reply ref, :ok
        end)
      end
      
      # Wait for all tasks to complete
      Enum.each(tasks, &Task.await/1)
      
      # All messages should be stored
      messages = Chat.get_messages("general")
      assert length(messages) == 3
      
      # All messages should be from the same user
      Enum.each(messages, fn msg ->
        assert msg.sender_id == user_id_1
      end)
    end
  end

  describe "Performance and scalability" do
    test "handles high message volume efficiently", %{user_id_1: user_id_1} do
      socket = create_test_socket(user_id_1)
      {:ok, _reply, socket} = join(socket, "chat:general")
      
      # Send many messages quickly
      message_count = 50
      start_time = System.monotonic_time(:millisecond)
      
      for i <- 1..message_count do
        ref = push(socket, "new_message", %{
          "content" => "Speed test message #{i}",
          "sender_name" => "User1"
        })
        assert_reply ref, :ok
      end
      
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time
      
      # Should process messages reasonably quickly
      assert duration < 5000  # Less than 5 seconds for 50 messages
      
      # Messages should be stored
      messages = Chat.get_messages("general")
      assert length(messages) > 0
    end

    test "handles multiple rooms efficiently", %{user_id_1: user_id_1} do
      # Join multiple rooms
      rooms = ["general", "tech", "random", "announcements", "help"]
      
      sockets = for room <- rooms do
        socket = create_test_socket(user_id_1)
        {:ok, _reply, socket} = join(socket, "chat:#{room}")
        {room, socket}
      end
      
      # Send message to each room
      for {room, socket} <- sockets do
        ref = push(socket, "new_message", %{
          "content" => "Hello #{room}!",
          "sender_name" => "User1"
        })
        assert_reply ref, :ok
      end
      
      # Verify room isolation
      for room <- rooms do
        messages = Chat.get_messages(room)
        assert length(messages) == 1
        assert hd(messages).content == "Hello #{room}!"
        assert hd(messages).room == room
      end
    end
  end
end