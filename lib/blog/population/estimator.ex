defmodule Blog.Population.Estimator do
  @moduledoc """
  Estimates population within a drawn polygon.

  Pipeline:
  1. Compute bounding box from polygon vertices
  2. Query Postgres for lots in bounding box
  3. Filter to lots inside polygon (point-in-polygon)
  4. Group by census tract, fetch tract populations
  5. Distribute population proportionally by residential units
  """

  alias Blog.Census.Cache, as: CensusCache
  alias Blog.Pluto
  alias Blog.Pluto.Lot
  alias Blog.Population.Geometry

  @boro_to_fips %{
    "1" => "061",
    "2" => "005",
    "3" => "047",
    "4" => "081",
    "5" => "085"
  }

  @type polygon :: [[float()]]
  @type result :: %{
          total_population: float(),
          total_lots: non_neg_integer(),
          total_residential_units: non_neg_integer(),
          tract_count: non_neg_integer(),
          lots: [map()]
        }

  @doc """
  Estimates population within a polygon.

  Polygon is a list of `[lat, lng]` pairs from Leaflet.draw.
  """
  @spec estimate(polygon()) :: {:ok, result()} | {:error, term()}
  def estimate(polygon) do
    bbox = Geometry.bounding_box(polygon)
    lots = Pluto.lots_in_bbox(bbox)

    lots
    |> filter_in_polygon(polygon)
    |> compute_populations()
    |> then(&{:ok, &1})
  end

  @doc "Filters lots to those inside the polygon. Pure function."
  @spec filter_in_polygon([Lot.t()], polygon()) :: [Lot.t()]
  def filter_in_polygon(lots, polygon) do
    Enum.filter(lots, fn lot ->
      lot.latitude != nil and lot.longitude != nil and
        Geometry.point_in_polygon?({lot.latitude, lot.longitude}, polygon)
    end)
  end

  @doc "Computes population estimates for lots. Returns the result map."
  @spec compute_populations([Lot.t()]) :: result()
  def compute_populations(lots) do
    tract_groups = Enum.group_by(lots, & &1.bct2020)
    tract_codes = Map.keys(tract_groups) |> Enum.reject(&(&1 == "" or is_nil(&1)))

    total_units_by_tract = Pluto.tract_total_units(tract_codes)

    geoids = Enum.map(tract_codes, &bct2020_to_geoid/1) |> Enum.reject(&is_nil/1)
    census_pops = CensusCache.get_populations(geoids)

    lot_results =
      Enum.flat_map(tract_groups, fn {bct2020, tract_lots} ->
        geoid = bct2020_to_geoid(bct2020)
        tract_pop = Map.get(census_pops, geoid, 0)
        total_units = Map.get(total_units_by_tract, bct2020, 0)

        Enum.map(tract_lots, fn lot ->
          estimated_pop = proportional_pop(lot.units_res, total_units, tract_pop)

          %{
            lat: lot.latitude,
            lng: lot.longitude,
            address: lot.address || "",
            units: lot.units_res || 0,
            estimated_pop: estimated_pop,
            bbl: lot.bbl,
            bldg_class: lot.bldg_class
          }
        end)
      end)

    %{
      total_population:
        lot_results |> Enum.map(& &1.estimated_pop) |> Enum.sum() |> Float.round(0),
      total_lots: length(lots),
      total_residential_units: lots |> Enum.map(& &1.units_res) |> Enum.sum(),
      tract_count: length(tract_codes),
      lots: lot_results
    }
  end

  @doc "Converts PLUTO bct2020 to Census geoid."
  @spec bct2020_to_geoid(String.t()) :: String.t() | nil
  def bct2020_to_geoid(nil), do: nil
  def bct2020_to_geoid(""), do: nil

  def bct2020_to_geoid(bct2020) when byte_size(bct2020) >= 2 do
    boro = String.first(bct2020)
    tract = String.slice(bct2020, 1..-1//1)

    case Map.get(@boro_to_fips, boro) do
      nil -> nil
      fips -> fips <> tract
    end
  end

  def bct2020_to_geoid(_), do: nil

  @spec proportional_pop(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: float()
  defp proportional_pop(_lot_units, 0, _tract_pop), do: 0.0

  defp proportional_pop(lot_units, total_units, tract_pop) do
    Float.round(tract_pop * (lot_units / total_units), 1)
  end
end
