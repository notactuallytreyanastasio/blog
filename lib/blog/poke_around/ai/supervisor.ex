defmodule Blog.PokeAround.AI.Supervisor do
  @moduledoc """
  Supervisor for AI-related processes.

  Supervises the Axon tagger for automatic link tagging.

  ## Configuration

      config :blog, Blog.PokeAround.AI.AxonTagger,
        enabled: false,  # DISABLED by default - prod postgres too small
        model_path: "priv/models/poke_around_tagger",
        threshold: 0.25,
        batch_size: 20,
        interval_ms: 10_000,
        langs: ["en"]

  ## Note

  This is DISABLED by default in the blog app because the prod server's
  postgres is too small to handle the volume of the firehose.
  """

  use Supervisor

  require Logger

  def start_link(opts \\ []) do
    name = opts[:name] || __MODULE__
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    config = Application.get_env(:blog, Blog.PokeAround.AI.AxonTagger, [])

    # Generate unique child name if supervisor has custom name
    tagger_name = case opts[:name] do
      nil -> Blog.PokeAround.AI.AxonTagger
      sup_name -> :"#{sup_name}_tagger"
    end

    # DISABLED by default (enabled: false)
    children =
      if Keyword.get(config, :enabled, false) do
        Logger.info("Starting AI tagger (enabled in config)")

        [
          {Blog.PokeAround.AI.AxonTagger, [
            name: tagger_name,
            model_path: Keyword.get(config, :model_path, "priv/models/poke_around_tagger"),
            threshold: Keyword.get(config, :threshold, 0.25),
            batch_size: Keyword.get(config, :batch_size, 20),
            interval: Keyword.get(config, :interval_ms, 10_000),
            langs: Keyword.get(config, :langs, ["en"]),
            auto_tag: Keyword.get(config, :auto_tag, true)
          ]}
        ]
      else
        Logger.info("AI tagger disabled (set enabled: true in config to enable)")
        []
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
