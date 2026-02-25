defmodule Blog.GitHub.WorkLogPoller do
  use GenServer
  require Logger

  @poll_interval 60_000
  @github_username "notactuallytreyanastasio"
  @events_url "https://api.github.com/users/#{@github_username}/events/public"
  @topic "github:work_log"

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_events do
    GenServer.call(__MODULE__, :get_events)
  end

  @impl true
  def init(_opts) do
    send(self(), :poll)
    {:ok, %{events: [], last_updated: nil}}
  end

  @impl true
  def handle_call(:get_events, _from, state) do
    {:reply, {state.events, state.last_updated}, state}
  end

  @impl true
  def handle_info(:poll, state) do
    events = fetch_events()
    now = DateTime.utc_now()

    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:work_log_updated, events, now})

    Process.send_after(self(), :poll, @poll_interval)
    {:noreply, %{state | events: events, last_updated: now}}
  end

  defp fetch_events do
    case Req.get(@events_url, headers: [{"user-agent", "bobbby-work-log"}]) do
      {:ok, %{status: 200, body: body}} when is_list(body) ->
        body
        |> Enum.filter(&(&1["type"] == "PushEvent"))
        |> Enum.map(&parse_push_event/1)

      {:ok, %{status: status}} ->
        Logger.warning("GitHub Events API returned #{status}")
        state_or_empty(status)

      {:error, error} ->
        Logger.error("GitHub Events API failed: #{inspect(error)}")
        []
    end
  end

  defp state_or_empty(304), do: :unchanged
  defp state_or_empty(_), do: []

  defp parse_push_event(event) do
    %{
      repo: event["repo"]["name"],
      branch: (event["payload"]["ref"] || "") |> String.replace("refs/heads/", ""),
      commits:
        Enum.map(event["payload"]["commits"] || [], fn c ->
          %{
            sha: String.slice(c["sha"] || "", 0..6),
            message: String.split(c["message"] || "", "\n") |> List.first(),
            author: get_in(c, ["author", "name"])
          }
        end),
      created_at: parse_datetime(event["created_at"])
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
