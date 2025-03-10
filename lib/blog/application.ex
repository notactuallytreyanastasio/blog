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

    # Create the ETS table for Reddit links
    :ets.new(:reddit_links, [:named_table, :ordered_set, :public, read_concurrency: true])

    # Initialize the chat message store
    Blog.Chat.MessageStore.init()

    children = [
      # Start the WordStore as a supervised process
      Blog.Wordle.WordStore,
      # Start the GameStore for persisting game states
      Blog.Wordle.GameStore,
      Blog.Repo,
      BlogWeb.Telemetry,
      {Phoenix.PubSub, name: Blog.PubSub},
      BlogWeb.Presence,
      {Finch, name: Blog.Finch},
      # Start the presence tracker for chat
      Blog.Chat.Presence,
      # Start the cursor points manager
      Blog.CursorPoints,
      # Start the bookmark store
      Blog.Bookmarks.Store,
      # Start the Endpoint (http/https)
      BlogWeb.Endpoint,
      BlueskyHose
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  rescue
    ArgumentError ->
      # Table already exists, continue with startup

      # Initialize the chat message store (we still try this as it checks if tables exist)
      Blog.Chat.MessageStore.init()

      children = [
        # Start the WordStore as a supervised process
        Blog.Wordle.WordStore,
        # Start the GameStore for persisting game states
        Blog.Wordle.GameStore,
        Blog.Repo,
        BlogWeb.Telemetry,
        {Phoenix.PubSub, name: Blog.PubSub},
        BlogWeb.Presence,
        {Finch, name: Blog.Finch},
        # Start the presence tracker for chat
        Blog.Chat.Presence,
        # Start the cursor points manager
        Blog.CursorPoints,
        # Start the bookmark store
        Blog.Bookmarks.Store,
        # Start the Endpoint (http/https)
        BlogWeb.Endpoint,
        BlueskyHose
      ]

      opts = [strategy: :one_for_one, name: Blog.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
