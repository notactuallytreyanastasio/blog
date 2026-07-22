defmodule Blog.Blinks.LinkCheck do
  @moduledoc """
  The dead-link sentinel: once a day, re-checks every saved URL. Links that
  404/error get flagged (`dead_at`) and the UI swaps their title link to the
  wayback copy; links that recover get unflagged.
  """

  use GenServer
  require Logger
  import Ecto.Query
  alias Blog.Blinks.Blink
  alias Blog.Repo

  # first sweep 10 minutes after boot, then daily
  @initial_delay :timer.minutes(10)
  @interval :timer.hours(24)

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_) do
    Process.send_after(self(), :sweep, @initial_delay)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:sweep, state) do
    {checked, died} = sweep()
    Logger.info("blinks link check: #{checked} checked, #{died} dead")
    Process.send_after(self(), :sweep, @interval)
    {:noreply, state}
  end

  @doc "Check every blink not checked in the last 20 hours. Returns {checked, dead}."
  @spec sweep() :: {non_neg_integer(), non_neg_integer()}
  def sweep do
    cutoff = NaiveDateTime.add(NaiveDateTime.utc_now(), -20 * 3600)

    Blink
    |> where([b], is_nil(b.last_checked_at) or b.last_checked_at < ^cutoff)
    |> Repo.all()
    |> Enum.reduce({0, 0}, fn blink, {checked, died} ->
      status = check_url(blink.url)
      {:ok, updated} = record_result(blink, status)
      {checked + 1, died + if(updated.dead_at, do: 1, else: 0)}
    end)
  end

  @doc "One HTTP check: :ok when the page answers < 400, :dead otherwise."
  @spec check_url(String.t()) :: :ok | :dead
  def check_url(url) do
    case Req.get(url,
           redirect: true,
           max_redirects: 5,
           receive_timeout: 15_000,
           retry: false,
           headers: [{"user-agent", "blinks-linkcheck/1.0 (+https://bobbby.online/blinks)"}]
         ) do
      {:ok, %Req.Response{status: status}} when status < 400 -> :ok
      {:ok, %Req.Response{}} -> :dead
      {:error, _} -> :dead
    end
  end

  @doc """
  Persist a check result. A single flaky failure doesn't kill a link — it
  takes two consecutive failed sweeps before `dead_at` is set. Success
  resets everything; repeat failures keep the original death timestamp.
  """
  @spec record_result(Blink.t(), :ok | :dead) :: {:ok, Blink.t()}
  def record_result(%Blink{} = blink, status) do
    now = NaiveDateTime.utc_now(:second)

    attrs =
      case status do
        :ok ->
          %{dead_at: nil, fail_count: 0, last_checked_at: now}

        :dead ->
          fails = blink.fail_count + 1

          %{
            fail_count: fails,
            dead_at: if(fails >= 2, do: blink.dead_at || now),
            last_checked_at: now
          }
      end

    blink |> Blink.changeset(attrs) |> Repo.update()
  end
end
