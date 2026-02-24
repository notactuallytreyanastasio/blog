defmodule BlueskyJetstream do
  use WebSockex
  require Logger

  # Try the public Jetstream endpoint
  @jetstream_url "wss://jetstream2.us-east.bsky.network/subscribe"

  def start_link(opts \\ []) do
    # Subscribe to all events first to see if we connect at all
    url = @jetstream_url
    
    Logger.debug("Connecting to Bluesky Jetstream at #{url}")
    
    WebSockex.start_link(
      url,
      __MODULE__,
      %{reconnect_attempts: 0, message_count: 0},
      opts ++ [name: __MODULE__, handle_initial_conn_failure: true]
    )
  end

  def handle_connect(_conn, state) do
    Logger.debug("Connected to Bluesky Jetstream")
    Blog.HoseMonitor.report_up(:jetstream)
    {:ok, Map.put(state, :reconnect_attempts, 0)}
  end

  def handle_disconnect(reason, state) do
    Logger.debug("Disconnected from Jetstream: #{inspect(reason)}, reconnecting")
    Blog.HoseMonitor.report_down(:jetstream)
    {:reconnect, Map.update(state, :reconnect_attempts, 0, &(&1 + 1))}
  end

  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, decoded} ->
        handle_decoded_message(decoded)
        {:ok, Map.update(state, :message_count, 1, &(&1 + 1))}

      {:error, _error} ->
        {:ok, state}
    end
  end

  def handle_frame(frame, state) do
    Logger.debug("Received non-text frame: #{inspect(frame)}")
    {:ok, state}
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
  
  defp handle_decoded_message(_data), do: :ok

  defp handle_commit(nil), do: :ok

  defp handle_commit(commit) when is_map(commit) do
    collection = Map.get(commit, "collection", "unknown")
    operation = Map.get(commit, "operation", "unknown")

    if collection == "app.bsky.feed.post" and operation == "create" do
      did = Map.get(commit, "did", "unknown")
      if record = Map.get(commit, "record") do
        handle_post_create(record, did, %{"commit" => commit, "did" => did})
      end
    end
  end

  defp handle_post_create(record, did, full_event) do
    # Broadcast raw event for PokeAround fallback when Turbostream is down
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "jetstream:firehose:fallback",
      {:jetstream_post, full_event}
    )

    # Extract text from the post record
    case record do
      %{"text" => text} when is_binary(text) ->
        # Broadcast to jetstream-specific topic
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

  defp handle_identity(%{"did" => _did, "handle" => _handle}), do: :ok

  defp handle_identity(_identity) do
    :ok
  end

  defp handle_account(_account), do: :ok

  def terminate(_reason, _state), do: :ok
end