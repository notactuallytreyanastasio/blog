defmodule BlueskyHose do
  use WebSockex
  require Logger

  @table_name :reddit_links

  def start_link(opts \\ []) do
    # Create ETS table if it doesn't exist
    :ets.new(@table_name, [:named_table, :ordered_set, :public, read_concurrency: true])

    WebSockex.start_link(
      "wss://bsky-relay.c.theo.io/subscribe?wantedCollections=app.bsky.feed.post",
      __MODULE__,
      :fake_state,
      opts
    )
  rescue
    ArgumentError ->
      # Table already exists
      WebSockex.start_link(
        "wss://bsky-relay.c.theo.io/subscribe?wantedCollections=app.bsky.feed.post",
        __MODULE__,
        :fake_state,
        opts
      )
  end

  def handle_connect(_conn, _state) do
    Logger.info("Connected!")
    IO.puts("#{DateTime.utc_now()}")
    {:ok, 0}
  end

  def handle_frame({:text, msg}, state) do
    msg = Jason.decode!(msg)

    case msg do
      %{"commit" => record = %{"record" => %{"text" => skeet}}} = _msg ->
        # Broadcast to the general skeet feed
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "bluesky:skeet",
          {:new_skeet, skeet}
        )

        case contains_external_uri?(skeet, record) do
          {:ok, link} ->
            Phoenix.PubSub.broadcast(
              Blog.PubSub,
              "reddit_links",
              {:reddit_link, link}
            )
          _ -> :no_nothing_no_link
        end


        # Broadcast to subscribers

      _ ->
        nil
    end

    {:ok, state + 1}
  end

  defp contains_external_uri?(skeet, record) when is_binary(skeet) do
    uri =
      case record do
        %{
          "record" => %{
            "embed" => %{
              "external" => %{
                "uri" => uri
              }
            },
          },
        } ->
          uri
        _ -> nil
      end
    if uri do
      if String.contains?(uri, "youtube.com") || String.contains?(uri, "youtu.be") do
        {:ok, uri}
      end
    end
  end

  defp generate_id do
    :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower)
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  # Function to get all stored Reddit links
  def get_reddit_links(limit \\ 50) do
    case :ets.info(@table_name) do
      :undefined ->
        []

      _ ->
        :ets.tab2list(@table_name)
        # Already sorted by key, but just to be sure
        |> Enum.sort()
        |> Enum.take(limit)
        |> Enum.map(fn {_key, value} -> value end)
    end
  end
end
