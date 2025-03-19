defmodule Blog.Chat.MessageStore do
  @moduledoc """
  Manages ETS storage for chat messages.

  This module provides a way to persist chat messages between page refreshes
  using ETS (Erlang Term Storage). It handles creation, retrieval and storage
  of messages with efficient retrieval by timestamp.
  """

  @table_name :allowed_chat_messages
  @allowed_words_table :allowed_chat_words
  @global_words_key :global_allowed_words
  @max_messages 100
  @topic "allowed_chat"

  @doc """
  Initializes the ETS tables needed for chat functionality.

  Should be called when the application starts.
  """
  def init do
    # Create ETS table for messages if it doesn't exist
    if :ets.info(@table_name) == :undefined do
      :ets.new(@table_name, [:named_table, :ordered_set, :public])
    end

    # Create ETS table for allowed words if it doesn't exist
    if :ets.info(@allowed_words_table) == :undefined do
      :ets.new(@allowed_words_table, [:named_table, :set, :public])

      # Initialize the global allowed words set if it doesn't exist
      if :ets.lookup(@allowed_words_table, @global_words_key) == [] do
        :ets.insert(@allowed_words_table, {@global_words_key, MapSet.new()})
      end
    end

    :ok
  end

  @doc """
  Stores a message in the ETS table.

  The message is stored with a key that ensures messages are ordered by timestamp
  in descending order (most recent first). Message visibility is calculated dynamically
  by the LiveView and not stored in the ETS table.
  """
  def store_message(message) do
    # We use negative timestamp as key to get descending order
    timestamp_key = -DateTime.to_unix(message.timestamp, :microsecond)

    # Store the message (we're removing visibility fields if they exist since they'll be calculated dynamically)
    clean_message = Map.drop(message, [:is_visible, :matching_words])
    :ets.insert(@table_name, {timestamp_key, clean_message})

    # Prune old messages if we exceed the maximum
    prune_messages()

    # Broadcast the new message to all connected clients
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:new_message, clean_message})

    :ok
  end

  @doc """
  Retrieves the most recent messages from the ETS table.

  Returns a list of messages, sorted by timestamp (newest first).
  """
  def get_recent_messages(limit \\ @max_messages) do
    # Get messages ordered by timestamp (newest first)
    case :ets.info(@table_name) do
      :undefined ->
        []

      _ ->
        :ets.tab2list(@table_name)
        # Sort by key (negative timestamp)
        |> Enum.sort()
        |> Enum.take(limit)
        |> Enum.map(fn {_key, message} -> message end)
    end
  end

  @doc """
  Adds a word to the global allowed words list.
  """
  def add_allowed_word(word) do
    current_words = get_allowed_words()
    new_words = MapSet.put(current_words, word)
    :ets.insert(@allowed_words_table, {@global_words_key, new_words})

    # Broadcast allowed words update to all users
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:allowed_words_updated, new_words})

    :ok
  end

  @doc """
  Removes a word from the global allowed words list.
  """
  def remove_allowed_word(word) do
    current_words = get_allowed_words()
    new_words = MapSet.delete(current_words, word)
    :ets.insert(@allowed_words_table, {@global_words_key, new_words})

    # Broadcast allowed words update to all users
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:allowed_words_updated, new_words})

    :ok
  end

  @doc """
  Retrieves the global allowed words list.

  Returns a MapSet of allowed words. If no global list exists,
  returns an empty MapSet and initializes one.
  """
  def get_allowed_words do
    case :ets.lookup(@allowed_words_table, @global_words_key) do
      [{@global_words_key, allowed_words}] ->
        allowed_words

      [] ->
        # If no global list exists, initialize an empty one
        empty_set = MapSet.new()
        :ets.insert(@allowed_words_table, {@global_words_key, empty_set})
        empty_set
    end
  end

  # For backwards compatibility - will get the global list
  def get_allowed_words(_user_id) do
    get_allowed_words()
  end

  # For backwards compatibility - will update the global list
  def store_allowed_words(_user_id, allowed_words) do
    :ets.insert(@allowed_words_table, {@global_words_key, allowed_words})

    # Broadcast allowed words update
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:allowed_words_updated, allowed_words})

    :ok
  end

  # Private helper to prune old messages
  defp prune_messages do
    case :ets.info(@table_name) do
      :undefined ->
        :ok

      info ->
        count = info[:size]

        if count > @max_messages do
          # Get all keys
          keys = :ets.tab2list(@table_name) |> Enum.map(fn {k, _} -> k end) |> Enum.sort(:desc)
          # Keep only the most recent @max_messages
          keys_to_delete = Enum.drop(keys, @max_messages)
          Enum.each(keys_to_delete, fn key -> :ets.delete(@table_name, key) end)
        end
    end
  end

  @doc """
  Returns the topic name for PubSub subscriptions.
  """
  def topic, do: @topic
end
