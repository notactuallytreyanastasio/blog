defmodule Blog.Population.Geometry do
  @moduledoc """
  Pure geometric operations for polygon-based spatial queries.
  """

  @type point :: {float(), float()}
  @type vertex :: [float()]
  @type polygon :: [vertex()]
  @type bbox :: {float(), float(), float(), float()}

  @doc """
  Computes the bounding box of a polygon.

  Returns `{min_lat, max_lat, min_lng, max_lng}`.
  """
  @spec bounding_box(polygon()) :: bbox()
  def bounding_box(polygon) do
    {lats, lngs} =
      Enum.reduce(polygon, {[], []}, fn [lat, lng], {lats, lngs} ->
        {[lat | lats], [lng | lngs]}
      end)

    {Enum.min(lats), Enum.max(lats), Enum.min(lngs), Enum.max(lngs)}
  end

  @doc """
  Tests whether a point lies inside a polygon using ray-casting.

  Point is `{lat, lng}`, polygon is a list of `[lat, lng]` vertices.
  """
  @spec point_in_polygon?(point(), polygon()) :: boolean()
  def point_in_polygon?({lat, lng}, polygon) do
    polygon
    |> Enum.zip(rotate(polygon))
    |> Enum.reduce(false, fn {[lat1, lng1], [lat2, lng2]}, inside ->
      if edge_crosses?(lat, lat1, lat2) and ray_left_of_edge?(lng, lat, lng1, lat1, lng2, lat2) do
        not inside
      else
        inside
      end
    end)
  end

  defp edge_crosses?(lat, lat1, lat2), do: lat1 > lat != lat2 > lat

  defp ray_left_of_edge?(lng, lat, lng1, lat1, lng2, lat2) do
    lng < lng1 + (lat - lat1) / (lat2 - lat1) * (lng2 - lng1)
  end

  defp rotate([h | t]), do: t ++ [h]
end
