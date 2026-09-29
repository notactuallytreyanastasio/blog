defp deps do
  [
    {:phoenix, "~> 1.7.12"},
    {:phoenix_ecto, "~> 4.5"},
    {:ecto_sql, "~> 3.11"},
    {:postgrex, ">= 0.0.0"},
    {:phoenix_html, "~> 4.1"},
    {:phoenix_live_reload, "~> 1.2", only: :dev},
    {:phoenix_live_view, "~> 0.20.14"},
    {:telemetry_metrics, "~> 0.6"},
    {:telemetry_poller, "~> 1.0"},
    {:jason, "~> 1.2"},
    {:bandit, "~> 1.2"},

    # Add this line
    {:gen_stage, "~> 1.2"}
  ]
end