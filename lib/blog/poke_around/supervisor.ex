defmodule Blog.PokeAround.Supervisor do
  @moduledoc """
  Root supervisor for the PokeAround subsystem.

  Manages:
  - Bluesky firehose (link collection from Turbostream)
  - AI tagger (disabled by default)

  ## Configuration

      # Enable/disable the whole poke_around system
      config :blog, Blog.PokeAround.Supervisor,
        enabled: true

      # Bluesky firehose settings
      config :blog, Blog.PokeAround.Bluesky.Supervisor,
        enabled: true

      # AI tagger settings (disabled by default)
      config :blog, Blog.PokeAround.AI.AxonTagger,
        enabled: false

  ## Usage

  Add to your application.ex children:

      children = [
        # ... other children
        Blog.PokeAround.Supervisor
      ]
  """

  use Supervisor

  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    if enabled?() do
      Logger.info("Starting PokeAround supervisor")

      children = [
        Blog.PokeAround.Bluesky.Supervisor,
        Blog.PokeAround.AI.Supervisor
      ]

      Supervisor.init(children, strategy: :one_for_one)
    else
      Logger.info("PokeAround system disabled")
      :ignore
    end
  end

  @doc """
  Check if the poke_around system is enabled.
  """
  def enabled? do
    Application.get_env(:blog, __MODULE__, [])
    |> Keyword.get(:enabled, true)
  end
end
