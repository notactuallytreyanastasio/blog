defmodule Blog.Pluto.Lot do
  @moduledoc "Schema for a PLUTO tax lot."
  use Ecto.Schema

  schema "lots" do
    field :bbl, :string
    field :borough, :string
    field :block, :string
    field :lot, :string
    field :address, :string
    field :latitude, :float
    field :longitude, :float
    field :units_res, :integer, default: 0
    field :bct2020, :string
    field :bldg_class, :string
    field :land_use, :string
    field :num_floors, :float
    field :year_built, :integer
    field :res_area, :integer, default: 0
  end
end
