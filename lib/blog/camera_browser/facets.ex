defmodule Blog.CameraBrowser.Facets do
  @moduledoc """
  Slice-and-dice for the camera table. Facets are computed in memory over the
  current base result set (a few hundred rows at most), so every keystroke and
  every chip toggle re-counts instantly and the counts always reflect the other
  active filters: a facet's own selection is excluded when counting its values,
  the way a good product search does it.

  Within a facet, selections OR together; across facets they AND.
  """

  alias Blog.CameraBrowser.Listing

  @type value :: String.t()
  @type active :: %{atom() => [value()]}
  @type facet :: %{name: atom(), label: String.t(), values: [%{value: value(), label: String.t(), count: non_neg_integer(), on: boolean()}]}

  # Order matters: this is the order the rail shows them in.
  @facets [
    {:brand, "Brand"},
    {:format, "Format"},
    {:tags, "Read"},
    {:rarity, "Rarity"},
    {:price_take, "Price take"},
    {:condition, "Condition"},
    {:price, "Price"},
    {:photos, "Photos"},
    {:when, "Bumped"},
    {:contact, "Contact"}
  ]

  @brands ~w(leica hasselblad mamiya rolleiflex rollei contax nikon canon pentax olympus minolta yashica
             bronica fuji fujifilm konica ricoh voigtlander zeiss plaubel linhof graflex polaroid kodak minox
             holga lomo argus agfa exakta praktica petri miranda topcon chinon vivitar edixa)

  # brand aliases -> canonical
  @brand_alias %{"rolleiflex" => "rollei", "fujifilm" => "fuji", "leitz" => "leica"}

  @formats [
    {"35mm", ["35mm", "35 mm", "135 film"]},
    {"medium format", ["medium format", "120 film", "6x6", "6x7", "6x9", "6x4.5", "645", "rz67", "rb67", "hasselblad", "rolleiflex", "tlr"]},
    {"large format", ["large format", "4x5", "8x10", "sheet film", "graflex", "linhof"]},
    {"instant", ["instant", "polaroid", "instax", "sx-70", "land camera"]},
    {"rangefinder", ["rangefinder", "leica m", "contax g", "canonet"]},
    {"slr", ["slr"]},
    {"point & shoot", ["point and shoot", "point & shoot", "point-and-shoot", "compact", "stylus", "mju", "contax t2", "contax t3", "yashica t4", "gr1", "klasse"]},
    {"tlr", ["tlr", "rolleiflex", "rolleicord", "yashica mat", "c330"]}
  ]

  @spec names() :: [atom()]
  def names, do: Enum.map(@facets, &elem(&1, 0))

  @spec label(atom()) :: String.t()
  def label(name), do: @facets |> List.keyfind(name, 0) |> elem(1)

  # ---------------------------------------------------------------------------
  # Per-listing derived values
  # ---------------------------------------------------------------------------

  @doc "Values this listing has for a facet (a listing can have several formats or tags)."
  @spec values(Listing.t(), atom()) :: [value()]
  def values(l, :brand), do: brand(l) |> List.wrap()
  def values(l, :format), do: formats(l)
  def values(l, :tags), do: l.tags || []
  def values(l, :condition), do: (l.attrs["condition"] && [String.downcase(l.attrs["condition"])]) || []
  def values(l, :rarity), do: (l.analysis && l.analysis["rarity"] && [String.duplicate("★", l.analysis["rarity"])]) || []
  def values(l, :price_take), do: (l.analysis && l.analysis["price_take"] && [l.analysis["price_take"]]) || []
  def values(l, :price), do: [price_bucket(l.price_cents)]
  def values(l, :photos), do: [photo_bucket(length(l.image_ids || []))]
  def values(l, :when), do: [age_bucket(l.renewed_at || l.posted_at)]
  def values(l, :contact), do: if(map_size(l.contact || %{}) > 0, do: ["phone/email in post"], else: [])

  @doc "Brand from the seller's make attribute, else the first brand word in the title."
  @spec brand(Listing.t()) :: String.t() | nil
  def brand(l) do
    make = l.attrs["make / manufacturer"] || l.attrs["make"] || ""
    haystack = String.downcase(make <> " " <> (l.title || ""))

    Enum.find_value(@brands, fn b ->
      if Regex.match?(~r/(?<![a-z])#{Regex.escape(b)}(?![a-z])/, haystack), do: Map.get(@brand_alias, b, b)
    end)
  end

  defp formats(l) do
    text = String.downcase((l.title || "") <> " " <> (l.body || ""))

    for {name, needles} <- @formats,
        Enum.any?(needles, &String.contains?(text, &1)),
        do: name
  end

  defp price_bucket(nil), do: "no price"
  defp price_bucket(c) when c < 20_000, do: "under $200"
  defp price_bucket(c) when c < 50_000, do: "$200–500"
  defp price_bucket(c) when c < 100_000, do: "$500–1k"
  defp price_bucket(c) when c < 250_000, do: "$1k–2.5k"
  defp price_bucket(_), do: "$2.5k+"

  defp photo_bucket(0), do: "none"
  defp photo_bucket(n) when n <= 2, do: "1–2"
  defp photo_bucket(n) when n <= 5, do: "3–5"
  defp photo_bucket(_), do: "6+"

  defp age_bucket(nil), do: "unknown"

  defp age_bucket(dt) do
    days = DateTime.diff(DateTime.utc_now(), dt, :day)

    cond do
      days < 1 -> "today"
      days < 3 -> "3 days"
      days < 7 -> "this week"
      days < 30 -> "this month"
      true -> "older"
    end
  end

  # buckets have a natural order; everything else sorts by count
  @ordered %{
    price: ["under $200", "$200–500", "$500–1k", "$1k–2.5k", "$2.5k+", "no price"],
    photos: ["6+", "3–5", "1–2", "none"],
    when: ["today", "3 days", "this week", "this month", "older", "unknown"],
    condition: ["new", "like new", "excellent", "good", "fair", "salvage"],
    rarity: ["★★★★★", "★★★★", "★★★", "★★", "★"],
    price_take: ["steal", "fair", "high", "unclear"]
  }

  # ---------------------------------------------------------------------------
  # Apply + count
  # ---------------------------------------------------------------------------

  @doc "Keep rows matching every active facet (OR within a facet)."
  @spec filter([Listing.t()], active()) :: [Listing.t()]
  def filter(rows, active) do
    active = Enum.reject(active, fn {_, vs} -> vs == [] end)
    Enum.filter(rows, fn l -> Enum.all?(active, fn {name, vs} -> matches?(l, name, vs) end) end)
  end

  defp matches?(l, name, vs), do: Enum.any?(values(l, name), &(&1 in vs))

  @doc """
  Facets with counts. Each facet is counted over the rows that pass every
  *other* facet, so picking "leica" doesn't collapse the brand list to one.
  Values with zero rows are dropped unless currently selected.
  """
  @spec compute([Listing.t()], active()) :: [facet()]
  def compute(rows, active) do
    for {name, label} <- @facets do
      others = Map.delete(active, name)
      pool = filter(rows, others)
      selected = Map.get(active, name, [])

      counts =
        pool
        |> Enum.flat_map(&values(&1, name))
        |> Enum.frequencies()

      vals =
        counts
        |> Map.keys()
        |> Enum.concat(selected)
        |> Enum.uniq()
        |> Enum.map(fn v -> %{value: v, label: v, count: Map.get(counts, v, 0), on: v in selected} end)
        |> sort_values(name)
        |> Enum.take(if(name in [:brand, :tags], do: 18, else: 12))

      %{name: name, label: label, values: vals}
    end
    |> Enum.reject(&(&1.values == []))
  end

  defp sort_values(vals, name) do
    case Map.get(@ordered, name) do
      nil -> Enum.sort_by(vals, &{-&1.count, &1.value})
      order -> Enum.sort_by(vals, &(Enum.find_index(order, fn o -> o == &1.value end) || 99))
    end
  end

  # ---------------------------------------------------------------------------
  # URL <-> active
  # ---------------------------------------------------------------------------

  @doc "Read facet selections out of query params: `brand=leica,nikon&price=under+%24200`."
  @spec from_params(map()) :: active()
  def from_params(params) do
    for name <- names(), into: %{} do
      vs =
        case params[Atom.to_string(name)] do
          s when is_binary(s) and s != "" -> s |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
          _ -> []
        end

      {name, vs}
    end
  end

  @spec to_params(active()) :: map()
  def to_params(active) do
    for {name, vs} <- active, vs != [], into: %{}, do: {Atom.to_string(name), Enum.join(vs, ",")}
  end

  @doc "Flip one value in one facet."
  @spec toggle(active(), atom(), value()) :: active()
  def toggle(active, name, value) do
    current = Map.get(active, name, [])
    next = if value in current, do: List.delete(current, value), else: current ++ [value]
    Map.put(active, name, next)
  end

  @spec any?(active()) :: boolean()
  def any?(active), do: Enum.any?(active, fn {_, vs} -> vs != [] end)
end
