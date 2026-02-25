defmodule Blog.GitHub.WorkLogPoller do
  use GenServer
  require Logger

  @poll_interval 60_000
  @github_username "notactuallytreyanastasio"
  @events_url "https://api.github.com/users/#{@github_username}/events/public"
  @topic "github:work_log"
  @max_compares_per_cycle 10

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_events do
    Blog.GitHub.WorkLog.list_recent()
  end

  @impl true
  def init(_opts) do
    send(self(), :poll)
    {:ok, %{seen_event_ids: MapSet.new()}}
  end

  @impl true
  def handle_info(:poll, state) do
    state =
      case fetch_events() do
        {:ok, events} ->
          {new_seen, _} = process_events(events, state.seen_event_ids)
          Phoenix.PubSub.broadcast(Blog.PubSub, @topic, :work_log_updated)
          %{state | seen_event_ids: new_seen}

        :unchanged ->
          state

        {:error, reason} ->
          Logger.warning("WorkLog poll failed: #{reason}")
          state
      end

    Process.send_after(self(), :poll, @poll_interval)
    {:noreply, state}
  end

  defp fetch_events do
    case Req.get(@events_url, headers: [{"user-agent", "bobbby-work-log"}]) do
      {:ok, %{status: 200, body: body}} when is_list(body) ->
        events =
          body
          |> Enum.filter(&(&1["type"] == "PushEvent"))
          |> Enum.map(&parse_push_event/1)
        {:ok, events}

      {:ok, %{status: 304}} ->
        :unchanged

      {:ok, %{status: status}} ->
        {:error, "GitHub Events API returned #{status}"}

      {:error, error} ->
        {:error, "GitHub Events API failed: #{inspect(error)}"}
    end
  end

  defp process_events(events, seen) do
    new_events =
      events
      |> Enum.filter(fn e ->
        not MapSet.member?(seen, e.event_id) and
          e.before_sha != "0000000000000000000000000000000000000000"
      end)
      |> Enum.take(@max_compares_per_cycle)

    new_seen =
      Enum.reduce(new_events, seen, fn event, acc ->
        case fetch_compare(event) do
          {:ok, compare_data} ->
            Blog.GitHub.WorkLog.upsert_from_compare(
              event.repo, event.branch, event.event_id, compare_data
            )
            MapSet.put(acc, event.event_id)

          {:error, _} ->
            acc
        end
      end)

    # Also mark all current event IDs as seen
    all_seen = Enum.reduce(events, new_seen, fn e, acc -> MapSet.put(acc, e.event_id) end)
    {all_seen, new_events}
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
            %{sha: String.slice(c["sha"] || "", 0..6), message: msg}
          end)
          |> Enum.filter(fn c -> c.message != "" end)

        {:ok, %{stats: %{additions: additions, deletions: deletions}, commits: commits}}

      {:ok, %{status: status}} ->
        {:error, "Compare API returned #{status}"}

      {:error, error} ->
        {:error, "Compare API failed: #{inspect(error)}"}
    end
  end

  defp parse_push_event(event) do
    %{
      event_id: event["id"],
      repo: event["repo"]["name"],
      branch: (event["payload"]["ref"] || "") |> String.replace("refs/heads/", ""),
      before_sha: event["payload"]["before"] || "",
      head_sha: event["payload"]["head"] || "",
      created_at: event["created_at"]
    }
  end
end
