defmodule Blog.CameraBrowser.Poller do
  @moduledoc """
  Runs `Blog.CameraBrowser.poll/0` every 15 minutes. First run is a couple of
  minutes after boot so a deploy doesn't immediately hammer Craigslist, and
  each run is wrapped so one bad sweep never takes the process down.
  """
  use GenServer
  require Logger

  @initial_delay :timer.minutes(2)
  @interval :timer.minutes(15)

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @doc "Kick off a poll right now (asynchronously)."
  @spec poll_now() :: :ok
  def poll_now, do: GenServer.cast(__MODULE__, :poll)

  @impl true
  def init(_) do
    Process.send_after(self(), :poll, @initial_delay)
    {:ok, %{last: nil}}
  end

  @impl true
  def handle_info(:poll, state) do
    state = run(state)
    Process.send_after(self(), :poll, @interval)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:poll, state), do: {:noreply, run(state)}

  defp run(state) do
    try do
      %{state | last: Blog.CameraBrowser.poll()}
    rescue
      e ->
        Logger.error("camera browser poll crashed: #{Exception.message(e)}")
        state
    end
  end
end
