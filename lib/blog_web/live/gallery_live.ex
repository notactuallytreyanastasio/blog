defmodule BlogWeb.GalleryLive do
  @moduledoc """
  An iCloud Shared Album browsed like the iCloud web app, dressed as System 7.

  The grid is server-rendered from `Blog.Gallery`. The viewer window is owned
  entirely by the `GalleryAmbient` JS hook — it holds the shuffled deck, runs
  the crossfade and the drift, and is marked `phx-update="ignore"` so a
  LiveView patch never interrupts a fade in progress. The server talks to it
  only through `push_event/3`.
  """
  use BlogWeb, :live_view

  alias Blog.Gallery

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Gallery.subscribe()

    photos = Gallery.photos()

    {:ok,
     socket
     |> assign(:page_title, Gallery.album_name())
     |> assign(:album, Gallery.album_name())
     |> assign(:configured, Gallery.configured?())
     |> assign_photos(photos)}
  end

  @impl true
  def handle_info({:gallery, :updated, photos}, socket) do
    # New photos arrive without a reload: the grid re-renders and the hook
    # splices the additions into its deck.
    {:noreply,
     socket
     |> assign(:album, Gallery.album_name())
     |> assign_photos(photos)
     |> push_event("gallery:photos", %{photos: payload(photos)})}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl true
  def handle_event("open", %{"guid" => guid}, socket) do
    {:noreply, push_event(socket, "gallery:show", %{guid: guid})}
  end

  def handle_event("slideshow", _params, socket) do
    {:noreply, push_event(socket, "gallery:slideshow", %{})}
  end

  defp assign_photos(socket, photos) do
    socket
    |> assign(:photos, photos)
    |> assign(:count, length(photos))
    |> assign(:groups, group_by_month(photos))
    |> assign(:payload, Jason.encode!(payload(photos)))
  end

  defp payload(photos) do
    Enum.map(photos, fn p ->
      %{
        guid: p.guid,
        w: p.width,
        h: p.height,
        caption: p.caption,
        date: pretty_date(p.created_at)
      }
    end)
  end

  # iCloud's web album breaks the grid into date sections; so does this.
  defp group_by_month(photos) do
    photos
    |> Enum.chunk_by(fn p -> month_key(p.created_at) end)
    |> Enum.map(fn chunk ->
      {month_label(List.first(chunk).created_at), chunk}
    end)
  end

  defp month_key(nil), do: :undated
  defp month_key(%DateTime{year: y, month: m}), do: {y, m}

  defp month_label(nil), do: "Undated"

  defp month_label(%DateTime{year: y, month: m}),
    do: "#{month_name(m)} #{y}"

  defp month_name(m) do
    elem(
      {"January", "February", "March", "April", "May", "June", "July", "August", "September",
       "October", "November", "December"},
      m - 1
    )
  end

  defp pretty_date(nil), do: nil

  defp pretty_date(%DateTime{} = dt),
    do: "#{month_name(dt.month)} #{dt.day}, #{dt.year}"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="gal" id="gal-desktop" phx-hook="GalleryAmbient" data-photos={@payload}>
      <div class="gal-menubar">
        <div class="gal-menu-left">
          <span class="gal-apple">&#63743;</span>
          <span class="gal-menu-item">File</span>
          <span class="gal-menu-item">Edit</span>
          <span class="gal-menu-item">View</span>
          <span class="gal-menu-item">Special</span>
        </div>
        <div class="gal-menu-right">{@album}</div>
      </div>

      <div class="gal-deskspace">
        <div class="gal-win gal-albumwin">
          <div class="gal-titlebar">
            <.link navigate={~p"/"} class="gal-close" title="Close"></.link>
            <div class="gal-title">{@album}</div>
            <div class="gal-resize"></div>
          </div>

          <div class="gal-infobar">
            <span>{@count} {if @count == 1, do: "item", else: "items"}</span>
            <span class="gal-sep"></span>
            <span class="gal-dim">shared album</span>
            <button class="gal-btn" phx-click="slideshow" disabled={@count == 0}>
              Slideshow
            </button>
          </div>

          <div class="gal-body">
            <div class="gal-scroll" data-gal="scroll">
            <div :if={@count == 0} class="gal-empty">
              <div class="gal-empty-icon"></div>
              <p :if={@configured}>
                This folder is empty. The album is still syncing from iCloud —
                it fills in within a minute or two of boot.
              </p>
              <p :if={!@configured}>
                No album connected. Set <code>ICLOUD_ALBUM_TOKEN</code> and restart.
              </p>
            </div>

            <div :for={{label, chunk} <- @groups} class="gal-group">
              <div class="gal-grouphead">{label}</div>
              <div class="gal-grid">
                <button
                  :for={photo <- chunk}
                  class="gal-cell"
                  phx-click="open"
                  phx-value-guid={photo.guid}
                  title={photo.caption || label}
                >
                  <img
                    src={~p"/gallery/img/#{photo.guid}/thumb"}
                    loading="lazy"
                    decoding="async"
                    alt={photo.caption || "Photo from #{label}"}
                  />
                </button>
              </div>
            </div>
            </div>

            <div class="gal-sbar" data-gal="sbar" aria-hidden="true">
              <button class="gal-sb-arrow up" data-gal="sb-up"></button>
              <div class="gal-sb-track" data-gal="sb-track">
                <div class="gal-sb-thumb" data-gal="sb-thumb"></div>
              </div>
              <button class="gal-sb-arrow down" data-gal="sb-down"></button>
            </div>
          </div>
        </div>
      </div>

      <div class="gal-viewer" id="gal-viewer" phx-update="ignore" hidden>
        <div class="gal-win gal-viewerwin" id="gal-viewerwin">
          <div class="gal-titlebar">
            <a class="gal-close" data-gal="close" title="Close"></a>
            <div class="gal-title" data-gal="title">Photo</div>
            <div class="gal-resize"></div>
          </div>

          <div class="gal-stage" data-gal="stage">
            <div class="gal-backdrop" data-gal="backdrop"></div>
            <img class="gal-layer" data-gal="layer-a" alt="" />
            <img class="gal-layer" data-gal="layer-b" alt="" />
            <button class="gal-nav prev" data-gal="prev" aria-label="Previous">&#8249;</button>
            <button class="gal-nav next" data-gal="next" aria-label="Next">&#8250;</button>
          </div>

          <div class="gal-controls">
            <button class="gal-btn" data-gal="prev">&#9664;</button>
            <button class="gal-btn gal-btn-default" data-gal="toggle">Pause</button>
            <button class="gal-btn" data-gal="next">&#9654;</button>
            <span class="gal-counter" data-gal="counter"></span>
            <span class="gal-caption" data-gal="caption"></span>
            <button class="gal-btn" data-gal="shuffle" title="Reshuffle the deck">Shuffle</button>
          </div>
        </div>
      </div>

      <style>
        <%= raw(styles()) %>
      </style>
    </div>
    """
  end

  defp styles do
    """
    .gal {
      min-height: 100vh;
      /* The classic 50% dither, drawn as a 2px checker rather than an image. */
      background-color: #8f8f9c;
      background-image:
        linear-gradient(45deg, #7e7e8c 25%, transparent 25%, transparent 75%, #7e7e8c 75%),
        linear-gradient(45deg, #7e7e8c 25%, transparent 25%, transparent 75%, #7e7e8c 75%);
      background-size: 4px 4px;
      background-position: 0 0, 2px 2px;
      font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
      font-size: 13px;
      color: #000;
      -webkit-font-smoothing: none;
    }
    .gal *, .gal *::before, .gal *::after { box-sizing: border-box; }
    .gal a { color: #000; text-decoration: none; }
    .gal button { font-family: inherit; color: #000; }

    /* ---- Menu bar ---- */
    .gal-menubar {
      position: sticky; top: 0; z-index: 30; height: 24px; background: #fff;
      border-bottom: 1px solid #000; display: flex; justify-content: space-between;
      align-items: center; padding: 0 8px;
    }
    .gal-menu-left { display: flex; gap: 16px; align-items: center; }
    .gal-apple { font-family: system-ui; font-size: 15px; line-height: 1; }
    .gal-menu-item { font-size: 14px; padding: 0 2px; }
    .gal-menu-item:hover, .gal-apple:hover { background: #000; color: #fff; }
    .gal-menu-right { font-size: 13px; }

    /* ---- Window chrome ---- */
    .gal-deskspace { padding: 22px 22px 80px; }
    .gal-win { background: #fff; border: 1px solid #000; box-shadow: 2px 2px 0 #000; }
    .gal-albumwin { max-width: 1180px; margin: 0 auto; }
    .gal-titlebar {
      height: 24px; border-bottom: 1px solid #000; display: flex; align-items: center;
      padding: 0 4px; gap: 6px; user-select: none;
      background: repeating-linear-gradient(90deg, #fff 0px, #fff 1px, #000 1px, #000 2px, #fff 2px, #fff 3px);
    }
    .gal-close {
      width: 12px; height: 12px; border: 1px solid #000; background: #fff;
      flex-shrink: 0; cursor: pointer;
    }
    .gal-close:active { background: #000; }
    .gal-resize { width: 12px; height: 12px; border: 1px solid #000; background: #fff; flex-shrink: 0; }
    .gal-title {
      flex: 1; text-align: center; background: #fff; padding: 0 10px; font-size: 13px;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }

    /* ---- Finder info bar ---- */
    .gal-infobar {
      display: flex; align-items: center; gap: 10px; padding: 3px 8px;
      border-bottom: 1px solid #000; background: #fff; font-size: 11px;
      font-family: "Geneva", "Helvetica", sans-serif;
    }
    .gal-sep { flex: 1; height: 1px; background: #000; opacity: 0.25; }
    .gal-dim { color: #555; }

    .gal-btn {
      font-family: "Chicago", "Geneva", "Helvetica", sans-serif; font-size: 12px;
      border: 1px solid #000; background: #fff; padding: 1px 10px; cursor: pointer;
      box-shadow: 1px 1px 0 #000; border-radius: 0; line-height: 17px;
    }
    .gal-btn:active { background: #000; color: #fff; transform: translate(1px, 1px); box-shadow: none; }
    .gal-btn:disabled { color: #999; border-color: #999; box-shadow: 1px 1px 0 #999; cursor: default; }
    /* System 7 marked the default button with a heavy outset ring. */
    .gal-btn-default { box-shadow: 1px 1px 0 #000, 0 0 0 2px #000; margin: 2px 3px; }
    .gal-btn-default:active { box-shadow: 0 0 0 2px #000; }

    /* ---- Grid ---- */
    /* The native scroll bar is hidden and replaced with real DOM below: the
       ::-webkit pseudo-elements are ignored under overlay scrollbars and
       Firefox never honoured them, and this window needs its elevator. */
    .gal-body { display: flex; align-items: stretch; background: #fff; }
    .gal-scroll {
      flex: 1; min-width: 0;
      max-height: calc(100vh - 190px); overflow-y: auto; overflow-x: hidden;
      padding: 10px 12px 16px;
      scrollbar-width: none;
    }
    .gal-scroll::-webkit-scrollbar { width: 0; height: 0; }

    .gal-sbar {
      width: 16px; flex-shrink: 0; border-left: 1px solid #000;
      display: flex; flex-direction: column;
    }
    .gal-sb-arrow {
      height: 16px; flex-shrink: 0; padding: 0; cursor: default;
      background-color: #fff; border: 0; border-bottom: 1px solid #000;
      background-repeat: no-repeat; background-position: center; background-size: 9px 9px;
    }
    .gal-sb-arrow.down { border-bottom: 0; border-top: 1px solid #000; }
    .gal-sb-arrow.up {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'%3E%3Cpath d='M5 2 L9 8 L1 8 Z' fill='%23000'/%3E%3C/svg%3E");
    }
    .gal-sb-arrow.down {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'%3E%3Cpath d='M5 8 L1 2 L9 2 Z' fill='%23000'/%3E%3C/svg%3E");
    }
    .gal-sb-arrow:active { background-color: #000; filter: invert(1); }
    .gal-sb-track {
      flex: 1; position: relative; min-height: 0;
      /* 50% checkerboard — the System 7 scroll track. */
      background: repeating-conic-gradient(#fff 0% 25%, #9a9a9a 0% 50%) 50% / 2px 2px;
    }
    .gal-sb-thumb {
      position: absolute; left: 0; right: 0; top: 0; height: 0;
      background: #fff; border: 1px solid #000; cursor: default;
    }
    .gal-sb-thumb:active { background: #ddd; }
    .gal-sbar.idle .gal-sb-thumb { display: none; }
    .gal-sbar.idle .gal-sb-arrow { background-color: #eee; opacity: 0.4; }

    .gal-group + .gal-group { margin-top: 18px; }
    .gal-grouphead {
      font-size: 11px; text-transform: uppercase; letter-spacing: 0.6px;
      border-bottom: 1px solid #000; padding-bottom: 2px; margin-bottom: 8px;
    }
    .gal-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(116px, 1fr)); gap: 8px; }
    .gal-cell {
      padding: 0; border: 1px solid #000; background: #eee; cursor: pointer;
      aspect-ratio: 1; overflow: hidden; display: block; position: relative;
    }
    .gal-cell img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .gal-cell:hover { box-shadow: 0 0 0 2px #000; }
    /* Selection in System 7 was an inverted swatch, not a tint. */
    .gal-cell:active img { filter: invert(1); }

    .gal-empty { padding: 60px 20px; text-align: center; color: #444; font-family: "Geneva", sans-serif; font-size: 12px; }
    .gal-empty-icon {
      width: 48px; height: 40px; margin: 0 auto 14px; border: 1px solid #000;
      background: repeating-linear-gradient(45deg, #fff, #fff 3px, #ddd 3px, #ddd 6px);
    }
    .gal-empty code { font-family: Monaco, monospace; background: #eee; padding: 0 3px; border: 1px solid #ccc; }

    /* ---- Viewer window ---- */
    .gal-viewer { position: fixed; inset: 0; z-index: 40; display: flex; align-items: center; justify-content: center; pointer-events: none; }
    .gal-viewer[hidden] { display: none; }
    .gal-viewerwin { width: min(1020px, calc(100vw - 40px)); pointer-events: auto; box-shadow: 3px 3px 0 rgba(0,0,0,0.55); }

    .gal-stage {
      position: relative; height: min(64vh, 620px); background: #000; overflow: hidden;
      border-bottom: 1px solid #000;
    }
    .gal-backdrop {
      position: absolute; inset: -24px; background-size: cover; background-position: center;
      filter: blur(22px) saturate(0.7) brightness(0.5); opacity: 0; transition: opacity 550ms ease;
    }
    .gal-layer {
      position: absolute; inset: 0; margin: auto; max-width: 100%; max-height: 100%;
      width: auto; height: auto; opacity: 0;
      /* Duration is set per-transition by the hook: out is quicker than in. */
      transition: opacity 850ms ease;
      will-change: opacity, transform;
    }
    .gal-layer.on { opacity: 1; }
    /* The slow push is what makes a still photo feel alive on a wall. */
    @keyframes gal-drift {
      from { transform: scale(1) translate(0, 0); }
      to   { transform: scale(1.075) translate(var(--gal-dx, 1%), var(--gal-dy, -1%)); }
    }
    .gal-layer.drift { animation: gal-drift var(--gal-dur, 13s) linear forwards; }

    .gal-nav {
      position: absolute; top: 0; bottom: 0; width: 64px; border: 0; background: transparent;
      color: #fff; font-size: 34px; cursor: pointer; opacity: 0; transition: opacity 180ms;
      text-shadow: 0 0 6px #000; font-family: "Geneva", sans-serif;
    }
    .gal-nav.prev { left: 0; } .gal-nav.next { right: 0; }
    .gal-stage:hover .gal-nav { opacity: 0.8; }
    .gal-nav:hover { opacity: 1 !important; background: rgba(0,0,0,0.22); }

    .gal-controls {
      display: flex; align-items: center; gap: 8px; padding: 5px 8px; background: #fff;
      font-family: "Geneva", "Helvetica", sans-serif; font-size: 11px;
    }
    .gal-counter { white-space: nowrap; }
    .gal-caption { flex: 1; color: #555; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

    @media (max-width: 640px) {
      .gal-deskspace { padding: 12px 10px 60px; }
      .gal-grid { grid-template-columns: repeat(auto-fill, minmax(94px, 1fr)); gap: 6px; }
      .gal-stage { height: 52vh; }
      .gal-caption { display: none; }
      .gal-viewerwin { width: calc(100vw - 20px); }
    }
    @media (prefers-reduced-motion: reduce) {
      .gal-layer { transition: opacity 200ms ease; }
      .gal-layer.drift { animation: none; }
    }
    """
  end
end
