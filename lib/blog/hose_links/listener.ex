defmodule Blog.HoseLinks.Listener do
  @moduledoc """
  Subscribes to the Bluesky firehose and records every link observation.

  Unlike the PokeAround extractor, this processes ALL posts regardless
  of author quality. The signal is collective attention.
  """

  use GenServer
  require Logger

  alias Blog.PokeAround.Bluesky.Parser
  alias Blog.HoseLinks
  alias Blog.HoseLinks.URLNormalizer

  @stats_interval_ms 60_000

  defstruct [
    :started_at,
    posts_seen: 0,
    links_extracted: 0,
    links_recorded: 0,
    breakthroughs: 0,
    errors: 0
  ]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Blog.PubSub, "jetstream:firehose:fallback")
    schedule_stats_log()

    Logger.info("HoseLinks Listener started, subscribed to jetstream:firehose:fallback")
    {:ok, %__MODULE__{started_at: DateTime.utc_now()}}
  end

  @impl true
  def handle_info({:jetstream_post, event}, state) do
    state = process_event(event, state)
    {:noreply, state}
  end

  @impl true
  def handle_info(:log_stats, state) do
    log_stats(state)
    schedule_stats_log()
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  @impl true
  def handle_call(:get_stats, _from, state) do
    {:reply, build_stats(state), state}
  end

  defp process_event(event, state) do
    state = %{state | posts_seen: state.posts_seen + 1}

    case Parser.parse_post(event) do
      {:ok, post} ->
        links = Parser.extract_links(post)

        if links == [] do
          state
        else
          state = %{state | links_extracted: state.links_extracted + length(links)}

          Enum.reduce(links, state, fn raw_url, acc ->
            record_one_link(raw_url, acc)
          end)
        end

      {:error, _} ->
        state
    end
  end

  defp record_one_link(raw_url, state) do
    case URLNormalizer.normalize(raw_url) do
      {:ok, normalized} ->
        case HoseLinks.record_link(normalized, raw_url) do
          :ok ->
            %{state | links_recorded: state.links_recorded + 1}

          :breakthrough ->
            %{state | links_recorded: state.links_recorded + 1, breakthroughs: state.breakthroughs + 1}

          :error ->
            %{state | errors: state.errors + 1}
        end

      :error ->
        state
    end
  end

  defp build_stats(state) do
    uptime = DateTime.diff(DateTime.utc_now(), state.started_at, :second)

    %{
      posts_seen: state.posts_seen,
      links_extracted: state.links_extracted,
      links_recorded: state.links_recorded,
      breakthroughs: state.breakthroughs,
      errors: state.errors,
      uptime_seconds: uptime,
      links_per_second:
        if(uptime > 0, do: Float.round(state.links_recorded / uptime, 2), else: 0.0)
    }
  end

  defp log_stats(state) do
    stats = build_stats(state)

    Logger.info(
      "HoseLinks: #{stats.posts_seen} posts, " <>
        "#{stats.links_extracted} extracted, " <>
        "#{stats.links_recorded} recorded, " <>
        "#{stats.breakthroughs} breakthroughs, " <>
        "#{stats.errors} errors, " <>
        "#{stats.links_per_second} links/sec"
    )
  end

  defp schedule_stats_log do
    Process.send_after(self(), :log_stats, @stats_interval_ms)
  end
end
