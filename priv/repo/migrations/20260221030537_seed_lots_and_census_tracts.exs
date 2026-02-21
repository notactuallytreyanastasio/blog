defmodule Blog.Repo.Migrations.SeedLotsAndCensusTracts do
  use Ecto.Migration

  @batch_size 4000
  @base_url "https://api.census.gov/data/2020/dec/pl"
  @nyc_counties [
    {"061", "Manhattan"},
    {"005", "Bronx"},
    {"047", "Brooklyn"},
    {"081", "Queens"},
    {"085", "Staten Island"}
  ]

  def up do
    import_pluto()
    import_census()
  end

  def down do
    execute("TRUNCATE lots RESTART IDENTITY")
    execute("TRUNCATE census_tracts RESTART IDENTITY")
  end

  # -- PLUTO import from gzipped CSV --

  defp import_pluto do
    path = Application.app_dir(:blog, "priv/data/PLUTO.csv.gz")

    unless File.exists?(path) do
      raise "PLUTO.csv.gz not found at #{path}"
    end

    [header_line | _] =
      path
      |> File.stream!([:compressed])
      |> Enum.take(1)

    headers = parse_csv_line(header_line)

    path
    |> File.stream!([:compressed])
    |> Stream.drop(1)
    |> Stream.map(fn line -> line |> parse_csv_line() |> zip_headers(headers) end)
    |> Stream.map(&parse_pluto_row/1)
    |> Stream.reject(&(&1 == :skip))
    |> Stream.chunk_every(@batch_size)
    |> Enum.each(fn batch ->
      repo().insert_all("lots", batch, on_conflict: :nothing)
    end)
  end

  defp parse_pluto_row(row) do
    with {lat, _} <- Float.parse(row["latitude"] || ""),
         {lng, _} <- Float.parse(row["longitude"] || "") do
      %{
        bbl: row["BBL"] || "",
        borough: row["borough"] || "",
        block: row["Tax block"] || "",
        lot: row["Tax lot"] || "",
        address: row["address"] || "",
        latitude: lat,
        longitude: lng,
        units_res: parse_int(row["unitsres"]),
        bct2020: row["bct2020"] || "",
        bldg_class: row["bldgclass"] || "",
        land_use: row["landuse"] || "",
        num_floors: parse_float(row["numfloors"]),
        year_built: parse_int(row["yearbuilt"]),
        res_area: parse_int(row["resarea"])
      }
    else
      _ -> :skip
    end
  end

  defp parse_csv_line(line) do
    line
    |> String.trim()
    |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
    |> hd()
  end

  defp zip_headers(values, headers) do
    Enum.zip(headers, values) |> Map.new()
  end

  # -- Census import from API --

  defp import_census do
    Application.ensure_all_started(:req)

    Enum.each(@nyc_counties, fn {fips, _name} ->
      case fetch_county(fips) do
        {:ok, tracts} ->
          repo().insert_all("census_tracts", tracts, on_conflict: :nothing)

        {:error, _reason} ->
          :ok
      end
    end)
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

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0

  defp parse_int(s) when is_binary(s) do
    case s |> String.replace(",", "") |> Integer.parse() do
      {n, _} -> n
      :error -> 0
    end
  end

  defp parse_float(nil), do: 0.0
  defp parse_float(""), do: 0.0

  defp parse_float(s) when is_binary(s) do
    case s |> String.replace(",", "") |> Float.parse() do
      {f, _} -> f
      :error -> 0.0
    end
  end
end
