defmodule Blog.GifMaker.Processor do
  use GenServer
  require Logger

  alias Blog.GifMaker
  alias Blog.GifMaker.{YouTube, FrameExtractor}

  @max_concurrent 2

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{active: 0}, name: __MODULE__)
  end

  def process_job(job_id) do
    GenServer.cast(__MODULE__, {:process, job_id})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:process, job_id}, %{active: active} = state) when active >= @max_concurrent do
    Logger.warning("GIF Maker: max concurrent jobs reached, queueing job #{job_id}")
    Process.send_after(self(), {:retry, job_id}, 5_000)
    {:noreply, state}
  end

  def handle_cast({:process, job_id}, %{active: active} = state) do
    Task.Supervisor.async_nolink(Blog.GifMaker.TaskSupervisor, fn ->
      run_pipeline(job_id)
    end)

    {:noreply, %{state | active: active + 1}}
  end

  @impl true
  def handle_info({:retry, job_id}, state) do
    handle_cast({:process, job_id}, state)
    {:noreply, state}
  end

  def handle_info({ref, _result}, %{active: active} = state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    {:noreply, %{state | active: max(active - 1, 0)}}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, %{active: active} = state) do
    if reason != :normal do
      Logger.error("GIF Maker task crashed: #{inspect(reason)}")
    end

    {:noreply, %{state | active: max(active - 1, 0)}}
  end

  defp run_pipeline(job_id) do
    job = GifMaker.get_job!(job_id)
    broadcast(job_id, :downloading, "Downloading video segment...")

    with {:ok, _} <- GifMaker.update_job_status(job, "downloading"),
         {:ok, video_path, temp_dir} <- download_segment(job),
         {:ok, _} <- GifMaker.update_job_status(job, "extracting"),
         _ <- broadcast(job_id, :extracting, "Extracting frames..."),
         {:ok, count} <- FrameExtractor.extract_frames(video_path, job_id),
         {:ok, _} <- GifMaker.update_job_status(job, "ready", %{frame_count: count}) do
      File.rm_rf(temp_dir)
      broadcast(job_id, :ready, "#{count} frames ready!")
      Logger.info("GIF Maker job #{job_id}: #{count} frames extracted")
    else
      {:error, reason} ->
        GifMaker.update_job_status(job, "failed", %{error_message: to_string(reason)})
        broadcast(job_id, :failed, to_string(reason))
        Logger.error("GIF Maker job #{job_id} failed: #{reason}")
    end
  end

  defp download_segment(job) do
    start_sec = div(job.start_time_ms, 1000)
    duration_sec = div(job.end_time_ms - job.start_time_ms, 1000)
    YouTube.download_segment(job.youtube_url, start_sec, duration_sec)
  end

  defp broadcast(job_id, status, message) do
    Phoenix.PubSub.broadcast(Blog.PubSub, "gif_maker:#{job_id}", {:processing_update, status, message})
  end
end
