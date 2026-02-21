defmodule Blog.Pluto do
  @moduledoc "Context for querying PLUTO tax lot data."

  alias Blog.Pluto.Lot
  alias Blog.Repo

  import Ecto.Query

  @type bbox :: {float(), float(), float(), float()}

  @doc """
  Fetches lots within a bounding box.

  Returns lots where latitude/longitude fall within the given bounds.
  """
  @spec lots_in_bbox(bbox()) :: [Lot.t()]
  def lots_in_bbox({min_lat, max_lat, min_lng, max_lng}) do
    Lot
    |> where(
      [l],
      l.latitude >= ^min_lat and l.latitude <= ^max_lat and
        l.longitude >= ^min_lng and l.longitude <= ^max_lng
    )
    |> Repo.all()
  end

  @doc """
  Returns the total residential units per census tract for given tract codes.

  Returns `%{bct2020 => total_units}`.
  """
  @spec tract_total_units([String.t()]) :: %{String.t() => non_neg_integer()}
  def tract_total_units([]), do: %{}

  def tract_total_units(bct2020_codes) do
    Lot
    |> where([l], l.bct2020 in ^bct2020_codes)
    |> group_by([l], l.bct2020)
    |> select([l], {l.bct2020, sum(l.units_res)})
    |> Repo.all()
    |> Map.new()
  end
end
