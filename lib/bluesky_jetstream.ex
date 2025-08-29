defmodule BlueskyJetstream do
  use WebSockex
  require Logger

  # Try the public Jetstream endpoint
  @jetstream_url "wss://jetstream2.us-east.bsky.network/subscribe"
  @max_skeets 100_000

  def start_link(opts \\ []) do
    # Subscribe to all events first to see if we connect at all
    url = @jetstream_url
    
    Logger.info("🚀 Connecting to Bluesky Jetstream at #{url}")
    
    WebSockex.start_link(
      url,
      __MODULE__,
      %{reconnect_attempts: 0, message_count: 0},
      opts ++ [name: __MODULE__]
    )
  end

  def handle_connect(_conn, state) do
    Logger.info("✅ Connected to Bluesky Jetstream!")
    {:ok, Map.put(state, :reconnect_attempts, 0)}
  end

  def handle_disconnect(reason, state) do
    Logger.warn("❌ Disconnected from Jetstream: #{inspect(reason)}, attempting to reconnect...")
    {:reconnect, Map.update(state, :reconnect_attempts, 0, &(&1 + 1))}
  end

  def handle_frame({:text, msg}, state) do
    # Log raw message if it's the first one
    if state[:message_count] == 0 do
      Logger.info("📨 First raw Jetstream message: #{String.slice(msg, 0, 500)}")
    end
    
    case Jason.decode(msg) do
      {:ok, decoded} ->
        # Log every 100th message to verify we're receiving data
        new_count = state[:message_count] + 1
        if rem(new_count, 100) == 0 do
          Logger.info("Jetstream: Received #{new_count} messages so far")
        end
        
        handle_decoded_message(decoded)
        {:ok, Map.put(state, :message_count, new_count)}
        
      {:error, error} ->
        Logger.error("Failed to decode Jetstream message: #{inspect(error)}")
        Logger.error("Raw message was: #{String.slice(msg, 0, 200)}")
        {:ok, state}
    end
  end
  
  defp handle_decoded_message(%{"kind" => "commit", "commit" => commit}) do
    handle_commit(commit)
  end
  
  defp handle_decoded_message(%{"kind" => "identity", "identity" => identity}) do
    handle_identity(identity)
  end
  
  defp handle_decoded_message(%{"kind" => "account", "account" => account}) do
    handle_account(account)
  end
  
  defp handle_decoded_message(data) do
    Logger.debug("Received event type: #{Map.get(data, "kind", "unknown")}")
  end

  def handle_frame(frame, state) do
    Logger.debug("Received non-text frame: #{inspect(frame)}")
    {:ok, state}
  end

  defp handle_commit(commit) when is_map(commit) do
    # Log ALL commits to see what we're getting
    collection = Map.get(commit, "collection", "unknown")
    operation = Map.get(commit, "operation", "unknown") 
    did = Map.get(commit, "did", "unknown")
    
    # Log every 10th commit of any type
    if :rand.uniform(10) == 1 do
      Logger.info("Jetstream commit: #{operation} on #{collection} by #{String.slice(did, 0, 20)}...")
    end
    
    # Handle post creates
    if collection == "app.bsky.feed.post" and operation == "create" do
      if record = Map.get(commit, "record") do
        handle_post_create(record, did)
      end
    end
  end

  defp handle_post_create(record, did) do
    # Extract text from the post record
    case record do
      %{"text" => text} when is_binary(text) ->
        # Log if it contains bobby for debugging
        if String.contains?(String.downcase(text), "bobby") do
          Logger.info("JETSTREAM: Bobby post detected from #{did}: #{String.slice(text, 0, 100)}")
        end
        
        # Broadcast to jetstream-specific topic with unique message
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "jetstream:skeet",
          {:jetstream_skeet, %{text: text, did: did}}
        )
        
      _ ->
        # Post without text (might be just images/links)
        :ok
    end
  end

  defp handle_identity(%{"did" => did, "handle" => handle}) do
    # Identity update - could cache DID to handle mappings here
    Logger.debug("Identity update: #{did} -> #{handle}")
    :ok
  end

  defp handle_account(account) do
    # Account status changes
    Logger.debug("Account update: #{inspect(account)}")
    :ok
  end

  def terminate(reason, _state) do
    Logger.info("Jetstream WebSocket terminating: #{inspect(reason)}")
    :ok
  end
end