defmodule BlogWeb.BlinksReviewLive do
  use BlogWeb, :live_view

  alias Blog.Blinks

  # Personal triage queue: upvote a bookmark to make it a blink, downvote to
  # dismiss. Gated by the blinks API token (?key=) since votes write data.
  def mount(params, _session, socket) do
    expected = Application.get_env(:blog, :blinks_api_token)

    if is_binary(expected) and expected != "" and
         Plug.Crypto.secure_compare(params["key"] || "", expected) do
      {:ok,
       assign(socket,
         page_title: "bookmark review",
         candidates: Blinks.pending_candidates(),
         counts: Blinks.candidate_counts(),
         key: params["key"]
       )}
    else
      {:ok, socket |> redirect(to: "/blinks")}
    end
  end

  def handle_event("vote", %{"id" => id, "dir" => dir}, socket) do
    {id, _} = Integer.parse(id)
    verdict = if dir == "up", do: :add, else: :dismiss
    {:ok, _} = Blinks.review_candidate(id, verdict)

    {:noreply,
     assign(socket,
       candidates: Enum.reject(socket.assigns.candidates, &(&1.id == id)),
       counts: Blinks.candidate_counts()
     )}
  end

  defp domain(url) do
    case URI.parse(url).host do
      nil -> ""
      host -> String.replace_prefix(host, "www.", "")
    end
  end

  defp done(counts), do: Map.get(counts, "added", 0) + Map.get(counts, "dismissed", 0)
  defp total(counts), do: counts |> Map.values() |> Enum.sum()

  def render(assigns) do
    ~H"""
    <div id="review-page">
      <style>
        #review-page, #review-page * { box-sizing: border-box; }
        #review-page { font: 12px verdana, arial, helvetica, sans-serif; color: #000; background: #fff; min-height: 100vh; }
        #review-page a { text-decoration: none; }
        #review-page .bar { background: #cee3f8; border-bottom: 1px solid #5f99cf; padding: 5px 10px; display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
        #review-page .bar h1 { font-size: 15px; font-weight: bold; margin: 0; }
        #review-page .bar h1 span { color: #ff4500; }
        #review-page .progress { color: #369; font-size: 11px; }
        #review-page .progress b.added { color: #ff4500; }
        #review-page .backlink { margin-left: auto; color: #369; font-size: 11px; }
        #review-page .list { max-width: 900px; padding: 8px 12px; }
        #review-page .row { display: flex; gap: 8px; padding: 5px 0; border-bottom: 1px dotted #eee; align-items: flex-start; }
        #review-page .arrows { display: flex; flex-direction: column; align-items: center; width: 28px; flex-shrink: 0; }
        #review-page .arrow { cursor: pointer; font-size: 16px; line-height: 1.1; color: #c6c6c6; user-select: none; }
        #review-page .arrow.up:hover { color: #ff4500; }
        #review-page .arrow.down:hover { color: #9494ff; }
        #review-page .entry { min-width: 0; }
        #review-page .rtitle { font-size: 13px; color: #0000ff; }
        #review-page .rtitle:visited { color: #551a8b; }
        #review-page .rdomain { color: #888; font-size: 10px; }
        #review-page .flair { display: inline-block; background: #f5f5f5; border: 1px solid #ddd; border-radius: 2px; color: #369; font-size: 9px; padding: 0 4px; margin-left: 4px; }
        #review-page .hint { color: #888; font-size: 10px; margin: 6px 0 10px; }
        #review-page .done-msg { padding: 40px 0; text-align: center; color: #888; font-size: 14px; }
        @media (max-width: 700px) {
          #review-page .arrow { font-size: 22px; padding: 2px 6px; }
        }
      </style>

      <div class="bar">
        <h1>bookmark <span>review</span></h1>
        <span class="progress">
          {done(@counts)} / {total(@counts)} reviewed ·
          <b class="added">{Map.get(@counts, "added", 0)} blinked</b> ·
          {Map.get(@counts, "dismissed", 0)} passed
        </span>
        <a class="backlink" href="/blinks">→ back to blinks</a>
      </div>

      <div class="list">
        <div class="hint">
          ▲ makes it a blink (tagged <b>bookmarks</b> + its folder) · ▼ dismisses it forever
        </div>

        <div :if={@candidates == []} class="done-msg">
          queue zero. every bookmark has been judged. 🏁
        </div>

        <div :for={candidate <- @candidates} class="row">
          <div class="arrows">
            <span
              class="arrow up"
              phx-click="vote"
              phx-value-id={candidate.id}
              phx-value-dir="up"
              title="blink it"
            >
              ▲
            </span>
            <span
              class="arrow down"
              phx-click="vote"
              phx-value-id={candidate.id}
              phx-value-dir="down"
              title="not worth keeping"
            >
              ▼
            </span>
          </div>
          <div class="entry">
            <a class="rtitle" href={candidate.url} target="_blank" rel="noopener">
              {candidate.title || candidate.url}
            </a>
            <span class="rdomain">({domain(candidate.url)})</span>
            <span :if={candidate.folder && candidate.folder != "Favorites"} class="flair">
              {candidate.folder}
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
