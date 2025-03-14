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

    # Initialize the chat message store
    Blog.Chat.MessageStore.init()

    children = [
      # Start the Telemetry supervisor
      BlogWeb.Telemetry,
      BlueskyHose,
      # Start the PubSub system
      {Phoenix.PubSub, name: Blog.PubSub},
      # Start Finch
      {Finch, name: Blog.Finch},
      # Start the Endpoint (http/https)
      BlogWeb.Endpoint,
      # Start a worker by calling: Blog.Worker.start_link(arg)
      # {Blog.Worker, arg}
      Blog.RedditBookmarkProcessor
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
        # Start the Telemetry supervisor
        BlogWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Blog.PubSub},
        # Start Finch
        {Finch, name: Blog.Finch},
        # Start the Endpoint (http/https)
        BlogWeb.Endpoint,
        # Start a worker by calling: Blog.Worker.start_link(arg)
        # {Blog.Worker, arg}
        Blog.RedditBookmarkProcessor
      ]

      opts = [strategy: :one_for_one, name: Blog.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # Create all ETS tables safely
  defp create_ets_tables do
    # For each table, check if it exists first
    Enum.each([
      {:reddit_links, [:ordered_set, :public, read_concurrency: true]},
      {:bookmarks_table, [:set, :public, read_concurrency: true]},
      {:pong_games, [:set, :public]}
    ], fn {table_name, table_opts} ->
      # Only create if it doesn't exist
      if :ets.whereis(table_name) == :undefined do
        :ets.new(table_name, [:named_table | table_opts])
      end
    end)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
