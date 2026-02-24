defmodule Blog.PlutoTest do
  use Blog.DataCase, async: true

  alias Blog.Pluto
  alias Blog.Repo

  @moduletag :db

  # Use unique tract codes unlikely to exist in seed data
  @test_tract_1 "9990100"
  @test_tract_2 "9990200"

  defp insert_lot!(attrs) do
    defaults = %{
      bbl: "9990010001",
      borough: "MN",
      block: "00001",
      lot: "0001",
      address: "1 TEST ST",
      latitude: 40.7128,
      longitude: -74.0060,
      units_res: 10,
      bct2020: @test_tract_1,
      bldg_class: "O5",
      land_use: "05",
      num_floors: 10.0,
      year_built: 1920,
      res_area: 5000
    }

    merged = Map.merge(defaults, attrs)
    {1, _} = Repo.insert_all("lots", [merged])
    merged
  end

  describe "lots_in_bbox/1" do
    test "returns lots within bounding box" do
      # Use coordinates in a remote area (North Pole-ish) to avoid seed data
      insert_lot!(%{bbl: "999101", latitude: 89.01, longitude: 0.01})
      insert_lot!(%{bbl: "999102", latitude: 89.02, longitude: 0.02})
      insert_lot!(%{bbl: "999103", latitude: 10.00, longitude: 10.00})

      results = Pluto.lots_in_bbox({89.00, 89.10, 0.00, 0.10})

      bbls = Enum.map(results, & &1.bbl)
      assert "999101" in bbls
      assert "999102" in bbls
      refute "999103" in bbls
    end

    test "returns empty list when no lots match" do
      # Searching in area with no data
      assert Pluto.lots_in_bbox({89.90, 89.99, 179.90, 179.99}) == []
    end
  end

  describe "tract_total_units/1" do
    test "returns total units grouped by tract" do
      insert_lot!(%{bbl: "999201", bct2020: @test_tract_1, units_res: 10})
      insert_lot!(%{bbl: "999202", bct2020: @test_tract_1, units_res: 20})
      insert_lot!(%{bbl: "999203", bct2020: @test_tract_2, units_res: 5})

      result = Pluto.tract_total_units([@test_tract_1, @test_tract_2])

      assert result[@test_tract_1] == 30
      assert result[@test_tract_2] == 5
    end

    test "returns empty map for empty input" do
      assert Pluto.tract_total_units([]) == %{}
    end

    test "returns empty map when no tracts match" do
      assert Pluto.tract_total_units(["9999999"]) == %{}
    end
  end

  describe "tract_centroids/0" do
    test "returns centroids grouped by tract code" do
      insert_lot!(%{
        bbl: "999301",
        bct2020: @test_tract_1,
        latitude: 89.50,
        longitude: 179.50,
        units_res: 10
      })

      insert_lot!(%{
        bbl: "999302",
        bct2020: @test_tract_1,
        latitude: 89.52,
        longitude: 179.52,
        units_res: 20
      })

      results = Pluto.tract_centroids()
      tract = Enum.find(results, &(&1.bct2020 == @test_tract_1))

      assert tract != nil
      assert_in_delta tract.lat, 89.51, 0.02
      assert_in_delta tract.lng, 179.51, 0.02
      assert tract.units == 30
    end

    test "excludes lots with empty bct2020" do
      insert_lot!(%{bbl: "999401", bct2020: "", latitude: 89.60, longitude: 179.60})

      results = Pluto.tract_centroids()
      # Should not find any tract with empty bct2020
      refute Enum.any?(results, &(&1.bct2020 == ""))
    end
  end
end
