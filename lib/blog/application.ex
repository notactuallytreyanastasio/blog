defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Start :inets application - needed by Pythonx
    :ok = Application.ensure_started(:inets)

    # Configure Pythonx environment variables
    # Point to Python executable found via SSH
    System.put_env("PYTHONX_PYTHON_PATH", "/usr/bin/python3")
    # Use a directory with write permissions - changed from /tmp/pythonx_cache to /tmp
    System.put_env("PYTHONX_CACHE_DIR", "/tmp")
    # Disable download of binaries (use system Python)
    System.put_env("PYTHONX_SKIP_DOWNLOAD", "true")

    # Create cache directory with proper permissions
    File.mkdir_p!("/tmp/pythonx_venv")

    # Create the ETS tables - in a safe way that handles table already existing
    create_ets_tables()

    # Pre-initialize the SkeetStore
    # This ensures the module is loaded and the table is ready
    ensure_skeet_store_initialized()

    children = [
      # Start the Repo
      Blog.Repo,
      # Start the Telemetry supervisor
      BlogWeb.Telemetry,
      BlueskyHose,
      BlueskyJetstream,
      # Start the PubSub system
      {Phoenix.PubSub, name: Blog.PubSub},
      # Start Finch
      {Finch, name: Blog.Finch},
      # Start the Endpoint (http/https)
      BlogWeb.Endpoint,
      # Start a worker by calling: Blog.Worker.start_link(arg)
      # {Blog.Worker, arg}
      Blog.RedditBookmarkProcessor,
      # Start the Wordle stores
      Blog.Wordle.WordStore,
      Blog.Wordle.GameStore,
      # Start the Presence service for real-time user tracking
      BlogWeb.Presence
    ]

    # Pre-load the Games modules to ensure they're available
    _ = Blog.Games
    _ = Blog.Games.Blackjack
    # Pre-load SkeetStore module
    _ = Blog.SkeetStore

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  rescue
    ArgumentError ->
      # Table already exists, continue with startup

      # Pre-initialize the SkeetStore
      ensure_skeet_store_initialized()

      children = [
        # Start the Repo
        Blog.Repo,
        # Start the Telemetry supervisor
        BlogWeb.Telemetry,
        BlueskyHose,
        BlueskyJetstream,
        # Start the PubSub system
        {Phoenix.PubSub, name: Blog.PubSub},
        # Start Finch
        {Finch, name: Blog.Finch},
        # Start the Endpoint (http/https)
        BlogWeb.Endpoint,
        # Start a worker by calling: Blog.Worker.start_link(arg)
        # {Blog.Worker, arg}
        Blog.RedditBookmarkProcessor,
        # Start the Wordle stores
        Blog.Wordle.WordStore,
        Blog.Wordle.GameStore,
        # Start the Presence service for real-time user tracking
        BlogWeb.Presence
      ]

      opts = [strategy: :one_for_one, name: Blog.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # Create all ETS tables safely
  defp create_ets_tables do
    # For each table, check if it exists first
    Enum.each(
      [
        {:reddit_links, [:ordered_set, :public, read_concurrency: true]},
        {:bookmarks_table, [:set, :public, read_concurrency: true]},
        {:pong_games, [:set, :public]},
        {:war_players, [:set, :public, read_concurrency: true, write_concurrency: true]},
        {:sample_skeets_table, [:named_table, :ordered_set, :public, read_concurrency: true]}
      ],
      fn {table_name, table_opts} ->
        # Only create if it doesn't exist
        if :ets.whereis(table_name) == :undefined do
          :ets.new(table_name, [:named_table | table_opts])
        end
      end
    )
  end

  # Ensure the SkeetStore is initialized
  defp ensure_skeet_store_initialized do
    # Create tables if they don't exist, this can be called safely multiple times
    if Code.ensure_loaded?(Blog.SkeetStore) do
      try do
        Blog.SkeetStore.init()
      rescue
        # Ignore any errors during initialization
        _ -> :ok
      end
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
