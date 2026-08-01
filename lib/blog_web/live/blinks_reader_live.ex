defmodule BlogWeb.BlinksReaderLive do
  @moduledoc """
  A reading-room view of the same links `/blinks` shows.

  Where the front page is a newspaper — two hand-set columns, everything
  shrunk to fit one screenful — this one is a contact sheet. It packs more
  links per screen by going wide instead of tall, and it treats pictures as
  something you might actually want to look at: every thumbnail opens into a
  full-viewport lightbox that you can walk end to end with the arrow keys,
  because a 48-pixel square is a table of contents, not an image.

  Same data, same filters, same URL params as `/blinks` — a link with `?q=` or
  `?tags=` on it works in either place.
  """
  use BlogWeb, :live_view

  alias Blog.Blinks

  @page_size 60

  def mount(_params, session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Blog.PubSub, Blinks.topic())

    {:ok,
     assign(socket,
       page_title: "Blinks reader",
       total: Blinks.count_blinks(),
       page_size: @page_size,
       dork_tags: Blinks.dork_tags(),
       shuffle_seed:
         Map.get(session, "blinks_shuffle_seed") || Base.encode16(:crypto.strong_rand_bytes(4)),
       lightbox: nil
     )}
  end

  def handle_params(params, _uri, socket) do
    page =
      case Integer.parse(params["page"] || "1") do
        {n, ""} when n >= 1 -> n
        _ -> 1
      end

    tags =
      (params["tags"] || "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    {:noreply,
     socket
     |> assign(
       q: params["q"] || "",
       selected_tags: tags,
       nodork: params["nodork"] == "1",
       timeframe: if(params["t"] in ~w(1d 3d 1w 1mo 1y), do: params["t"]),
       shuffle_on: params["shuffle"] == "1",
       page: page
     )
     |> reload()}
  end

  defp reload(socket) do
    %{q: q, selected_tags: tags, page: page, page_size: page_size} = socket.assigns
    exclude = if socket.assigns.nodork, do: socket.assigns.dork_tags, else: []

    blinks =
      Blinks.list_blinks(
        query: q,
        tags: tags,
        exclude_tags: exclude,
        since: since_for(socket.assigns.timeframe),
        shuffle_seed: if(socket.assigns.shuffle_on, do: socket.assigns.shuffle_seed),
        limit: page_size + 1,
        offset: (page - 1) * page_size
      )

    has_more = length(blinks) > page_size
    blinks = Enum.take(blinks, page_size)

    # One flat, numbered gallery for the whole page: the lightbox walks it
    # straight through, so arrowing off the last picture of one link lands on
    # the first picture of the next rather than dead-ending.
    gallery =
      blinks
      |> Enum.flat_map(fn blink ->
        Enum.map(media_items(blink), &Map.merge(&1, %{blink_id: blink.id, blink: blink}))
      end)
      |> Enum.with_index()
      |> Enum.map(fn {item, idx} -> Map.put(item, :idx, idx) end)

    assign(socket,
      blinks: blinks,
      has_more: has_more,
      gallery: gallery,
      media_by_blink: Enum.group_by(gallery, & &1.blink_id),
      tags: Blinks.list_tags([], exclude)
    )
  end

  # ---- media -------------------------------------------------------------

  # Everything worth enlarging, in reading order: each post in a thread, then
  # anything it quotes. Links with no thread fall back to the og image, which
  # is the only picture they have.
  defp media_items(blink) do
    from_thread =
      blink
      |> thread_posts()
      |> Enum.flat_map(fn post -> media_from(post) ++ media_from(post["quote"]) end)

    case from_thread do
      [] -> og_image(blink)
      items -> items
    end
  end

  defp og_image(%{image_url: url} = blink) when is_binary(url) and url != "" do
    [%{kind: :image, thumb: url, full: url, alt: blink.title || ""}]
  end

  defp og_image(_blink), do: []

  defp media_from(%{} = m) do
    images =
      for img <- m["images"] || [], is_binary(img["thumb"]) do
        %{kind: :image, thumb: img["thumb"], full: img["full"] || img["thumb"], alt: img["alt"] || ""}
      end

    video =
      case m["video"] do
        %{"thumb" => thumb} when is_binary(thumb) ->
          [%{kind: :video, thumb: thumb, full: thumb, alt: ""}]

        _ ->
          []
      end

    images ++ video
  end

  defp media_from(_), do: []

  defp thread_posts(%{thread: %{"posts" => posts}}) when is_list(posts), do: posts
  defp thread_posts(_blink), do: []

  defp root_quote(blink) do
    case thread_posts(blink) do
      [%{"quote" => %{} = quote} | _] -> quote
      _ -> nil
    end
  end

  # The reader has room to breathe, so headlines run longer here than the
  # front page's 140 characters.
  defp headline(blink) do
    cond do
      blink.quotes != [] -> "“#{List.first(blink.quotes)}”"
      thread_posts(blink) != [] -> thread_posts(blink) |> hd() |> Map.get("text", "") |> String.slice(0, 300)
      true -> blink.title || blink.url
    end
  end

  defp domain(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> String.replace_prefix(host, "www.", "")
      _ -> url
    end
  end

  defp site_label(blink), do: blink.site_name || domain(blink.url)

  @day 86_400
  defp since_for("1d"), do: NaiveDateTime.add(NaiveDateTime.utc_now(), -@day)
  defp since_for("3d"), do: NaiveDateTime.add(NaiveDateTime.utc_now(), -3 * @day)
  defp since_for("1w"), do: NaiveDateTime.add(NaiveDateTime.utc_now(), -7 * @day)
  defp since_for("1mo"), do: NaiveDateTime.add(NaiveDateTime.utc_now(), -30 * @day)
  defp since_for("1y"), do: NaiveDateTime.add(NaiveDateTime.utc_now(), -365 * @day)
  defp since_for(_), do: nil

  defp stamp(nil), do: ""
  defp stamp(dt), do: Calendar.strftime(dt, "%b %-d")

  # ---- events ------------------------------------------------------------

  def handle_event("open-media", %{"idx" => idx}, socket) do
    {:noreply, assign(socket, lightbox: to_index(idx, socket))}
  end

  def handle_event("close-media", _params, socket), do: {:noreply, assign(socket, lightbox: nil)}

  def handle_event("step-media", %{"by" => by}, socket) do
    {:noreply, assign(socket, lightbox: step(socket, String.to_integer(by)))}
  end

  # Arrow keys walk the gallery, escape closes. Everything else falls through
  # so typing in the search box isn't hijacked.
  def handle_event("media-key", %{"key" => key}, socket) do
    case key do
      "Escape" -> {:noreply, assign(socket, lightbox: nil)}
      "ArrowRight" -> {:noreply, assign(socket, lightbox: step(socket, 1))}
      "ArrowLeft" -> {:noreply, assign(socket, lightbox: step(socket, -1))}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("search", %{"q" => q}, socket), do: {:noreply, patch(socket, q: q, page: 1)}

  def handle_event("toggle-tag", %{"tag" => tag}, socket) do
    tags = socket.assigns.selected_tags

    next = if tag in tags, do: tags -- [tag], else: [tag | tags]
    {:noreply, patch(socket, tags: Enum.join(next, ","), page: 1)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, patch(socket, q: "", tags: "", t: "", page: 1)}
  end

  def handle_event("set-window", %{"t" => t}, socket), do: {:noreply, patch(socket, t: t, page: 1)}

  def handle_event("toggle-shuffle", _params, socket) do
    {:noreply, patch(socket, shuffle: if(socket.assigns.shuffle_on, do: "0", else: "1"), page: 1)}
  end

  def handle_event("more", _params, socket) do
    {:noreply, patch(socket, page: socket.assigns.page + 1)}
  end

  def handle_event("prev-page", _params, socket) do
    {:noreply, patch(socket, page: max(1, socket.assigns.page - 1))}
  end

  def handle_info({event, %Blinks.Blink{}}, socket)
      when event in [:blink_saved, :blink_deleted, :blink_updated] do
    {:noreply, reload(socket)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp to_index(idx, socket) do
    n = length(socket.assigns.gallery)

    case Integer.parse(to_string(idx)) do
      {i, ""} when i >= 0 -> if i < n, do: i, else: nil
      _ -> nil
    end
  end

  # Wrap at both ends so the gallery is a loop, not a corridor.
  defp step(socket, by) do
    n = length(socket.assigns.gallery)

    case socket.assigns.lightbox do
      nil -> nil
      _ when n == 0 -> nil
      i -> Integer.mod(i + by, n)
    end
  end

  defp current_media(%{lightbox: nil}), do: nil
  defp current_media(%{lightbox: i, gallery: gallery}), do: Enum.at(gallery, i)

  defp patch(socket, overrides) do
    current = [
      q: socket.assigns.q,
      tags: Enum.join(socket.assigns.selected_tags, ","),
      t: socket.assigns.timeframe,
      page: socket.assigns.page,
      shuffle: if(socket.assigns.shuffle_on, do: "1"),
      nodork: if(socket.assigns.nodork, do: "1")
    ]

    query =
      current
      |> Keyword.merge(overrides)
      |> Enum.reject(fn {k, v} -> is_nil(v) or v == "" or (k == :page and v == 1) end)
      |> URI.encode_query()

    push_patch(socket, to: "/blinks-reader" <> if(query == "", do: "", else: "?" <> query))
  end

  # ---- render ------------------------------------------------------------

  def render(assigns) do
    ~H"""
    <div id="blinks-reader">
      <style>
        #blinks-reader, #blinks-reader *, #blinks-reader *::before, #blinks-reader *::after { box-sizing: border-box; }
        #blinks-reader { font: 12px verdana, arial, helvetica, sans-serif; color: #000; background: #fff; height: 100dvh; display: flex; flex-direction: column; overflow: hidden; }
        #blinks-reader a { text-decoration: none; }

        #blinks-reader .masthead { flex-shrink: 0; background: #cee3f8; border-bottom: 1px solid #5f99cf; padding: 4px 10px; display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
        #blinks-reader .masthead h1 { font-size: 15px; font-weight: bold; letter-spacing: -0.5px; margin: 0; display: inline; }
        #blinks-reader .masthead h1 span { color: #ff4500; }
        #blinks-reader .dateline { color: #369; font-size: 10px; }
        #blinks-reader .tabs { display: flex; gap: 3px; align-self: flex-end; margin-bottom: -5px; }
        #blinks-reader .tabs .tab { font-size: 11px; font-weight: bold; color: #369; background: #b9d2ec; border: 1px solid #5f99cf; border-bottom: none; border-radius: 3px 3px 0 0; padding: 2px 10px; }
        #blinks-reader .tabs .tab.on { background: #fff; color: #ff4500; }
        #blinks-reader .searchform { margin-left: auto; }
        #blinks-reader .searchform input[type="text"] { border: 1px solid #5f99cf; font-size: 12px; padding: 2px 4px; width: 220px; }

        #blinks-reader .railbar { flex-shrink: 0; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; padding: 4px 10px; border-bottom: 1px solid #e2e2e2; font-size: 10px; color: #888; }
        #blinks-reader .railbar .tag { color: #369; background: #eef4fb; border: 1px solid #d5e4f5; border-radius: 2px; padding: 0 4px; cursor: pointer; white-space: nowrap; }
        #blinks-reader .railbar .tag:hover { border-color: #5f99cf; }
        #blinks-reader .railbar .tag.on { background: #ff4500; border-color: #ff4500; color: #fff; }
        #blinks-reader .railbar .tag .tcount { color: #aaa; margin-left: 3px; }
        #blinks-reader .railbar .tag.on .tcount { color: #ffd9c9; }
        #blinks-reader .railbar .sep { color: #ccc; }
        #blinks-reader .railbar .ctl { color: #369; cursor: pointer; }
        #blinks-reader .railbar .ctl.on { color: #ff4500; font-weight: bold; }

        /* the contact sheet: as many columns as the window will hold */
        #blinks-reader .sheet { flex: 1 1 auto; min-height: 0; overflow-y: auto; padding: 8px 10px 20px; display: grid; grid-template-columns: repeat(auto-fill, minmax(310px, 1fr)); gap: 8px 14px; align-content: start; }
        #blinks-reader .card { border: 1px solid #e2e2e2; border-radius: 2px; padding: 6px 8px 7px; display: flex; flex-direction: column; gap: 3px; min-width: 0; }
        #blinks-reader .card:hover { border-color: #5f99cf; }
        #blinks-reader .card.dead { filter: grayscale(1); opacity: 0.55; }

        #blinks-reader .toprow { display: flex; align-items: baseline; gap: 5px; font-size: 10px; color: #888; min-width: 0; }
        #blinks-reader .toprow .rank { color: #bbb; font-weight: bold; }
        #blinks-reader .toprow .favicon { width: 11px; height: 11px; vertical-align: -1px; }
        #blinks-reader .toprow .site { color: #369; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        #blinks-reader .toprow .when { margin-left: auto; white-space: nowrap; color: #bbb; }

        #blinks-reader .title { color: #0000ff; font-size: 12px; font-weight: bold; line-height: 1.35; overflow-wrap: anywhere; }
        #blinks-reader .title:visited { color: #551a8b; }
        #blinks-reader .card.dead .title { color: #666; }
        #blinks-reader .subtitle { color: #333; font-size: 11px; line-height: 1.35; }
        #blinks-reader .desc { color: #555; font-size: 11px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
        #blinks-reader .bquote { color: #666; font-size: 10px; line-height: 1.35; border-left: 2px solid #ddd; padding-left: 5px; }

        /* thumbnails: uniform strip, click to enlarge */
        #blinks-reader .strip { display: flex; flex-wrap: wrap; gap: 3px; margin-top: 1px; }
        #blinks-reader .shot { position: relative; width: 74px; height: 56px; border: 1px solid #ddd; border-radius: 2px; overflow: hidden; cursor: zoom-in; background: #f4f4f4; padding: 0; display: block; }
        #blinks-reader .shot img { width: 100%; height: 100%; object-fit: cover; display: block; }
        #blinks-reader .shot:hover { border-color: #ff4500; }
        #blinks-reader .shot .play { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 20px; text-shadow: 0 0 8px rgba(0,0,0,0.9); }

        #blinks-reader .foot { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; font-size: 10px; color: #aaa; margin-top: 1px; }
        #blinks-reader .foot .tag { color: #369; cursor: pointer; }
        #blinks-reader .foot .tag:hover { text-decoration: underline; }
        #blinks-reader .foot .tag.on { color: #ff4500; font-weight: bold; }
        #blinks-reader .foot a { color: #aaa; }
        #blinks-reader .foot a:hover { color: #369; }

        #blinks-reader .pager { grid-column: 1 / -1; display: flex; justify-content: center; gap: 14px; padding: 10px 0 0; }
        #blinks-reader .pager .pg { color: #369; font-weight: bold; cursor: pointer; font-size: 11px; }
        #blinks-reader .empty { grid-column: 1 / -1; color: #888; padding: 20px 0; text-align: center; }

        /* lightbox */
        #blinks-reader .lb { position: fixed; inset: 0; z-index: 60; background: rgba(12,12,14,0.94); display: flex; flex-direction: column; }
        #blinks-reader .lb .lbstage { flex: 1 1 auto; min-height: 0; display: flex; align-items: center; justify-content: center; padding: 34px 56px 6px; }
        #blinks-reader .lb .lbstage img { max-width: 100%; max-height: 100%; object-fit: contain; display: block; }
        #blinks-reader .lb .lbnav { position: absolute; top: 0; bottom: 0; width: 52px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 26px; cursor: pointer; opacity: 0.55; user-select: none; background: none; border: none; }
        #blinks-reader .lb .lbnav:hover { opacity: 1; }
        #blinks-reader .lb .lbprev { left: 0; }
        #blinks-reader .lb .lbnext { right: 0; }
        #blinks-reader .lb .lbclose { position: absolute; top: 6px; right: 10px; color: #fff; font-size: 20px; cursor: pointer; opacity: 0.6; background: none; border: none; }
        #blinks-reader .lb .lbclose:hover { opacity: 1; }
        #blinks-reader .lb .lbbar { flex-shrink: 0; color: #ddd; font-size: 11px; padding: 8px 56px 14px; display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; }
        #blinks-reader .lb .lbbar .lbtitle { color: #fff; font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 60%; }
        #blinks-reader .lb .lbbar a { color: #7fb2e5; }
        #blinks-reader .lb .lbbar .lbcount { margin-left: auto; color: #999; white-space: nowrap; }
        #blinks-reader .lb .lbalt { color: #aaa; font-size: 10px; padding: 0 56px 10px; max-height: 3.6em; overflow-y: auto; }
        #blinks-reader .lb .lbvideo { color: #ffb08a; font-size: 10px; }

        @media (max-width: 640px) {
          #blinks-reader .sheet { grid-template-columns: 1fr; }
          #blinks-reader .lb .lbstage { padding: 30px 8px 6px; }
          #blinks-reader .lb .lbbar, #blinks-reader .lb .lbalt { padding-left: 12px; padding-right: 12px; }
        }
      </style>

      <div class="masthead">
        <h1>blinks<span>.</span>reader</h1>
        <span class="dateline">{@total} links · contact sheet</span>
        <div class="tabs">
          <a class="tab" href="/blinks">newspaper</a>
          <span class="tab on">reader</span>
        </div>
        <form class="searchform" phx-submit="search" phx-change="search">
          <input
            type="text"
            name="q"
            value={@q}
            placeholder="search links"
            autocomplete="off"
            phx-debounce="300"
          />
        </form>
      </div>

      <div class="railbar">
        <span
          :for={t <- ~w(1d 3d 1w 1mo 1y)}
          class={["ctl", @timeframe == t && "on"]}
          phx-click="set-window"
          phx-value-t={if @timeframe == t, do: "", else: t}
        >{t}</span>
        <span class="sep">|</span>
        <span class={["ctl", @shuffle_on && "on"]} phx-click="toggle-shuffle">shuffle</span>
        <span class="sep">|</span>
        <span
          :for={tag <- Enum.take(Enum.filter(@tags, &(&1.count >= 2)), 28)}
          class={["tag", tag.name in @selected_tags && "on"]}
          phx-click="toggle-tag"
          phx-value-tag={tag.name}
        >{tag.name}<span class="tcount">{tag.count}</span></span>
        <span
          :if={@q != "" or @selected_tags != [] or @timeframe}
          class="ctl"
          phx-click="clear"
          style="margin-left:auto;"
        >clear filters ✕</span>
      </div>

      <div class="sheet" id="sheet">
        <div :if={@blinks == []} class="empty">nothing here. go save some links.</div>

        <div
          :for={{blink, i} <- Enum.with_index(@blinks, (@page - 1) * @page_size + 1)}
          class={["card", blink.dead_at && "dead"]}
          id={"rcard-#{blink.id}"}
        >
          <div class="toprow">
            <span class="rank">{i}</span>
            <img :if={blink.favicon_url} class="favicon" src={blink.favicon_url} loading="lazy" />
            <a class="site" href={"/blinks-reader?" <> URI.encode_query(q: domain(blink.url))}>
              {site_label(blink)}
            </a>
            <span class="when">{stamp(blink.inserted_at)}</span>
          </div>

          <a
            class="title"
            href={if blink.dead_at, do: "https://web.archive.org/web/2/" <> blink.url, else: blink.url}
            target="_blank"
            rel="noopener"
            title={blink.dead_at && "original link is dead — points at the wayback copy"}
          >
            {headline(blink)}
          </a>

          <div :if={blink.quotes != [] && blink.title} class="subtitle">{blink.title}</div>
          <div :if={blink.description && blink.description != ""} class="desc">{blink.description}</div>
          <div :if={root_quote(blink)} class="bquote">
            ↳ <b>@{root_quote(blink)["handle"]}</b>: “{root_quote(blink)["text"]}”
          </div>

          <div :if={Map.has_key?(@media_by_blink, blink.id)} class="strip">
            <button
              :for={shot <- Map.get(@media_by_blink, blink.id, [])}
              type="button"
              class="shot"
              phx-click="open-media"
              phx-value-idx={shot.idx}
              title="click to enlarge"
            >
              <img src={shot.thumb} alt={shot.alt} loading="lazy" />
              <span :if={shot.kind == :video} class="play">▶</span>
            </button>
          </div>

          <div class="foot">
            <span
              :for={tag <- blink.tags}
              class={["tag", tag in @selected_tags && "on"]}
              phx-click="toggle-tag"
              phx-value-tag={tag}
            >{tag}</span>
            <a href={"https://web.archive.org/web/*/" <> blink.url} target="_blank" rel="noopener">
              wayback
            </a>
          </div>
        </div>

        <div :if={@blinks != []} class="pager">
          <span :if={@page > 1} class="pg" phx-click="prev-page">‹ prev</span>
          <span :if={@has_more} class="pg" phx-click="more">more ›</span>
        </div>
      </div>

      <div
        :if={current_media(assigns)}
        class="lb"
        phx-window-keydown="media-key"
        phx-click="close-media"
      >
        <% shot = current_media(assigns) %>
        <button type="button" class="lbclose" phx-click="close-media" aria-label="close">✕</button>
        <button
          :if={length(@gallery) > 1}
          type="button"
          class="lbnav lbprev"
          phx-click="step-media"
          phx-value-by="-1"
          aria-label="previous"
        >‹</button>
        <button
          :if={length(@gallery) > 1}
          type="button"
          class="lbnav lbnext"
          phx-click="step-media"
          phx-value-by="1"
          aria-label="next"
        >›</button>

        <div class="lbstage">
          <img src={shot.full} alt={shot.alt} />
        </div>

        <div class="lbalt" :if={shot.alt != ""}>{shot.alt}</div>

        <div class="lbbar">
          <span class="lbtitle">{headline(shot.blink)}</span>
          <a href={shot.blink.url} target="_blank" rel="noopener">
            {if shot.kind == :video, do: "▶ watch on #{site_label(shot.blink)}", else: "open #{site_label(shot.blink)}"}
          </a>
          <span :if={shot.kind == :video} class="lbvideo">still frame — playback lives on the source</span>
          <span class="lbcount">{@lightbox + 1} / {length(@gallery)} · ← → to browse, esc to close</span>
        </div>
      </div>
    </div>
    """
  end
end
