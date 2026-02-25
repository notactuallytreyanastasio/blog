defmodule Blog.GitHub.WorkLogPoller do
  use GenServer
  require Logger

  @poll_interval 60_000
  @github_username "notactuallytreyanastasio"
  @events_url "https://api.github.com/users/#{@github_username}/events/public"
  @topic "github:work_log"
  @max_stats_per_cycle 5

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_events do
    GenServer.call(__MODULE__, :get_events)
  end

  @impl true
  def init(_opts) do
    send(self(), :poll)
    {:ok, %{events: [], last_updated: nil, compare_cache: %{}}}
  end

  @impl true
  def handle_call(:get_events, _from, state) do
    {:reply, {state.events, state.last_updated}, state}
  end

  @impl true
  def handle_info(:poll, state) do
    case fetch_events() do
      :unchanged ->
        Process.send_after(self(), :poll, @poll_interval)
        {:noreply, state}

      events when is_list(events) ->
        {enriched, new_cache} = enrich_with_compare(events, state.compare_cache)
        # Filter out events with no diff
        enriched = Enum.filter(enriched, fn e ->
          is_nil(e.stats) or e.stats.additions > 0 or e.stats.deletions > 0
        end)
        now = DateTime.utc_now()
        Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:work_log_updated, enriched, now})
        Process.send_after(self(), :poll, @poll_interval)
        {:noreply, %{state | events: enriched, last_updated: now, compare_cache: new_cache}}
    end
  end

  defp fetch_events do
    case Req.get(@events_url, headers: [{"user-agent", "bobbby-work-log"}]) do
      {:ok, %{status: 200, body: body}} when is_list(body) ->
        body
        |> Enum.filter(&(&1["type"] == "PushEvent"))
        |> Enum.map(&parse_push_event/1)

      {:ok, %{status: 304}} ->
        :unchanged

      {:ok, %{status: status}} ->
        Logger.warning("GitHub Events API returned #{status}")
        []

      {:error, error} ->
        Logger.error("GitHub Events API failed: #{inspect(error)}")
        []
    end
  end

  defp enrich_with_compare(events, cache) do
    needs_compare =
      events
      |> Enum.filter(fn e ->
        not Map.has_key?(cache, e.event_id) and
          e.before_sha != "0000000000000000000000000000000000000000"
      end)
      |> Enum.take(@max_stats_per_cycle)

    new_entries =
      needs_compare
      |> Enum.map(fn event -> {event.event_id, fetch_compare(event)} end)
      |> Enum.into(%{})

    updated_cache = Map.merge(cache, new_entries)

    enriched =
      Enum.map(events, fn event ->
        case Map.get(updated_cache, event.event_id) do
          nil ->
            event

          compare ->
            %{event | stats: compare.stats, commits: compare.commits}
        end
      end)

    {enriched, updated_cache}
  end

  defp fetch_compare(%{repo: repo, before_sha: before_sha, head_sha: head_sha}) do
    url = "https://api.github.com/repos/#{repo}/compare/#{before_sha}...#{head_sha}"

    case Req.get(url, headers: [{"user-agent", "bobbby-work-log"}]) do
      {:ok, %{status: 200, body: body}} ->
        files = body["files"] || []
        additions = files |> Enum.map(&((&1["additions"] || 0))) |> Enum.sum()
        deletions = files |> Enum.map(&((&1["deletions"] || 0))) |> Enum.sum()

        commits =
          (body["commits"] || [])
          |> Enum.map(fn c ->
            msg = get_in(c, ["commit", "message"]) |> to_string() |> String.trim()
            %{
              sha: String.slice(c["sha"] || "", 0..6),
              message: msg
            }
          end)
          |> Enum.filter(fn c -> c.message != "" end)

        %{
          stats: %{additions: additions, deletions: deletions},
          commits: commits
        }

      {:ok, %{status: status}} ->
        Logger.debug("GitHub Compare API returned #{status} for #{repo}")
        nil

      {:error, error} ->
        Logger.debug("GitHub Compare API failed: #{inspect(error)}")
        nil
    end
  end

  defp parse_push_event(event) do
    %{
      event_id: event["id"],
      repo: event["repo"]["name"],
      branch: (event["payload"]["ref"] || "") |> String.replace("refs/heads/", ""),
      before_sha: event["payload"]["before"] || "",
      head_sha: event["payload"]["head"] || "",
      commits: [],
      created_at: parse_datetime(event["created_at"]),
      stats: nil
    }
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end
end
