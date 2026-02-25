defmodule BlogWeb.WorkLogLive do
  use BlogWeb, :live_view

  @topic "github:work_log"

  @impl true
  def mount(_params, _session, socket) do
    {events, last_updated} =
      case GenServer.whereis(Blog.GitHub.WorkLogPoller) do
        nil -> {[], nil}
        _pid -> Blog.GitHub.WorkLogPoller.get_events()
      end

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

  defp short_date(nil), do: ""
  defp short_date(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d %H:%M")

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
  defp short_sha(sha), do: String.slice(sha, 0..6)

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .wl-desktop {
        min-height: 100vh;
        background: repeating-linear-gradient(0deg, #a8a8a8, #a8a8a8 1px, #b8b8b8 1px, #b8b8b8 2px);
        padding: 20px;
        font-family: "Chicago", "Geneva", "Helvetica Neue", sans-serif;
        font-size: 12px;
      }
      .wl-menubar {
        height: 24px; background: #fff; border-bottom: 1px solid #000;
        display: flex; align-items: center; padding: 0 12px;
        font-size: 13px; font-weight: bold;
        position: fixed; top: 0; left: 0; right: 0; z-index: 10;
      }
      .wl-menubar a { color: #000; text-decoration: none; margin-right: 16px; }
      .wl-menubar .menu-right { margin-left: auto; font-weight: normal; font-size: 11px; color: #666; }
      .wl-body { padding-top: 34px; padding-bottom: 32px; }
      .wl-window {
        max-width: 860px; margin: 0 auto;
        border: 2px solid #000; box-shadow: 2px 2px 0 #000;
      }
      .wl-titlebar {
        height: 20px;
        background: repeating-linear-gradient(90deg, #fff 0px, #fff 1px, #000 1px, #000 2px);
        display: flex; align-items: center; padding: 0 6px; border-bottom: 2px solid #000;
      }
      .wl-close {
        width: 12px; height: 12px; border: 1px solid #000;
        background: #fff; flex-shrink: 0; display: block; text-decoration: none;
      }
      .wl-title {
        flex: 1; text-align: center; font-size: 11px; font-weight: bold;
        background: #fff; padding: 0 8px; margin: 0 40px; white-space: nowrap;
      }
      .wl-term {
        background: #1a1a2e; color: #c8c8c8;
        font-family: "Monaco", "Menlo", "Courier New", monospace;
        font-size: 12px; line-height: 1.4;
        padding: 12px 16px; min-height: 300px; max-height: 80vh;
        overflow-y: auto; overflow-x: auto;
      }
      .wl-term a { color: inherit; text-decoration: none; }
      .wl-term a:hover { text-decoration: underline; }
      .push-header { color: #c8c8c8; margin-top: 8px; white-space: nowrap; }
      .push-header:first-child { margin-top: 0; }
      .push-header .sha { color: #e8a838; }
      .push-header .sha a { color: #e8a838; }
      .push-header .stats { color: #888; }
      .push-header .stats .p { color: #5ce65c; }
      .push-header .stats .m { color: #e65c5c; }
      .push-header .ref { color: #5ccccc; }
      .push-header .ref a { color: #5ccccc; }
      .push-header .dt { color: #666; }
      .commit-line { padding-left: 4ch; color: #fff; white-space: pre-wrap; word-break: break-word; }
      .commit-line .sha { color: #e8a838; }
      .commit-line .sha a { color: #e8a838; }
      .prompt { color: #8888aa; }
      .empty-msg { color: #8888aa; padding: 40px 0; text-align: center; }
      .wl-statusbar {
        height: 22px; border-top: 1px solid #000; background: #fff;
        display: flex; justify-content: space-between; align-items: center;
        padding: 0 12px; font-size: 11px;
        position: fixed; bottom: 0; left: 0; right: 0;
      }
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
            <span class="wl-title">Work Log — git log</span>
          </div>
          <div class="wl-term">
            <div class="prompt">$ git log</div>
            <%= if Enum.empty?(@events) do %>
              <div class="empty-msg">No recent push events.</div>
            <% else %>
              <%= for event <- @events do %>
                <div class="push-header"><span class="sha"><a href={head_url(event.repo, event.before_sha, event.head_sha)} target="_blank">{short_sha(event.head_sha)}</a></span> <%= if event.stats do %><span class="stats"><span class="p">+{event.stats.additions}</span>/<span class="m">-{event.stats.deletions}</span></span> <% end %><span class="ref"><a href={repo_url(event.repo)} target="_blank">{short_repo(event.repo)}</a>/{event.branch}</span> <span class="dt">{short_date(event.created_at)}</span></div>
                <%= for commit <- event.commits do %>
                  <div class="commit-line"><span class="sha"><a href={commit_url(event.repo, commit.sha)} target="_blank">{commit.sha}</a></span> {commit.message}</div>
                <% end %>
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
