defmodule Blog.Pluto.Parser do
  @moduledoc """
  Pure functions for parsing PLUTO CSV rows into lot maps.
  """

  @doc """
  Parses a CSV row map into a lot attrs map for Repo.insert.

  Returns `:skip` for rows without valid coordinates.
  """
  @spec parse_row(map()) :: map() | :skip
  def parse_row(row) do
    with {lat, _} <- Float.parse(row["latitude"] || ""),
         {lng, _} <- Float.parse(row["longitude"] || "") do
      build_lot_attrs(row, lat, lng)
    else
      _ -> :skip
    end
  end

  defp build_lot_attrs(row, lat, lng) do
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
  end

  @spec parse_int(String.t() | nil) :: non_neg_integer()
  def parse_int(nil), do: 0
  def parse_int(""), do: 0

  def parse_int(s) when is_binary(s) do
    s |> String.replace(",", "") |> do_parse_int()
  end

  defp do_parse_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end

  @spec parse_float(String.t() | nil) :: float()
  def parse_float(nil), do: 0.0
  def parse_float(""), do: 0.0

  def parse_float(s) when is_binary(s) do
    case s |> String.replace(",", "") |> Float.parse() do
      {f, _} -> f
      :error -> 0.0
    end
  end
end
