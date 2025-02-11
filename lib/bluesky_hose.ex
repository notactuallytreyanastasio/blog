defmodule BlueskyHose do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    WebSockex.start_link("wss://bsky-relay.c.theo.io/subscribe?wantedCollections=app.bsky.feed.post", __MODULE__, :fake_state, opts)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    IO.puts("#{DateTime.utc_now}")
    {:ok, 0}
  end

  def handle_frame({:text, msg}, state) do
    msg = Jason.decode!(msg)
    case msg do
      %{"commit" => %{"record" => %{"text" => skeet}}} = msg ->
        case String.contains?(skeet, "muenster") do
          true ->
            IO.puts("Got cheese skeet\n\n\n\n#{skeet}")
            Phoenix.PubSub.broadcast(
              Blog.PubSub,
              "muenster_posts",
              {:new_post, skeet}
            )
          false -> :do_nothing
        end
      _ ->
        nil
    end
    {:ok, state + 1}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end
