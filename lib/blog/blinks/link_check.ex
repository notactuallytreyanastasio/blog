defmodule Blog.Blinks.LinkCheck do
  @moduledoc """
  The dead-link sentinel: once a day, re-checks every saved URL. Links that are
  really gone get flagged (`dead_at`) and the UI swaps their title link to the
  wayback copy; links that recover get unflagged.

  The hard part is not detecting death, it's refusing to call something dead
  when we simply failed to look at it. A checker that can't tell "this page is
  gone" from "I have no network" will happily bury an entire library the first
  time its own host drops off the internet — which is exactly what happened on
  2026-07-24, when a billing block on the host null-routed us and 38 links died
  in the same four-minute window. So checks resolve three ways, not two, and a
  sweep that looks broken on our end throws its own results away.
  """

  use GenServer
  require Logger
  import Ecto.Query
  alias Blog.Blinks.Blink
  alias Blog.Repo

  # first sweep 10 minutes after boot, then daily
  @initial_delay :timer.minutes(10)
  @interval :timer.hours(24)

  # Only these mean the page is gone. Everything else a server says — 403 from a
  # bot wall, 429 from a rate limiter, 5xx from a bad afternoon — is a page we
  # couldn't read, not a page that stopped existing.
  @dead_statuses [404, 410]

  # Reachable third parties used to prove we have a working network before we
  # trust a single result. If none of these answer, the problem is us.
  @canaries ["https://example.com/", "https://www.cloudflare.com/"]

  # A sweep where this share of links "fails" is a sweep to distrust: real link
  # rot trickles in, it does not arrive all at once.
  @max_fail_ratio 0.3
  @min_sample 5

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

  @doc """
  Check every blink not checked in the last 20 hours. Returns {checked, dead}.

  Results are gathered before any of them are written, so the sweep can look at
  its own shape and bail out wholesale if it smells like a local outage rather
  than a bad day for the web.
  """
  @spec sweep() :: {non_neg_integer(), non_neg_integer()}
  def sweep do
    case due_blinks() do
      [] ->
        {0, 0}

      blinks ->
        if network_up?() do
          blinks |> Enum.map(&{&1, check_url(&1.url)}) |> commit_sweep()
        else
          Logger.error("blinks link check: no canary reachable, skipping sweep — the network is ours to fix")
          {0, 0}
        end
    end
  end

  defp due_blinks do
    cutoff = NaiveDateTime.add(NaiveDateTime.utc_now(), -20 * 3600)

    Blink
    |> where([b], is_nil(b.last_checked_at) or b.last_checked_at < ^cutoff)
    |> Repo.all()
  end

  # Write the batch, unless too much of it failed to resolve — a mass failure is
  # far likelier to be one broken checker than N broken websites.
  defp commit_sweep(results) do
    total = length(results)
    failed = Enum.count(results, fn {_blink, status} -> status != :ok end)

    if total >= @min_sample and failed / total > @max_fail_ratio do
      Logger.error(
        "blinks link check: #{failed}/#{total} links failed, discarding sweep — " <>
          "that ratio means something broke on our side, not theirs"
      )

      {0, 0}
    else
      Enum.reduce(results, {0, 0}, fn {blink, status}, {checked, died} ->
        {:ok, updated} = record_result(blink, status)
        {checked + 1, died + if(updated.dead_at, do: 1, else: 0)}
      end)
    end
  end

  defp network_up?, do: Enum.any?(@canaries, &(check_url(&1) == :ok))

  @doc """
  One HTTP check, resolving three ways:

    * `:ok` — the page answered.
    * `:dead` — the page is gone: 404, 410, or a domain that no longer resolves.
    * `:unknown` — we couldn't tell. Bot walls (403), rate limits (429), auth
      gates (401), server errors, timeouts, TLS failures. These leave the
      link's record alone rather than counting against it.
  """
  @spec check_url(String.t()) :: :ok | :dead | :unknown
  def check_url(url) do
    case Req.get(url,
           redirect: true,
           max_redirects: 5,
           receive_timeout: 15_000,
           retry: false,
           headers: [{"user-agent", "blinks-linkcheck/1.0 (+https://bobbby.online/blinks)"}]
         ) do
      {:ok, %Req.Response{status: status}} when status < 400 -> :ok
      {:ok, %Req.Response{status: status}} when status in @dead_statuses -> :dead
      {:ok, %Req.Response{}} -> :unknown
      # A domain that stopped resolving is the classic way a link rots. Every
      # other transport failure is our problem until proven otherwise.
      {:error, %{reason: :nxdomain}} -> :dead
      {:error, _} -> :unknown
    end
  end

  @doc """
  Persist a check result. A single flaky failure doesn't kill a link — it
  takes two consecutive failed sweeps before `dead_at` is set. Success
  resets everything; repeat failures keep the original death timestamp.

  An `:unknown` result is not evidence either way, so it only records that we
  looked: the fail count and any existing death stand untouched.
  """
  @spec record_result(Blink.t(), :ok | :dead | :unknown) :: {:ok, Blink.t()}
  def record_result(%Blink{} = blink, status) do
    now = NaiveDateTime.utc_now(:second)

    attrs =
      case status do
        :ok ->
          %{dead_at: nil, fail_count: 0, last_checked_at: now}

        :unknown ->
          %{last_checked_at: now}

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
