defmodule Blog.Chat do
  @moduledoc """
  Module for handling chat functionality and message persistence using ETS.
  """
  require Logger

  @table_name :blog_chat_messages
  @banned_words_table :blog_chat_banned_words
  @max_messages_per_room 100

  @doc """
  Ensures the ETS table is started. Should be called during application startup.
  """
  def ensure_started do
    # Initialize message table
    case :ets.info(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:ordered_set, :public, :named_table])
        Logger.info("Created new chat message ETS table")
        initialize_rooms()

      _ ->
        Logger.debug("Chat message ETS table already exists")
        :ok
    end

    # Initialize banned words table
    case :ets.info(@banned_words_table) do
      :undefined ->
        :ets.new(@banned_words_table, [:set, :protected, :named_table])
        # Add some initial banned words (these should be severe ones)
        add_banned_word("somedefaultbannedword")
        Logger.info("Created new banned words ETS table")

      _ ->
        Logger.debug("Banned words ETS table already exists")
        :ok
    end
  end

  @doc """
  Initialize the default rooms with welcome messages.
  """
  defp initialize_rooms do
    # Check if rooms are already initialized
    case get_messages("general") do
      [] ->
        # Add welcome messages to each room
        rooms = ["general", "random", "programming", "music"]

        welcome_messages = %{
          "general" => "Welcome to the General chat room! This is where everyone hangs out.",
          "random" => "Welcome to the Random chat room! Random conversations welcome!",
          "programming" =>
            "Welcome to the Programming chat room! Discuss code, programming languages, and tech.",
          "music" =>
            "Welcome to the Music chat room! Share your favorite artists, songs, and musical opinions."
        }

        Enum.each(rooms, fn room ->
          save_message(%{
            id: System.os_time(:millisecond),
            sender_id: "system",
            sender_name: "ChatBot",
            sender_color: "hsl(210, 70%, 50%)",
            content: Map.get(welcome_messages, room),
            timestamp: DateTime.utc_now(),
            room: room
          })

          Logger.info("Initialized #{room} room with welcome message")
        end)

      _ ->
        Logger.debug("Rooms already initialized with welcome messages")
        :ok
    end
  end

  @doc """
  Adds a word to the banned list.
  """
  def add_banned_word(word) when is_binary(word) do
    lowercase_word = String.downcase(String.trim(word))

    if lowercase_word != "" do
      :ets.insert(@banned_words_table, {lowercase_word, true})
      Logger.info("Added new banned word: #{lowercase_word}")
      {:ok, lowercase_word}
    else
      {:error, :empty_word}
    end
  end

  @doc """
  Gets all banned words.
  """
  def get_banned_words do
    :ets.tab2list(@banned_words_table)
    |> Enum.map(fn {word, _} -> word end)
    |> Enum.sort()
  end

  @doc """
  Checks if a message contains any banned words.
  Returns {:ok, message} if no banned words are found.
  Returns {:error, :contains_banned_words} if banned words are found.
  """
  def check_for_banned_words(message) when is_binary(message) do
    lowercase_message = String.downcase(message)

    # Get all banned words
    banned_words = get_banned_words()

    # Check if any banned word is in the message
    found_banned_word =
      Enum.find(banned_words, fn word ->
        String.contains?(lowercase_message, word)
      end)

    if found_banned_word do
      Logger.warn("Message contained banned word, rejected")
      {:error, :contains_banned_words}
    else
      {:ok, message}
    end
  end

  @doc """
  Saves a message to ETS storage.
  """
  def save_message(message) do
    # Use room and timestamp as key for ordering
    key = {message.room, message.id}

    # Insert into ETS table
    result = :ets.insert(@table_name, {key, message})

    # Debug the actual key structure to ensure consistency
    Logger.debug(
      "Saved message to ETS with key structure: #{inspect(key)}, result: #{inspect(result)}"
    )

    Logger.debug("Message content: #{inspect(message)}")

    # Debug the current state of the table
    count = :ets.info(@table_name, :size)
    Logger.debug("ETS table now has #{count} total messages")

    # Trim messages if we have too many
    trim_messages(message.room)

    # Return the stored message
    message
  end

  @doc """
  Trims messages in a room to keep only the most recent ones.
  """
  defp trim_messages(room) do
    # Count messages in this room using match_object instead of select_count with fun2ms
    messages = :ets.match_object(@table_name, {{room, :_}, :_})
    count = length(messages)

    Logger.debug("Room #{room} has #{count} messages, max is #{@max_messages_per_room}")

    if count > @max_messages_per_room do
      # Sort messages by ID (timestamp)
      sorted_messages =
        messages
        |> Enum.sort_by(fn {{_, id}, _} -> id end)

      # Delete the oldest messages
      to_delete = Enum.take(sorted_messages, count - @max_messages_per_room)

      Enum.each(to_delete, fn {{r, id}, _} ->
        :ets.delete(@table_name, {r, id})
        Logger.debug("Deleted old message with key {#{r}, #{id}}")
      end)

      Logger.info("Trimmed #{length(to_delete)} old messages from room #{room}")
    end
  end

  @doc """
  Gets messages for a specific room.
  """
  def get_messages(room) do
    # Debug the query we're about to run
    Logger.debug("Fetching messages for room '#{room}' from ETS table #{inspect(@table_name)}")

    # Use match_object to get all messages for the room
    all_matching = :ets.match_object(@table_name, {{room, :_}, :_})
    Logger.debug("Found #{length(all_matching)} raw entries for room #{room}")

    # Show raw results for debugging
    if length(all_matching) > 0 do
      Logger.debug("First matched entry: #{inspect(hd(all_matching))}")
    end

    # Extract the messages from the match_object results
    messages = Enum.map(all_matching, fn {_key, msg} -> msg end)

    # Log what we found
    Logger.debug("Retrieved #{length(messages)} message structs for room #{room}")

    # Sort and return the messages
    sorted_messages =
      messages
      |> Enum.sort_by(fn msg -> msg.id end, :desc)
      |> Enum.take(50)

    Logger.debug("Returning #{length(sorted_messages)} sorted messages")
    sorted_messages
  end

  @doc """
  Debug function to list all messages in all rooms.
  """
  def list_all_messages do
    # Get all objects from the table
    all_messages = :ets.tab2list(@table_name)
    Logger.debug("Total messages in ETS: #{length(all_messages)}")

    # Log the raw data
    if length(all_messages) > 0 do
      sample = Enum.take(all_messages, 3)
      Logger.debug("Raw message data sample: #{inspect(sample)}")
    end

    # Group by room
    result =
      all_messages
      |> Enum.map(fn {{room, _id}, message} -> {room, message} end)
      |> Enum.group_by(fn {room, _} -> room end, fn {_, message} -> message end)

    # Log the count per room
    Enum.each(result, fn {room, msgs} ->
      Logger.debug("Room #{room} has #{length(msgs)} messages")
    end)

    result
  end

  @doc """
  Clears all messages from a room.
  """
  def clear_room(room) do
    # Get all messages in the room
    messages = :ets.match_object(@table_name, {{room, :_}, :_})

    # Delete them one by one
    deleted_count =
      Enum.reduce(messages, 0, fn {{r, id}, _}, acc ->
        :ets.delete(@table_name, {r, id})
        acc + 1
      end)

    Logger.info("Cleared #{deleted_count} messages from room #{room}")
    deleted_count
  end

  @doc """
  Clears all messages from all rooms.
  """
  def clear_all do
    count = :ets.info(@table_name, :size)
    :ets.delete_all_objects(@table_name)
    Logger.info("Cleared all #{count} chat messages from all rooms")
    initialize_rooms()
  end
end
