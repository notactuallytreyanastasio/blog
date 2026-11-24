defmodule FactoryReport.MixProject do
  use Mix.Project

  # FACTORY_REPORT_COMPAT=1 runs the same suite against the oldest supported
  # pair (Phoenix 1.7, LiveView 1.0) with its own lockfile, deps and build
  # directories, so the two sets never overwrite each other:
  #
  #     FACTORY_REPORT_COMPAT=1 mix do deps.get + test
  #
  # Only where the tests are: a vendored copy (install.sh ships mix.exs, lib/
  # and the README) has no test/ and never takes this branch.
  @compat System.get_env("FACTORY_REPORT_COMPAT") == "1" and File.dir?(Path.join(__DIR__, "test"))

  def project do
    [
      app: :factory_report,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A sub-app's own account of its inside, for the obs_factor observer"
    ] ++ paths()
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp paths do
    if @compat do
      [lockfile: "mix.compat.lock", deps_path: "deps_compat", build_path: "_build_compat"]
    else
      []
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:telemetry, "~> 1.0"},
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.2"},
      # Never called at compile time and never required at run time: listed
      # (optional) only so that a host app's versions are checked and so the
      # tests have something real to watch.
      {:phoenix, if(@compat, do: "~> 1.7.14", else: "~> 1.7"), optional: true},
      {:phoenix_live_view, if(@compat, do: "~> 1.0.0", else: "~> 1.0"), optional: true},
      # Phoenix.LiveViewTest's HTML parser: floki up to LiveView 1.0, lazy_html after.
      {:floki, ">= 0.30.0", only: :test},
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end
end
