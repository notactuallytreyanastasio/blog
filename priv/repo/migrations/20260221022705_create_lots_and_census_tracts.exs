defmodule Blog.Repo.Migrations.CreateLotsAndCensusTracts do
  use Ecto.Migration

  def change do
    create table(:lots) do
      add :bbl, :string
      add :borough, :string
      add :block, :string
      add :lot, :string
      add :address, :string
      add :latitude, :float
      add :longitude, :float
      add :units_res, :integer, default: 0
      add :bct2020, :string
      add :bldg_class, :string
      add :land_use, :string
      add :num_floors, :float
      add :year_built, :integer
      add :res_area, :integer, default: 0
    end

    create index(:lots, [:latitude, :longitude])
    create index(:lots, [:bct2020])

    create table(:census_tracts) do
      add :geoid, :string
      add :name, :string
      add :fips_county, :string
      add :tract_code, :string
      add :population, :integer, default: 0
    end

    create unique_index(:census_tracts, [:geoid])
  end
end
