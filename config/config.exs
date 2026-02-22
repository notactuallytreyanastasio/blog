# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :blog,
  ecto_repos: [Blog.Repo]

# Configures the endpoint
config :blog, BlogWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BlogWeb.ErrorHTML, json: BlogWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Blog.PubSub,
  live_view: [signing_salt: "aLPIOUxY"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :blog, Blog.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  blog: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --external:leaflet),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  blog: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Live draft API token (dev default)
config :blog, :live_draft_api_token, "dev-live-draft-token"

# Finder admin password (override in prod via FINDER_ADMIN_PASSWORD env var)
config :blog, :finder_admin_password, "letmein"

# Import receipt printer configuration
import_config "receipt_printer.exs"

# PokeAround (StumbleUpon clone) configuration
config :blog, Blog.PokeAround.Supervisor,
  enabled: true

config :blog, Blog.PokeAround.Bluesky.Supervisor,
  enabled: true

# AI tagger is DISABLED by default - prod postgres too small for this volume
config :blog, Blog.PokeAround.AI.AxonTagger,
  enabled: false,
  model_path: "priv/models/poke_around_tagger",
  threshold: 0.25,
  batch_size: 20,
  interval_ms: 10_000,
  langs: ["en"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
