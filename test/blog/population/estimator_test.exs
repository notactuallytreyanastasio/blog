defmodule Blog.Population.EstimatorTest do
  use ExUnit.Case, async: true

  alias Blog.Population.Estimator

  describe "bct2020_to_geoid/1" do
    test "converts Manhattan borough code to FIPS" do
      assert Estimator.bct2020_to_geoid("1000100") == "061000100"
    end

    test "converts Bronx borough code to FIPS" do
      assert Estimator.bct2020_to_geoid("2003900") == "005003900"
    end

    test "converts Brooklyn borough code to FIPS" do
      assert Estimator.bct2020_to_geoid("3012300") == "047012300"
    end

    test "converts Queens borough code to FIPS" do
      assert Estimator.bct2020_to_geoid("4045600") == "081045600"
    end

    test "converts Staten Island borough code to FIPS" do
      assert Estimator.bct2020_to_geoid("5002100") == "085002100"
    end

    test "returns nil for nil input" do
      assert Estimator.bct2020_to_geoid(nil) == nil
    end

    test "returns nil for empty string" do
      assert Estimator.bct2020_to_geoid("") == nil
    end

    test "returns nil for single character (invalid borough)" do
      assert Estimator.bct2020_to_geoid("9") == nil
    end

    test "returns nil for unknown borough code" do
      assert Estimator.bct2020_to_geoid("6123456") == nil
    end

    test "handles two-character input" do
      # Borough 1 with tract "0"
      assert Estimator.bct2020_to_geoid("10") == "0610"
    end
  end

  describe "filter_in_polygon/2" do
    @polygon [[0.0, 0.0], [0.0, 10.0], [10.0, 10.0], [10.0, 0.0]]

    test "keeps lots inside the polygon" do
      lots = [
        %{latitude: 5.0, longitude: 5.0, id: 1},
        %{latitude: 15.0, longitude: 5.0, id: 2}
      ]

      result = Estimator.filter_in_polygon(lots, @polygon)

      assert length(result) == 1
      assert hd(result).id == 1
    end

    test "excludes lots with nil coordinates" do
      lots = [
        %{latitude: nil, longitude: 5.0, id: 1},
        %{latitude: 5.0, longitude: nil, id: 2},
        %{latitude: 5.0, longitude: 5.0, id: 3}
      ]

      result = Estimator.filter_in_polygon(lots, @polygon)

      assert length(result) == 1
      assert hd(result).id == 3
    end

    test "returns empty list when no lots are inside" do
      lots = [
        %{latitude: 15.0, longitude: 15.0, id: 1},
        %{latitude: -5.0, longitude: -5.0, id: 2}
      ]

      result = Estimator.filter_in_polygon(lots, @polygon)

      assert result == []
    end

    test "returns empty list for empty lots input" do
      assert Estimator.filter_in_polygon([], @polygon) == []
    end
  end
end
