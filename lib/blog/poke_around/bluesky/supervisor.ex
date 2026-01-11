defmodule Blog.PokeAround.Bluesky.Supervisor do
  @moduledoc """
  Supervisor for the Bluesky firehose subsystem.

  Manages the Turbostream WebSocket connection.

  ## Configuration

      config :blog, Blog.PokeAround.Bluesky.Supervisor,
        enabled: true

  Set `enabled: false` to disable the firehose on startup.
  """

  use Supervisor

  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    if enabled?() do
      Logger.info("Starting Bluesky firehose supervisor")

      children = [
        Blog.PokeAround.Bluesky.Firehose,
        Blog.PokeAround.Bluesky.Extractor
      ]

      Supervisor.init(children, strategy: :one_for_one)
    else
      Logger.info("Bluesky firehose disabled")
      :ignore
    end
  end

  @doc """
  Check if the firehose is enabled.
  """
  def enabled? do
    Application.get_env(:blog, __MODULE__, [])
    |> Keyword.get(:enabled, true)
  end
end
