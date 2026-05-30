defmodule Blog.ChatTest do
  # Postgres-backed context. DataCase wraps each test in a SQL sandbox
  # transaction, so async is safe (the old ETS-based design that forced
  # async: false no longer exists).
  use Blog.DataCase, async: true

  alias Blog.Chat
  alias Blog.Chat.{Chatter, Message}

  describe "hash_ip/1" do
    test "hashes a binary IP to a 16-char lowercase hex string" do
      hash = Chat.hash_ip("192.168.0.1")

      assert is_binary(hash)
      assert String.length(hash) == 16
      assert hash == String.downcase(hash)
      # Deterministic
      assert hash == Chat.hash_ip("192.168.0.1")
      # Different inputs produce different hashes
      assert hash != Chat.hash_ip("10.0.0.1")
    end

    test "returns nil for non-binary input" do
      assert Chat.hash_ip(nil) == nil
      assert Chat.hash_ip(12_345) == nil
    end
  end

  describe "find_or_create_chatter/2" do
    test "creates a new chatter for a new IP" do
      assert {:ok, chatter} = Chat.find_or_create_chatter("alice", "1.2.3.4")
      assert chatter.screen_name == "alice"
      assert chatter.ip_hash == Chat.hash_ip("1.2.3.4")
      # A color is assigned automatically
      assert is_binary(chatter.color)
      assert chatter.id != nil
    end

    test "returns the existing chatter for a returning IP with the same name" do
      {:ok, original} = Chat.find_or_create_chatter("bob", "5.6.7.8")
      {:ok, returning} = Chat.find_or_create_chatter("bob", "5.6.7.8")

      assert returning.id == original.id
    end

    test "updates the name for a returning IP that changed its screen name" do
      {:ok, original} = Chat.find_or_create_chatter("carol", "9.9.9.9")
      {:ok, renamed} = Chat.find_or_create_chatter("caroline", "9.9.9.9")

      assert renamed.id == original.id
      assert renamed.screen_name == "caroline"
    end

    test "appends a numeric suffix when the screen name is taken by another IP" do
      {:ok, first} = Chat.find_or_create_chatter("dave", "1.1.1.1")
      {:ok, second} = Chat.find_or_create_chatter("dave", "2.2.2.2")

      assert first.screen_name == "dave"
      assert second.id != first.id
      # Name collision resolved with a suffix
      assert second.screen_name == "dave2"
    end

    test "trims whitespace from the screen name" do
      assert {:ok, chatter} = Chat.find_or_create_chatter("  erin  ", "3.3.3.3")
      assert chatter.screen_name == "erin"
    end
  end

  describe "get_chatter_by_ip/1 and get_chatter_by_name/1" do
    test "look up an existing chatter by ip hash and by name" do
      {:ok, chatter} = Chat.find_or_create_chatter("frank", "4.4.4.4")

      assert Chat.get_chatter_by_ip(Chat.hash_ip("4.4.4.4")).id == chatter.id
      assert Chat.get_chatter_by_name("frank").id == chatter.id
    end

    test "return nil when no chatter matches" do
      assert Chat.get_chatter_by_ip("nonexistenthash") == nil
      assert Chat.get_chatter_by_name("nobody") == nil
    end
  end

  describe "create_message/3" do
    setup do
      {:ok, chatter} = Chat.find_or_create_chatter("grace", "7.7.7.7")
      %{chatter: chatter}
    end

    test "creates a message with a preloaded chatter", %{chatter: chatter} do
      assert {:ok, message} = Chat.create_message(chatter, "Hello world", "general")
      assert message.content == "Hello world"
      assert message.room == "general"
      assert message.chatter_id == chatter.id
      # chatter association is preloaded after creation
      assert message.chatter.id == chatter.id
      assert message.chatter.screen_name == "grace"
    end

    test "defaults the room to \"terminal\"", %{chatter: chatter} do
      assert {:ok, message} = Chat.create_message(chatter, "no room given")
      assert message.room == "terminal"
    end

    test "trims whitespace from the content", %{chatter: chatter} do
      assert {:ok, message} = Chat.create_message(chatter, "  spaced  ", "general")
      assert message.content == "spaced"
    end

    test "rejects empty content with a changeset error", %{chatter: chatter} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Chat.create_message(chatter, "", "general")

      assert "can't be blank" in errors_on(changeset).content
    end

    test "broadcasts the new message on the chat topic", %{chatter: chatter} do
      Phoenix.PubSub.subscribe(Blog.PubSub, Chat.topic())

      {:ok, message} = Chat.create_message(chatter, "broadcast me", "general")

      assert_receive {:new_chat_message, broadcast_message}
      assert broadcast_message.id == message.id
      assert broadcast_message.content == "broadcast me"
    end
  end

  describe "list_messages/2 (and get_messages/1 alias)" do
    setup do
      {:ok, chatter} = Chat.find_or_create_chatter("heidi", "8.8.8.8")
      %{chatter: chatter}
    end

    test "returns messages for a specific room only", %{chatter: chatter} do
      {:ok, _} = Chat.create_message(chatter, "general message", "general")
      {:ok, _} = Chat.create_message(chatter, "random message", "random")

      general_content = Chat.list_messages("general") |> Enum.map(& &1.content)
      random_content = Chat.list_messages("random") |> Enum.map(& &1.content)

      assert "general message" in general_content
      refute "random message" in general_content

      assert "random message" in random_content
      refute "general message" in random_content
    end

    test "returns messages ordered ascending by insertion time", %{chatter: chatter} do
      {:ok, _} = Chat.create_message(chatter, "first", "general")
      {:ok, _} = Chat.create_message(chatter, "second", "general")
      {:ok, _} = Chat.create_message(chatter, "third", "general")

      messages = Chat.list_messages("general")

      # All three are returned for the room.
      contents = Enum.map(messages, & &1.content)
      assert "first" in contents
      assert "second" in contents
      assert "third" in contents

      # inserted_at is non-decreasing (ascending order), the opposite of the
      # old ETS implementation which returned newest-first by id.
      timestamps = Enum.map(messages, & &1.inserted_at)
      assert timestamps == Enum.sort(timestamps, {:asc, NaiveDateTime})
    end

    test "limits the number of returned messages", %{chatter: chatter} do
      for i <- 1..10 do
        {:ok, _} = Chat.create_message(chatter, "message #{i}", "general")
      end

      assert length(Chat.list_messages("general", 5)) == 5
    end

    test "defaults to a limit of 50 messages", %{chatter: chatter} do
      for i <- 1..60 do
        {:ok, _} = Chat.create_message(chatter, "message #{i}", "general")
      end

      assert length(Chat.list_messages("general")) == 50
    end

    test "preloads the chatter on each message", %{chatter: chatter} do
      {:ok, _} = Chat.create_message(chatter, "hi", "general")

      [message] = Chat.list_messages("general")
      assert message.chatter.screen_name == "heidi"
    end

    test "get_messages/1 is an alias for list_messages/1", %{chatter: chatter} do
      {:ok, _} = Chat.create_message(chatter, "via alias", "general")

      contents = Chat.get_messages("general") |> Enum.map(& &1.content)
      assert "via alias" in contents
    end
  end

  describe "save_message/1 (backwards-compatible old map format)" do
    test "creates an anonymous chatter and stores the message" do
      message_map = %{
        sender_name: "LegacyUser",
        sender_color: "hsl(200, 50%, 50%)",
        content: "Hello from the old API",
        room: "general"
      }

      assert {:ok, %Message{} = message} = Chat.save_message(message_map)
      assert message.content == "Hello from the old API"
      assert message.room == "general"
      # An anonymous chatter is created from sender_name/sender_color
      assert message.chatter.screen_name == "LegacyUser"
      assert message.chatter.color == "hsl(200, 50%, 50%)"

      # And it is retrievable via list_messages
      contents = Chat.get_messages("general") |> Enum.map(& &1.content)
      assert "Hello from the old API" in contents
    end

    test "reuses an existing chatter with the same screen name" do
      base = %{sender_color: "hsl(0, 50%, 50%)", room: "general"}

      {:ok, first} =
        Chat.save_message(Map.merge(base, %{sender_name: "Repeat", content: "one"}))

      {:ok, second} =
        Chat.save_message(Map.merge(base, %{sender_name: "Repeat", content: "two"}))

      assert first.chatter_id == second.chatter_id
    end
  end

  describe "list_online_chatters/1" do
    test "extracts the first meta from each presence entry" do
      presence_list = %{
        "user1" => %{metas: [%{screen_name: "Ann"}, %{screen_name: "stale"}]},
        "user2" => %{metas: [%{screen_name: "Ben"}]}
      }

      result = Chat.list_online_chatters(presence_list)

      assert length(result) == 2
      screen_names = Enum.map(result, & &1.screen_name)
      assert "Ann" in screen_names
      assert "Ben" in screen_names
      # Only the head meta is used per user
      refute %{screen_name: "stale"} in result
    end
  end

  describe "Chatter schema" do
    test "random_color/0 produces an HSL string" do
      assert Chatter.random_color() =~ ~r/^hsl\(\d+, 70%, 40%\)$/
    end

    test "changeset requires a screen_name and enforces length bounds" do
      assert {:error, changeset} =
               %Chatter{} |> Chatter.changeset(%{screen_name: ""}) |> Repo.insert()

      refute changeset.valid?

      too_long = String.duplicate("x", 21)

      assert {:error, changeset} =
               %Chatter{} |> Chatter.changeset(%{screen_name: too_long}) |> Repo.insert()

      assert "should be at most 20 character(s)" in errors_on(changeset).screen_name
    end

    test "enforces a unique screen_name" do
      {:ok, _} = Chat.find_or_create_chatter("unique_name", "10.0.0.1")

      assert {:error, changeset} =
               %Chatter{}
               |> Chatter.changeset(%{screen_name: "unique_name"})
               |> Repo.insert()

      assert "has already been taken" in errors_on(changeset).screen_name
    end
  end

  # NOTE: The banned-words feature and the ETS-table lifecycle from the old
  # implementation no longer exist. The current Postgres-backed Blog.Chat keeps
  # only no-op backwards-compatibility stubs for callers in post_live/index.ex.
  # Blog.Chat.get_banned_words/0 was removed entirely (no replacement), so the
  # tests that exercised real banning behavior could not be ported. These tests
  # pin the documented current behavior of the remaining stubs.
  describe "backwards-compatibility stubs" do
    test "ensure_started/0 is a no-op that returns :ok" do
      assert Chat.ensure_started() == :ok
    end

    test "add_banned_word/1 is a stub returning {:ok, \"\"}" do
      assert Chat.add_banned_word("anything") == {:ok, ""}
    end

    test "check_for_banned_words/1 is a stub that passes the message through unchanged" do
      assert Chat.check_for_banned_words("this used to be filtered") ==
               {:ok, "this used to be filtered"}
    end
  end
end
