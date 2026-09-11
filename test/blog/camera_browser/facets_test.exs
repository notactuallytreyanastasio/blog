defmodule Blog.CameraBrowser.FacetsTest do
  use ExUnit.Case, async: true

  alias Blog.CameraBrowser.{Facets, Listing}

  defp l(over) do
    struct(
      Listing,
      Map.merge(
        %{
          id: System.unique_integer([:positive]),
          title: "Nikon FM2",
          body: "35mm slr, works",
          attrs: %{"condition" => "excellent", "make / manufacturer" => "Nikon"},
          tags: ["film", "working"],
          price_cents: 30_000,
          image_ids: ["a", "b", "c"],
          contact: %{},
          renewed_at: DateTime.utc_now(),
          posted_at: DateTime.utc_now()
        },
        over
      )
    )
  end

  test "derives brand, formats and buckets" do
    x = l(%{})
    assert Facets.brand(x) == "nikon"
    assert "35mm" in Facets.values(x, :format) and "slr" in Facets.values(x, :format)
    assert Facets.values(x, :price) == ["$200–500"]
    assert Facets.values(x, :photos) == ["3–5"]
    assert Facets.values(x, :when) == ["today"]
    assert Facets.values(l(%{contact: %{"phones" => ["1"]}}), :contact) == ["phone/email in post"]
    assert Facets.brand(l(%{title: "Rolleiflex 2.8f", attrs: %{}})) == "rollei"
    assert Facets.brand(l(%{title: "old camera", attrs: %{}})) == nil
  end

  test "ORs within a facet, ANDs across, and counts exclude the facet's own selection" do
    rows = [
      l(%{title: "Leica M6", attrs: %{"condition" => "good"}}),
      l(%{title: "Leica M3", attrs: %{"condition" => "excellent"}}),
      l(%{title: "Nikon F3", attrs: %{"condition" => "excellent"}})
    ]

    active = %{brand: ["leica"], condition: ["excellent"]}
    assert [%{title: "Leica M3"}] = Facets.filter(rows, active)

    facets = Facets.compute(rows, active)
    brand = Enum.find(facets, &(&1.name == :brand))
    assert %{count: 1, on: true} = Enum.find(brand.values, &(&1.value == "leica"))
    assert %{count: 1, on: false} = Enum.find(brand.values, &(&1.value == "nikon"))

    cond_f = Enum.find(facets, &(&1.name == :condition))
    assert %{count: 1} = Enum.find(cond_f.values, &(&1.value == "good"))
    assert %{count: 1, on: true} = Enum.find(cond_f.values, &(&1.value == "excellent"))

    assert length(Facets.filter(rows, %{brand: ["leica", "nikon"], condition: ["good", "excellent"]})) == 3
  end

  test "round-trips through URL params and toggles" do
    active = %{brand: ["leica", "nikon"], price: ["under $200"]}
    params = Facets.to_params(active)
    assert params == %{"brand" => "leica,nikon", "price" => "under $200"}
    back = Facets.from_params(params)
    assert back.brand == ["leica", "nikon"] and back.price == ["under $200"] and back.tags == []
    assert Facets.toggle(back, :brand, "nikon").brand == ["leica"]
    assert Facets.toggle(back, :tags, "film").tags == ["film"]
    assert Facets.any?(back) and not Facets.any?(Facets.from_params(%{}))
  end
end
