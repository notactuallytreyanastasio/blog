defmodule BlogWeb.WorkLogLive do
  use BlogWeb, :live_view

  @topic "github:work_log"
  @max_files_shown 12

  @impl true
  def mount(_params, _session, socket) do
    {events, last_updated} = Blog.GitHub.WorkLogPoller.get_events()

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)
    end

    {:ok,
     assign(socket,
       page_title: "Work Log",
       events: events,
       last_updated: last_updated
     )}
  end

  @impl true
  def handle_info({:work_log_updated, events, last_updated}, socket) do
    {:noreply, assign(socket, events: events, last_updated: last_updated)}
  end

  defp format_git_date(nil), do: ""

  defp format_git_date(%DateTime{} = dt) do
    Calendar.strftime(dt, "%a %b %d %H:%M:%S %Y +0000")
  end

  defp repo_url(repo_name), do: "https://github.com/#{repo_name}"
  defp commit_url(repo_name, sha), do: "https://github.com/#{repo_name}/commit/#{sha}"
  defp short_repo(full_name), do: full_name |> String.split("/") |> List.last()

  defp head_url(repo, before_sha, head_sha) do
    if before_sha == "0000000000000000000000000000000000000000" do
      "https://github.com/#{repo}/commit/#{head_sha}"
    else
      "https://github.com/#{repo}/compare/#{before_sha}...#{head_sha}"
    end
  end

  defp short_sha(nil), do: ""
  defp short_sha(""), do: ""
  defp short_sha(sha), do: String.slice(sha, 0..10)

  defp stat_bar(additions, deletions) do
    total = additions + deletions
    max_w = 20

    if total == 0 do
      %{plus: "", minus: ""}
    else
      scale = min(total, max_w) / total
      pn = if additions > 0, do: max(1, round(additions * scale)), else: 0
      mn = if deletions > 0, do: max(1, round(deletions * scale)), else: 0
      %{plus: String.duplicate("+", pn), minus: String.duplicate("-", mn)}
    end
  end

  defp short_path(path) do
    if String.length(path) > 50 do
      "..." <> String.slice(path, -47..-1)
    else
      path
    end
  end

  defp visible_files(files), do: Enum.take(files, @max_files_shown)

  defp hidden_file_count(files), do: max(0, length(files) - @max_files_shown)

  defp pluralize(1, singular, _plural), do: "1 #{singular}"
  defp pluralize(n, _singular, plural), do: "#{n} #{plural}"

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .wl-desktop {
        min-height: 100vh;
        background: repeating-linear-gradient(
          0deg, #a8a8a8, #a8a8a8 1px, #b8b8b8 1px, #b8b8b8 2px
        );
        padding: 20px;
        font-family: "Chicago", "Geneva", "Helvetica Neue", sans-serif;
        font-size: 12px;
      }
      .wl-menubar {
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 12px;
        font-size: 13px;
        font-weight: bold;
        position: fixed;
        top: 0; left: 0; right: 0;
        z-index: 10;
      }
      .wl-menubar a { color: #000; text-decoration: none; margin-right: 16px; }
      .wl-menubar .menu-right {
        margin-left: auto;
        font-weight: normal;
        font-size: 11px;
        color: #666;
      }
      .wl-body { padding-top: 34px; padding-bottom: 32px; }
      .wl-window {
        max-width: 860px;
        margin: 0 auto;
        border: 2px solid #000;
        box-shadow: 2px 2px 0 #000;
      }
      .wl-titlebar {
        height: 20px;
        background: repeating-linear-gradient(
          90deg, #fff 0px, #fff 1px, #000 1px, #000 2px
        );
        display: flex;
        align-items: center;
        padding: 0 6px;
        border-bottom: 2px solid #000;
      }
      .wl-close {
        width: 12px; height: 12px;
        border: 1px solid #000;
        background: #fff;
        flex-shrink: 0;
        display: block;
        text-decoration: none;
      }
      .wl-title {
        flex: 1;
        text-align: center;
        font-size: 11px;
        font-weight: bold;
        background: #fff;
        padding: 0 8px;
        margin: 0 40px;
        white-space: nowrap;
      }
      .wl-term {
        background: #1a1a2e;
        color: #c8c8c8;
        font-family: "Monaco", "Menlo", "Courier New", monospace;
        font-size: 12px;
        line-height: 1.5;
        padding: 12px 16px;
        min-height: 300px;
        max-height: 80vh;
        overflow-y: auto;
        overflow-x: auto;
      }
      .wl-term .ln { white-space: pre; }
      .wl-term .blank { height: 0.7em; }
      .wl-term .prompt { color: #8888aa; }
      .wl-term .sha { color: #e8a838; }
      .wl-term .sha a { color: #e8a838; text-decoration: none; }
      .wl-term .sha a:hover { text-decoration: underline; }
      .wl-term .ref { color: #5ccccc; }
      .wl-term .ref a { color: #5ccccc; text-decoration: none; }
      .wl-term .ref a:hover { text-decoration: underline; }
      .wl-term .msg { color: #fff; }
      .wl-term .msg a { color: #e8a838; text-decoration: none; }
      .wl-term .msg a:hover { text-decoration: underline; }
      .wl-term .fname { color: #c8c8c8; }
      .wl-term .plus { color: #5ce65c; }
      .wl-term .minus { color: #e65c5c; }
      .wl-term .summary { color: #888; }
      .wl-term .empty-msg { color: #8888aa; padding: 40px 0; text-align: center; }
      .log-entry { margin-bottom: 0; }
      .log-divider {
        border: none;
        border-top: 1px dashed #333355;
        margin: 12px 0;
      }
      .wl-statusbar {
        height: 22px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 12px;
        font-size: 11px;
        position: fixed;
        bottom: 0; left: 0; right: 0;
      }
      .log-entry-old { display: none; }
    </style>

    <div class="wl-desktop">
      <div class="wl-menubar">
        <a href="/">bobbby.online</a>
        <span>Work Log</span>
        <span class="menu-right">
          <%= if @last_updated do %>
            updated {Calendar.strftime(@last_updated, "%H:%M:%S UTC")}
          <% end %>
        </span>
      </div>

      <div class="wl-body">
        <div class="wl-window">
          <div class="wl-titlebar">
            <a href="/" class="wl-close"></a>
            <span class="wl-title">Work Log — git log --stat</span>
          </div>
          <div class="wl-term">
            <div class="ln"><span class="prompt">$ git log --stat</span></div>
            <div class="blank"></div>
            <%= if Enum.empty?(@events) do %>
              <div class="empty-msg">No recent push events.</div>
            <% else %>
              <%= for {event, idx} <- Enum.with_index(@events) do %>
                <%= if idx > 0 do %>
                  <hr class="log-divider" />
                <% end %>
                <div class="log-entry">
                  <div class="ln"><span class="sha">commit <a href={head_url(event.repo, event.before_sha, event.head_sha)} target="_blank">{short_sha(event.head_sha)}</a></span> <span class="ref">(<a href={repo_url(event.repo)} target="_blank">{short_repo(event.repo)}</a>/{event.branch})</span></div>
                  <div class="ln">Author: {(List.first(event.commits) || %{})[:author] || "notactuallytreyanastasio"}</div>
                  <div class="ln">Date:   {format_git_date(event.created_at)}</div>
                  <div class="blank"></div>
                  <%= for commit <- event.commits do %>
                    <div class="ln msg">    <span class="sha"><a href={commit_url(event.repo, commit.sha)} target="_blank">{commit.sha}</a></span></div>
                    <div class="ln msg">    {commit.message}</div>
                    <div class="blank"></div>
                  <% end %>
                  <%= if event.stats do %>
                    <%= for file <- visible_files(event.stats.files) do %>
                      <% bar = stat_bar(file.additions, file.deletions) %>
                      <div class="ln"><span class="fname"> {short_path(file.filename)}</span> | {file.additions + file.deletions} <span class="plus">{bar.plus}</span><span class="minus">{bar.minus}</span></div>
                    <% end %>
                    <%= if hidden_file_count(event.stats.files) > 0 do %>
                      <div class="ln summary"> ... and {hidden_file_count(event.stats.files)} more files</div>
                    <% end %>
                    <div class="ln summary"> {pluralize(length(event.stats.files), "file changed", "files changed")}, {event.stats.additions} insertions(+), {event.stats.deletions} deletions(-)</div>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <div class="wl-statusbar">
        <span>{length(@events)} push events</span>
        <span>github.com/notactuallytreyanastasio</span>
      </div>
    </div>
    """
  end
end
