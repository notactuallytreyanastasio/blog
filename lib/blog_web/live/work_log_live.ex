defmodule BlogWeb.WorkLogLive do
  use BlogWeb, :live_view

  @topic "github:work_log"

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

  defp format_time(nil), do: ""
  defp format_time(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %H:%M")

  defp repo_url(repo_name), do: "https://github.com/#{repo_name}"
  defp commit_url(repo_name, sha), do: "https://github.com/#{repo_name}/commit/#{sha}"
  defp short_repo(full_name), do: full_name |> String.split("/") |> List.last()

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .work-log-desktop {
        min-height: 100vh;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
        padding: 0;
        font-family: "Chicago", "Geneva", "Helvetica Neue", sans-serif;
        font-size: 12px;
      }

      .work-log-menubar {
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 12px;
        font-size: 13px;
        font-weight: bold;
      }

      .work-log-menubar a {
        color: #000;
        text-decoration: none;
        margin-right: 16px;
      }

      .work-log-menubar .menu-right {
        margin-left: auto;
        font-weight: normal;
        font-size: 11px;
        color: #666;
      }

      .work-log-content {
        max-width: 700px;
        margin: 20px auto;
        padding: 0 20px;
      }

      .work-log-header {
        font-size: 11px;
        color: #666;
        margin-bottom: 16px;
      }

      .push-event {
        border: 1px solid #000;
        margin-bottom: 8px;
        background: #fff;
        box-shadow: 1px 1px 0 #000;
      }

      .push-event-titlebar {
        height: 18px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px, #fff 1px,
          #000 1px, #000 2px
        );
        display: flex;
        align-items: center;
        padding: 0 6px;
      }

      .push-event-repo {
        background: #fff;
        padding: 0 4px;
        font-size: 11px;
        font-weight: bold;
      }

      .push-event-repo a {
        color: #000;
        text-decoration: none;
      }

      .push-event-branch {
        font-weight: normal;
        color: #666;
      }

      .push-event-time {
        margin-left: auto;
        background: #fff;
        padding: 0 4px;
        font-size: 10px;
        color: #666;
      }

      .push-event-commits {
        padding: 6px 8px;
      }

      .commit-row {
        margin-bottom: 3px;
        font-size: 11px;
        display: flex;
        gap: 6px;
      }

      .commit-sha {
        font-family: monospace;
        font-size: 10px;
        color: #000;
        text-decoration: none;
        flex-shrink: 0;
      }

      .commit-sha:hover {
        text-decoration: underline;
      }

      .commit-message {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .work-log-statusbar {
        height: 22px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 12px;
        font-size: 11px;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
      }

      .work-log-empty {
        text-align: center;
        padding: 60px 20px;
        color: #666;
      }
    </style>

    <div class="work-log-desktop">
      <div class="work-log-menubar">
        <a href="/">bobbby.online</a>
        <span>Work Log</span>
        <span class="menu-right">
          <%= if @last_updated do %>
            updated {Calendar.strftime(@last_updated, "%H:%M:%S UTC")}
          <% end %>
        </span>
      </div>

      <div class="work-log-content">
        <div class="work-log-header">
          Recent pushes by notactuallytreyanastasio. Live-updates every 60s.
        </div>

        <%= if Enum.empty?(@events) do %>
          <div class="work-log-empty">
            <p>No recent push events.</p>
          </div>
        <% else %>
          <%= for event <- @events do %>
            <div class="push-event">
              <div class="push-event-titlebar">
                <span class="push-event-repo">
                  <a href={repo_url(event.repo)} target="_blank">
                    {short_repo(event.repo)}
                  </a>
                  <span class="push-event-branch">/{event.branch}</span>
                </span>
                <span class="push-event-time">{format_time(event.created_at)}</span>
              </div>
              <div class="push-event-commits">
                <%= for commit <- event.commits do %>
                  <div class="commit-row">
                    <a class="commit-sha" href={commit_url(event.repo, commit.sha)} target="_blank">
                      {commit.sha}
                    </a>
                    <span class="commit-message">{commit.message}</span>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>

      <div class="work-log-statusbar">
        <span>{length(@events)} push events</span>
        <span>github.com/notactuallytreyanastasio</span>
      </div>
    </div>
    """
  end
end
