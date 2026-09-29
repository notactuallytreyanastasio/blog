defmodule JobProcessor.Consumer do
  use GenStage
  require Logger
  alias JobProcessor.{Job, JobQueue}

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    {:consumer, opts, subscribe_to: [JobProcessor.Producer]}
  end

  @impl true
  def handle_events(jobs, _from, state) do
    Logger.info("Consumer received #{length(jobs)} jobs")

    for job <- jobs do
      execute_job(job)
    end

    {:noreply, [], state}
  end

  defp execute_job(%{id: job_id, payload: payload, attempts: attempts}) do
    try do
      {module, function, args} = Job.decode_job(payload)

      Logger.info("Executing job #{job_id}: #{module}.#{function}")

      # Execute the job
      result = apply(module, function, args)

      # Mark as completed
      JobQueue.complete_job(job_id)

      Logger.info("Job #{job_id} completed successfully")

      result
    rescue
      error ->
        error_message = Exception.format(:error, error, __STACKTRACE__)
        Logger.error("Job #{job_id} failed: #{error_message}")

        # Mark as failed (with retry logic)
        JobQueue.fail_job(job_id, error_message, attempts + 1)
    end
  end
end