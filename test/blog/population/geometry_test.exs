defmodule Blog.Population.GeometryTest do
  use ExUnit.Case, async: true

  alias Blog.Population.Geometry

  describe "bounding_box/1" do
    test "computes correct bounding box for a rectangle" do
      polygon = [[40.0, -74.0], [40.0, -73.0], [41.0, -73.0], [41.0, -74.0]]

      assert Geometry.bounding_box(polygon) == {40.0, 41.0, -74.0, -73.0}
    end

    test "computes correct bounding box for a triangle" do
      polygon = [[40.0, -74.0], [41.0, -73.5], [40.5, -73.0]]

      assert Geometry.bounding_box(polygon) == {40.0, 41.0, -74.0, -73.0}
    end

    test "handles polygon with single point" do
      polygon = [[40.7, -73.9]]

      assert Geometry.bounding_box(polygon) == {40.7, 40.7, -73.9, -73.9}
    end

    test "handles polygon with negative coordinates" do
      polygon = [[-10.0, -20.0], [-5.0, -15.0], [-8.0, -10.0]]

      assert Geometry.bounding_box(polygon) == {-10.0, -5.0, -20.0, -10.0}
    end
  end

  describe "point_in_polygon?/2" do
    # Simple square: (0,0), (0,10), (10,10), (10,0)
    @square [[0.0, 0.0], [0.0, 10.0], [10.0, 10.0], [10.0, 0.0]]

    test "returns true for point inside a square" do
      assert Geometry.point_in_polygon?({5.0, 5.0}, @square)
    end

    test "returns false for point outside a square" do
      refute Geometry.point_in_polygon?({15.0, 5.0}, @square)
    end

    test "returns false for point far outside" do
      refute Geometry.point_in_polygon?({100.0, 100.0}, @square)
    end

    test "returns true for point near a corner but inside" do
      assert Geometry.point_in_polygon?({0.1, 0.1}, @square)
    end

    test "returns false for point just outside" do
      refute Geometry.point_in_polygon?({-0.1, 5.0}, @square)
    end

    test "works with a triangle" do
      triangle = [[0.0, 0.0], [10.0, 5.0], [0.0, 10.0]]

      # Point clearly inside the triangle
      assert Geometry.point_in_polygon?({3.0, 5.0}, triangle)

      # Point clearly outside
      refute Geometry.point_in_polygon?({8.0, 1.0}, triangle)
    end

    test "works with an irregular polygon" do
      # L-shaped polygon
      polygon = [
        [0.0, 0.0],
        [0.0, 10.0],
        [5.0, 10.0],
        [5.0, 5.0],
        [10.0, 5.0],
        [10.0, 0.0]
      ]

      # Inside the bottom part of the L
      assert Geometry.point_in_polygon?({7.0, 2.5}, polygon)

      # Inside the left part of the L
      assert Geometry.point_in_polygon?({2.5, 7.5}, polygon)

      # In the "missing" upper-right corner
      refute Geometry.point_in_polygon?({7.0, 7.5}, polygon)
    end

    test "works with NYC-like coordinates" do
      # Rough polygon around lower Manhattan
      polygon = [
        [40.700, -74.020],
        [40.700, -73.990],
        [40.720, -73.990],
        [40.720, -74.020]
      ]

      # Point inside
      assert Geometry.point_in_polygon?({40.710, -74.005}, polygon)

      # Point outside (Brooklyn)
      refute Geometry.point_in_polygon?({40.680, -73.970}, polygon)
    end
  end
end
