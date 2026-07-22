defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = Application.ensure_started(:inets)

    # Pythonx config for PythonDemoLive
    System.put_env("PYTHONX_PYTHON_PATH", "/usr/bin/python3")
    System.put_env("PYTHONX_CACHE_DIR", "/tmp")
    System.put_env("PYTHONX_SKIP_DOWNLOAD", "true")

    create_ets_tables()
    ensure_skeet_store_initialized()

    children = [
      Blog.Repo,
      BlogWeb.Telemetry,
      Blog.HoseMonitor,
      BlueskyHose,
      BlueskyJetstream,
      {Phoenix.PubSub, name: Blog.PubSub},
      Blog.LiveDraft,
      {Finch, name: Blog.Finch},
      BlogWeb.Endpoint,
      Blog.RedditBookmarkProcessor,
      Blog.Wordle.WordStore,
      Blog.Wordle.GameStore,
      BlogWeb.Presence,
      Blog.PokeAround.Supervisor,
      {Registry, keys: :unique, name: Blog.SmartSteps.SessionRegistry},
      {DynamicSupervisor, name: Blog.SmartSteps.SessionSupervisor, strategy: :one_for_one},
      Blog.Census.Cache,
      {Task.Supervisor, name: Blog.Chess.TaskSupervisor},
      {Task.Supervisor, name: Blog.GifMaker.TaskSupervisor},
      Blog.GifMaker.Processor,
      Blog.GifMaker.Cleanup,
      {Task.Supervisor, name: Blog.CollageMaker.TaskSupervisor},
      Blog.CollageMaker.Processor,
      Blog.CollageMaker.Cleanup
    ]

    children = children ++ work_log_poller_children() ++ blinks_link_check_children()

    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # The poller makes live GitHub API calls and writes to the database, so it
  # is disabled in the test environment (see config/test.exs).
  # Daily dead-link sweep does live HTTP; keep it out of tests (config/test.exs).
  defp blinks_link_check_children do
    if Application.get_env(:blog, :start_blinks_link_check, true) do
      [Blog.Blinks.LinkCheck]
    else
      []
    end
  end

  defp work_log_poller_children do
    if Application.get_env(:blog, :start_work_log_poller, true) do
      [Blog.GitHub.WorkLogPoller]
    else
      []
    end
  end

  # Create all ETS tables safely
  defp create_ets_tables do
    # For each table, check if it exists first
    Enum.each(
      [
        {:reddit_links, [:ordered_set, :public, read_concurrency: true]},
        {:bookmarks_table, [:set, :public, read_concurrency: true]},
        {:pong_games, [:set, :public]},
        {:sample_skeets_table, [:named_table, :ordered_set, :public, read_concurrency: true]},
        {:gif_maker_rate_limits,
         [:set, :public, read_concurrency: true, write_concurrency: true]},
        {:collage_maker_rate_limits,
         [:set, :public, read_concurrency: true, write_concurrency: true]}
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
