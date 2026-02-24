defmodule Blog.Pluto.ParserTest do
  use ExUnit.Case, async: true

  alias Blog.Pluto.Parser

  describe "parse_int/1" do
    test "returns 0 for nil" do
      assert Parser.parse_int(nil) == 0
    end

    test "returns 0 for empty string" do
      assert Parser.parse_int("") == 0
    end

    test "parses a simple integer string" do
      assert Parser.parse_int("42") == 42
    end

    test "parses comma-formatted numbers" do
      assert Parser.parse_int("1,000") == 1000
      assert Parser.parse_int("1,234,567") == 1_234_567
    end

    test "returns 0 for non-numeric strings" do
      assert Parser.parse_int("abc") == 0
    end

    test "parses strings with trailing non-numeric characters" do
      assert Parser.parse_int("42abc") == 42
    end
  end

  describe "parse_float/1" do
    test "returns 0.0 for nil" do
      assert Parser.parse_float(nil) == 0.0
    end

    test "returns 0.0 for empty string" do
      assert Parser.parse_float("") == 0.0
    end

    test "parses a simple float string" do
      assert Parser.parse_float("3.14") == 3.14
    end

    test "parses integer strings as float" do
      assert Parser.parse_float("42") == 42.0
    end

    test "parses comma-formatted floats" do
      assert Parser.parse_float("1,000.5") == 1000.5
    end

    test "returns 0.0 for non-numeric strings" do
      assert Parser.parse_float("abc") == 0.0
    end
  end

  describe "parse_row/1" do
    test "parses a valid row with coordinates" do
      row = %{
        "latitude" => "40.7128",
        "longitude" => "-74.0060",
        "BBL" => "1000010001",
        "borough" => "MN",
        "Tax block" => "00001",
        "Tax lot" => "0001",
        "address" => "1 BROADWAY",
        "unitsres" => "100",
        "bct2020" => "1000100",
        "bldgclass" => "O5",
        "landuse" => "05",
        "numfloors" => "10",
        "yearbuilt" => "1920",
        "resarea" => "50000"
      }

      result = Parser.parse_row(row)

      assert result.bbl == "1000010001"
      assert result.borough == "MN"
      assert result.block == "00001"
      assert result.lot == "0001"
      assert result.address == "1 BROADWAY"
      assert_in_delta result.latitude, 40.7128, 0.0001
      assert_in_delta result.longitude, -74.0060, 0.0001
      assert result.units_res == 100
      assert result.bct2020 == "1000100"
      assert result.bldg_class == "O5"
      assert result.land_use == "05"
      assert result.num_floors == 10.0
      assert result.year_built == 1920
      assert result.res_area == 50_000
    end

    test "returns :skip when latitude is missing" do
      row = %{"latitude" => nil, "longitude" => "-74.0060"}

      assert Parser.parse_row(row) == :skip
    end

    test "returns :skip when longitude is missing" do
      row = %{"latitude" => "40.7128", "longitude" => nil}

      assert Parser.parse_row(row) == :skip
    end

    test "returns :skip when latitude is not a valid float" do
      row = %{"latitude" => "not_a_number", "longitude" => "-74.0060"}

      assert Parser.parse_row(row) == :skip
    end

    test "defaults missing string fields to empty string" do
      row = %{
        "latitude" => "40.7128",
        "longitude" => "-74.0060"
      }

      result = Parser.parse_row(row)

      assert result.bbl == ""
      assert result.borough == ""
      assert result.address == ""
    end

    test "defaults missing numeric fields to zero" do
      row = %{
        "latitude" => "40.7128",
        "longitude" => "-74.0060"
      }

      result = Parser.parse_row(row)

      assert result.units_res == 0
      assert result.year_built == 0
      assert result.res_area == 0
      assert result.num_floors == 0.0
    end
  end
end
