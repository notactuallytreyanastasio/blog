defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Create the ETS table for Reddit links
    :ets.new(:reddit_links, [:named_table, :ordered_set, :public, read_concurrency: true])

    children = [
      # Blog.Repo,
      BlogWeb.Telemetry,
      {Phoenix.PubSub, name: Blog.PubSub},
      BlogWeb.Presence,
      {Finch, name: Blog.Finch},
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
      children = [
        # Blog.Repo,
        BlogWeb.Telemetry,
        {Phoenix.PubSub, name: Blog.PubSub},
        BlogWeb.Presence,
        {Finch, name: Blog.Finch},
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
