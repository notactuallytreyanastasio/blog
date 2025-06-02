defmodule Blog.TestHelpers do
  @moduledoc """
  Test helpers and utilities for the Blog application test suite.
  """

  import ExUnit.Assertions
  alias Blog.Bookmarks.{Bookmark, Store}
  alias Blog.Wordle.Game
  alias Blog.Games.Blackjack
  alias Blog.Content.{Post, Tag}

  @doc """
  Creates a test bookmark with default or custom attributes.
  """
  def create_bookmark(attrs \\ %{}) do
    default_attrs = %{
      url: "https://example-#{:rand.uniform(1000)}.com",
      title: "Test Bookmark #{:rand.uniform(1000)}",
      description: "A test bookmark for unit testing",
      tags: ["test", "example"],
      favicon_url: "https://example.com/favicon.ico",
      user_id: "test_user_#{:rand.uniform(1000)}"
    }

    attrs = Map.merge(default_attrs, attrs)
    Bookmark.new(attrs)
  end

  @doc """
  Creates and saves a bookmark to the store.
  """
  def create_and_save_bookmark(attrs \\ %{}) do
    bookmark = create_bookmark(attrs)
    {:ok, saved_bookmark} = Store.add_bookmark(bookmark)
    saved_bookmark
  end

  @doc """
  Creates multiple test bookmarks for a user.
  """
  def create_bookmarks_for_user(user_id, count \\ 3) do
    for i <- 1..count do
      create_and_save_bookmark(%{
        url: "https://site-#{i}.com",
        title: "Site #{i}",
        description: "Description for site #{i}",
        tags: ["tag#{i}", "test"],
        user_id: user_id
      })
    end
  end

  @doc """
  Creates a test Wordle game with default or custom attributes.
  """
  def create_wordle_game(attrs \\ %{}) do
    default_attrs = %{
      player_id: "test_player_#{:rand.uniform(1000)}",
      session_id: "test_session_#{:rand.uniform(1000)}",
      target_word: "tests",
      guesses: [],
      current_guess: "",
      max_attempts: 6,
      game_over: false,
      hard_mode: false,
      used_letters: %{},
      message: nil
    }

    struct(Game, Map.merge(default_attrs, attrs))
  end

  @doc """
  Creates a test Blackjack game with players.
  """
  def create_blackjack_game(player_ids \\ ["player1", "player2"]) do
    Blackjack.new_game(player_ids)
  end

  @doc """
  Creates test posts data structure (not from files).
  """
  def create_test_posts(count \\ 3) do
    for i <- 1..count do
      %{
        title: "Test Post #{i}",
        tags: [%Tag{name: if(rem(i, 2) == 0, do: "tech", else: "life")}],
        content: "# Test Post #{i}\n\nThis is test content for post #{i}.",
        written_on: Date.add(Date.utc_today(), -i),
        slug: "test-post-#{i}"
      }
    end
  end

  @doc """
  Creates a test chat message.
  """
  def create_chat_message(attrs \\ %{}) do
    default_attrs = %{
      id: System.os_time(:millisecond),
      sender_id: "test_user_#{:rand.uniform(1000)}",
      sender_name: "Test User",
      sender_color: "hsl(#{:rand.uniform(360)}, 70%, 50%)",
      content: "Test message #{:rand.uniform(1000)}",
      timestamp: DateTime.utc_now(),
      room: "general"
    }

    Map.merge(default_attrs, attrs)
  end

  @doc """
  Creates multiple test chat messages for a room.
  """
  def create_chat_messages(room, count \\ 5) do
    for i <- 1..count do
      create_chat_message(%{
        id: System.os_time(:millisecond) + i,
        content: "Message #{i} in #{room}",
        room: room
      })
    end
  end

  @doc """
  Creates a test cursor point.
  """
  def create_cursor_point(attrs \\ %{}) do
    default_attrs = %{
      x: :rand.uniform(500),
      y: :rand.uniform(300),
      color: "rgb(#{:rand.uniform(255)}, #{:rand.uniform(255)}, #{:rand.uniform(255)})",
      user_id: "test_user_#{:rand.uniform(1000)}",
      timestamp: DateTime.utc_now()
    }

    Map.merge(default_attrs, attrs)
  end

  @doc """
  Clears all ETS tables used in testing.
  """
  def clear_all_ets_tables do
    tables = [
      :bookmarks_table,
      :blog_chat_messages,
      :blog_chat_banned_words,
      :cursor_points,
      :wordle_games
    ]

    for table <- tables do
      case :ets.info(table) do
        :undefined -> :ok
        _ -> :ets.delete_all_objects(table)
      end
    end
  end

  @doc """
  Sets up ETS tables for testing if they don't exist.
  """
  def setup_ets_tables do
    tables = [
      {:bookmarks_table, [:set, :public, :named_table]},
      {:blog_chat_messages, [:ordered_set, :public, :named_table]},
      {:blog_chat_banned_words, [:set, :protected, :named_table]},
      {:cursor_points, [:set, :public, :named_table]},
      {:wordle_games, [:set, :public, :named_table]}
    ]

    for {name, opts} <- tables do
      case :ets.info(name) do
        :undefined -> :ets.new(name, opts)
        _ -> :ok
      end
    end
  end

  @doc """
  Generates a random user ID for testing.
  """
  def random_user_id do
    "test_user_#{:rand.uniform(999999)}"
  end

  @doc """
  Generates a random color string.
  """
  def random_color do
    "hsl(#{:rand.uniform(360)}, 70%, 50%)"
  end

  @doc """
  Creates test presence data for LiveView testing.
  """
  def create_presence_data(user_id, attrs \\ %{}) do
    default_attrs = %{
      color: random_color(),
      joined_at: DateTime.utc_now(),
      cursor: %{x: 0, y: 0, in_viz: false}
    }

    {user_id, %{metas: [Map.merge(default_attrs, attrs)]}}
  end

  @doc """
  Waits for a LiveView to update (useful for async operations).
  """
  def wait_for_update(live_view, timeout \\ 100) do
    Process.sleep(timeout)
    live_view
  end

  @doc """
  Asserts that HTML contains a specific pattern with a timeout.
  """
  def assert_html_eventually(live_view, pattern, timeout \\ 1000) do
    end_time = System.monotonic_time(:millisecond) + timeout
    
    assert_html_loop(live_view, pattern, end_time)
  end

  defp assert_html_loop(live_view, pattern, end_time) do
    if System.monotonic_time(:millisecond) > end_time do
      html = Phoenix.LiveViewTest.render(live_view)
      flunk("Expected HTML to contain #{inspect(pattern)}, but got: #{html}")
    end

    html = Phoenix.LiveViewTest.render(live_view)
    
    if html =~ pattern do
      :ok
    else
      Process.sleep(10)
      assert_html_loop(live_view, pattern, end_time)
    end
  end


  @doc """
  Subscribes to a PubSub topic for testing broadcasts.
  """
  def subscribe_to_topic(topic) do
    Phoenix.PubSub.subscribe(Blog.PubSub, topic)
  end

  @doc """
  Asserts that a specific message was broadcast to the current process.
  """
  defmacro assert_broadcast_received(topic, event, payload_pattern \\ :_, timeout \\ 100) do
    quote do
      case unquote(payload_pattern) do
        :_ ->
          assert_receive %Phoenix.Socket.Broadcast{
            topic: unquote(topic),
            event: unquote(event),
            payload: _
          }, unquote(timeout)
        pattern ->
          assert_receive %Phoenix.Socket.Broadcast{
            topic: unquote(topic),
            event: unquote(event),
            payload: ^pattern
          }, unquote(timeout)
      end
    end
  end

  @doc """
  Creates test Blackjack cards for testing card game logic.
  """
  def create_test_deck do
    [
      {"A", "♠️"}, {"K", "♠️"}, {"Q", "♠️"}, {"J", "♠️"}, {"10", "♠️"},
      {"9", "♠️"}, {"8", "♠️"}, {"7", "♠️"}, {"6", "♠️"}, {"5", "♠️"}
    ]
  end

  @doc """
  Creates a Blackjack hand that totals to a specific value.
  """
  def create_blackjack_hand(target_value) do
    case target_value do
      21 -> [{"A", "♠️"}, {"K", "♣️"}]  # Blackjack
      20 -> [{"K", "♠️"}, {"Q", "♣️"}]   # 20
      19 -> [{"K", "♠️"}, {"9", "♣️"}]   # 19
      15 -> [{"7", "♠️"}, {"8", "♣️"}]   # 15
      12 -> [{"5", "♠️"}, {"7", "♣️"}]   # 12
      _ -> [{"2", "♠️"}, {"3", "♣️"}]    # Default to 5
    end
  end

  @doc """
  Mock the PythonRunner for testing without actual Python execution.
  """
  def mock_python_result(result) do
    case result do
      :success -> {:ok, "mocked output"}
      :error -> {:error, "mocked error"}
      custom when is_binary(custom) -> {:ok, custom}
    end
  end

  @doc """
  Creates a test file structure for content testing.
  """
  def create_test_markdown_file(filename, content) do
    path = Path.join([System.tmp_dir(), "test_posts", filename])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
    path
  end

  @doc """
  Cleans up test files created during testing.
  """
  def cleanup_test_files do
    test_dir = Path.join(System.tmp_dir(), "test_posts")
    if File.exists?(test_dir) do
      File.rm_rf!(test_dir)
    end
  end
end