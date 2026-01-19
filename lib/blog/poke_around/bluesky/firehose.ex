defmodule Blog.PokeAround.Bluesky.Firehose do
  @moduledoc """
  WebSocket client for Graze Turbostream.

  Turbostream provides hydrated Bluesky events with full profile info,
  resolved mentions, and parent/root posts already fetched.

  ## Usage

      # Start via supervisor (recommended)
      children = [Blog.PokeAround.Bluesky.Firehose]

      # Or start manually
      {:ok, pid} = Blog.PokeAround.Bluesky.Firehose.start_link([])

  Events are broadcast via Phoenix.PubSub to "poke_around:firehose:events".
  Subscribe with:

      Phoenix.PubSub.subscribe(Blog.PubSub, "poke_around:firehose:events")

  You'll receive messages like:

      {:post, %{did: "did:plc:...", post: %{...}, author: %{...}}}
  """

  use WebSockex

  require Logger

  @turbostream_url "wss://api.graze.social/app/api/v1/turbostream/turbostream"
  @stats_interval_ms 30_000

  defstruct [
    :url,
    :started_at,
    messages_received: 0,
    posts_received: 0
  ]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  def start_link(opts \\ []) do
    url = opts[:url] || config(:url, @turbostream_url)
    name = opts[:name] || __MODULE__

    state = %__MODULE__{
      url: url,
      started_at: DateTime.utc_now()
    }

    Logger.info("Connecting to Turbostream: #{url}")
    WebSockex.start_link(url, __MODULE__, state, name: name)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent,
      type: :worker
    }
  end

  @doc """
  Get current stats from the firehose.
  """
  def get_stats(server \\ __MODULE__) do
    WebSockex.cast(server, {:get_stats, self()})

    receive do
      {:stats, stats} -> stats
    after
      5_000 -> {:error, :timeout}
    end
  end

  # ---------------------------------------------------------------------------
  # WebSockex Callbacks
  # ---------------------------------------------------------------------------

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("Connected to Turbostream")
    schedule_stats_log()
    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(disconnect_map, state) do
    Logger.warning("Disconnected from Turbostream: #{inspect(disconnect_map[:reason])}")
    Process.sleep(5_000)
    {:reconnect, state}
  end

  @impl WebSockex
  def handle_frame({:text, msg}, state) do
    state = %{state | messages_received: state.messages_received + 1}

    case Jason.decode(msg) do
      {:ok, event} ->
        state = handle_event(event, state)
        {:ok, state}

      {:error, reason} ->
        Logger.debug("Failed to decode message: #{inspect(reason)}")
        {:ok, state}
    end
  end

  @impl WebSockex
  def handle_frame({:binary, _msg}, state) do
    {:ok, state}
  end

  @impl WebSockex
  def handle_cast({:get_stats, from}, state) do
    stats = build_stats(state)
    send(from, {:stats, stats})
    {:ok, state}
  end

  @impl WebSockex
  def handle_info(:log_stats, state) do
    stats = build_stats(state)

    Logger.info(
      "Firehose: #{stats.messages_received} msgs, #{stats.posts_received} posts, " <>
        "#{Float.round(stats.messages_per_second, 1)} msg/sec"
    )

    schedule_stats_log()
    {:ok, state}
  end

  @impl WebSockex
  def handle_info(msg, state) do
    Logger.debug("Unexpected message: #{inspect(msg)}")
    {:ok, state}
  end

  @impl WebSockex
  def terminate(reason, state) do
    Logger.info("Firehose terminating: #{inspect(reason)}, #{state.messages_received} messages processed")
    :ok
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  # Turbostream format: at_uri, did, hydrated_metadata, message, time_us
  defp handle_event(%{"at_uri" => at_uri, "message" => message} = event, state) do
    # Check if this is a post create
    if is_post_create?(at_uri, message) do
      broadcast_post(event)
      %{state | posts_received: state.posts_received + 1}
    else
      state
    end
  end

  defp handle_event(_event, state), do: state

  defp is_post_create?(at_uri, message) do
    # at_uri format: at://did:plc:xxx/app.bsky.feed.post/rkey
    String.contains?(at_uri, "/app.bsky.feed.post/") &&
      message["commit"]["operation"] == "create"
  end

  defp broadcast_post(event) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "poke_around:firehose:events",
      {:post, event}
    )
  end

  defp build_stats(state) do
    uptime = DateTime.diff(DateTime.utc_now(), state.started_at, :second)

    %{
      messages_received: state.messages_received,
      posts_received: state.posts_received,
      uptime_seconds: uptime,
      messages_per_second: if(uptime > 0, do: state.messages_received / uptime, else: 0.0)
    }
  end

  defp schedule_stats_log do
    Process.send_after(self(), :log_stats, @stats_interval_ms)
  end

  defp config(key, default) do
    Application.get_env(:blog, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
