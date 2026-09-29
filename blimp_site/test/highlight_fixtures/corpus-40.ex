defmodule JobProcessor.WorkerRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register_worker(queue, pid, metadata \\ %{}) do
    GenServer.cast(__MODULE__, {:register, queue, pid, metadata})
  end

  def get_workers(queue) do
    GenServer.call(__MODULE__, {:get_workers, queue})
  end

  def get_worker_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  def handle_cast({:register, queue, pid, metadata}, state) do
    Process.monitor(pid)

    worker_info = %{
      pid: pid,
      queue: queue,
      started_at: DateTime.utc_now(),
      jobs_processed: 0,
      last_job_at: nil,
      metadata: metadata
    }

    new_workers = Map.put(state.workers || %{}, pid, worker_info)
    {:noreply, %{state | workers: new_workers}}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.warn("Worker #{inspect(pid)} died: #{inspect(reason)}")
    new_workers = Map.delete(state.workers, pid)
    {:noreply, %{state | workers: new_workers}}
  end
end