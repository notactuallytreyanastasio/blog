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
        # Logger.info("New post: #{inspect(msg)}")
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "skeet_feed",
          {:new_post, skeet}
        )

        if contains_reddit_link?(skeet) do
          # require IEx; IEx.pry
          Logger.info("Reddit link found in skeet: #{skeet}")

          # Create a skeet record with timestamp
          timestamp = DateTime.utc_now()

          # Extract Reddit link from skeet text
          reddit_link = case Regex.run(~r/(https?:\/\/)?(www\.)?(reddit\.com|redd\.it)\/[^\s]+/, skeet) do
            [match | _] -> match
            nil -> nil
          end
          skeet_record = %{
            text: reddit_link,
            time: timestamp,
            id: generate_id()
          }
          # Update skeet record with extracted link
          # skeet_record = Map.put(skeet_record, :reddit_link, reddit_link)
          # require IEx; IEx.pry
          # Store in ETS with timestamp as key (negative for reverse chronological order)
          :ets.insert(@table_name, {{-DateTime.to_unix(timestamp)}, skeet_record})

          # Broadcast to subscribers
          Phoenix.PubSub.broadcast(
            Blog.PubSub,
            "reddit_links",
            {:reddit_link, skeet_record}
          )
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
