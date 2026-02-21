defmodule Blog.Census.Tract do
  @moduledoc "Schema for a Census tract with population."
  use Ecto.Schema

  schema "census_tracts" do
    field :geoid, :string
    field :name, :string
    field :fips_county, :string
    field :tract_code, :string
    field :population, :integer, default: 0
  end
end
