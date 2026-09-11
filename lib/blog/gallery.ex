defmodule Blog.Gallery do
  @moduledoc """
  An iCloud Shared Album, held in memory and served straight from Apple's CDN.

  Nothing is mirrored. This process keeps two things current:

    * the photo list, re-fetched when the album's `streamCtag` changes
    * the signed CDN urls, which Apple expires about three hours out

  Reads go through an ETS table so LiveView processes never block on the
  GenServer, and `photos/0` stays cheap enough to call on every mount.

  The album is configured with its public-website token:

      config :blog, :gallery, token: System.get_env("ICLOUD_ALBUM_TOKEN")

  With no token configured the whole feature no-ops — `photos/0` returns `[]`
  and the page renders an empty desktop rather than crashing.
  """
  use GenServer
  require Logger

  alias Blog.Gallery.ICloud

  @table :gallery_cache
  @topic "gallery"

  # Apple's ctag makes the poll nearly free, so this can be brisk.
  @poll_interval :timer.minutes(15)
  @boot_delay :timer.seconds(3)
  # Signed urls last ~3h; refresh well inside that so a slow or failed refresh
  # still has a wide margin before anything on screen goes dead.
  @url_refresh :timer.minutes(100)
  @retry_delay :timer.minutes(1)

  defstruct token: nil,
            host: nil,
            ctag: nil,
            name: nil,
            photos: [],
            urls: %{},
            urls_fetched_at: nil,
            last_error: nil

  # ---------------------------------------------------------------- public api

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Every photo in the album, newest first. Safe to call before the first fetch."
  @spec photos() :: [map()]
  def photos, do: lookup(:photos, [])

  @doc "The album's name as set in Photos.app."
  @spec album_name() :: String.t()
  def album_name, do: lookup(:name, "Shared Album")

  @doc """
  The current signed CDN url for one photo at `:thumb` or `:display` size.
  Returns nil for an unknown guid, or when urls have not been resolved yet.
  """
  @spec url(String.t(), :thumb | :display) :: String.t() | nil
  def url(guid, size) when size in [:thumb, :display] do
    with %{} = photo <- Map.get(lookup(:by_guid, %{}), guid),
         checksum when is_binary(checksum) <- Map.get(photo, size) do
      Map.get(lookup(:urls, %{}), checksum)
    else
      _ -> nil
    end
  end

  @doc "Subscribe to `{:gallery, :updated, photos}` broadcasts."
  @spec subscribe() :: :ok | {:error, term()}
  def subscribe, do: Phoenix.PubSub.subscribe(Blog.PubSub, @topic)

  @doc "Force a refresh now, ignoring the cached ctag. Returns immediately."
  @spec refresh() :: :ok
  def refresh, do: GenServer.cast(__MODULE__, :refresh)

  @doc "Diagnostics for the sync state — photo count, ctag, last error."
  @spec status() :: map()
  def status, do: GenServer.call(__MODULE__, :status)

  @doc "Whether a token is configured at all."
  @spec configured?() :: boolean()
  def configured?, do: is_binary(token()) and token() != ""

  # ------------------------------------------------------------------ callbacks

  @impl true
  def init(_opts) do
    :ets.new(@table, [:named_table, :set, :protected, read_concurrency: true])

    state = %__MODULE__{token: token(), host: ICloud.first_host()}

    if configured?() do
      Process.send_after(self(), :poll, @boot_delay)
    else
      Logger.info("[gallery] no ICLOUD_ALBUM_TOKEN configured — gallery is idle")
    end

    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    state = sync(state, :if_changed)
    Process.send_after(self(), :poll, interval_for(state))
    {:noreply, state}
  end

  def handle_info(:refresh_urls, state) do
    {:noreply, resolve_urls(state)}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  @impl true
  def handle_cast(:refresh, state), do: {:noreply, sync(state, :force)}

  @impl true
  def handle_call(:status, _from, state) do
    {:reply,
     %{
       configured: configured?(),
       album: state.name,
       photos: length(state.photos),
       host: state.host,
       ctag: state.ctag,
       urls: map_size(state.urls),
       urls_fetched_at: state.urls_fetched_at,
       last_error: state.last_error
     }, state}
  end

  # -------------------------------------------------------------------- syncing

  defp sync(%{token: token} = state, mode) when is_binary(token) and token != "" do
    ctag = if mode == :force, do: nil, else: state.ctag

    case ICloud.fetch_stream(token, state.host, ctag) do
      {:ok, %{ctag: ^ctag, photos: _}} when mode != :force and not is_nil(ctag) ->
        # Unchanged album. Urls still age out on their own schedule.
        %{state | last_error: nil}

      {:ok, result} ->
        changed? = result.ctag != state.ctag

        state = %{
          state
          | host: result.host,
            ctag: result.ctag,
            name: result.name,
            photos: sort_photos(result.photos),
            last_error: nil
        }

        state = resolve_urls(state)
        publish(state)

        if changed? do
          Logger.info("[gallery] #{length(state.photos)} photos in #{inspect(state.name)}")
        end

        state

      {:error, reason} ->
        Logger.warning("[gallery] stream fetch failed: #{inspect(reason)}")
        %{state | last_error: reason}
    end
  end

  defp sync(state, _mode), do: state

  defp resolve_urls(%{photos: []} = state), do: state

  defp resolve_urls(state) do
    guids = Enum.map(state.photos, & &1.guid)

    case ICloud.fetch_asset_urls(state.token, state.host, guids) do
      {:ok, urls} when map_size(urls) > 0 ->
        state = %{state | urls: urls, urls_fetched_at: DateTime.utc_now(), last_error: nil}
        put(:urls, urls)
        schedule_url_refresh(urls)
        state

      {:ok, _empty} ->
        state

      {:error, reason} ->
        Logger.warning("[gallery] asset url fetch failed: #{inspect(reason)}")
        Process.send_after(self(), :refresh_urls, @retry_delay)
        %{state | last_error: reason}
    end
  end

  # Refresh ahead of the real expiry rather than on a blind timer, so a batch
  # that comes back with an unusually short lease still gets renewed in time.
  defp schedule_url_refresh(urls) do
    soonest =
      urls
      |> Map.values()
      |> Enum.map(&ICloud.ttl/1)
      |> Enum.min(fn -> 0 end)

    delay =
      case soonest do
        0 -> @url_refresh
        ttl -> min(@url_refresh, max(:timer.seconds(ttl) - :timer.minutes(20), @retry_delay))
      end

    Process.send_after(self(), :refresh_urls, delay)
  end

  defp publish(state) do
    put(:photos, state.photos)
    put(:name, state.name)
    put(:by_guid, Map.new(state.photos, &{&1.guid, &1}))

    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:gallery, :updated, state.photos})
  end

  # Newest first, and stable for photos with no date so ordering never jitters
  # between polls (the shuffle on the page supplies the randomness).
  defp sort_photos(photos) do
    photos
    |> Enum.with_index()
    |> Enum.sort_by(fn {p, i} ->
      {-date_key(p.created_at), i}
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp date_key(nil), do: 0
  defp date_key(%DateTime{} = dt), do: DateTime.to_unix(dt)

  defp interval_for(%{last_error: nil}), do: @poll_interval
  defp interval_for(_), do: @retry_delay

  # ----------------------------------------------------------------------- ets

  defp put(key, value), do: :ets.insert(@table, {key, value})

  defp lookup(key, default) do
    case :ets.whereis(@table) do
      :undefined ->
        default

      _ ->
        case :ets.lookup(@table, key) do
          [{^key, value}] -> value
          [] -> default
        end
    end
  end

  defp token do
    :blog |> Application.get_env(:gallery, []) |> Keyword.get(:token)
  end
end
