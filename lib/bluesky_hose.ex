defmodule BlueskyHose do
  use WebSockex
  require Logger
  alias Blog.Social.Skeet
  alias Blog.Repo

  @table_name :reddit_links

  def start_link(opts \\ []) do
    # Create ETS table if it doesn't exist
    :ets.new(@table_name, [:named_table, :ordered_set, :public, read_concurrency: true])
    WebSockex.start_link("wss://bsky-relay.c.theo.io/subscribe?wantedCollections=app.bsky.feed.post", __MODULE__, :fake_state, opts)
  rescue
    ArgumentError ->
      # Table already exists
      WebSockex.start_link("wss://bsky-relay.c.theo.io/subscribe?wantedCollections=app.bsky.feed.post", __MODULE__, :fake_state, opts)
  end

  def handle_connect(_conn, _state) do
    Logger.info("Connected!")
    IO.puts("#{DateTime.utc_now}")
    {:ok, 0}
  end

  def handle_frame({:text, msg}, state) do
    msg = Jason.decode!(msg)
    case msg do
      %{"commit" => %{"record" => %{"text" => skeet}}} = msg ->
        # Broadcast to the general skeet feed
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "skeet_feed",
          {:new_post, skeet}
        )

        if contains_reddit_link?(skeet) do
          Logger.info("Reddit link found in skeet: #{skeet}")

          # Create a skeet record with timestamp
          timestamp = DateTime.utc_now()

          # Extract all Reddit links from skeet text
          reddit_links = extract_reddit_links(skeet)

          if length(reddit_links) > 0 do
            skeet_record = %{
              original_text: skeet,
              links: reddit_links,
              time: timestamp,
              id: generate_id()
            }

            # Store in ETS with timestamp as key (negative for reverse chronological order)
            :ets.insert(@table_name, {{-DateTime.to_unix(timestamp)}, skeet_record})

            # Broadcast to subscribers
            Phoenix.PubSub.broadcast(
              Blog.PubSub,
              "reddit_links",
              {:reddit_link, skeet_record}
            )
          end
        end
      _ ->
        nil
    end
    {:ok, state + 1}
  end

  defp contains_reddit_link?(skeet) when is_binary(skeet) do
    String.match?(skeet, ~r/reddit\.com|redd\.it/i)
  end

  defp contains_reddit_link?(_), do: false

  defp extract_reddit_links(text) do
    # More comprehensive regex to capture full Reddit URLs
    # This pattern is designed to capture the entire URL including query parameters
    regex = ~r/(https?:\/\/)?(www\.)?(reddit\.com|redd\.it)\/[^\s"'<>()\[\]{}]+/i

    # Find all matches
    Regex.scan(regex, text)
    |> Enum.map(fn [full_match | _] ->
      # Clean up the URL - remove trailing punctuation that might have been captured
      clean_url = Regex.replace(~r/[.,;:!?]+$/, full_match, "")

      # Ensure URL has http prefix
      if String.starts_with?(clean_url, "http") do
        clean_url
      else
        "https://#{clean_url}"
      end
    end)
    |> Enum.uniq()
  end

  defp generate_id do
    :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower)
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  # Function to get all stored Reddit links
  def get_reddit_links(limit \\ 50) do
    case :ets.info(@table_name) do
      :undefined -> []
      _ ->
        :ets.tab2list(@table_name)
        |> Enum.sort() # Already sorted by key, but just to be sure
        |> Enum.take(limit)
        |> Enum.map(fn {_key, value} -> value end)
    end
  end
end
