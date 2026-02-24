defmodule Blog.Census.CacheTest do
  use Blog.DataCase, async: false

  alias Blog.Census.Cache
  alias Blog.Repo

  @moduletag :db

  # Use geoids unlikely to exist in seed data
  @test_geoid_1 "061999901"
  @test_geoid_2 "061999902"

  defp insert_tract!(geoid, population) do
    Repo.insert_all(
      "census_tracts",
      [
        %{
          geoid: geoid,
          name: "Test Tract #{geoid}",
          fips_county: String.slice(geoid, 0, 3),
          tract_code: String.slice(geoid, 3..-1//1),
          population: population
        }
      ],
      on_conflict: {:replace, [:population]},
      conflict_target: :geoid
    )
  end

  defp clear_ets_cache do
    :ets.delete_all_objects(:census_population_cache)
  end

  setup do
    clear_ets_cache()
    :ok
  end

  describe "get_population/1" do
    test "returns population from database and caches it" do
      insert_tract!(@test_geoid_1, 5000)

      assert Cache.get_population(@test_geoid_1) == 5000

      # Verify it's now in ETS
      assert [{_, 5000}] = :ets.lookup(:census_population_cache, @test_geoid_1)
    end

    test "returns 0 for unknown geoid" do
      assert Cache.get_population("999999999") == 0
    end

    test "returns cached value on second call" do
      insert_tract!(@test_geoid_1, 3000)

      # First call loads into cache
      assert Cache.get_population(@test_geoid_1) == 3000

      # Manually insert a different value into ETS to verify cache is used
      :ets.insert(:census_population_cache, {@test_geoid_1, 9999})
      assert Cache.get_population(@test_geoid_1) == 9999
    end
  end

  describe "get_populations/1" do
    test "returns populations for multiple geoids" do
      insert_tract!(@test_geoid_1, 5000)
      insert_tract!(@test_geoid_2, 3000)

      result = Cache.get_populations([@test_geoid_1, @test_geoid_2])

      assert result[@test_geoid_1] == 5000
      assert result[@test_geoid_2] == 3000
    end

    test "mixes cached and uncached lookups" do
      insert_tract!(@test_geoid_2, 3000)

      # Pre-cache one value
      :ets.insert(:census_population_cache, {@test_geoid_1, 5000})

      result = Cache.get_populations([@test_geoid_1, @test_geoid_2])

      assert result[@test_geoid_1] == 5000
      assert result[@test_geoid_2] == 3000
    end

    test "returns empty map for empty input" do
      assert Cache.get_populations([]) == %{}
    end

    test "handles all missing geoids gracefully" do
      result = Cache.get_populations(["999999999"])
      assert result == %{}
    end
  end
end
