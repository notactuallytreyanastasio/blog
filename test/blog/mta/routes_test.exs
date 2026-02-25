defmodule Blog.Mta.RoutesTest do
  use ExUnit.Case, async: true

  alias Blog.Mta.Routes

  describe "for_borough/1" do
    test "returns Manhattan routes" do
      routes = Routes.for_borough(:manhattan)
      assert is_map(routes)
      assert map_size(routes) > 0
      assert Map.has_key?(routes, "M14A-SBS")
      assert routes["M14A-SBS"] == "MTA NYCT_M14A+"
    end

    test "returns Brooklyn routes" do
      routes = Routes.for_borough(:brooklyn)
      assert is_map(routes)
      assert map_size(routes) > 0
      assert Map.has_key?(routes, "B1")
      assert routes["B44-SBS"] == "MTA NYCT_B44+"
    end

    test "returns Queens routes" do
      routes = Routes.for_borough(:queens)
      assert is_map(routes)
      assert map_size(routes) > 0
      assert Map.has_key?(routes, "Q1")
      assert routes["Q70-SBS"] == "MTA NYCT_Q70+"
    end

    test "returns all routes combined" do
      all = Routes.for_borough(:all)
      manhattan = Routes.for_borough(:manhattan)
      brooklyn = Routes.for_borough(:brooklyn)
      queens = Routes.for_borough(:queens)

      assert map_size(all) == map_size(manhattan) + map_size(brooklyn) + map_size(queens)
    end

    test "boroughs do not overlap" do
      manhattan_keys = Routes.for_borough(:manhattan) |> Map.keys() |> MapSet.new()
      brooklyn_keys = Routes.for_borough(:brooklyn) |> Map.keys() |> MapSet.new()
      queens_keys = Routes.for_borough(:queens) |> Map.keys() |> MapSet.new()

      assert MapSet.disjoint?(manhattan_keys, brooklyn_keys)
      assert MapSet.disjoint?(manhattan_keys, queens_keys)
      assert MapSet.disjoint?(brooklyn_keys, queens_keys)
    end
  end

  describe "borough_name/1" do
    test "returns display names" do
      assert Routes.borough_name(:manhattan) == "Manhattan"
      assert Routes.borough_name(:brooklyn) == "Brooklyn"
      assert Routes.borough_name(:queens) == "Queens"
      assert Routes.borough_name(:all) == "All Boroughs"
    end
  end

  describe "boroughs/0" do
    test "returns all borough atoms" do
      assert Routes.boroughs() == [:manhattan, :brooklyn, :queens, :all]
    end
  end

  describe "toggle_route/2" do
    test "adds a route when not present" do
      selected = MapSet.new(["M1", "M2"])
      result = Routes.toggle_route(selected, "M3")

      assert MapSet.member?(result, "M3")
      assert MapSet.size(result) == 3
    end

    test "removes a route when already present" do
      selected = MapSet.new(["M1", "M2", "M3"])
      result = Routes.toggle_route(selected, "M2")

      refute MapSet.member?(result, "M2")
      assert MapSet.size(result) == 2
    end

    test "works with empty set" do
      result = Routes.toggle_route(MapSet.new(), "M1")
      assert MapSet.member?(result, "M1")
    end
  end

  describe "filter_selected/2" do
    test "returns only routes whose keys are in the selected set" do
      all_routes = %{"M1" => "MTA NYCT_M1", "M2" => "MTA NYCT_M2", "M3" => "MTA NYCT_M3"}
      selected = MapSet.new(["M1", "M3"])

      result = Routes.filter_selected(all_routes, selected)

      assert result == %{"M1" => "MTA NYCT_M1", "M3" => "MTA NYCT_M3"}
    end

    test "returns empty map when nothing is selected" do
      all_routes = %{"M1" => "MTA NYCT_M1"}
      selected = MapSet.new()

      assert Routes.filter_selected(all_routes, selected) == %{}
    end

    test "ignores selected keys not in all_routes" do
      all_routes = %{"M1" => "MTA NYCT_M1"}
      selected = MapSet.new(["M1", "NONEXISTENT"])

      assert Routes.filter_selected(all_routes, selected) == %{"M1" => "MTA NYCT_M1"}
    end
  end

  describe "build_bus_map/1" do
    test "converts results list to a map keyed by route name" do
      results = [
        %{route: "M1", buses: [%{id: "bus1"}]},
        %{route: "M2", buses: []}
      ]

      result = Routes.build_bus_map(results)

      assert result == %{"M1" => [%{id: "bus1"}], "M2" => []}
    end

    test "returns empty map for empty results" do
      assert Routes.build_bus_map([]) == %{}
    end
  end

  describe "all/0" do
    test "returns the same as for_borough(:all)" do
      assert Routes.all() == Routes.for_borough(:all)
    end

    test "all Manhattan routes start with M" do
      Routes.for_borough(:manhattan)
      |> Map.keys()
      |> Enum.each(fn key -> assert String.starts_with?(key, "M") end)
    end

    test "all Brooklyn routes start with B" do
      Routes.for_borough(:brooklyn)
      |> Map.keys()
      |> Enum.each(fn key -> assert String.starts_with?(key, "B") end)
    end

    test "all Queens routes start with Q" do
      Routes.for_borough(:queens)
      |> Map.keys()
      |> Enum.each(fn key -> assert String.starts_with?(key, "Q") end)
    end

    test "all line references start with MTA NYCT_" do
      Routes.all()
      |> Map.values()
      |> Enum.each(fn ref -> assert String.starts_with?(ref, "MTA NYCT_") end)
    end
  end
end
