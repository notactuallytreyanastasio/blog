defmodule BlogWeb.BlinksSurfLive do
  @moduledoc """
  StumbleUpon for the link stack: one link at a time, full attention, and a
  big orange button that throws the dice again.

  Every press pulls a random blink you haven't been shown this session, so a
  long session walks the whole collection without repeats before it reshuffles.
  Channels narrow the pool to one tag, `◀ back` retraces your hops, and
  `more like this` swaps the dice for the similarity ranking when something
  lands close to what you wanted.
  """
  use BlogWeb, :live_view

  alias Blog.Blinks

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Blinks: stumble",
       blink: nil,
       history: [],
       seen: MapSet.new(),
       channel: nil,
       tags: Enum.take(Blinks.list_tags(), 24),
       total: Blinks.count_blinks(),
       exhausted: false
     )}
  end

  def handle_params(params, _uri, socket) do
    channel =
      case params["tag"] do
        tag when is_binary(tag) and tag != "" -> tag
        _ -> nil
      end

    socket = assign(socket, channel: channel, pool: pool_size(channel))

    # First landing (or a channel switch that orphans the current card):
    # deal a card so the page never opens empty.
    if socket.assigns.blink == nil or not in_channel?(socket.assigns.blink, channel) do
      {:noreply, stumble(socket)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("stumble", _params, socket), do: {:noreply, stumble(socket)}

  def handle_event("back", _params, socket) do
    case socket.assigns.history do
      [prev | rest] ->
        {:noreply, assign(socket, blink: prev, history: rest, exhausted: false)}

      [] ->
        {:noreply, socket}
    end
  end

  def handle_event("more-like-this", _params, socket) do
    case socket.assigns.blink do
      nil ->
        {:noreply, socket}

      blink ->
        next =
          blink
          |> Blinks.list_similar(8)
          |> Enum.reject(&MapSet.member?(socket.assigns.seen, &1.id))
          |> case do
            [] -> blink |> Blinks.list_similar(8) |> Enum.take(3) |> random_or(nil)
            fresh -> fresh |> Enum.take(3) |> random_or(nil)
          end

        if next, do: {:noreply, deal(socket, next)}, else: {:noreply, stumble(socket)}
    end
  end

  def handle_event("channel", %{"tag" => tag}, socket) do
    {:noreply, push_patch(socket, to: ~p"/blinks/surf?#{channel_params(tag)}")}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, socket |> assign(seen: MapSet.new(), exhausted: false) |> stumble()}
  end

  def handle_event("keydown", %{"key" => key}, socket) when key in ["ArrowRight", "s"] do
    {:noreply, stumble(socket)}
  end

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    handle_event("back", %{}, socket)
  end

  def handle_event("keydown", _params, socket), do: {:noreply, socket}

  defp stumble(socket) do
    %{seen: seen, channel: channel, blink: current} = socket.assigns
    exclude = if current, do: [current.id | MapSet.to_list(seen)], else: MapSet.to_list(seen)

    case Blinks.random_blink(exclude: exclude, tags: List.wrap(channel)) do
      nil -> assign(socket, exhausted: true)
      blink -> deal(socket, blink)
    end
  end

  defp deal(socket, blink) do
    history = if socket.assigns.blink, do: [socket.assigns.blink | socket.assigns.history], else: []

    assign(socket,
      blink: blink,
      history: Enum.take(history, 50),
      seen: MapSet.put(socket.assigns.seen, blink.id),
      exhausted: false
    )
  end

  defp random_or([], default), do: default
  defp random_or(list, _default), do: Enum.random(list)

  defp in_channel?(_blink, nil), do: true
  defp in_channel?(blink, tag), do: tag in blink.tags

  defp pool_size(nil), do: Blinks.count_blinks()
  defp pool_size(tag), do: Blinks.count_blinks(tags: [tag])

  defp channel_params(""), do: %{}
  defp channel_params(tag), do: %{tag: tag}

  defp domain(url) do
    case URI.parse(url).host do
      nil -> url
      host -> String.replace_prefix(host, "www.", "")
    end
  end

  def render(assigns) do
    ~H"""
    <div id="surf-page" phx-window-keydown="keydown">
      <style>
        #surf-page { min-height: 100dvh; background: #fff; font: 12px verdana, arial, helvetica, sans-serif; color: #000; display: flex; flex-direction: column; }
        #surf-page .bar { background: #cee3f8; border-bottom: 1px solid #5f99cf; padding: 6px 10px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        #surf-page .bar a { color: #369; text-decoration: none; font-size: 11px; }
        #surf-page .bar a:hover { text-decoration: underline; }
        #surf-page .wordmark { font-weight: bold; font-size: 13px; color: #369; }
        #surf-page .wordmark a { font-size: 13px; }
        #surf-page .stumble-btn { font: bold 15px verdana; color: #fff; background: #ff4500; border: 3px outset #ff8c61; border-radius: 4px; padding: 8px 22px; cursor: pointer; letter-spacing: 1px; }
        #surf-page .stumble-btn:active { border-style: inset; background: #b33000; }
        #surf-page .back-btn { font: bold 12px verdana; color: #369; background: #b9d2ec; border: 2px outset #cee3f8; border-radius: 4px; padding: 8px 12px; cursor: pointer; }
        #surf-page .back-btn:disabled { color: #99a; cursor: default; }
        #surf-page .bar select { font-size: 11px; border: 1px solid #5f99cf; background: #fff; color: #369; }
        #surf-page .meter { margin-left: auto; color: #666; font-size: 10px; }
        #surf-page .stage { flex: 1; display: flex; align-items: center; justify-content: center; padding: 24px 16px 40px; }
        #surf-page .card { max-width: 660px; width: 100%; border: 1px solid #5f99cf; border-radius: 4px; box-shadow: 3px 3px 0 #cee3f8; overflow: hidden; }
        #surf-page .card-img { display: block; width: 100%; max-height: 44vh; object-fit: cover; border-bottom: 1px solid #cee3f8; background: #f5f9fd; }
        #surf-page .card-body { padding: 14px 18px 16px; }
        #surf-page .site { color: #666; font-size: 10px; display: flex; align-items: center; gap: 5px; margin-bottom: 6px; }
        #surf-page .site img { width: 12px; height: 12px; }
        #surf-page .card h2 { margin: 0 0 8px; font-size: 19px; line-height: 1.25; }
        #surf-page .card h2 a { color: #00e; text-decoration: none; }
        #surf-page .card h2 a:visited { color: #551a8b; }
        #surf-page .card h2 a:hover { text-decoration: underline; }
        #surf-page .desc { color: #333; font-size: 12px; line-height: 1.5; max-width: 62ch; }
        #surf-page .quote { font-style: italic; color: #555; font-size: 11px; border-left: 3px solid #cee3f8; padding-left: 8px; margin: 8px 0; white-space: pre-wrap; }
        #surf-page .tagrow { margin-top: 10px; }
        #surf-page .tag { display: inline-block; background: #f5f5f5; border: 1px solid #ddd; border-radius: 2px; color: #369; font-size: 9px; padding: 1px 4px; margin: 0 3px 3px 0; cursor: pointer; }
        #surf-page .tag:hover, #surf-page .tag.on { background: #cee3f8; border-color: #5f99cf; }
        #surf-page .card-actions { display: flex; align-items: center; gap: 8px; border-top: 1px solid #eee; padding: 10px 18px; background: #fafcff; }
        #surf-page .visit { font: bold 12px verdana; color: #fff; background: #369; border: 2px outset #5f99cf; border-radius: 3px; padding: 5px 14px; text-decoration: none; }
        #surf-page .visit:active { border-style: inset; }
        #surf-page .morelike { font-size: 10px; color: #369; background: none; border: none; cursor: pointer; text-decoration: underline; }
        #surf-page .saved-on { margin-left: auto; color: #999; font-size: 10px; }
        #surf-page .hint { text-align: center; color: #999; font-size: 10px; padding-bottom: 14px; }
        #surf-page kbd { border: 1px solid #ccc; border-radius: 2px; background: #f5f5f5; padding: 0 3px; font-size: 9px; }
        #surf-page .exhausted { text-align: center; }
        #surf-page .exhausted h2 { color: #369; }
        @media (max-width: 700px) { #surf-page .meter { display: none; } }
      </style>

      <div class="bar">
        <span class="wordmark"><a href="/blinks">bobbby's links</a> / stumble 🎲</span>
        <button class="stumble-btn" phx-click="stumble">STUMBLE!</button>
        <button class="back-btn" phx-click="back" disabled={@history == []}>◀ back</button>
        <form phx-change="channel">
          <select name="tag">
            <option value="" selected={is_nil(@channel)}>all channels</option>
            <option :for={t <- @tags} value={t.name} selected={@channel == t.name}>
              {t.name} ({t.count})
            </option>
          </select>
        </form>
        <span class="meter">
          {MapSet.size(@seen)} stumbled · {@pool} in channel
        </span>
        <a href="/blinks/walk">walk 🥾</a>
        <a href="/blinks/tv">tv 📺</a>
      </div>

      <div class="stage">
        <div :if={@exhausted} class="exhausted">
          <h2>you've stumbled the whole channel 🏁</h2>
          <p>all {@pool} links seen this session.</p>
          <button class="stumble-btn" phx-click="reset">SHUFFLE &amp; GO AGAIN</button>
        </div>

        <div :if={!@exhausted && @blink} class="card" id={"surf-card-#{@blink.id}"}>
          <a :if={@blink.image_url} href={@blink.url} target="_blank" rel="noopener">
            <img class="card-img" src={@blink.image_url} alt="" loading="lazy" />
          </a>
          <div class="card-body">
            <div class="site">
              <img :if={@blink.favicon_url} src={@blink.favicon_url} alt="" />
              <span>{@blink.site_name || domain(@blink.url)}</span>
            </div>
            <h2>
              <a href={@blink.url} target="_blank" rel="noopener">
                {@blink.title || @blink.url}
              </a>
            </h2>
            <p :if={@blink.description} class="desc">{@blink.description}</p>
            <blockquote :for={q <- Enum.take(@blink.quotes, 2)} class="quote">{q}</blockquote>
            <div :if={@blink.tags != []} class="tagrow">
              <a
                :for={tag <- @blink.tags}
                class={["tag", @channel == tag && "on"]}
                phx-click="channel"
                phx-value-tag={tag}
              >
                {tag}
              </a>
            </div>
          </div>
          <div class="card-actions">
            <a class="visit" href={@blink.url} target="_blank" rel="noopener">visit ↗</a>
            <button class="morelike" phx-click="more-like-this">more like this</button>
            <span class="saved-on">
              saved {Calendar.strftime(@blink.inserted_at, "%b %-d, %Y")}
            </span>
          </div>
        </div>
      </div>

      <div class="hint">
        <kbd>→</kbd> or <kbd>s</kbd> stumble · <kbd>←</kbd> back · click a tag to tune the channel
      </div>
    </div>
    """
  end
end
