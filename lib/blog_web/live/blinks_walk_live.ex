defmodule BlogWeb.BlinksWalkLive do
  @moduledoc """
  A wiki-walk through the stack: start anywhere, and every card offers a few
  doors out.

  Where `/blinks/surf` is pure dice, this one is a choose-your-own-adventure —
  the doors are the three nearest neighbors by shared tags + title similarity
  (the same ranking `/blinks` uses for "similar"), plus one wildcard that can
  teleport you anywhere. The trail you've walked stays on screen, and clicking
  a crumb rewinds to that fork to try a different door.
  """
  use BlogWeb, :live_view

  alias Blog.Blinks

  def mount(params, _session, socket) do
    start =
      case Integer.parse(params["from"] || "") do
        {id, ""} -> Blinks.get_blink(id)
        _ -> nil
      end || Blinks.random_blink()

    {:ok,
     socket
     |> assign(page_title: "Blinks: walk", trail: [])
     |> arrive(start)}
  end

  def handle_event("step", %{"id" => id}, socket) do
    case Blinks.get_blink(id) do
      nil -> {:noreply, socket}
      blink -> {:noreply, arrive(socket, blink)}
    end
  end

  def handle_event("wildcard", _params, socket) do
    walked = Enum.map(socket.assigns.trail, & &1.id)
    walked = if socket.assigns.blink, do: [socket.assigns.blink.id | walked], else: walked

    case Blinks.random_blink(exclude: walked) do
      nil -> {:noreply, socket}
      blink -> {:noreply, arrive(socket, blink)}
    end
  end

  def handle_event("rewind", %{"id" => id}, socket) do
    {id, ""} = Integer.parse(id)

    case Enum.split_while(socket.assigns.trail, &(&1.id != id)) do
      {_skipped, [stop | earlier]} ->
        # Everything after the crumb (including the current stop) is abandoned,
        # so blank the current blink before arriving to keep it off the trail.
        {:noreply,
         socket
         |> assign(blink: nil, trail: earlier)
         |> arrive(stop)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("restart", _params, socket) do
    {:noreply, socket |> assign(trail: []) |> arrive(Blinks.random_blink())}
  end

  # Make `blink` the current stop: push the old stop onto the trail and lay
  # out fresh doors from here.
  defp arrive(socket, nil), do: assign(socket, blink: nil, doors: [])

  defp arrive(socket, blink) do
    trail =
      case socket.assigns[:blink] do
        nil -> socket.assigns.trail
        prev -> [prev | socket.assigns.trail]
      end

    walked = MapSet.new([blink.id | Enum.map(trail, & &1.id)])

    doors =
      blink
      |> Blinks.list_similar(12)
      |> Enum.reject(&MapSet.member?(walked, &1.id))
      |> Enum.take(3)

    assign(socket, blink: blink, trail: trail, doors: doors)
  end

  defp shared_tags(door, blink), do: Enum.filter(door.tags, &(&1 in blink.tags))

  defp domain(url) do
    case URI.parse(url).host do
      nil -> url
      host -> String.replace_prefix(host, "www.", "")
    end
  end

  def render(assigns) do
    ~H"""
    <div id="walk-page">
      <style>
        #walk-page { min-height: 100dvh; background: #fff; font: 12px verdana, arial, helvetica, sans-serif; color: #000; display: flex; flex-direction: column; }
        #walk-page .bar { background: #cee3f8; border-bottom: 1px solid #5f99cf; padding: 6px 10px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        #walk-page .bar a { color: #369; text-decoration: none; font-size: 11px; }
        #walk-page .bar a:hover { text-decoration: underline; }
        #walk-page .wordmark { font-weight: bold; font-size: 13px; color: #369; }
        #walk-page .wordmark a { font-size: 13px; }
        #walk-page .restart { font: bold 11px verdana; color: #369; background: #b9d2ec; border: 2px outset #cee3f8; border-radius: 3px; padding: 3px 10px; cursor: pointer; }
        #walk-page .bar .others { margin-left: auto; display: flex; gap: 10px; }
        #walk-page .trail { padding: 8px 14px 0; font-size: 10px; color: #999; line-height: 2; }
        #walk-page .crumb { color: #369; cursor: pointer; text-decoration: underline; }
        #walk-page .crumb-here { color: #000; font-weight: bold; }
        #walk-page .stage { flex: 1; max-width: 720px; width: 100%; margin: 0 auto; padding: 12px 16px 40px; box-sizing: border-box; }
        #walk-page .here { border: 1px solid #5f99cf; border-radius: 4px; box-shadow: 3px 3px 0 #cee3f8; overflow: hidden; margin-bottom: 18px; }
        #walk-page .here-img { display: block; width: 100%; max-height: 36vh; object-fit: cover; border-bottom: 1px solid #cee3f8; background: #f5f9fd; }
        #walk-page .here-body { padding: 12px 16px 14px; }
        #walk-page .site { color: #666; font-size: 10px; display: flex; align-items: center; gap: 5px; margin-bottom: 5px; }
        #walk-page .site img { width: 12px; height: 12px; }
        #walk-page .here h2 { margin: 0 0 6px; font-size: 17px; line-height: 1.3; }
        #walk-page .here h2 a { color: #00e; text-decoration: none; }
        #walk-page .here h2 a:hover { text-decoration: underline; }
        #walk-page .desc { color: #333; font-size: 12px; line-height: 1.5; max-width: 64ch; }
        #walk-page .tag { display: inline-block; background: #f5f5f5; border: 1px solid #ddd; border-radius: 2px; color: #369; font-size: 9px; padding: 0 3px; margin: 6px 3px 0 0; }
        #walk-page .doors-label { font-weight: bold; color: #369; font-size: 11px; margin: 0 0 6px; }
        #walk-page .doors { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 8px; }
        #walk-page .door { text-align: left; background: #fafcff; border: 1px solid #cee3f8; border-radius: 3px; padding: 9px 10px; cursor: pointer; font: 11px verdana; }
        #walk-page .door:hover { border-color: #5f99cf; background: #f0f6fc; }
        #walk-page .door b { color: #00e; font-size: 12px; display: block; margin-bottom: 3px; line-height: 1.3; }
        #walk-page .door .via { color: #999; font-size: 9px; }
        #walk-page .door .via .tag { margin-top: 3px; }
        #walk-page .door.wild { background: #fffbe6; border-color: #e8d76f; }
        #walk-page .door.wild:hover { border-color: #cbb52e; }
        #walk-page .door.wild b { color: #b33000; }
      </style>

      <div class="bar">
        <span class="wordmark"><a href="/blinks">bobbby's links</a> / walk 🥾</span>
        <button class="restart" phx-click="restart">start over somewhere random</button>
        <span class="others">
          <a href="/blinks/surf">stumble 🎲</a>
          <a href="/blinks/tv">tv 📺</a>
        </span>
      </div>

      <div :if={@trail != []} class="trail">
        <%= for stop <- Enum.reverse(@trail) do %>
          <span class="crumb" phx-click="rewind" phx-value-id={stop.id}>
            {stop.title || domain(stop.url)}
          </span>
          <span> → </span>
        <% end %>
        <span :if={@blink} class="crumb-here">{@blink.title || domain(@blink.url)}</span>
      </div>

      <div class="stage" :if={@blink}>
        <div class="here" id={"walk-here-#{@blink.id}"}>
          <a :if={@blink.image_url} href={@blink.url} target="_blank" rel="noopener">
            <img class="here-img" src={@blink.image_url} alt="" loading="lazy" />
          </a>
          <div class="here-body">
            <div class="site">
              <img :if={@blink.favicon_url} src={@blink.favicon_url} alt="" />
              <span>{@blink.site_name || domain(@blink.url)}</span>
            </div>
            <h2>
              <a href={@blink.url} target="_blank" rel="noopener">{@blink.title || @blink.url}</a>
            </h2>
            <p :if={@blink.description} class="desc">{@blink.description}</p>
            <span :for={tag <- @blink.tags} class="tag">{tag}</span>
          </div>
        </div>

        <p class="doors-label">where to next?</p>
        <div class="doors">
          <button :for={door <- @doors} class="door" phx-click="step" phx-value-id={door.id}>
            <b>{door.title || domain(door.url)}</b>
            <span class="via">
              {domain(door.url)}
              <span :for={tag <- Enum.take(shared_tags(door, @blink), 3)} class="tag">{tag}</span>
            </span>
          </button>
          <button class="door wild" phx-click="wildcard">
            <b>??? — total wildcard</b>
            <span class="via">teleport anywhere in the stack</span>
          </button>
        </div>
      </div>

      <div class="stage" :if={is_nil(@blink)}>
        <p>nothing saved yet — the walk starts once there are links.</p>
      </div>
    </div>
    """
  end
end
