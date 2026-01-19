defmodule Blog.PokeAround.Bluesky.Extractor do
  @moduledoc """
  Extracts and filters links from the firehose.

  Subscribes to firehose events, parses posts, extracts links,
  and applies quality filtering based on author metrics.

  ## Usage

      # Start via supervisor
      children = [Blog.PokeAround.Bluesky.Extractor]

  Qualified links are broadcast to "poke_around:links:extracted":

      Phoenix.PubSub.subscribe(Blog.PubSub, "poke_around:links:extracted")
      # Receive: {:link, %{url: "...", post: %Post{}, score: 85}}
  """

  use GenServer

  require Logger

  alias Blog.PokeAround.Bluesky.Parser
  alias Blog.PokeAround.Links

  # Quality thresholds
  @min_followers 500
  @max_following 5000
  @min_account_age_days 365
  @min_text_length 50
  @max_hashtags 1
  @max_emojis 1

  # Banned domains (URL shorteners, spam magnets, media hosts, crypto, social)
  @banned_domains [
    # URL shorteners
    "tinyurl.com",
    "bit.ly",
    "t.co",
    # Social media
    "x.com",
    "twitter.com",
    # Media hosts
    "media.tenor.com",
    # Crypto exchanges
    "coinbase.com",
    "binance.com",
    "binance.us",
    "kraken.com",
    "crypto.com",
    "gemini.com",
    "kucoin.com",
    "bybit.com",
    "okx.com",
    "bitfinex.com",
    "bitstamp.net",
    "gate.io",
    "huobi.com",
    "mexc.com",
    "bitget.com",
    # Crypto news/media
    "coindesk.com",
    "cointelegraph.com",
    "decrypt.co",
    "theblock.co",
    "bitcoinmagazine.com",
    # NFT/DeFi
    "opensea.io",
    "uniswap.org",
    "rarible.com",
    "foundation.app",
    "blur.io",
    "looksrare.org",
    "pancakeswap.finance",
    "aave.com",
    # Crypto trackers
    "coingecko.com",
    "coinmarketcap.com",
    "dextools.io",
    "dexscreener.com",
    # Meme coin pumps
    "pump.fun",
    # Wallets
    "metamask.io",
    "phantom.app",
    "trustwallet.com"
  ]

  @stats_interval_ms 30_000

  defstruct [
    :started_at,
    posts_processed: 0,
    links_found: 0,
    links_qualified: 0
  ]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent,
      type: :worker
    }
  end

  def get_stats(server \\ __MODULE__) do
    GenServer.call(server, :get_stats)
  end

  # ---------------------------------------------------------------------------
  # GenServer Callbacks
  # ---------------------------------------------------------------------------

  @impl GenServer
  def init(opts) do
    # Allow disabling PubSub subscription for testing
    unless opts[:subscribe] == false do
      Phoenix.PubSub.subscribe(Blog.PubSub, "poke_around:firehose:events")
    end

    schedule_stats_log()

    state = %__MODULE__{started_at: DateTime.utc_now()}
    Logger.info(
      "Link extractor started: " <>
        "min_followers=#{@min_followers}, max_following=#{@max_following}, " <>
        "min_account_age=#{@min_account_age_days}d, min_text=#{@min_text_length}, " <>
        "max_hashtags=#{@max_hashtags}"
    )

    {:ok, state}
  end

  @impl GenServer
  def handle_info({:post, event}, state) do
    state = process_post(event, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:log_stats, state) do
    log_stats(state)
    schedule_stats_log()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_msg, state), do: {:noreply, state}

  @impl GenServer
  def handle_call(:get_stats, _from, state) do
    {:reply, build_stats(state), state}
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp process_post(event, state) do
    case Parser.parse_post(event) do
      {:ok, post} ->
        state = %{state | posts_processed: state.posts_processed + 1}
        links = Parser.extract_links(post)

        if links != [] do
          state = %{state | links_found: state.links_found + length(links)}
          process_links(links, post, state)
        else
          state
        end

      {:error, _} ->
        state
    end
  end

  defp process_links(links, post, state) do
    # Multiple links = spam, only process if single link
    if length(links) == 1 && qualifies?(post) do
      [url] = links

      # Check if domain is banned
      if domain_banned?(url) do
        state
      else
        case store_link(url, post) do
          :ok -> %{state | links_qualified: state.links_qualified + 1}
          _ -> state
        end
      end
    else
      state
    end
  end

  defp domain_banned?(url) do
    uri = URI.parse(url)
    host = uri.host || ""

    Enum.any?(@banned_domains, fn banned ->
      host == banned || String.ends_with?(host, "." <> banned)
    end)
  end

  # No author = skip
  defp qualifies?(%{author: nil}), do: false

  defp qualifies?(%{author: author, text: text, langs: langs}) do
    lang_qualifies?(langs) && author_qualifies?(author) && post_qualifies?(text)
  end

  # Must include English
  defp lang_qualifies?(nil), do: false
  defp lang_qualifies?([]), do: false
  defp lang_qualifies?(langs) when is_list(langs) do
    Enum.any?(langs, fn lang ->
      lang == "en" || String.starts_with?(to_string(lang), "en-")
    end)
  end

  defp author_qualifies?(author) do
    followers = author.followers_count || 0
    following = author.follows_count || 0
    has_bio = author.description != nil && String.trim(author.description) != ""
    account_old_enough = account_age_ok?(author.indexed_at)

    followers >= @min_followers &&
      following <= @max_following &&
      has_bio &&
      account_old_enough
  end

  defp post_qualifies?(text) when is_binary(text) do
    hashtag_count = count_hashtags(text)
    emoji_count = count_emojis(text)

    # Text length AFTER removing hashtags - must have real content
    text_without_hashtags = Regex.replace(~r/#\w+/, text, "") |> String.trim()
    clean_text_length = String.length(text_without_hashtags)

    clean_text_length >= @min_text_length &&
      hashtag_count <= @max_hashtags &&
      emoji_count <= @max_emojis
  end

  defp post_qualifies?(_), do: false

  defp account_age_ok?(nil), do: false

  defp account_age_ok?(%DateTime{} = indexed_at) do
    days_old = DateTime.diff(DateTime.utc_now(), indexed_at, :day)
    days_old >= @min_account_age_days
  end

  defp count_hashtags(text) do
    ~r/#\w+/
    |> Regex.scan(text)
    |> length()
  end

  defp count_emojis(text) do
    # Match common emoji ranges
    ~r/[\x{1F300}-\x{1F9FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|[\x{1F600}-\x{1F64F}]|[\x{1F680}-\x{1F6FF}]/u
    |> Regex.scan(text)
    |> length()
  end

  defp store_link(url, post) do
    attrs = %{
      url: url,
      post_uri: post.uri,
      post_text: post.text,
      post_created_at: post.created_at,
      author_did: post.author && post.author.did,
      author_handle: post.author && post.author.handle,
      author_display_name: post.author && post.author.display_name,
      author_followers_count: post.author && post.author.followers_count,
      score: calculate_score(post),
      langs: post.langs || []
    }

    case Links.store_link(attrs) do
      {:ok, :exists} -> :exists
      {:ok, _link} -> :ok
      {:error, _} -> :error
    end
  end

  defp calculate_score(%{author: nil}), do: 0

  defp calculate_score(%{author: author}) do
    followers = author.followers_count || 0
    following = author.follows_count || 1

    # Base score from followers (log scale, diminishing returns)
    follower_score = :math.log10(max(followers, 1)) * 15

    # Bonus for good follower/following ratio (curated taste, not follow-for-follow)
    ratio = followers / max(following, 1)
    ratio_bonus = min(ratio * 5, 20)

    # Combined score, capped at 100
    min(round(follower_score + ratio_bonus), 100)
  end

  defp build_stats(state) do
    uptime = DateTime.diff(DateTime.utc_now(), state.started_at, :second)

    %{
      posts_processed: state.posts_processed,
      links_found: state.links_found,
      links_qualified: state.links_qualified,
      uptime_seconds: uptime,
      qualification_rate:
        if(state.links_found > 0, do: state.links_qualified / state.links_found, else: 0.0)
    }
  end

  defp log_stats(state) do
    stats = build_stats(state)

    Logger.info(
      "Extractor: #{stats.posts_processed} posts, " <>
        "#{stats.links_found} links found, " <>
        "#{stats.links_qualified} qualified (#{Float.round(stats.qualification_rate * 100, 1)}%)"
    )
  end

  defp schedule_stats_log do
    Process.send_after(self(), :log_stats, @stats_interval_ms)
  end
end
