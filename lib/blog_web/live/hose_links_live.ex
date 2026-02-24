defmodule BlogWeb.HoseLinksLive do
  use BlogWeb, :live_view

  alias Blog.HoseLinks

  @refresh_interval 30_000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "hose_links:breakthrough")
      schedule_refresh()
    end

    breakthroughs = HoseLinks.list_breakthroughs(limit: 50)
    top_links = HoseLinks.top_links(20)

    stats =
      try do
        HoseLinks.Listener.get_stats()
      rescue
        _ -> %{posts_seen: 0, links_extracted: 0, links_recorded: 0, breakthroughs: 0, errors: 0, uptime_seconds: 0, links_per_second: 0.0}
      end

    {:ok,
     assign(socket,
       breakthroughs: breakthroughs,
       top_links: top_links,
       stats: stats,
       threshold: HoseLinks.current_threshold(),
       db_stats: HoseLinks.stats()
     )}
  end

  def handle_info({:breakthrough, _url, _count}, socket) do
    breakthroughs = HoseLinks.list_breakthroughs(limit: 50)
    db_stats = HoseLinks.stats()
    {:noreply, assign(socket, breakthroughs: breakthroughs, db_stats: db_stats)}
  end

  def handle_info(:refresh, socket) do
    top_links = HoseLinks.top_links(20)

    stats =
      try do
        HoseLinks.Listener.get_stats()
      rescue
        _ -> socket.assigns.stats
      end

    db_stats = HoseLinks.stats()
    schedule_refresh()

    {:noreply, assign(socket, top_links: top_links, stats: stats, db_stats: db_stats)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp format_time_ago(datetime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :second)

    cond do
      diff < 60 -> "#{diff}s ago"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      true -> "#{div(diff, 86400)}d ago"
    end
  end

  defp format_uptime(seconds) do
    hours = div(seconds, 3600)
    mins = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)

    cond do
      hours > 0 -> "#{hours}h #{mins}m"
      mins > 0 -> "#{mins}m #{secs}s"
      true -> "#{secs}s"
    end
  end

  defp linkify(normalized_url) do
    "https://#{normalized_url}"
  end

  def render(assigns) do
    ~H"""
    <style>
      .hose-container {
        max-width: 1200px;
        margin: 20px auto;
        padding: 0 20px;
        font-family: "Geneva", "Chicago", "Helvetica Neue", monospace;
        color: #000;
      }
      .hose-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
        border-bottom: 2px solid #000;
        padding-bottom: 12px;
      }
      .hose-header h1 {
        font-size: 22px;
        margin: 0;
      }
      .hose-stats-bar {
        display: flex;
        gap: 20px;
        font-size: 12px;
        color: #666;
      }
      .hose-stat {
        display: flex;
        gap: 4px;
      }
      .hose-stat-value {
        font-weight: bold;
        color: #000;
      }
      .hose-section {
        margin-bottom: 24px;
      }
      .hose-section h2 {
        font-size: 16px;
        margin: 0 0 10px 0;
        padding: 6px 10px;
        background: #000;
        color: #fff;
      }
      .hose-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
      }
      .hose-table th {
        text-align: left;
        padding: 6px 10px;
        border-bottom: 2px solid #000;
        font-size: 11px;
        text-transform: uppercase;
        color: #666;
      }
      .hose-table td {
        padding: 6px 10px;
        border-bottom: 1px solid #e0e0e0;
        vertical-align: top;
      }
      .hose-table tr:hover {
        background: #f5f5f5;
      }
      .hose-url {
        max-width: 500px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .hose-url a {
        color: #0066cc;
        text-decoration: none;
      }
      .hose-url a:hover {
        text-decoration: underline;
      }
      .hose-obs {
        font-weight: bold;
        font-size: 15px;
        font-variant-numeric: tabular-nums;
      }
      .hose-domain {
        color: #888;
        font-size: 11px;
      }
      .hose-time {
        color: #888;
        font-size: 11px;
        white-space: nowrap;
      }
      .hose-breakthrough-badge {
        display: inline-block;
        background: #ff4400;
        color: #fff;
        padding: 1px 6px;
        font-size: 10px;
        font-weight: bold;
        margin-left: 6px;
      }
      .hose-empty {
        text-align: center;
        padding: 40px 20px;
        color: #999;
        font-size: 14px;
      }
      .hose-refresh-note {
        font-size: 11px;
        color: #999;
        text-align: right;
        margin-top: 4px;
      }
      .hose-back-link {
        font-size: 13px;
        color: #000;
        text-decoration: none;
        border: 1px solid #000;
        padding: 4px 12px;
      }
      .hose-back-link:hover {
        background: #000;
        color: #fff;
      }
    </style>

    <div class="hose-container">
      <div class="hose-header">
        <h1>Firehose Link Tracker</h1>
        <div class="hose-stats-bar">
          <div class="hose-stat">
            <span>Posts seen:</span>
            <span class="hose-stat-value"><%= @stats.posts_seen %></span>
          </div>
          <div class="hose-stat">
            <span>Links/sec:</span>
            <span class="hose-stat-value"><%= @stats.links_per_second %></span>
          </div>
          <div class="hose-stat">
            <span>Active links:</span>
            <span class="hose-stat-value"><%= @db_stats.active_links %></span>
          </div>
          <div class="hose-stat">
            <span>Threshold:</span>
            <span class="hose-stat-value"><%= @threshold %></span>
          </div>
          <div class="hose-stat">
            <span>Uptime:</span>
            <span class="hose-stat-value"><%= format_uptime(@stats.uptime_seconds) %></span>
          </div>
          <a href="/" class="hose-back-link">Back</a>
        </div>
      </div>

      <div class="hose-section">
        <h2>Breakthrough Links (<%= length(@breakthroughs) %>)</h2>
        <%= if @breakthroughs == [] do %>
          <div class="hose-empty">
            No breakthroughs yet. Watching for links with <%= @threshold %>+ observations in a 2-hour window...
          </div>
        <% else %>
          <table class="hose-table">
            <thead>
              <tr>
                <th>URL</th>
                <th>Observations</th>
                <th>Peak</th>
                <th>Domain</th>
                <th>First Seen</th>
                <th>Broke Through</th>
              </tr>
            </thead>
            <tbody>
              <%= for bt <- @breakthroughs do %>
                <tr>
                  <td class="hose-url">
                    <a href={linkify(bt.normalized_url)} target="_blank" rel="noopener">
                      <%= bt.normalized_url %>
                    </a>
                    <span class="hose-breakthrough-badge">BREAKTHROUGH</span>
                  </td>
                  <td class="hose-obs"><%= bt.observations_at_breakthrough %></td>
                  <td class="hose-obs"><%= bt.peak_observations %></td>
                  <td class="hose-domain"><%= bt.domain %></td>
                  <td class="hose-time"><%= format_time_ago(bt.first_seen_at) %></td>
                  <td class="hose-time"><%= format_time_ago(bt.breakthrough_at) %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
      </div>

      <div class="hose-section">
        <h2>Trending Now (top 20 active links)</h2>
        <%= if @top_links == [] do %>
          <div class="hose-empty">No links being tracked yet. Waiting for firehose data...</div>
        <% else %>
          <table class="hose-table">
            <thead>
              <tr>
                <th>URL</th>
                <th>Observations</th>
                <th>First Seen</th>
                <th>Last Seen</th>
              </tr>
            </thead>
            <tbody>
              <%= for link <- @top_links do %>
                <tr>
                  <td class="hose-url">
                    <a href={linkify(link.normalized_url)} target="_blank" rel="noopener">
                      <%= link.normalized_url %>
                    </a>
                  </td>
                  <td class="hose-obs"><%= link.observations %></td>
                  <td class="hose-time"><%= format_time_ago(link.first_seen_at) %></td>
                  <td class="hose-time"><%= format_time_ago(link.last_seen_at) %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
        <div class="hose-refresh-note">Refreshes every 30 seconds</div>
      </div>
    </div>
    """
  end
end
