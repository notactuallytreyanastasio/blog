defmodule BlogWeb.CameraBrowserLive do
  @moduledoc """
  The camera browser: every film camera live on Craigslist in SF, the East Bay
  and NYC, in one dense table. Thumb, title, where, price, when, and what we
  think it is. Click a row for the photos in a lightbox with the full post,
  attributes and contact underneath.

  Filters are in the URL so a view is shareable: city, tag, text, price,
  status (open/closed/all), sort. Star and hide are ours and stick.
  """
  use BlogWeb, :live_view

  alias Blog.CameraBrowser
  alias Blog.CameraBrowser.{Analyst, Facets, Listing}

  # Top-level tabs, each with the sub-city chips shown under it. The tab's own
  # value is what "all of this region" filters on.
  @tabs [
    {"nyc", "NYC", [{"mnh", "Manhattan"}, {"brk", "Brooklyn"}, {"que", "Queens"}, {"brx", "Bronx"}]},
    {"bay", "SF / East Bay", [{"sfc", "San Francisco"}, {"eby", "East Bay"}]},
    {"sea", "Seattle", [{"see", "Seattle"}, {"est", "Eastside"}]},
    {"pdx", "Portland", [{"mlt", "Portland"}, {"wsc", "Washington Co"}, {"clc", "Clackamas"}, {"clk", "Vancouver WA"}]}
  ]

  @sorts [{"best", "best"}, {"newest", "newest"}, {"price_asc", "cheapest"}, {"price_desc", "priciest"}]

  def mount(params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Blog.PubSub, "camera_browser")

    {:ok,
     assign(socket,
       page_title: "Camera Browser",
       admin?: admin?(params["key"]),
       key: params["key"],
       tabs: @tabs,
       sorts: @sorts,
       stats: CameraBrowser.stats(),
       tag_counts: CameraBrowser.tag_counts(),
       open: nil,
       photo: 0
     )}
  end

  def handle_params(params, _uri, socket) do
    filters = %{
      status: parse_status(params["status"]),
      city: params["city"] || "nyc",
      q: params["q"] || "",
      min_price: parse_dollars(params["min"]),
      max_price: parse_dollars(params["max"]),
      show_hidden: params["hidden"] == "1",
      starred: params["starred"] == "1",
      sort: parse_sort(params["sort"]),
      key: socket.assigns.key
    }

    active = Facets.from_params(params)
    base = CameraBrowser.list_listings(filters)
    listings = base |> Facets.filter(active) |> CameraBrowser.collapse_dupes()

    socket =
      assign(socket,
        filters: filters,
        active: active,
        facets: Facets.compute(base, active),
        base_count: length(base),
        listings: listings
      )

    socket =
      case params["open"] do
        nil -> assign(socket, open: nil, photo: 0)
        id -> open_listing(socket, id)
      end

    {:noreply, socket}
  end

  # -- filters ---------------------------------------------------------------

  def handle_event("filter", params, socket) do
    # A form submit omits unchecked boxes; a tab/chip click sends only its key.
    params =
      if Map.has_key?(params, "status"),
        do: Map.merge(%{"hidden" => nil, "starred" => nil}, params),
        else: params

    {:noreply, push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, params)}")}
  end

  def handle_event("facet", %{"name" => name, "value" => value}, socket) do
    name = String.to_existing_atom(name)
    active = Facets.toggle(socket.assigns.active, name, value)
    {:noreply, push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, %{}, active)}")}
  end

  def handle_event("clear-facets", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, %{}, %{})}")}
  end

  def handle_event("clear", _params, socket), do: {:noreply, push_patch(socket, to: ~p"/cameras")}

  # -- lightbox --------------------------------------------------------------

  def handle_event("open", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, %{"open" => id})}")}
  end

  def handle_event("close", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, %{})}")}
  end

  def handle_event("photo", %{"by" => by}, socket), do: {:noreply, step_photo(socket, String.to_integer(by))}
  def handle_event("photo", %{"i" => i}, socket), do: {:noreply, assign(socket, photo: String.to_integer(i))}

  def handle_event("keydown", %{"key" => key}, socket) do
    case {socket.assigns.open, key} do
      {nil, _} -> {:noreply, socket}
      {_, "Escape"} -> handle_event("close", %{}, socket)
      {_, "ArrowRight"} -> {:noreply, step_photo(socket, 1)}
      {_, "ArrowLeft"} -> {:noreply, step_photo(socket, -1)}
      {_, "ArrowDown"} -> {:noreply, step_listing(socket, 1)}
      {_, "ArrowUp"} -> {:noreply, step_listing(socket, -1)}
      {_, "s"} -> handle_event("star", %{"id" => to_string(socket.assigns.open.id)}, socket)
      {_, "h"} -> handle_event("hide", %{"id" => to_string(socket.assigns.open.id)}, socket)
      _ -> {:noreply, socket}
    end
  end

  # -- curation --------------------------------------------------------------

  def handle_event("star", %{"id" => id}, socket) do
    guard(socket, fn ->
    listing = id |> String.to_integer() |> CameraBrowser.get_listing!() |> CameraBrowser.toggle_star()
    {:noreply, replace_listing(socket, listing)}
    end)
  end

  def handle_event("hide", %{"id" => id}, socket) do
    guard(socket, fn ->
    listing = id |> String.to_integer() |> CameraBrowser.get_listing!() |> CameraBrowser.toggle_hidden()
    {:noreply, replace_listing(socket, listing)}
    end)
  end

  def handle_event("note", %{"listing_id" => id, "note" => note}, socket) do
    guard(socket, fn ->
      listing = id |> String.to_integer() |> CameraBrowser.get_listing!() |> CameraBrowser.set_note(String.trim(note))
      {:noreply, replace_listing(socket, listing)}
    end)
  end

  def handle_event("refetch", %{"id" => id}, socket) do
    guard(socket, fn ->
    listing = id |> String.to_integer() |> CameraBrowser.get_listing!()

    case CameraBrowser.fetch_detail(listing) do
      {:ok, l} -> {:noreply, replace_listing(socket, l)}
      {:gone, l} -> {:noreply, replace_listing(socket, l)}
      {:error, _} -> {:noreply, put_flash(socket, :error, "couldn't reach craigslist")}
    end
    end)
  end

  def handle_info({:camera_browser_polled, _summary}, socket) do
    %{filters: filters, active: active} = socket.assigns
    base = CameraBrowser.list_listings(filters)

    {:noreply,
     assign(socket,
       base_count: length(base),
       facets: Facets.compute(base, active),
       listings: base |> Facets.filter(active) |> CameraBrowser.collapse_dupes(),
       stats: CameraBrowser.stats(),
       tag_counts: CameraBrowser.tag_counts()
     )}
  end

  # -- helpers ---------------------------------------------------------------

  # Star/hide/note write data, so on the public site they need the same
  # ?key= token the blinks review page uses. With no token configured (dev)
  # everything is open.
  defp admin?(key) do
    case Application.get_env(:blog, :blinks_api_token) do
      t when is_binary(t) and t != "" -> Plug.Crypto.secure_compare(key || "", t)
      _ -> true
    end
  end

  defp guard(socket, fun) do
    if socket.assigns.admin?, do: fun.(), else: {:noreply, socket}
  end

  defp open_listing(socket, id) do
    case Integer.parse(id) do
      {n, ""} ->
        case CameraBrowser.get_listing(n) do
          nil -> assign(socket, open: nil)
          l -> assign(socket, open: l, photo: 0)
        end

      _ ->
        assign(socket, open: nil)
    end
  end

  defp step_photo(%{assigns: %{open: nil}} = socket, _), do: socket

  defp step_photo(socket, by) do
    n = max(length(photos(socket.assigns.open)), 1)
    assign(socket, photo: Integer.mod(socket.assigns.photo + by, n))
  end

  defp step_listing(socket, by) do
    ids = Enum.map(socket.assigns.listings, & &1.id)

    case Enum.find_index(ids, &(&1 == socket.assigns.open.id)) do
      nil ->
        socket

      i ->
        next = Enum.at(ids, Integer.mod(i + by, length(ids)))
        push_patch(socket, to: ~p"/cameras?#{filter_params(socket.assigns, %{"open" => next})}")
    end
  end

  defp replace_listing(socket, listing) do
    listings =
      Enum.map(socket.assigns.listings, fn l -> if l.id == listing.id, do: listing, else: l end)

    open = if socket.assigns.open && socket.assigns.open.id == listing.id, do: listing, else: socket.assigns.open
    assign(socket, listings: listings, open: open, stats: CameraBrowser.stats())
  end

  defp filter_params(%{filters: filters, active: active}, overrides), do: filter_params(filters, overrides, active)

  defp filter_params(%{filters: filters}, overrides, active), do: filter_params(filters, overrides, active)

  defp filter_params(filters, overrides, active) do
    base = %{
      "status" => Atom.to_string(filters.status),
      "city" => filters.city,
      "q" => filters.q,
      "min" => filters.min_price && div(filters.min_price, 100),
      "max" => filters.max_price && div(filters.max_price, 100),
      "hidden" => if(filters.show_hidden, do: "1"),
      "starred" => if(filters.starred, do: "1"),
      "sort" => Atom.to_string(filters.sort),
      "key" => filters.key
    }

    base
    |> Map.merge(Facets.to_params(active))
    |> Map.merge(Map.take(overrides, Map.keys(base) ++ ["open"]))
    |> Enum.reject(fn {k, v} ->
      v in [nil, "", "0"] or (k == "status" and v == "open") or (k == "sort" and v == "best") or
        (k == "city" and v == "nyc")
    end)
    |> Map.new()
  end

  defp parse_status("closed"), do: :closed
  defp parse_status("all"), do: :all
  defp parse_status(_), do: :open

  defp parse_sort("newest"), do: :newest
  defp parse_sort("price_asc"), do: :price_asc
  defp parse_sort("price_desc"), do: :price_desc
  defp parse_sort(_), do: :best

  defp parse_dollars(nil), do: nil
  defp parse_dollars(""), do: nil

  defp parse_dollars(s) do
    case Integer.parse(s) do
      {n, _} when n > 0 -> n * 100
      _ -> nil
    end
  end

  defp photos(listing), do: CameraBrowser.image_urls(listing, "1200x900")

  defp price(nil), do: "—"
  defp price(cents), do: "$" <> (cents |> div(100) |> Integer.to_string() |> thousands())

  defp thousands(s) do
    s |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1,") |> String.reverse()
  end

  defp ago(nil), do: ""

  defp ago(dt) do
    secs = DateTime.diff(DateTime.utc_now(), dt)

    cond do
      secs < 3600 -> "#{max(div(secs, 60), 1)}m"
      secs < 86_400 -> "#{div(secs, 3600)}h"
      secs < 86_400 * 30 -> "#{div(secs, 86_400)}d"
      true -> Calendar.strftime(dt, "%b %-d")
    end
  end

  defp where(l) do
    [l.neighborhood, l.location]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> List.first()
    |> case do
      nil -> Listing.city(l)
      hood -> hood
    end
  end

  # Which tab a city value belongs to: "mnh" -> "nyc", "sfc" -> "bay".
  defp tab_of(city) do
    Enum.find_value(@tabs, "nyc", fn {tab, _, subs} ->
      if city == tab or Enum.any?(subs, &(elem(&1, 0) == city)), do: tab
    end)
  end

  defp tag_class("working"), do: "t-good"
  defp tag_class("hopeful"), do: "t-hope"
  defp tag_class("lot"), do: "t-hope"
  defp tag_class("not film?"), do: "t-bad"
  defp tag_class("accessory"), do: "t-bad"
  defp tag_class("needs work"), do: "t-warn"
  defp tag_class(_), do: ""

  defp sort_label(:newest), do: "newest"
  defp sort_label(:price_asc), do: "cheapest"
  defp sort_label(:price_desc), do: "priciest"
  defp sort_label(_), do: "best"

  defp map_url(%{lat: lat, lng: lng}) when is_float(lat) and is_float(lng),
    do: "https://www.google.com/maps?q=#{lat},#{lng}"

  defp map_url(_), do: nil

  def render(assigns) do
    ~H"""
    <div class="cam" id="cam-page" phx-window-keydown="keydown">
      <div class="cam-menubar">
        <div class="cam-menu-left">
          <.link navigate={~p"/"} class="cam-apple">&#63743;</.link>
          <.link navigate={~p"/"} class="cam-menu-item">Finder</.link>
          <.link navigate={~p"/blog"} class="cam-menu-item">Blog</.link>
          <.link navigate={~p"/directory"} class="cam-menu-item">Directory</.link>
          <span class="cam-menu-item cam-menu-on">Cameras</span>
        </div>
        <div class="cam-menu-right">
          <span :if={@stats.last_seen}>Swept {ago(@stats.last_seen)} ago</span>
          <span :if={!@stats.last_seen}>Never swept</span>
        </div>
      </div>

      <div class="cam-desktop">
        <div class="cam-win">
          <div class="cam-titlebar">
            <.link navigate={~p"/"} class="cam-close"></.link>
            <div class="cam-title">Camera Browser — film cameras live on craigslist</div>
            <div class="cam-resize"></div>
          </div>

          <div class="cam-toolbar">
            <span class="cam-tabs">
              <a
                :for={{tab, label, _subs} <- @tabs}
                class={["cam-tab", tab_of(@filters.city) == tab && "on"]}
                phx-click="filter"
                phx-value-city={tab}
              >
                {label}
              </a>
            </span>
            <span class="cam-chips">
              <% {tab, _, subs} = Enum.find(@tabs, &(elem(&1, 0) == tab_of(@filters.city))) %>
              <a class={["cam-tag", @filters.city == tab && "cam-tag-on"]} phx-click="filter" phx-value-city={tab}>all</a>
              <a :for={{v, label} <- subs} class={["cam-tag", @filters.city == v && "cam-tag-on"]} phx-click="filter" phx-value-city={v}>{label}</a>
            </span>
            <form phx-change="filter" phx-submit="filter" class="cam-form">
              <select name="status">
                <option value="open" selected={@filters.status == :open}>live</option>
                <option value="closed" selected={@filters.status == :closed}>gone</option>
                <option value="all" selected={@filters.status == :all}>all</option>
              </select>
              <select name="sort">
                <option :for={{v, label} <- @sorts} value={v} selected={Atom.to_string(@filters.sort) == v}>{label}</option>
              </select>
              <input type="text" name="q" value={@filters.q} placeholder="search as you type" phx-debounce="150" autocomplete="off" />
              <label>$<input type="number" name="min" value={@filters.min_price && div(@filters.min_price, 100)} placeholder="min" phx-debounce="400" /></label>
              <label>–<input type="number" name="max" value={@filters.max_price && div(@filters.max_price, 100)} placeholder="max" phx-debounce="400" /></label>
              <label><input type="checkbox" name="starred" value="1" checked={@filters.starred} /> ★</label>
              <label :if={@admin?}><input type="checkbox" name="hidden" value="1" checked={@filters.show_hidden} /> hidden</label>
            </form>
            <button class="cam-reset" phx-click="clear">reset</button>
          </div>

          <div class="cam-main">
            <aside class="cam-rail">
              <div class="cam-rail-head">
                <span>{length(@listings)} of {@base_count}</span>
                <a :if={Facets.any?(@active)} phx-click="clear-facets">clear</a>
              </div>
              <details :for={f <- @facets} class="cam-facet" open={Enum.any?(f.values, & &1.on) || f.name in [:brand, :format, :tags]}>
                <summary>{f.label}<span :if={n = Enum.count(f.values, & &1.on); n > 0} class="on-n">{n}</span></summary>
                <a
                  :for={v <- f.values}
                  class={["cam-fv", v.on && "on", v.count == 0 && "zero"]}
                  phx-click="facet"
                  phx-value-name={f.name}
                  phx-value-value={v.value}
                >
                  <span class="box">{if v.on, do: "■", else: "□"}</span>
                  <span class="lbl">{v.label}</span>
                  <span class="cnt">{v.count}</span>
                </a>
              </details>
            </aside>
            <div class="cam-content">
          <div :if={@listings == []} class="cam-empty">
            Nothing here.
            <span :if={@stats.open == 0}>Seed it with <code>Blog.CameraBrowser.poll()</code>.</span>
          </div>

          <div class="cam-scroll" :if={@listings != []}>
            <table class="cam-table">
              <thead>
                <tr>
                  <th></th>
                  <th>Listing</th>
                  <th>Where</th>
                  <th class="r">Price</th>
                  <th class="r cam-when">Bumped</th>
                  <th class="r cam-score">Score</th>
                  <th :if={@admin?}></th>
                </tr>
              </thead>
              <tbody>
                <tr
                  :for={l <- @listings}
                  id={"l-#{l.id}"}
                  class={["row", l.starred_at && "starred", l.hidden_at && "hidden", l.closed_at && "closed"]}
                  phx-click="open"
                  phx-value-id={l.id}
                >
                  <td class="pic">
                    <img :if={CameraBrowser.thumb_url(l)} class="thumb" src={CameraBrowser.thumb_url(l)} alt="" loading="lazy" />
                    <div :if={!CameraBrowser.thumb_url(l)} class="nothumb"></div>
                  </td>
                  <td>
                    <div class="title">{if l.starred_at, do: "★ "}{l.title}<span :if={l.dupe_count > 1} class="cam-tag dupe" title="posted this many times">×{l.dupe_count}</span></div>
                    <div class="sub">
                      <span :for={t <- l.tags} class={["cam-tag", tag_class(t), t in Map.get(@active, :tags, []) && "cam-tag-on"]} phx-click="facet" phx-value-name="tags" phx-value-value={t} onclick="event.stopPropagation()">{t}</span>
                      <span :if={l.analysis} class={["cam-tag", "pt-" <> l.analysis["price_take"]]} title={l.analysis["price_note"]}>{l.analysis["price_take"]}</span>
                      <span :if={l.analysis} class="stars" title="rarity">{Analyst.stars(l.analysis)}</span>
                      <span :if={l.attrs["condition"]}>{l.attrs["condition"]} · </span>
                      <span :if={length(l.image_ids) > 0}>{length(l.image_ids)} photos</span>
                      <span :if={l.closed_at}> · gone ({l.closed_reason})</span>
                      <span :if={l.note}> · <i>{l.note}</i></span>
                    </div>
                  </td>
                  <td class="where"><b>{Listing.city(l)}</b><span :if={where(l) != Listing.city(l)} class="hood"> · {where(l)}</span></td>
                  <td class="price">{price(l.price_cents)}</td>
                  <td class="when cam-when" title={l.posted_at && "first posted #{Calendar.strftime(l.posted_at, "%b %-d")}"}>{ago(l.renewed_at || l.posted_at)}</td>
                  <td class="score cam-score">{l.score}</td>
                  <td :if={@admin?} class="act" onclick="event.stopPropagation()">
                    <button class={["ib", l.starred_at && "on"]} phx-click="star" phx-value-id={l.id} title="star">★</button>
                    <button class="ib" phx-click="hide" phx-value-id={l.id} title={if l.hidden_at, do: "unhide", else: "hide"}>{if l.hidden_at, do: "↺", else: "✕"}</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
            </div>
          </div>

          <div class="cam-statusbar">
            <span>{length(@listings)} shown · {@stats.open} live · {@stats.closed} gone · {@stats.starred} starred</span>
            <span>{tab_of(@filters.city) |> String.upcase()} · {sort_label(@filters.sort)}</span>
          </div>
        </div>
      </div>

      <div :if={@open} class="cam-lb" id={"lb-#{@open.id}"}>
        <div class="cam-win cam-lbwin">
          <div class="cam-titlebar">
            <a class="cam-close" phx-click="close"></a>
            <div class="cam-title">{@open.title}</div>
            <div class="cam-resize"></div>
          </div>
          <div class="cam-stage">
            <% urls = photos(@open) %>
            <img :if={urls != []} src={Enum.at(urls, @photo)} alt="" />
            <div :if={urls == []} class="cam-nophoto">no photos</div>
            <div :if={length(urls) > 1} class="nav prev" phx-click="photo" phx-value-by="-1">‹</div>
            <div :if={length(urls) > 1} class="nav next" phx-click="photo" phx-value-by="1">›</div>
            <div :if={length(urls) > 1} class="strip">
              <img :for={{u, i} <- Enum.with_index(urls)} src={u} class={i == @photo && "on"} phx-click="photo" phx-value-i={i} alt="" />
            </div>
          </div>
          <div class="cam-panel">
            <div>
              <div class="meta">
                <b>{price(@open.price_cents)}</b>
                · {Listing.city(@open)}<span :if={where(@open) != Listing.city(@open)}> · {where(@open)}</span>
                · posted {ago(@open.posted_at)} ago<span :if={@open.renewed_at && @open.posted_at && DateTime.diff(@open.renewed_at, @open.posted_at) > 3600}>, bumped {ago(@open.renewed_at)} ago</span>
                <span :if={@open.closed_at}> · <b class="gone">gone</b> ({@open.closed_reason}, {ago(@open.closed_at)} ago)</span>
              </div>
              <div :if={@open.analysis} class="ai">
                <div class="ai-head">
                  <b>the take</b>
                  <span class="stars" title="rarity">{Analyst.stars(@open.analysis)}</span>
                  <span class={["cam-tag", "pt-" <> @open.analysis["price_take"]]}>{@open.analysis["price_take"]}</span>
                </div>
                <p class="ai-quick">{@open.analysis["quick_take"]}</p>
                <p class="ai-price"><b>price:</b> {@open.analysis["price_note"]}</p>
                <p>{@open.analysis["commentary"]}</p>
                <div :if={@open.analysis["fun_features"] != []} class="ai-list">
                  <b>fun features</b>
                  <ul><li :for={f <- @open.analysis["fun_features"]}>{f}</li></ul>
                </div>
                <div :if={@open.analysis["facts"] != []} class="ai-list">
                  <b>did you know</b>
                  <ul><li :for={f <- @open.analysis["facts"]}>{f}</li></ul>
                </div>
                <div class="ai-foot">{@open.analysis["model"]} · not gospel</div>
              </div>
              <div :if={!@open.analysis && @open.body} class="ai ai-pending">analysis pending — it's queued for the next sweep</div>
              <div class="body" :if={@open.body}>{@open.body}</div>
              <div class="body dim" :if={!@open.body}>
                Full post not fetched yet.
                <button :if={@admin?} class="cam-btn" phx-click="refetch" phx-value-id={@open.id}>fetch now</button>
              </div>
            </div>
            <div class="side">
              <div class="btns">
                <a class="cam-btn" href={@open.url} target="_blank" rel="noopener">craigslist ↗</a>
                <a :if={@open.reply_url} class="cam-btn" href={@open.reply_url} target="_blank" rel="noopener">reply ↗</a>
                <a :if={map_url(@open)} class="cam-btn" href={map_url(@open)} target="_blank" rel="noopener">map ↗</a>
                <button :if={@admin?} class={["cam-btn", @open.starred_at && "on"]} phx-click="star" phx-value-id={@open.id}>★ star</button>
                <button :if={@admin?} class={["cam-btn", @open.hidden_at && "on"]} phx-click="hide" phx-value-id={@open.id}>{if @open.hidden_at, do: "unhide", else: "hide"}</button>
              </div>
              <div :if={@open.contact != %{}} class="contact">
                <div :for={{k, vs} <- @open.contact}><b>{k}:</b> {Enum.join(vs, ", ")}</div>
              </div>
              <table class="kv">
                <tr :for={{k, v} <- @open.attrs}><th>{k}</th><td>{v}</td></tr>
                <tr><th>tags</th><td><span :for={t <- @open.tags} class={["cam-tag", tag_class(t)]}>{t}</span></td></tr>
                <tr><th>found via</th><td>{Enum.join(@open.queries, ", ")}</td></tr>
                <tr><th>score</th><td>{@open.score}</td></tr>
                <tr><th>seen</th><td>{ago(@open.first_seen_at)} ago → {ago(@open.last_seen_at)} ago</td></tr>
                <tr><th>id</th><td><code>{@open.posting_id}</code></td></tr>
              </table>
              <form :if={@admin?} phx-submit="note" phx-change="note">
                <input type="hidden" name="listing_id" value={@open.id} />
                <textarea name="note" placeholder="your note" phx-debounce="600">{@open.note}</textarea>
              </form>
              <div :if={!@admin? && @open.note} class="note">{@open.note}</div>
            </div>
          </div>
          <div class="cam-statusbar">
            <span>{@photo + 1} / {max(length(urls), 1)} photos</span>
            <span>← → photos · ↑ ↓ next listing<span :if={@admin?}> · s star · h hide</span> · esc close</span>
          </div>
        </div>
      </div>

      <style>
        .cam {
          min-height: 100vh;
          background: repeating-linear-gradient(0deg, #a8a8a8, #a8a8a8 1px, #b8b8b8 1px, #b8b8b8 2px);
          font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
          font-size: 13px;
          color: #000;
          -webkit-font-smoothing: none;
        }
        .cam *, .cam *::before, .cam *::after { box-sizing: border-box; }
        .cam a { color: #000; text-decoration: none; }

        /* ---- Menu bar ---- */
        .cam-menubar { position: sticky; top: 0; z-index: 10; height: 24px; background: #fff; border-bottom: 1px solid #000; display: flex; justify-content: space-between; align-items: center; padding: 0 8px; }
        .cam-menu-left { display: flex; gap: 16px; align-items: center; }
        .cam-apple { font-family: system-ui; font-size: 16px; line-height: 1; }
        .cam-menu-item { font-size: 14px; padding: 0 2px; }
        .cam-menu-item:hover, .cam-apple:hover { background: #000; color: #fff; }
        .cam-menu-on { background: #000; color: #fff; }
        .cam-menu-right { font-size: 13px; }

        /* ---- Window chrome ---- */
        .cam-desktop { padding: 20px 20px 60px; }
        .cam-win { max-width: 1280px; margin: 0 auto; background: #fff; border: 1px solid #000; box-shadow: 1px 1px 0 #000; }
        .cam-titlebar { height: 24px; border-bottom: 1px solid #000; display: flex; align-items: center; padding: 0 4px; background: repeating-linear-gradient(90deg, #fff 0px, #fff 1px, #000 1px, #000 2px, #fff 2px, #fff 3px); }
        .cam-close { width: 12px; height: 12px; border: 1px solid #000; background: #fff; margin-right: 8px; flex-shrink: 0; cursor: pointer; }
        .cam-close:hover { background: #000; }
        .cam-title { flex: 1; text-align: center; background: #fff; padding: 0 8px; font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .cam-resize { width: 12px; height: 12px; flex-shrink: 0; }
        .cam-statusbar { height: 22px; border-top: 1px solid #000; background: #fff; display: flex; justify-content: space-between; align-items: center; padding: 0 8px; font-size: 12px; color: #333; }

        /* ---- Toolbar ---- */
        .cam-toolbar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; padding: 6px 8px; border-bottom: 1px solid #000; background: #e0e0e0; }
        .cam-tabs { display: inline-flex; border: 1px solid #000; background: #fff; }
        .cam-tab { padding: 2px 12px; font-weight: bold; font-size: 13px; cursor: pointer; }
        .cam-tab + .cam-tab { border-left: 1px solid #000; }
        .cam-tab.on { background: #000; color: #fff; }
        .cam-tab:hover { background: #000; color: #fff; }
        .cam-chips { display: flex; gap: 4px; flex-wrap: wrap; min-width: 0; flex: 0 1 auto; }
        .cam-form { display: contents; }
        .cam-toolbar select, .cam-toolbar input[type=text], .cam-toolbar input[type=number] { font-family: "Geneva", "Helvetica", sans-serif; font-size: 12px; border: 1px solid #000; background: #fff; color: #000; padding: 1px 4px; height: 20px; border-radius: 0; }
        .cam-toolbar input[type=text] { width: 150px; }
        .cam-toolbar input[type=number] { width: 56px; }
        .cam-toolbar label { font-size: 12px; display: inline-flex; align-items: center; gap: 3px; }
        .cam-reset { font-family: inherit; font-size: 11px; border: 1px solid #000; background: #fff; padding: 1px 8px; cursor: pointer; margin-left: auto; }
        .cam-reset:hover { background: #000; color: #fff; }

        /* ---- Tags ---- */
        .cam-tag { display: inline-block; border: 1px solid #000; background: #fff; color: #000; padding: 0 5px; font-size: 10px; line-height: 15px; text-transform: uppercase; letter-spacing: 0.5px; white-space: nowrap; cursor: pointer; }
        .cam-tag .n { color: #666; }
        .cam .cam-tag-on { background: #000; color: #fff; }
        .cam .cam-tag-on .n { color: #bbb; }
        .cam-tag.t-good { border-color: #1a7a3a; color: #1a7a3a; }
        .cam-tag.t-hope { border-color: #9a6a00; color: #9a6a00; }
        .cam-tag.t-bad { border-color: #a00; color: #a00; border-style: dashed; }
        .cam-tag.t-warn { border-color: #a05000; color: #a05000; }
        .cam-tagbar { display: flex; gap: 4px; flex-wrap: wrap; padding: 6px 8px; border-bottom: 1px solid #000; }

        /* ---- Facet rail ---- */
        .cam-main { display: flex; align-items: stretch; min-height: 300px; }
        .cam-rail { width: 200px; flex-shrink: 0; border-right: 1px solid #000; background: #fff; font-size: 12px; }
        .cam-content { flex: 1; min-width: 0; }
        .cam-rail-head { display: flex; justify-content: space-between; align-items: center; padding: 4px 8px; border-bottom: 1px solid #000; background: #e0e0e0; font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #333; }
        .cam-rail-head a { cursor: pointer; text-decoration: underline; }
        .cam-facet { border-bottom: 1px solid #ccc; }
        .cam-facet summary { cursor: pointer; padding: 4px 8px; font-weight: bold; font-size: 11px; list-style: none; display: flex; justify-content: space-between; align-items: center; }
        .cam-facet summary::-webkit-details-marker { display: none; }
        .cam-facet summary::before { content: "▸ "; color: #666; }
        .cam-facet[open] summary::before { content: "▾ "; }
        .cam-facet .on-n { background: #000; color: #fff; font-size: 9px; padding: 0 5px; }
        .cam-fv { display: flex; gap: 5px; align-items: baseline; padding: 1px 8px 1px 14px; cursor: pointer; font-family: "Geneva", "Helvetica", sans-serif; font-size: 11px; }
        .cam-fv:hover { background: #000; color: #fff; text-decoration: none; }
        .cam-fv:hover .cnt { color: #ccc; }
        .cam-fv.on { font-weight: bold; }
        .cam-fv.zero { color: #999; }
        .cam-fv .box { font-size: 10px; }
        .cam-fv .lbl { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .cam-fv .cnt { color: #777; font-size: 10px; font-variant-numeric: tabular-nums; }
        .cam-table .sub .cam-tag { cursor: pointer; }

        /* ---- Analysis ---- */
        .cam .stars { color: #b8860b; font-size: 10px; letter-spacing: -1px; }
        .cam .cam-tag.pt-steal { border-color: #1a7a3a; color: #1a7a3a; background: #e8f7ec; }
        .cam .cam-tag.pt-fair { border-color: #555; color: #333; }
        .cam .cam-tag.pt-high { border-color: #a00; color: #a00; }
        .cam .cam-tag.pt-unclear { border-style: dashed; color: #777; }
        .cam-panel .ai { border: 1px solid #000; background: #fbf9f3; padding: 8px 10px; margin-bottom: 10px; font-size: 12px; line-height: 1.45; }
        .cam-panel .ai p { margin: 0 0 6px; }
        .cam-panel .ai-head { display: flex; gap: 8px; align-items: center; margin-bottom: 4px; font-family: "Chicago", "Geneva", "Helvetica", sans-serif; }
        .cam-panel .ai-quick { font-weight: bold; }
        .cam-panel .ai-list { margin: 4px 0; }
        .cam-panel .ai-list ul { margin: 2px 0 0; padding-left: 18px; }
        .cam-panel .ai-foot { color: #888; font-size: 10px; margin-top: 4px; }
        .cam-panel .ai-pending { color: #777; font-style: italic; }

        /* ---- Table ---- */
        .cam-scroll { overflow-x: auto; }
        .cam-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .cam-table th { background: #e0e0e0; border-bottom: 1px solid #000; text-align: left; padding: 4px 10px; font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #333; white-space: nowrap; }
        .cam-table th.r { text-align: right; }
        .cam-table td { padding: 4px 10px; border-bottom: 1px solid #ccc; vertical-align: middle; font-family: "Geneva", "Helvetica", sans-serif; line-height: 1.35; }
        .cam-table tbody tr:last-child td { border-bottom: 0; }
        .cam-table tr.row { cursor: pointer; }
        .cam-table tbody tr:hover td { background: #000; color: #fff; }
        .cam-table tbody tr:hover .cam-tag { background: #333; color: #fff; border-color: #fff; }
        .cam-table tbody tr:hover .hood, .cam-table tbody tr:hover .sub, .cam-table tbody tr:hover .when, .cam-table tbody tr:hover .score { color: #ccc; }
        .cam-table tr.starred td { background: #fff3b0; }
        .cam-table tr.hidden td { opacity: 0.4; }
        .cam-table tr.closed .title { text-decoration: line-through; }
        .cam-table td.pic { width: 62px; padding: 3px 6px 3px 10px; }
        .thumb { width: 56px; height: 42px; object-fit: cover; display: block; border: 1px solid #000; background: #eee; }
        .nothumb { width: 56px; height: 42px; border: 1px solid #000; background: repeating-linear-gradient(45deg, #fff, #fff 3px, #000 3px, #000 4px); }
        .cam-table .title { font-weight: bold; }
        .cam-table .title .dupe { margin-left: 6px; font-size: 10px; vertical-align: middle; background: #000; color: #fff; }
        .cam-table .sub { color: #444; font-size: 11px; margin-top: 2px; }
        .cam-table .sub .cam-tag { font-size: 9px; line-height: 13px; padding: 0 3px; margin-right: 2px; cursor: default; }
        .cam-table td.where { white-space: nowrap; max-width: 220px; overflow: hidden; text-overflow: ellipsis; }
        .cam-table .hood { color: #555; }
        .cam-table td.price { font-weight: bold; white-space: nowrap; text-align: right; font-variant-numeric: tabular-nums; }
        .cam-table td.when { white-space: nowrap; text-align: right; color: #555; font-variant-numeric: tabular-nums; }
        .cam-table td.score { text-align: right; color: #888; font-size: 11px; font-variant-numeric: tabular-nums; }
        .cam-table td.act { white-space: nowrap; text-align: right; }
        .ib { background: #fff; border: 1px solid #000; cursor: pointer; font-size: 12px; line-height: 16px; padding: 0 4px; color: #000; font-family: inherit; }
        .ib.on { background: #000; color: #fff; }
        .cam-empty { padding: 40px; text-align: center; color: #333; }
        .cam code { font-family: "SF Mono", "Monaco", "Menlo", monospace; font-size: 0.9em; }

        /* ---- Lightbox window ---- */
        .cam-lb { position: fixed; inset: 0; z-index: 50; background: rgba(0,0,0,0.55); padding: 16px; display: flex; align-items: center; justify-content: center; }
        .cam-lbwin { width: min(1180px, 100%); max-height: calc(100vh - 32px); display: flex; flex-direction: column; box-shadow: 2px 2px 0 #000; }
        .cam-stage { position: relative; background: #000; display: flex; align-items: center; justify-content: center; height: 52vh; min-height: 220px; flex-shrink: 0; }
        .cam-stage > img { max-width: 100%; max-height: 100%; object-fit: contain; }
        .cam-nophoto { color: #888; }
        .cam-stage .nav { position: absolute; top: 0; bottom: 0; width: 18%; display: flex; align-items: center; color: #fff; font-size: 44px; opacity: 0.4; cursor: pointer; user-select: none; }
        .cam-stage .nav:hover { opacity: 1; }
        .cam-stage .nav.prev { left: 0; justify-content: flex-start; padding-left: 14px; }
        .cam-stage .nav.next { right: 0; justify-content: flex-end; padding-right: 14px; }
        .cam-stage .strip { position: absolute; bottom: 6px; left: 0; right: 0; display: flex; gap: 3px; justify-content: center; flex-wrap: wrap; padding: 0 8px; }
        .cam-stage .strip img { width: 40px; height: 30px; object-fit: cover; opacity: 0.5; cursor: pointer; border: 1px solid #fff; }
        .cam-stage .strip img.on { opacity: 1; border: 2px solid #fff; }
        .cam-panel { overflow: auto; padding: 10px 14px 12px; display: grid; grid-template-columns: 1fr 280px; gap: 14px; border-top: 1px solid #000; font-family: "Geneva", "Helvetica", sans-serif; }
        .cam-panel .meta { font-size: 12px; color: #333; margin-bottom: 8px; }
        .cam-panel .meta b { font-size: 14px; color: #000; }
        .cam-panel .gone { color: #a00; }
        .cam-panel .body { white-space: pre-wrap; font-size: 12px; line-height: 1.45; }
        .cam-panel .body.dim { color: #666; }
        .cam-panel .side { font-size: 12px; }
        .cam-panel .btns { display: flex; gap: 5px; flex-wrap: wrap; margin-bottom: 8px; }
        .cam-btn { font-family: "Chicago", "Geneva", "Helvetica", sans-serif; font-size: 12px; border: 1px solid #000; background: #fff; color: #000; padding: 2px 8px; cursor: pointer; box-shadow: 1px 1px 0 #000; }
        .cam-btn:hover { background: #000; color: #fff; }
        .cam-btn.on { background: #000; color: #fff; }
        .cam-panel .contact { border: 1px solid #000; background: #fff3b0; padding: 4px 6px; margin-bottom: 8px; }
        .cam-panel .kv { border-collapse: collapse; width: 100%; margin-bottom: 8px; }
        .cam-panel .kv th { text-align: left; font-weight: normal; color: #555; padding: 1px 8px 1px 0; vertical-align: top; white-space: nowrap; }
        .cam-panel .kv td { padding: 1px 0; }
        .cam-panel .kv .cam-tag { margin: 0 2px 2px 0; cursor: default; }
        .cam-panel textarea { width: 100%; font-family: "Geneva", "Helvetica", sans-serif; font-size: 12px; border: 1px solid #000; padding: 3px; min-height: 44px; border-radius: 0; }
        .cam-panel .note { border-left: 3px solid #000; padding-left: 6px; font-style: italic; }

        @media (max-width: 760px) {
          .cam-desktop { padding: 8px 8px 40px; }
          .cam-main { flex-direction: column; }
          .cam-rail { width: auto; border-right: 0; border-bottom: 1px solid #000; }
          .cam-facet:not([open]) { display: inline-block; border: 1px solid #ccc; margin: 3px; }
          .cam-facet[open] { display: block; }
          .cam-when, .cam-score, .cam-menu-right { display: none; }
          .cam-table td.where { max-width: 110px; }
          .cam-toolbar input[type=text] { width: 110px; }
          .cam-panel { grid-template-columns: 1fr; }
          .cam-stage { height: 40vh; }
        }
      </style>
    </div>
    """
  end
end
