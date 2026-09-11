defmodule Blog.CameraBrowser do
  @moduledoc """
  The camera browser: a standing set of film-camera searches run against
  Craigslist every 15 minutes, with every hit kept — full post, photos, contact
  hints — from the hour we first see it until Craigslist says it's gone.

  The point isn't to mirror Craigslist. It's to see the *best of* what's live
  across a few cities at once, score each post on whether it smells like a
  working film camera or a hopeful estate lot, and then let us filter, star
  and hide with our own opinions layered on top.

  Lifecycle of a listing:

    1. `poll/0` runs every search in every area and upserts what it finds
       (`first_seen_at` / `last_seen_at`, and the search date as `renewed_at`).
    2. New listings get their post page fetched for body, attributes, all
       image ids, coords and any phone/email the seller typed. Photos are
       optionally mirrored to object storage so they outlive the post. Then
       `Analyst` asks OpenAI for a collector's read on anything not yet analyzed.
    3. Open listings that didn't show up in this sweep get their page checked
       directly. Craigslist says deleted/expired/flagged (or 404s) -> closed.
       Anything else -> still open, just fell out of the search window.
  """

  import Ecto.Query
  require Logger

  alias Blog.CameraBrowser.{Craigslist, Listing}
  alias Blog.Repo

  # area -> subareas we care about. "eby" is Craigslist's East Bay bucket,
  # which is where Oakland lives; there is no Oakland-only subarea. The NYC
  # search covers the whole newyork area and keeps the four boroughs.
  @cities %{
    "sfbay" => ["sfc", "eby"],
    "newyork" => ["mnh", "brk", "que", "brx"],
    "seattle" => ["see", "est"],
    "portland" => ["mlt", "wsc", "clc", "clk"]
  }

  # One search per entry. Generic terms catch the "old camera in a box" posts;
  # model names catch the ones where the seller knows what they have.
  @searches [
    "film camera", "35mm camera", "rangefinder camera", "medium format camera",
    "leica m6", "leica m3", "leica m2", "leica m4", "leica mp", "leica m-a", "leica iiif",
    "hasselblad 500", "hasselblad 503", "hasselblad swc",
    "mamiya 7", "mamiya 6", "mamiya rz67", "mamiya rb67", "mamiya 645", "mamiya c330",
    "rolleiflex", "rolleicord",
    "contax t2", "contax t3", "contax g1", "contax g2", "contax 645",
    "nikon f2", "nikon f3", "nikon fm2", "nikon fe2", "nikon fm3a", "nikon f100", "nikon f6", "nikon 28ti", "nikon 35ti",
    "canon ae-1", "canon a-1", "canon f-1", "canonet", "canon p rangefinder",
    "pentax k1000", "pentax 67", "pentax 645", "pentax spotmatic", "pentax lx", "pentax mx",
    "olympus om-1", "olympus om-2", "olympus om-4", "olympus xa", "olympus stylus epic", "olympus mju",
    "minolta x-700", "minolta srt", "minolta cle", "minolta tc-1",
    "yashica mat", "yashica t4", "yashica electro",
    "bronica", "fuji gw690", "fuji ga645", "fujifilm klasse", "fuji natura",
    "konica hexar", "ricoh gr1", "voigtlander bessa", "zeiss ikon",
    "plaubel makina", "linhof", "graflex speed graphic",
    "polaroid sx-70", "polaroid 600", "polaroid land camera",
    "kodak retina", "minox", "holga"
  ]

  # Craigslist-side filters applied to every search: by-owner, with photos,
  # and nothing under $100 (that floor alone removes most of the junk).
  @search_opts [has_pic: true, purveyor: "owner", min_price: 100]

  @detail_fetch_cap 80
  @between_requests_ms 600

  @spec cities() :: %{String.t() => [String.t()]}
  def cities, do: @cities

  @spec searches() :: [String.t()]
  def searches, do: @searches

  @spec search_opts() :: keyword()
  def search_opts, do: @search_opts

  # ---------------------------------------------------------------------------
  # Polling
  # ---------------------------------------------------------------------------

  @doc """
  One full sweep: search, upsert, fetch details for new posts, close what's
  gone. Returns a summary map. Safe to call by hand for the initial seed.
  """
  @spec poll(keyword()) :: map()
  def poll(opts \\ []) do
    started = DateTime.utc_now() |> DateTime.truncate(:second)
    searches = Keyword.get(opts, :searches, @searches)
    cities = Keyword.get(opts, :cities, @cities)

    {seen_ids, errors} =
      for {area, subareas} <- cities, query <- searches, reduce: {MapSet.new(), 0} do
        {seen, errs} ->
          Process.sleep(@between_requests_ms)

          case Craigslist.search(area, query, [subareas: subareas] ++ @search_opts) do
            {:ok, listings} ->
              ids = Enum.map(listings, &upsert_from_search(&1, query, started))
              {Enum.reduce(ids, seen, &MapSet.put(&2, &1)), errs}

            {:error, reason} ->
              Logger.warning("camera browser: search #{area} #{inspect(query)} failed: #{inspect(reason)}")
              {seen, errs + 1}
          end
      end

    fetched = fetch_missing_details(Keyword.get(opts, :detail_cap, @detail_fetch_cap))
    analyzed = Blog.CameraBrowser.Analyst.analyze_missing(Keyword.get(opts, :analyze_cap, 200))

    # Refuse to close anything if the sweep itself looked broken: if most
    # searches errored we did not look, and "not seen" means nothing.
    total_searches = map_size(cities) * length(searches)
    closed = if errors < total_searches / 2, do: close_unseen(started), else: 0

    summary = %{
      seen: MapSet.size(seen_ids),
      detail_fetched: fetched,
      analyzed: analyzed,
      closed: closed,
      search_errors: errors,
      started_at: started
    }

    Logger.info("camera browser poll: #{inspect(summary)}")
    Phoenix.PubSub.broadcast(Blog.PubSub, "camera_browser", {:camera_browser_polled, summary})
    summary
  end

  defp upsert_from_search(l, query, now) do
    existing = Repo.get_by(Listing, posting_id: l.posting_id)

    attrs = %{
      posting_id: l.posting_id,
      area: l.area,
      subarea: l.subarea,
      location: l.location,
      neighborhood: l.neighborhood,
      title: l.title,
      price_cents: l.price_cents,
      url: l.url,
      lat: l.lat,
      lng: l.lng,
      category_id: l.category_id,
      renewed_at: l.posted_at,
      last_seen_at: now,
      # a post that comes back to the search after we closed it was renewed
      closed_at: nil,
      closed_reason: nil
    }

    attrs =
      case existing do
        nil ->
          attrs
          |> Map.put(:first_seen_at, now)
          |> Map.put(:posted_at, l.posted_at)
          |> Map.put(:image_ids, l.image_ids)
          |> Map.put(:queries, [query])
          |> Map.merge(classify(l.title, nil, %{}, [query], l.image_ids))

        %Listing{} = e ->
          queries = Enum.uniq(e.queries ++ [query])

          attrs
          |> Map.put(:queries, queries)
          |> Map.put(:image_ids, if(e.image_ids == [], do: l.image_ids, else: e.image_ids))
          |> Map.merge(classify(e.title, e.body, e.attrs, queries, e.image_ids))
      end

    (existing || %Listing{})
    |> Listing.changeset(attrs)
    |> Repo.insert_or_update!()
    |> Map.fetch!(:posting_id)
  end

  @doc "Fetch full post pages for listings that don't have one yet, up to `cap`."
  @spec fetch_missing_details(pos_integer()) :: non_neg_integer()
  def fetch_missing_details(cap \\ @detail_fetch_cap) do
    Listing
    |> where([l], is_nil(l.detail_fetched_at) and is_nil(l.closed_at))
    |> order_by([l], desc: l.score, desc: l.renewed_at)
    |> limit(^cap)
    |> Repo.all()
    |> Enum.count(fn listing ->
      Process.sleep(@between_requests_ms)
      match?({:ok, _}, fetch_detail(listing))
    end)
  end

  @doc "Fetch and store one listing's post page. Marks it closed if Craigslist says so."
  @spec fetch_detail(Listing.t()) :: {:ok, Listing.t()} | {:gone, Listing.t()} | {:error, term()}
  def fetch_detail(%Listing{} = listing) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case Craigslist.fetch_post(listing.url) do
      {:ok, post} ->
        image_ids = if post.image_ids == [], do: listing.image_ids, else: post.image_ids
        queries = listing.queries

        attrs =
          %{
            title: post.title || listing.title,
            body: post.body,
            attrs: post.attrs,
            image_ids: image_ids,
            reply_url: post.reply_url,
            contact: post.contact,
            posted_at: post.posted_at || listing.posted_at,
            cl_updated_at: post.updated_at,
            lat: post.lat || listing.lat,
            lng: post.lng || listing.lng,
            detail_fetched_at: now,
            mirrored_images: mirror_images(listing.posting_id, image_ids)
          }
          |> Map.merge(classify(post.title || listing.title, post.body, post.attrs, queries, image_ids))

        {:ok, listing |> Listing.changeset(attrs) |> Repo.update!()}

      {:gone, reason} ->
        {:gone, close(listing, reason, now)}

      {:error, reason} ->
        Logger.warning("camera browser: detail #{listing.posting_id} failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Open listings that this sweep didn't touch: ask Craigslist directly.
  defp close_unseen(sweep_started) do
    Listing
    |> where([l], is_nil(l.closed_at) and l.last_seen_at < ^sweep_started)
    |> order_by([l], asc: l.last_seen_at)
    |> limit(150)
    |> Repo.all()
    |> Enum.count(fn listing ->
      Process.sleep(@between_requests_ms)
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      case Craigslist.fetch_post(listing.url) do
        {:gone, reason} ->
          close(listing, reason, now)
          true

        {:ok, _post} ->
          listing |> Listing.changeset(%{last_seen_at: now}) |> Repo.update!()
          false

        {:error, _} ->
          false
      end
    end)
  end

  defp close(listing, reason, now) do
    listing
    |> Listing.changeset(%{closed_at: now, closed_reason: reason})
    |> Repo.update!()
  end

  # Photos vanish with the post. When object storage is configured, keep a
  # 1200x900 copy of each so a closed listing still shows what it was.
  defp mirror_images(posting_id, image_ids) do
    if mirror_images?() do
      image_ids
      |> Enum.take(24)
      |> Enum.flat_map(fn id ->
        key = "camera-browser/#{posting_id}/#{id}.jpg"

        with {:ok, bin, ct} <- Craigslist.download_image(id),
             {:ok, _} <- Blog.Storage.upload(key, bin, content_type: ct) do
          [key]
        else
          _ -> []
        end
      end)
    else
      []
    end
  end

  defp mirror_images? do
    Application.get_env(:blog, :camera_browser, []) |> Keyword.get(:mirror_images, false) and
      Application.get_env(:ex_aws, :access_key_id) != nil
  end

  # ---------------------------------------------------------------------------
  # Classification: what does this post smell like?
  # ---------------------------------------------------------------------------

  @film_signals ["film", "35mm", "120 film", "220 film", "medium format", "rangefinder", "large format",
                 "sheet film", "instant film", "polaroid", "roll of film", "rolls of film"]
  @digital_signals ["digital", "mirrorless", "dslr", "megapixel", "4k video", "cmos", "sd card", "micro four thirds",
                    "eos r", "sony a7", "x-t", "x100", "z6", "z7", "d850", "d750", "5d mark"]
  @working_signals ["works perfectly", "works great", "works fine", "works well", "working", "fully functional",
                    "tested", "film tested", "serviced", "cla", "cla'd", "cla’d", "overhauled", "meter works",
                    "shutter speeds accurate", "just serviced", "recently serviced", "light seals replaced",
                    "new seals", "new light seals", "good working"]
  @hopeful_signals ["untested", "not tested", "haven't tested", "havent tested", "never tested", "as-is", "as is",
                    "no idea", "don't know", "dont know", "not sure", "estate", "grandfather", "grandpa",
                    "grandmother", "attic", "basement", "garage sale", "unknown condition", "can't test",
                    "cannot test", "no battery to test"]
  @lot_signals ["lot of", "camera lot", "collection", "bundle", "estate", "several cameras", "bunch of", "assorted",
                "multiple cameras"]
  @broken_signals ["broken", "doesn't work", "does not work", "not working", "needs repair", "for parts", "parts only",
                   "stuck shutter", "shutter stuck", "fungus", "haze", "light leak", "light leaks", "needs cla",
                   "needs service", "sticky"]
  @accessory_words ["lens", "lenses", "strap", "bag", "case", "flash", "tripod", "manual", "battery", "charger",
                    "filter", "filters", "adapter", "mount", "hood", "cap", "grip", "backpack", "enlarger",
                    "scanner", "darkroom", "film only", "expired film", "viewfinder", "finder", "prism", "knob",
                    "film back", "magazine", "cable release", "focusing screen", "eyepiece", "winder", "motor drive"]
  # A title with an accessory word is still a camera if it also says so.
  @camera_words ["camera body", "film camera", "slr", "rangefinder", "kit", "outfit", "w/", "with ", "+", "and lens",
                 "body", "set"]

  @doc """
  Tags and a 0-100ish score for a post from its title, body and attributes.
  Cheap keyword heuristics, tuned for "is this an interesting film camera".
  """
  @spec classify(String.t(), String.t() | nil, map(), [String.t()], [String.t()]) :: %{
          tags: [String.t()],
          score: integer()
        }
  def classify(title, body, attrs, queries, image_ids) do
    title_d = String.downcase(title || "")
    text = String.downcase(Enum.join([title || "", body || "", attrs_text(attrs)], "\n"))

    film? = any?(text, @film_signals) or any_model_query?(queries)
    digital? = any?(text, @digital_signals) and not any?(text, ["film"])
    working? = any?(text, @working_signals)
    hopeful? = any?(text, @hopeful_signals)
    lot? = any?(text, @lot_signals)
    broken? = any?(text, @broken_signals)

    # "Nikon FM2 with 50mm lens" is a camera; "Nikon camera strap" is not.
    accessory? =
      any?(title_d, @accessory_words) and not any?(title_d, @camera_words) and
        (not String.contains?(title_d, "camera") or
           Regex.match?(~r/camera (strap|bag|case|lens cap|cap|flash|tripod|manual|battery|charger|filter|adapter|mount|hood|grip|backpack|back)\b/, title_d))

    model_tags =
      queries
      |> Enum.filter(&any_model_query?([&1]))
      |> Enum.filter(&String.contains?(title_d, String.downcase(&1)))

    tags =
      Enum.reject(
        [
          film? && "film",
          digital? && "not film?",
          working? && "working",
          hopeful? && "hopeful",
          lot? && "lot",
          broken? && "needs work",
          accessory? && "accessory"
        ] ++ model_tags,
        &(&1 == false)
      )

    n_images = length(image_ids)

    score =
      50 +
        if(film?, do: 20, else: 0) +
        if(digital?, do: -40, else: 0) +
        if(working?, do: 15, else: 0) +
        if(hopeful?, do: 8, else: 0) +
        if(lot?, do: 10, else: 0) +
        if(broken?, do: -8, else: 0) +
        if(accessory?, do: -30, else: 0) +
        if(model_tags != [], do: 12, else: 0) +
        condition_bonus(attrs) +
        cond do
          n_images == 0 -> -15
          n_images >= 4 -> 5
          true -> 0
        end

    %{tags: tags, score: score}
  end

  @doc "Re-run the classifier over every stored listing (after tuning the heuristics)."
  @spec reclassify_all() :: non_neg_integer()
  def reclassify_all do
    Listing
    |> Repo.all()
    |> Enum.count(fn l ->
      l
      |> Listing.changeset(classify(l.title, l.body, l.attrs, l.queries, l.image_ids))
      |> Repo.update!()
      true
    end)
  end

  defp attrs_text(attrs) when is_map(attrs), do: attrs |> Enum.map(fn {k, v} -> "#{k}: #{v}" end) |> Enum.join("\n")
  defp attrs_text(_), do: ""

  # Whole-word matching, so "cla" doesn't fire on "class" or "tested" on "untested".
  defp any?(text, needles) do
    Enum.any?(needles, fn n -> Regex.match?(~r/(?<![a-z0-9])#{Regex.escape(n)}(?![a-z0-9])/, text) end)
  end

  @generic_queries ["film camera", "35mm camera", "rangefinder camera", "medium format camera"]
  defp any_model_query?(queries), do: Enum.any?(queries, &(&1 not in @generic_queries))

  defp condition_bonus(%{"condition" => c}) do
    case String.downcase(c) do
      "new" -> 5
      "like new" -> 8
      "excellent" -> 8
      "good" -> 4
      "fair" -> 0
      "salvage" -> -10
      _ -> 0
    end
  end

  defp condition_bonus(_), do: 0

  # ---------------------------------------------------------------------------
  # Reads
  # ---------------------------------------------------------------------------

  @type filters :: %{
          optional(:status) => :open | :closed | :all,
          optional(:city) => String.t() | nil,
          optional(:q) => String.t() | nil,
          optional(:max_price) => integer() | nil,
          optional(:min_price) => integer() | nil,
          optional(:show_hidden) => boolean(),
          optional(:starred) => boolean(),
          optional(:sort) => :best | :newest | :price_asc | :price_desc,
          optional(:limit) => pos_integer()
        }

  # Words that disqualify a post outright, wherever they appear. Digital
  # cameras keep leaking in through "film" in the body ("no film, digital only").
  @banned_words ["digital"]

  defp visible(query) do
    Enum.reduce(@banned_words, query, fn w, q ->
      pattern = "%#{w}%"
      where(q, [l], not ilike(l.title, ^pattern) and (is_nil(l.body) or not ilike(l.body, ^pattern)))
    end)
  end

  @spec list_listings(filters()) :: [Listing.t()]
  def list_listings(filters \\ %{}) do
    Listing
    |> visible()
    |> filter_status(Map.get(filters, :status, :open))
    |> filter_city(Map.get(filters, :city))
    |> filter_query(Map.get(filters, :q))
    |> filter_price(Map.get(filters, :min_price), Map.get(filters, :max_price))
    |> filter_hidden(Map.get(filters, :show_hidden, false))
    |> filter_starred(Map.get(filters, :starred, false))
    |> sort(Map.get(filters, :sort, :best))
    |> limit(^Map.get(filters, :limit, 500))
    |> Repo.all()
  end

  @doc """
  Sellers re-post the same camera under a dozen posting ids. Keep the first
  (best-sorted) of each title+price and remember how many it stood for. Run
  this after faceting so counts still reflect every post.
  """
  @spec collapse_dupes([Listing.t()]) :: [Listing.t()]
  def collapse_dupes(listings) do
    listings
    |> Enum.group_by(&dupe_key/1)
    |> Map.values()
    |> Enum.map(fn [first | rest] -> %{first | dupe_count: 1 + length(rest)} end)
    |> Enum.sort_by(&Enum.find_index(listings, fn l -> l.id == &1.id end))
  end

  defp dupe_key(l) do
    title = l.title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, " ") |> String.trim()
    {title, l.price_cents}
  end

  defp filter_status(q, :open), do: where(q, [l], is_nil(l.closed_at))
  defp filter_status(q, :closed), do: where(q, [l], not is_nil(l.closed_at))
  defp filter_status(q, _), do: q

  defp filter_city(q, nil), do: q
  defp filter_city(q, ""), do: q
  defp filter_city(q, "nyc"), do: where(q, [l], l.area == "newyork")
  defp filter_city(q, "bay"), do: where(q, [l], l.area == "sfbay")
  defp filter_city(q, "sea"), do: where(q, [l], l.area == "seattle")
  defp filter_city(q, "pdx"), do: where(q, [l], l.area == "portland")
  defp filter_city(q, sub), do: where(q, [l], l.subarea == ^sub)

  defp filter_query(q, nil), do: q
  defp filter_query(q, ""), do: q

  defp filter_query(q, text) do
    pattern = "%#{String.replace(text, ~r/[%_]/, "")}%"
    where(q, [l], ilike(l.title, ^pattern) or ilike(l.body, ^pattern))
  end

  defp filter_price(q, nil, nil), do: q
  defp filter_price(q, min, nil), do: where(q, [l], l.price_cents >= ^min)
  defp filter_price(q, nil, max), do: where(q, [l], l.price_cents <= ^max)
  defp filter_price(q, min, max), do: where(q, [l], l.price_cents >= ^min and l.price_cents <= ^max)

  defp filter_hidden(q, true), do: q
  defp filter_hidden(q, false), do: where(q, [l], is_nil(l.hidden_at))

  defp filter_starred(q, true), do: where(q, [l], not is_nil(l.starred_at))
  defp filter_starred(q, false), do: q

  defp sort(q, :newest), do: order_by(q, [l], desc_nulls_last: l.renewed_at, desc: l.id)
  defp sort(q, :price_asc), do: order_by(q, [l], asc_nulls_last: l.price_cents, desc: l.score)
  defp sort(q, :price_desc), do: order_by(q, [l], desc_nulls_last: l.price_cents, desc: l.score)
  defp sort(q, _best), do: order_by(q, [l], desc: l.score, desc_nulls_last: l.renewed_at)

  @spec get_listing!(integer()) :: Listing.t()
  def get_listing!(id), do: Repo.get!(Listing, id)

  @spec get_listing(integer()) :: Listing.t() | nil
  def get_listing(id), do: Repo.get(Listing, id)

  @doc "Counts for the header: open, closed, starred, last poll time."
  @spec stats() :: map()
  def stats do
    base = visible(Listing)

    %{
      open: Repo.aggregate(where(base, [l], is_nil(l.closed_at) and is_nil(l.hidden_at)), :count),
      closed: Repo.aggregate(where(base, [l], not is_nil(l.closed_at)), :count),
      starred: Repo.aggregate(where(base, [l], not is_nil(l.starred_at)), :count),
      last_seen: Repo.aggregate(Listing, :max, :last_seen_at)
    }
  end

  @doc "Tags in use among open listings, with counts."
  @spec tag_counts() :: [{String.t(), non_neg_integer()}]
  def tag_counts do
    Listing
    |> visible()
    |> where([l], is_nil(l.closed_at) and is_nil(l.hidden_at))
    |> select([l], l.tags)
    |> Repo.all()
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.sort_by(fn {t, n} -> {-n, t} end)
  end

  # ---------------------------------------------------------------------------
  # Curation
  # ---------------------------------------------------------------------------

  @spec toggle_star(Listing.t()) :: Listing.t()
  def toggle_star(%Listing{starred_at: nil} = l), do: set(l, starred_at: now())
  def toggle_star(%Listing{} = l), do: set(l, starred_at: nil)

  @spec toggle_hidden(Listing.t()) :: Listing.t()
  def toggle_hidden(%Listing{hidden_at: nil} = l), do: set(l, hidden_at: now())
  def toggle_hidden(%Listing{} = l), do: set(l, hidden_at: nil)

  @spec set_note(Listing.t(), String.t() | nil) :: Listing.t()
  def set_note(%Listing{} = l, note), do: set(l, note: note)

  defp set(listing, changes) do
    listing |> Listing.changeset(Map.new(changes)) |> Repo.update!()
  end

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  @doc "Image URLs for a listing: mirrored copies when we have them, else Craigslist's."
  @spec image_urls(Listing.t(), String.t()) :: [String.t()]
  def image_urls(%Listing{mirrored_images: [_ | _] = keys}, _size), do: Enum.map(keys, &Blog.Storage.url/1)
  def image_urls(%Listing{image_ids: ids}, size), do: Enum.map(ids, &Craigslist.image_url(&1, size))

  @spec thumb_url(Listing.t()) :: String.t() | nil
  def thumb_url(%Listing{image_ids: [id | _]}), do: Craigslist.image_url(id, "300x300")
  def thumb_url(_), do: nil
end
