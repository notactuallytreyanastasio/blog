defmodule Blog.Chat do
  @moduledoc """
  Module for handling chat functionality and message persistence using ETS.
  """

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
        initialize_rooms()
      _ ->
        :ok
    end

    # Initialize banned words table
    case :ets.info(@banned_words_table) do
      :undefined ->
        :ets.new(@banned_words_table, [:set, :protected, :named_table])
        # Add some initial banned words (these should be severe ones)
        add_banned_word("somedefaultbannedword")
      _ ->
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
          "programming" => "Welcome to the Programming chat room! Discuss code, programming languages, and tech.",
          "music" => "Welcome to the Music chat room! Share your favorite artists, songs, and musical opinions."
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
        end)
      _ ->
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
    found_banned_word = Enum.find(banned_words, fn word ->
      String.contains?(lowercase_message, word)
    end)

    if found_banned_word do
      {:error, :contains_banned_words}
    else
      {:ok, message}
    end
  end

  @doc """
  Saves a message to ETS storage.
  """
  def save_message(message) do
    # Use timestamp as part of the key for ordering
    key = {message.room, message.id}
    :ets.insert(@table_name, {key, message})

    # Trim messages if we have too many
    trim_messages(message.room)

    message
  end

  @doc """
  Trims messages in a room to keep only the most recent ones.
  """
  defp trim_messages(room) do
    # Count messages in this room
    count = :ets.select_count(@table_name, [{{{"#{room}", :_}, :_}, [], [true]}])

    if count > @max_messages_per_room do
      # Get all messages for this room
      messages =
        :ets.match_object(@table_name, {{{"#{room}", :_}, :_}})
        |> Enum.sort()

      # Delete the oldest messages
      to_delete = Enum.take(messages, count - @max_messages_per_room)

      Enum.each(to_delete, fn {key, _} ->
        :ets.delete(@table_name, key)
      end)
    end
  end

  @doc """
  Gets messages for a specific room.
  """
  def get_messages(room) do
    # Create a match pattern for the room
    case :ets.match_object(@table_name, {{{room, :_}, :_}}) do
      [] -> []
      messages ->
        messages
        |> Enum.sort(fn {{_, id1}, _}, {{_, id2}, _} -> id1 > id2 end)
        |> Enum.map(fn {_, message} -> message end)
        |> Enum.take(50)
    end
  end

  @doc """
  Clears all messages from a room.
  """
  def clear_room(room) do
    # Delete all messages in the room
    :ets.match_delete(@table_name, {{{room, :_}, :_}})
  end

  @doc """
  Clears all messages from all rooms.
  """
  def clear_all do
    :ets.delete_all_objects(@table_name)
    initialize_rooms()
  end
end
