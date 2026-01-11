defmodule Blog.PokeAround.AI.AxonTagger do
  @moduledoc """
  GenServer that uses a trained Axon model for link tagging.

  This is a lightweight alternative to Ollama-based tagging that runs
  entirely on-device using Nx (EXLA optional for acceleration).

  ## Usage

  Start the tagger (automatically loads model from priv/models/poke_around_tagger):

      {:ok, _pid} = AxonTagger.start_link()

  Get tag predictions for a link:

      {:ok, tags} = AxonTagger.predict(pid, %{post_text: "...", domain: "..."})

  ## Configuration

  The tagger can run in background mode to process untagged links:

      AxonTagger.start_link(
        auto_tag: true,          # Auto-process queue
        interval: 5_000,         # Process every 5 seconds
        batch_size: 20,          # Process 20 links at a time
        threshold: 0.3,          # Minimum confidence threshold
        langs: ["en"]            # Filter by language
      )

  ## Note

  This is DISABLED by default in the blog app because the prod server's
  postgres is too small to handle the volume.
  """

  use GenServer
  require Logger

  alias Blog.PokeAround.AI.Axon.TextClassifier
  alias Blog.{Repo, PokeAround.Tags}
  alias Blog.PokeAround.Link
  import Ecto.Query

  @default_model_path "priv/models/poke_around_tagger"
  @default_threshold 0.25
  @default_interval 10_000
  @default_batch_size 20

  defstruct [
    :model,
    :state,
    :vocab,
    :tag_index,
    :threshold,
    :auto_tag,
    :interval,
    :batch_size,
    :langs,
    :stats
  ]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc """
  Predict tags for a single link.
  Returns {:ok, [tags]} or {:error, reason}
  """
  def predict(server \\ __MODULE__, link) do
    GenServer.call(server, {:predict, link}, 30_000)
  end

  @doc """
  Get tagger statistics.
  """
  def stats(server \\ __MODULE__) do
    GenServer.call(server, :stats)
  end

  @doc """
  Manually trigger a batch of tagging.
  """
  def process_batch(server \\ __MODULE__) do
    GenServer.cast(server, :process_batch)
  end

  # ---------------------------------------------------------------------------
  # GenServer Callbacks
  # ---------------------------------------------------------------------------

  @impl true
  def init(opts) do
    model_path = opts[:model_path] || @default_model_path

    case File.exists?(Path.join(model_path, "metadata.json")) do
      true ->
        {model, state, vocab, tag_index} = TextClassifier.load_model(model_path)

        config = %__MODULE__{
          model: model,
          state: state,
          vocab: vocab,
          tag_index: tag_index,
          threshold: opts[:threshold] || @default_threshold,
          auto_tag: opts[:auto_tag] || false,
          interval: opts[:interval] || @default_interval,
          batch_size: opts[:batch_size] || @default_batch_size,
          langs: opts[:langs] || ["en"],
          stats: %{tagged: 0, errors: 0, started_at: DateTime.utc_now()}
        }

        Logger.info("Tagger ready: #{map_size(tag_index)} tags, threshold=#{config.threshold}")

        if config.auto_tag do
          schedule_batch(config.interval)
        end

        {:ok, config}

      false ->
        Logger.error("Tagger: Model not found at #{model_path}. Run training first.")
        {:stop, :model_not_found}
    end
  end

  @impl true
  def handle_call({:predict, link}, _from, config) do
    text = build_text(link)

    tags = TextClassifier.predict_tags(
      config.model,
      config.state,
      text,
      config.vocab,
      config.tag_index,
      config.threshold
    )

    {:reply, {:ok, tags}, config}
  end

  @impl true
  def handle_call(:stats, _from, config) do
    stats = Map.merge(config.stats, %{
      vocab_size: map_size(config.vocab),
      num_tags: map_size(config.tag_index),
      threshold: config.threshold,
      auto_tag: config.auto_tag,
      uptime_seconds: DateTime.diff(DateTime.utc_now(), config.stats.started_at)
    })
    {:reply, stats, config}
  end

  @impl true
  def handle_cast(:process_batch, config) do
    config = process_untagged_batch(config)
    {:noreply, config}
  end

  @impl true
  def handle_info(:process_batch, config) do
    config = process_untagged_batch(config)

    if config.auto_tag do
      schedule_batch(config.interval)
    end

    {:noreply, config}
  end

  # ---------------------------------------------------------------------------
  # Private Functions
  # ---------------------------------------------------------------------------

  defp schedule_batch(interval) do
    Process.send_after(self(), :process_batch, interval)
  end

  defp process_untagged_batch(config) do
    links = fetch_untagged_links(config.batch_size, config.langs)

    if length(links) == 0 do
      config
    else
      {tagged_count, error_count} =
        Enum.reduce(links, {0, 0}, fn link, {tagged, errors} ->
          case tag_link(link, config) do
            :ok -> {tagged + 1, errors}
            :skipped -> {tagged, errors}  # No confident predictions, but not an error
            :error -> {tagged, errors + 1}
          end
        end)

      new_stats = %{
        config.stats |
        tagged: config.stats.tagged + tagged_count,
        errors: config.stats.errors + error_count
      }

      # Calculate rate (tags per minute)
      uptime_mins = max(DateTime.diff(DateTime.utc_now(), new_stats.started_at) / 60, 1)
      tags_per_min = Float.round(new_stats.tagged / uptime_mins, 1)

      Logger.info("Tagger: #{tagged_count}/#{length(links)} tagged | #{new_stats.tagged} total | #{tags_per_min}/min")

      %{config | stats: new_stats}
    end
  end

  defp fetch_untagged_links(limit, langs) do
    query = from(l in Link,
      where: is_nil(l.tagged_at),
      where: not is_nil(l.post_text),
      order_by: [desc: l.inserted_at],
      limit: ^limit,
      select: %{id: l.id, post_text: l.post_text, domain: l.domain}
    )

    query = if langs != [] do
      from(l in query, where: fragment("? && ?", l.langs, ^langs))
    else
      query
    end

    Repo.all(query)
  end

  defp tag_link(link, config) do
    text = build_text_from_link(link)

    tags = TextClassifier.predict_tags(
      config.model,
      config.state,
      text,
      config.vocab,
      config.tag_index,
      config.threshold
    )

    if length(tags) > 0 do
      case Tags.tag_link(link, tags, source: "axon") do
        {:ok, _} -> :ok
        {:error, _} -> :error
      end
    else
      # No confident predictions - mark as processed but don't tag
      mark_as_processed(link)
      :skipped
    end
  end

  defp mark_as_processed(link) do
    from(l in Link, where: l.id == ^link.id)
    |> Repo.update_all(set: [tagged_at: DateTime.utc_now()])
  end

  defp build_text(%{post_text: text, domain: domain}) do
    "#{text || ""} #{domain || ""}"
  end

  defp build_text_from_link(link) do
    "#{link.post_text || ""} #{link.domain || ""}"
  end
end
