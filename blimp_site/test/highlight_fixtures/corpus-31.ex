defmodule JobProcessor.Producer do
  use GenStage
  require Logger
  alias JobProcessor.JobQueue

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Logger.info("Job Producer starting")
    {:producer, %{}, dispatcher: GenStage.DemandDispatcher}
  end

  @impl true
  def handle_demand(demand, state) when demand > 0 do
    Logger.info("Producer received demand for #{demand} jobs")

    case JobQueue.fetch_jobs(demand) do
      {:ok, {count, jobs}} when count > 0 ->
        Logger.info("Fetched #{count} jobs from database")
        {:noreply, jobs, state}

      {:ok, {0, []}} ->
        # No jobs available, schedule a check for later
        Process.send_after(self(), :check_for_jobs, 1000)
        {:noreply, [], state}

      {:error, reason} ->
        Logger.error("Failed to fetch jobs: #{inspect(reason)}")
        {:noreply, [], state}
    end
  end

  @impl true
  def handle_info(:check_for_jobs, state) do
    # This allows us to produce events even when there's no pending demand
    # if jobs become available
    case JobQueue.fetch_jobs(10) do
      {:ok, {count, jobs}} when count > 0 ->
        {:noreply, jobs, state}
      _ ->
        Process.send_after(self(), :check_for_jobs, 1000)
        {:noreply, [], state}
    end
  end
end