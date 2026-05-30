defmodule Blog.Integration.ChatFlowTest do
  @moduledoc """
  Integration tests for the complete chat system workflow.

  The chat system is backed by Postgres (`Blog.Chat` context) rather than the
  old ETS/GenServer + Phoenix.Channel design. Chatters are persisted with
  sticky, IP-hash-keyed screen names, messages belong to a chatter and a room,
  and new messages are broadcast over `Blog.PubSub` on `Chat.topic()`.
  """

  use Blog.DataCase, async: false

  alias Blog.Chat
  alias Blog.Chat.{Chatter, Message}

  setup do
    # Subscribe so we can assert on the message broadcasts the context emits.
    Phoenix.PubSub.subscribe(Blog.PubSub, Chat.topic())

    {:ok, ip_1: "192.0.2.1", ip_2: "198.51.100.7"}
  end

  describe "Complete chat workflow" do
    test "chatters can be created and exchange messages in a room", %{ip_1: ip_1, ip_2: ip_2} do
      {:ok, user1} = Chat.find_or_create_chatter("TestUser1", ip_1)
      {:ok, user2} = Chat.find_or_create_chatter("TestUser2", ip_2)

      assert user1.screen_name == "TestUser1"
      assert user2.screen_name == "TestUser2"
      # IPs are hashed for privacy, never stored raw.
      assert user1.ip_hash == Chat.hash_ip(ip_1)
      refute user1.ip_hash == ip_1

      # User 1 sends a message.
      message_content = "Hello everyone!"
      {:ok, msg1} = Chat.create_message(user1, message_content, "general")

      assert msg1.content == message_content
      assert msg1.room == "general"
      assert msg1.chatter.id == user1.id
      assert msg1.chatter.screen_name == "TestUser1"

      # The send is broadcast to subscribers (e.g. the LiveView).
      assert_receive {:new_chat_message, %Message{content: ^message_content, room: "general"}}

      # User 2 responds.
      response_content = "Hi there!"
      {:ok, _msg2} = Chat.create_message(user2, response_content, "general")
      assert_receive {:new_chat_message, %Message{content: ^response_content}}

      # Both messages are persisted, oldest-first.
      messages = Chat.get_messages("general")
      assert length(messages) == 2

      [first_msg, latest_msg] = messages
      assert first_msg.content == message_content
      assert latest_msg.content == response_content
    end

    test "content length validation rejects messages that are too long", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("TestUser", ip_1)

      # The schema caps content at 500 chars; over-long content is rejected
      # server-side and never persisted or broadcast.
      too_long = String.duplicate("a", 501)
      assert {:error, %Ecto.Changeset{} = changeset} =
               Chat.create_message(chatter, too_long, "general")

      assert "should be at most 500 character(s)" in errors_on(changeset).content
      refute_receive {:new_chat_message, _}
      assert Chat.get_messages("general") == []

      # A clean, in-bounds message goes through.
      {:ok, _} = Chat.create_message(chatter, "This is a clean message", "general")
      assert_receive {:new_chat_message, %Message{content: "This is a clean message"}}
      assert length(Chat.get_messages("general")) == 1
    end

    test "messages stay isolated between rooms", %{ip_1: ip_1, ip_2: ip_2} do
      {:ok, user1} = Chat.find_or_create_chatter("User1", ip_1)
      {:ok, user2} = Chat.find_or_create_chatter("User2", ip_2)

      {:ok, _} = Chat.create_message(user1, "Hello general!", "general")
      {:ok, _} = Chat.create_message(user1, "Hello tech!", "tech")
      {:ok, _} = Chat.create_message(user2, "Tech reply", "tech")

      general_messages = Chat.get_messages("general")
      tech_messages = Chat.get_messages("tech")

      assert length(general_messages) == 1
      assert length(tech_messages) == 2

      assert hd(general_messages).content == "Hello general!"
      assert Enum.map(tech_messages, & &1.content) == ["Hello tech!", "Tech reply"]
    end
  end

  describe "Sticky screen names" do
    test "a returning visitor (same IP) keeps the same chatter row", %{ip_1: ip_1} do
      {:ok, first} = Chat.find_or_create_chatter("Stickyname", ip_1)
      {:ok, second} = Chat.find_or_create_chatter("Stickyname", ip_1)

      assert first.id == second.id
      assert Chat.get_chatter_by_ip(Chat.hash_ip(ip_1)).id == first.id
    end

    test "a name taken by a different IP gets a numeric suffix", %{ip_1: ip_1, ip_2: ip_2} do
      {:ok, original} = Chat.find_or_create_chatter("PopularName", ip_1)
      {:ok, second} = Chat.find_or_create_chatter("PopularName", ip_2)

      assert original.screen_name == "PopularName"
      assert second.screen_name == "PopularName2"
      refute original.id == second.id
    end

    test "a returning visitor can change their screen name", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("OldName", ip_1)
      {:ok, renamed} = Chat.find_or_create_chatter("NewName", ip_1)

      assert chatter.id == renamed.id
      assert renamed.screen_name == "NewName"
    end
  end

  describe "Message history and persistence" do
    test "list_messages returns recent history in chronological order", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("Historian", ip_1)

      for i <- 1..5 do
        {:ok, _} = Chat.create_message(chatter, "Message #{i}", "general")
      end

      messages = Chat.list_messages("general", 10)
      assert length(messages) == 5

      contents = Enum.map(messages, & &1.content)
      assert contents == ["Message 1", "Message 2", "Message 3", "Message 4", "Message 5"]
    end

    test "the limit argument caps how many messages are returned", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("ChattyUser", ip_1)

      for i <- 1..25 do
        {:ok, _} = Chat.create_message(chatter, "Message #{i}", "general")
      end

      # All 25 are persisted...
      assert length(Chat.list_messages("general", 100)) == 25
      # ...but the limit constrains how many are returned. (We don't assert which
      # ones: the 25 inserts share inserted_at timestamps, so the order_by tie is
      # not deterministic — the contract under test is the cap, not the slice.)
      assert length(Chat.list_messages("general", 10)) == 10
      assert length(Chat.list_messages("general", 5)) == 5
    end
  end

  describe "Presence support" do
    test "list_online_chatters extracts the latest meta per presence", %{ip_1: ip_1, ip_2: ip_2} do
      presence_list = %{
        "user_a" => %{metas: [%{screen_name: "Alice", ip: ip_1}, %{stale: true}]},
        "user_b" => %{metas: [%{screen_name: "Bob", ip: ip_2}]}
      }

      online = Chat.list_online_chatters(presence_list)

      assert length(online) == 2
      screen_names = Enum.map(online, & &1.screen_name) |> Enum.sort()
      assert screen_names == ["Alice", "Bob"]
    end
  end

  describe "Error handling and edge cases" do
    test "empty and whitespace-only messages are rejected", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("EdgeUser", ip_1)

      # Empty content fails validate_required/validate_length.
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(chatter, "", "general")

      # Whitespace is trimmed to empty before insert, so it is also rejected.
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(chatter, "   \n\t  ", "general")

      refute_receive {:new_chat_message, _}
      assert Chat.get_messages("general") == []
    end

    test "content is trimmed before being stored", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("TrimUser", ip_1)

      {:ok, message} = Chat.create_message(chatter, "  padded  ", "general")
      assert message.content == "padded"
    end

    test "a 500-char message (the upper bound) is accepted", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("LongUser", ip_1)

      long_message = String.duplicate("a", 500)
      assert {:ok, %Message{}} = Chat.create_message(chatter, long_message, "general")
      assert_receive {:new_chat_message, _}
    end

    test "chatter creation requires a screen name" do
      # Blank screen names fail the changeset rather than creating a row.
      assert {:error, %Ecto.Changeset{} = changeset} = Chat.find_or_create_chatter("", "203.0.113.5")
      assert "can't be blank" in errors_on(changeset).screen_name
    end
  end

  describe "Concurrency and volume" do
    test "concurrent message sends from one chatter all persist", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("ConcurrentUser", ip_1)

      # The Ecto SQL sandbox connection is owned by the test process, so allow
      # the spawned tasks to share it before they touch the Repo.
      parent = self()

      tasks =
        for i <- 1..3 do
          Task.async(fn ->
            Ecto.Adapters.SQL.Sandbox.allow(Blog.Repo, parent, self())
            Chat.create_message(chatter, "Concurrent message #{i}", "general")
          end)
        end

      results = Enum.map(tasks, &Task.await/1)
      assert Enum.all?(results, &match?({:ok, %Message{}}, &1))

      messages = Chat.get_messages("general")
      assert length(messages) == 3
      assert Enum.all?(messages, fn msg -> msg.chatter_id == chatter.id end)
    end

    test "a high volume of messages is handled efficiently", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("SpeedUser", ip_1)

      message_count = 50
      start_time = System.monotonic_time(:millisecond)

      for i <- 1..message_count do
        {:ok, _} = Chat.create_message(chatter, "Speed test message #{i}", "general")
      end

      duration = System.monotonic_time(:millisecond) - start_time
      assert duration < 5000

      assert length(Chat.list_messages("general", message_count)) == message_count
    end

    test "many rooms are handled with full isolation", %{ip_1: ip_1} do
      {:ok, chatter} = Chat.find_or_create_chatter("MultiRoomUser", ip_1)
      rooms = ["general", "tech", "random", "announcements", "help"]

      for room <- rooms do
        {:ok, _} = Chat.create_message(chatter, "Hello #{room}!", room)
      end

      for room <- rooms do
        messages = Chat.get_messages(room)
        assert length(messages) == 1
        assert hd(messages).content == "Hello #{room}!"
        assert hd(messages).room == room
      end
    end
  end

  describe "Schema sanity" do
    test "Chatter and Message structs expose the current fields" do
      # Guards against silent schema drift: these are the fields the context
      # and LiveView rely on.
      assert %Chatter{screen_name: nil, ip_hash: nil, color: nil} = %Chatter{}
      assert %Message{content: nil, room: "terminal", chatter_id: nil} = %Message{}
    end
  end
end
