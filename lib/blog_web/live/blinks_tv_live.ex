defmodule BlogWeb.BlinksTvLive do
  @moduledoc """
  Lean-back mode: the stack as late-night cable.

  The screen tunes itself to a new link every few seconds with a burst of
  static; the top tags are the channels. No decisions required — put it on a
  spare monitor and let the collection wash over you. Click the screen (or hit
  enter) when something good is on.

  Channel surfing: `↑`/`↓` change channel, `→` skips ahead, `space` pauses.
  """
  use BlogWeb, :live_view

  alias Blog.Blinks

  # Long enough to read a title + description, short enough to feel like TV.
  @dwell :timer.seconds(9)
  @channel_count 12
  @no_repeat_window 25

  def mount(_params, _session, socket) do
    channels = [nil | Blinks.list_tags() |> Enum.take(@channel_count) |> Enum.map(& &1.name)]

    socket =
      assign(socket,
        page_title: "Blinks TV",
        channels: channels,
        ch_idx: 0,
        playing: true,
        recent: [],
        blink: nil,
        timer: nil
      )

    {:ok, socket |> tune() |> rearm()}
  end

  def handle_info(:tick, socket) do
    socket = if socket.assigns.playing, do: tune(socket), else: socket
    {:noreply, rearm(socket)}
  end

  def handle_event("next", _params, socket), do: {:noreply, socket |> tune() |> rearm()}

  def handle_event("toggle-play", _params, socket) do
    {:noreply, socket |> assign(playing: !socket.assigns.playing) |> rearm()}
  end

  def handle_event("channel-up", _params, socket), do: {:noreply, zap(socket, 1)}
  def handle_event("channel-down", _params, socket), do: {:noreply, zap(socket, -1)}

  def handle_event("keydown", %{"key" => key}, socket) do
    case key do
      "ArrowUp" -> {:noreply, zap(socket, 1)}
      "ArrowDown" -> {:noreply, zap(socket, -1)}
      "ArrowRight" -> {:noreply, socket |> tune() |> rearm()}
      " " -> handle_event("toggle-play", %{}, socket)
      _ -> {:noreply, socket}
    end
  end

  defp zap(socket, step) do
    idx = Integer.mod(socket.assigns.ch_idx + step, length(socket.assigns.channels))

    socket
    |> assign(ch_idx: idx, recent: [])
    |> tune()
    |> rearm()
  end

  defp tune(socket) do
    channel = Enum.at(socket.assigns.channels, socket.assigns.ch_idx)

    case Blinks.random_blink(
           exclude: socket.assigns.recent,
           tags: List.wrap(channel),
           with_image: true
         ) do
      nil ->
        # Channel exhausted within the no-repeat window — clear it and loop.
        # (With an already-empty window the stack itself is empty: no signal.)
        if socket.assigns.recent == [] do
          assign(socket, blink: nil)
        else
          tune(assign(socket, recent: []))
        end

      blink ->
        assign(socket,
          blink: blink,
          recent: Enum.take([blink.id | socket.assigns.recent], @no_repeat_window)
        )
    end
  end

  # (Re)start the dwell clock — one live timer at a time, so manual skips and
  # channel zaps don't stack ticks.
  defp rearm(socket) do
    if socket.assigns.timer, do: Process.cancel_timer(socket.assigns.timer)

    if connected?(socket) do
      assign(socket, timer: Process.send_after(self(), :tick, @dwell))
    else
      assign(socket, timer: nil)
    end
  end

  defp channel_label(channels, idx) do
    case Enum.at(channels, idx) do
      nil -> "ALL"
      tag -> String.upcase(tag)
    end
  end

  defp domain(url) do
    case URI.parse(url).host do
      nil -> url
      host -> String.replace_prefix(host, "www.", "")
    end
  end

  def render(assigns) do
    ~H"""
    <div id="tv-page" phx-window-keydown="keydown">
      <style>
        #tv-page { height: 100dvh; background: #111; color: #fff; font: 12px verdana, arial, helvetica, sans-serif; display: flex; flex-direction: column; overflow: hidden; }
        #tv-page .screen { position: relative; flex: 1; overflow: hidden; background: #000; }
        #tv-page .frame { position: absolute; inset: 0; display: block; color: inherit; text-decoration: none; }
        #tv-page .still { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; filter: saturate(1.15) contrast(1.05); }
        #tv-page .no-still { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; padding: 8vw; background: repeating-linear-gradient(45deg, #16213a 0 40px, #101830 40px 80px); }
        #tv-page .no-still span { font: bold 5vmin georgia, serif; line-height: 1.2; color: #cee3f8; text-shadow: 3px 3px 0 #000; text-align: center; }
        #tv-page .scanlines { position: absolute; inset: 0; pointer-events: none; background: repeating-linear-gradient(0deg, rgba(0,0,0,0.22) 0 1px, transparent 1px 3px); }
        #tv-page .vignette { position: absolute; inset: 0; pointer-events: none; box-shadow: inset 0 0 18vmin rgba(0,0,0,0.85); }
        #tv-page .static { position: absolute; inset: 0; pointer-events: none; mix-blend-mode: hard-light; background-image: repeating-radial-gradient(circle at 17% 32%, #000 0 1px, transparent 1px 2px), repeating-radial-gradient(circle at 73% 61%, #fff 0 1px, transparent 1px 3px), repeating-linear-gradient(0deg, rgba(0,0,0,0.35) 0 1px, transparent 1px 3px); background-size: 7px 7px, 11px 11px, 100% 4px; animation: tv-staticfuzz 1.1s steps(8) both; opacity: 0; }
        @keyframes tv-staticfuzz {
          0% { opacity: 0.95; background-position: 0 0, 0 0, 0 0; }
          25% { background-position: 3px 2px, -4px 3px, 0 2px; opacity: 0.8; }
          50% { background-position: -2px 4px, 5px -2px, 0 -1px; opacity: 0.5; }
          75% { background-position: 4px -3px, -3px -4px, 0 3px; opacity: 0.2; }
          100% { opacity: 0; }
        }
        #tv-page .osd { position: absolute; font: bold 2.6vmin 'Courier New', monospace; color: #3f3; text-shadow: 0 0 6px rgba(51,255,51,0.7), 2px 2px 0 #000; letter-spacing: 2px; }
        #tv-page .osd-ch { top: 3vmin; right: 3.5vmin; }
        #tv-page .osd-mode { top: 3vmin; left: 3.5vmin; }
        #tv-page .osd-date { top: 6.5vmin; left: 3.5vmin; font-size: 2vmin; }
        #tv-page .caption { position: absolute; left: 0; right: 0; bottom: 0; padding: 10vmin 4vmin 3vmin; background: linear-gradient(transparent, rgba(0,0,0,0.92)); }
        #tv-page .caption .site { color: #9db8d4; font-size: 11px; margin-bottom: 4px; display: flex; align-items: center; gap: 6px; }
        #tv-page .caption .site img { width: 13px; height: 13px; }
        #tv-page .caption h2 { margin: 0 0 5px; font: bold 3.4vmin georgia, serif; line-height: 1.2; text-shadow: 2px 2px 0 #000; }
        #tv-page .caption .desc { color: #ccc; font-size: 12px; max-width: 75ch; line-height: 1.45; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        #tv-page .caption .tag { display: inline-block; background: rgba(206,227,248,0.15); border: 1px solid #5f99cf; border-radius: 2px; color: #cee3f8; font-size: 9px; padding: 0 4px; margin: 6px 4px 0 0; }
        #tv-page .deck { background: #c0c0c0; border-top: 2px solid #dfdfdf; padding: 6px 10px; display: flex; align-items: center; gap: 8px; color: #000; flex-wrap: wrap; }
        #tv-page .deck a { color: #369; font-size: 11px; text-decoration: none; }
        #tv-page .deck a:hover { text-decoration: underline; }
        #tv-page .wordmark { font-weight: bold; font-size: 12px; color: #000; }
        #tv-page .vcr-btn { font: bold 12px verdana; background: #c0c0c0; color: #000; border: 2px solid; border-color: #fff #404040 #404040 #fff; padding: 4px 12px; cursor: pointer; }
        #tv-page .vcr-btn:active { border-color: #404040 #fff #fff #404040; }
        #tv-page .deck .spacer { margin-left: auto; }
        #tv-page .deck .hint { color: #555; font-size: 9px; }
      </style>

      <div class="screen">
        <a
          :if={@blink}
          class="frame"
          id={"tv-frame-#{@blink.id}"}
          href={@blink.url}
          target="_blank"
          rel="noopener"
          title="click to visit"
        >
          <img :if={@blink.image_url} class="still" src={@blink.image_url} alt="" />
          <div :if={!@blink.image_url} class="no-still">
            <span>{@blink.title || domain(@blink.url)}</span>
          </div>
          <div class="scanlines"></div>
          <div class="vignette"></div>
          <div class="caption">
            <div class="site">
              <img :if={@blink.favicon_url} src={@blink.favicon_url} alt="" />
              <span>{@blink.site_name || domain(@blink.url)}</span>
            </div>
            <h2>{@blink.title || @blink.url}</h2>
            <p :if={@blink.description} class="desc">{@blink.description}</p>
            <span :for={tag <- Enum.take(@blink.tags, 6)} class="tag">{tag}</span>
          </div>
          <div class="static"></div>
          <span class="osd osd-ch">CH {String.pad_leading("#{@ch_idx}", 2, "0")} · {channel_label(@channels, @ch_idx)}</span>
          <span class="osd osd-mode">{if @playing, do: "▶ PLAY", else: "⏸ PAUSE"}</span>
          <span class="osd osd-date">SAVED {Calendar.strftime(@blink.inserted_at, "%b %-d %Y")}</span>
        </a>
        <div :if={is_nil(@blink)} class="no-still"><span>NO SIGNAL</span></div>
      </div>

      <div class="deck">
        <span class="wordmark">📺 blinks tv</span>
        <button class="vcr-btn" phx-click="channel-down">CH ▼</button>
        <button class="vcr-btn" phx-click="channel-up">CH ▲</button>
        <button class="vcr-btn" phx-click="next">NEXT ⏭</button>
        <button class="vcr-btn" phx-click="toggle-play">
          {if @playing, do: "PAUSE ⏸", else: "PLAY ▶"}
        </button>
        <span class="spacer"></span>
        <span class="hint">↑↓ channel · → skip · space pause · click screen to visit</span>
        <a href="/blinks">all links</a>
        <a href="/blinks/surf">stumble 🎲</a>
        <a href="/blinks/walk">walk 🥾</a>
      </div>
    </div>
    """
  end
end
