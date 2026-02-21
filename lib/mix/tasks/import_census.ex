defmodule Mix.Tasks.ImportCensus do
  @moduledoc "Fetch 2020 Census tract populations for NYC and store in database."
  @shortdoc "Import Census tract population data"

  use Mix.Task

  alias Blog.Repo

  @base_url "https://api.census.gov/data/2020/dec/pl"

  # NYC FIPS county codes
  @nyc_counties [
    {"061", "Manhattan"},
    {"005", "Bronx"},
    {"047", "Brooklyn"},
    {"081", "Queens"},
    {"085", "Staten Island"}
  ]

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("Clearing existing census tracts...")
    Repo.query!("TRUNCATE census_tracts RESTART IDENTITY")

    Mix.shell().info("Fetching 2020 Census data for NYC...")

    total =
      Enum.reduce(@nyc_counties, 0, fn {fips, name}, acc ->
        Mix.shell().info("  Fetching #{name} (county #{fips})...")

        case fetch_county(fips) do
          {:ok, tracts} ->
            Repo.insert_all("census_tracts", tracts, on_conflict: :nothing)
            Mix.shell().info("    #{length(tracts)} tracts loaded")
            acc + length(tracts)

          {:error, reason} ->
            Mix.shell().error("    Failed: #{reason}")
            acc
        end
      end)

    Mix.shell().info("Done! Imported #{total} census tracts.")
  end

  defp fetch_county(fips) do
    url = "#{@base_url}?get=P1_001N,NAME&for=tract:*&in=state:36&in=county:#{fips}"

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: [_header | rows]}} ->
        tracts =
          Enum.map(rows, fn [population, name, _state, county, tract] ->
            %{
              geoid: "#{county}#{tract}",
              name: name,
              fips_county: county,
              tract_code: tract,
              population: parse_int(population)
            }
          end)

        {:ok, tracts}

      {:ok, %Req.Response{status: status}} ->
        {:error, "Census API returned status #{status}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp parse_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end
end
