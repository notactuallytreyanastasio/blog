defmodule Blog.GitHub.WorkLogPoller do
  use GenServer
  require Logger

  @poll_interval 60_000
  @github_username "notactuallytreyanastasio"
  @events_url "https://api.github.com/users/#{@github_username}/events/public"
  @topic "github:work_log"
  @max_stats_per_cycle 3

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_events do
    GenServer.call(__MODULE__, :get_events)
  end

  @impl true
  def init(_opts) do
    send(self(), :poll)
    {:ok, %{events: [], last_updated: nil, stats_cache: %{}}}
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
        {enriched, new_cache} = enrich_with_stats(events, state.stats_cache)
        now = DateTime.utc_now()
        Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:work_log_updated, enriched, now})
        Process.send_after(self(), :poll, @poll_interval)
        {:noreply, %{state | events: enriched, last_updated: now, stats_cache: new_cache}}
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

  defp enrich_with_stats(events, cache) do
    needs_stats =
      events
      |> Enum.filter(fn e ->
        not Map.has_key?(cache, e.event_id) and
          e.before_sha != "0000000000000000000000000000000000000000"
      end)
      |> Enum.take(@max_stats_per_cycle)

    new_entries =
      needs_stats
      |> Enum.map(fn event -> {event.event_id, fetch_compare_stats(event)} end)
      |> Enum.into(%{})

    updated_cache = Map.merge(cache, new_entries)

    enriched =
      Enum.map(events, fn event ->
        %{event | stats: Map.get(updated_cache, event.event_id)}
      end)

    {enriched, updated_cache}
  end

  defp fetch_compare_stats(%{repo: repo, before_sha: before_sha, head_sha: head_sha}) do
    url = "https://api.github.com/repos/#{repo}/compare/#{before_sha}...#{head_sha}"

    case Req.get(url, headers: [{"user-agent", "bobbby-work-log"}]) do
      {:ok, %{status: 200, body: body}} ->
        files =
          (body["files"] || [])
          |> Enum.map(fn f ->
            %{
              filename: f["filename"] || "",
              additions: f["additions"] || 0,
              deletions: f["deletions"] || 0
            }
          end)

        %{
          files: files,
          additions: Enum.sum(Enum.map(files, & &1.additions)),
          deletions: Enum.sum(Enum.map(files, & &1.deletions))
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
      commits:
        (event["payload"]["commits"] || [])
        |> Enum.map(fn c ->
          %{
            sha: String.slice(c["sha"] || "", 0..6),
            message: c["message"] |> to_string() |> String.split("\n") |> List.first(),
            author: get_in(c, ["author", "name"])
          }
        end)
        |> Enum.filter(fn c -> c.message != nil and String.trim(c.message) != "" end),
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
