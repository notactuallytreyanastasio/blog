defmodule Blog.Census.Tract do
  @moduledoc "Schema for a Census tract with population."
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer() | nil,
          geoid: String.t() | nil,
          name: String.t() | nil,
          fips_county: String.t() | nil,
          tract_code: String.t() | nil,
          population: integer()
        }

  schema "census_tracts" do
    field :geoid, :string
    field :name, :string
    field :fips_county, :string
    field :tract_code, :string
    field :population, :integer, default: 0
  end
end
