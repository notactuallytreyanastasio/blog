defmodule Blog.CameraBrowser.Craigslist do
  @moduledoc """
  A polite read-only client for Craigslist's own search API.

  Craigslist killed RSS in 2023 (the old `&format=rss` URL now returns a 403
  "blocked" page) and the search pages are a JS app, so the only cheap
  structured source is the JSON endpoint that app talks to:

      https://sapi.craigslist.org/web/v8/postings/search/full

  It returns up to 360 results per call as positional arrays plus a `decode`
  table of subareas/neighborhoods. Posting ids and timestamps are stored as
  offsets from `decode.minPostingId` / `decode.minPostedDate`. `search/2`
  turns all that back into plain maps.

  Post pages are still server-rendered HTML, so `fetch_post/1` scrapes the
  body, attribute list, image list, coords and posted/updated times. Contact
  info lives behind a JS-only reply endpoint with a captcha, so the best we
  can do is keep the reply URL and pull any phone/email the seller typed into
  the body.
  """

  require Logger

  @sapi "https://sapi.craigslist.org/web/v8/postings/search/full"
  @images "https://images.craigslist.org"

  @ua "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"

  # Craigslist "area" (the subdomain) -> numeric id the API wants in `batch`.
  @areas %{"sfbay" => 1, "seattle" => 2, "newyork" => 3, "portland" => 9}

  @type listing :: %{
          posting_id: integer(),
          area: String.t(),
          subarea: String.t() | nil,
          location: String.t() | nil,
          neighborhood: String.t() | nil,
          title: String.t(),
          price_cents: integer() | nil,
          posted_at: DateTime.t(),
          lat: float() | nil,
          lng: float() | nil,
          image_ids: [String.t()],
          url: String.t(),
          category_id: integer() | nil
        }

  @doc "Known areas and the numeric ids the API uses for them."
  @spec areas() :: %{String.t() => pos_integer()}
  def areas, do: @areas

  @doc """
  Search one Craigslist area. `area` is the subdomain ("sfbay", "newyork").

  Options (all mirror Craigslist's own search params):
    * `:category` - search path abbreviation, default "sss" (all for sale)
    * `:limit` - max results (API caps at 360), default 360
    * `:subareas` - if given, keep only these subarea codes ("sfc", "eby", ...)
    * `:has_pic` - only posts with photos
    * `:purveyor` - "owner" or "dealer"
    * `:min_price` / `:max_price` - whole dollars
    * `:lat`, `:lng`, `:radius` - search around a point (miles) instead of the whole area
  """
  @spec search(String.t(), String.t(), keyword()) :: {:ok, [listing()]} | {:error, term()}
  def search(area, query, opts \\ []) do
    with {:ok, area_id} <- Map.fetch(@areas, area) |> ok_or({:unknown_area, area}),
         limit = Keyword.get(opts, :limit, 360),
         params =
           [
             batch: "#{area_id}-0-#{limit}-0-0",
             cc: "US",
             lang: "en",
             query: query,
             searchPath: Keyword.get(opts, :category, "sss"),
             sort: "date"
           ] ++ extra_params(opts),
         {:ok, %{status: 200, body: %{"data" => data}}} <-
           Req.get(@sapi,
             params: params,
             headers: [{"user-agent", @ua}, {"referer", "https://#{area}.craigslist.org/"}],
             retry: false,
             receive_timeout: 20_000
           ) do
      listings =
        data
        |> decode_items(area)
        |> maybe_filter_subareas(Keyword.get(opts, :subareas))

      {:ok, listings}
    else
      {:ok, %{status: status}} -> {:error, {:http, status}}
      {:error, _} = err -> err
    end
  end

  defp extra_params(opts) do
    [
      hasPic: if(Keyword.get(opts, :has_pic), do: 1),
      purveyor: Keyword.get(opts, :purveyor),
      min_price: Keyword.get(opts, :min_price),
      max_price: Keyword.get(opts, :max_price),
      lat: Keyword.get(opts, :lat),
      lon: Keyword.get(opts, :lng),
      radius: Keyword.get(opts, :radius)
    ]
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
  end

  defp ok_or({:ok, v}, _), do: {:ok, v}
  defp ok_or(:error, reason), do: {:error, reason}

  defp maybe_filter_subareas(listings, nil), do: listings
  defp maybe_filter_subareas(listings, subs), do: Enum.filter(listings, &(&1.subarea in subs))

  @doc false
  # Each item is a positional array. Observed layout (10-12 elements):
  #   [id_offset, date_offset, category_id, price, "sub:loc[:hood]~lat~lng", hash,
  #    (optional -N flag), [13, view_token], [4, img...], [6, slug], [10, "$price"], title]
  # Tagged sub-arrays carry a small integer discriminator in slot 0, so we
  # locate them by tag instead of by position.
  def decode_items(%{"items" => items, "decode" => decode}, area) when is_map(decode) do
    min_id = decode["minPostingId"] || 0
    min_date = decode["minPostedDate"] || 0
    locations = decode["locations"] || []
    descriptions = decode["locationDescriptions"] || []
    hoods = decode["neighborhoods"] || []

    items
    |> Enum.map(fn item ->
      [id_off, date_off, category_id, price, loc | rest] = item
      title = List.last(item)
      tagged = Enum.filter(rest, &is_list/1)
      images = tagged |> find_tag(4) |> Enum.map(&strip_image_prefix/1)
      slug = tagged |> find_tag(6) |> List.first()
      view_token = tagged |> find_tag(13) |> List.first()
      {sub_idx, loc_idx, hood_idx, lat, lng} = parse_loc(loc)

      subarea =
        case Enum.at(locations, sub_idx || 0) do
          [_area_id, _area, sub] -> sub
          _ -> nil
        end

      posting_id = min_id + id_off

      %{
        posting_id: posting_id,
        area: area,
        subarea: subarea,
        location: loc_idx && Enum.at(descriptions, loc_idx),
        neighborhood: hood_idx && Enum.at(hoods, hood_idx),
        title: to_string(title),
        price_cents: price_to_cents(price),
        posted_at: DateTime.from_unix!(min_date + date_off),
        lat: lat,
        lng: lng,
        image_ids: images,
        category_id: category_id,
        url: post_url(area, subarea, slug, posting_id, view_token)
      }
    end)
  end

  # Zero-result responses come back with `"decode": 0` and no items.
  def decode_items(_data, _area), do: []

  defp find_tag(tagged, tag) do
    case Enum.find(tagged, &match?([^tag | _], &1)) do
      [_ | vals] -> vals
      nil -> []
    end
  end

  # "3:00a0a_jx892ZIFraf_0CI0qt" -> "00a0a_jx892ZIFraf_0CI0qt"
  defp strip_image_prefix(id) when is_binary(id) do
    case String.split(id, ":", parts: 2) do
      [_, short] -> short
      [short] -> short
    end
  end

  # "1:1~37.7751~-122.5001" or "2:2:1~37.78~-122.18" -> {sub, loc, hood, lat, lng}
  defp parse_loc(loc) when is_binary(loc) do
    {idxs, coords} =
      case String.split(loc, "~") do
        [idxs, lat, lng] -> {idxs, {to_float(lat), to_float(lng)}}
        [idxs] -> {idxs, {nil, nil}}
        _ -> {"", {nil, nil}}
      end

    ints = idxs |> String.split(":") |> Enum.map(&to_int/1)
    {lat, lng} = coords
    {Enum.at(ints, 0), Enum.at(ints, 1), Enum.at(ints, 2), lat, lng}
  end

  defp parse_loc(_), do: {nil, nil, nil, nil, nil}

  defp to_int(s), do: with({i, _} <- Integer.parse(s), do: i, else: (_ -> nil))
  defp to_float(s), do: with({f, _} <- Float.parse(s), do: f, else: (_ -> nil))

  defp price_to_cents(p) when is_integer(p), do: p * 100
  defp price_to_cents(p) when is_float(p), do: round(p * 100)
  defp price_to_cents(_), do: nil

  # Craigslist's canonical link is /view/d/<slug>/<token>. The classic
  # /<subarea>/<cat>/<id>.html form needs the category abbreviation, which the
  # search API only gives as a numeric id, so we only fall back to it blind.
  defp post_url(_area, _subarea, slug, _posting_id, token) when is_binary(token) do
    "https://www.craigslist.org/view/d/#{slug || "post"}/#{token}"
  end

  defp post_url(area, subarea, _slug, posting_id, _token) when is_binary(subarea) do
    "https://#{area}.craigslist.org/#{subarea}/sss/#{posting_id}.html"
  end

  defp post_url(area, _sub, _slug, posting_id, _token),
    do: "https://#{area}.craigslist.org/#{posting_id}.html"

  @doc "Image URL for a Craigslist image id at a given size (300x300, 600x450, 1200x900, 50x50c)."
  @spec image_url(String.t(), String.t()) :: String.t()
  def image_url(image_id, size \\ "600x450"), do: "#{@images}/#{image_id}_#{size}.jpg"

  @type post :: %{
          body: String.t() | nil,
          attrs: %{String.t() => String.t()},
          image_ids: [String.t()],
          posted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          lat: float() | nil,
          lng: float() | nil,
          reply_url: String.t() | nil,
          contact: %{optional(String.t()) => [String.t()]},
          title: String.t() | nil
        }

  @doc """
  Fetch and parse a post page. Returns `{:ok, post}`, `{:gone, reason}` when
  Craigslist says the post was deleted/expired/flagged (or 404s), or
  `{:error, term}` for anything that means "we could not look".
  """
  @spec fetch_post(String.t()) :: {:ok, post()} | {:gone, String.t()} | {:error, term()}
  def fetch_post(url) do
    case Req.get(url,
           headers: [{"user-agent", @ua}],
           retry: false,
           redirect: true,
           receive_timeout: 20_000
         ) do
      {:ok, %{status: 404}} -> {:gone, "404"}
      {:ok, %{status: 410}} -> {:gone, "410"}
      {:ok, %{status: 200, body: html}} when is_binary(html) -> parse_post(html)
      {:ok, %{status: status}} -> {:error, {:http, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  @gone_markers [
    {"This posting has been deleted by its author", "deleted"},
    {"This posting has expired", "expired"},
    {"This posting has been flagged for removal", "flagged"},
    {"This posting has been removed", "removed"}
  ]

  @doc false
  def parse_post(html) do
    case Enum.find(@gone_markers, fn {marker, _} -> String.contains?(html, marker) end) do
      {_, reason} ->
        {:gone, reason}

      nil ->
        doc = Floki.parse_document!(html)

        body =
          doc
          |> Floki.find("#postingbody")
          |> Floki.text(sep: "\n")
          |> String.replace("QR Code Link to This Post", "")
          |> String.split("\n")
          |> Enum.map(&String.trim/1)
          |> Enum.join("\n")
          |> String.replace(~r/\n{3,}/, "\n\n")
          |> String.trim()

        attrs =
          doc
          |> Floki.find(".attrgroup .attr")
          |> Enum.flat_map(fn attr ->
            label = attr |> Floki.find(".labl") |> Floki.text() |> String.trim_trailing(":") |> String.trim()
            value = attr |> Floki.find(".valu") |> Floki.text() |> String.trim()

            cond do
              label != "" and value != "" -> [{label, value}]
              # single-word attrs like "cryptocurrency ok" have no label/value split
              label == "" and String.trim(Floki.text(attr)) != "" -> [{String.trim(Floki.text(attr)), "yes"}]
              true -> []
            end
          end)
          |> Map.new()

        times =
          doc
          |> Floki.find("p.postinginfo time.date")
          |> Enum.map(&(Floki.attribute(&1, "datetime") |> List.first()))
          |> Enum.map(&parse_time/1)
          |> Enum.reject(&is_nil/1)

        {lat, lng} =
          case Floki.find(doc, "#map") do
            [] ->
              {nil, nil}

            [map | _] ->
              {Floki.attribute(map, "data-latitude") |> List.first() |> maybe_float(),
               Floki.attribute(map, "data-longitude") |> List.first() |> maybe_float()}
          end

        reply_url =
          case Regex.run(~r/reply-button[^>]*data-href="([^"]+)"/, html) do
            [_, href] -> String.replace(href, "/__SERVICE_ID__", "")
            _ -> nil
          end

        {:ok,
         %{
           title: doc |> Floki.find("#titletextonly") |> Floki.text() |> String.trim() |> blank_to_nil(),
           body: blank_to_nil(body),
           attrs: attrs,
           # imgList carries "imgid":"3:00a0a_xxx"; the "shortid" next to it drops
           # the width prefix that image URLs need, so we take imgid.
           image_ids:
             Regex.scan(~r/"imgid":"(?:\d+:)?([^"]+)"/, html)
             |> Enum.map(fn [_, id] -> id end)
             |> Enum.uniq(),
           posted_at: Enum.at(times, 0),
           updated_at: Enum.at(times, 1),
           lat: lat,
           lng: lng,
           reply_url: reply_url,
           contact: extract_contact(body)
         }}
    end
  end

  defp parse_time(nil), do: nil

  defp parse_time(iso) do
    case DateTime.from_iso8601(iso) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp maybe_float(nil), do: nil
  defp maybe_float(s), do: to_float(s)

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(s), do: s

  @phone ~r/(?:\+?1[\s.-]?)?\(?\b\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/
  @email ~r/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i

  @doc "Pull phone numbers and emails a seller typed into the body."
  @spec extract_contact(String.t() | nil) :: %{optional(String.t()) => [String.t()]}
  def extract_contact(nil), do: %{}

  def extract_contact(body) do
    phones = Regex.scan(@phone, body) |> List.flatten() |> Enum.map(&String.trim/1) |> Enum.uniq()
    emails = Regex.scan(@email, body) |> List.flatten() |> Enum.uniq()

    %{}
    |> put_nonempty("phones", phones)
    |> put_nonempty("emails", emails)
  end

  defp put_nonempty(map, _k, []), do: map
  defp put_nonempty(map, k, v), do: Map.put(map, k, v)

  @doc "Download one image; returns {:ok, binary, content_type} or error."
  @spec download_image(String.t(), String.t()) :: {:ok, binary(), String.t()} | {:error, term()}
  def download_image(image_id, size \\ "1200x900") do
    case Req.get(image_url(image_id, size), headers: [{"user-agent", @ua}], retry: false, decode_body: false) do
      {:ok, %{status: 200, body: bin, headers: headers}} ->
        ct = headers |> Map.get("content-type", ["image/jpeg"]) |> List.first()
        {:ok, bin, ct}

      {:ok, %{status: status}} ->
        {:error, {:http, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
