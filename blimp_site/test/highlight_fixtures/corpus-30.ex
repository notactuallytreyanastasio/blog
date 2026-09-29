defmodule JobProcessor.JobQueue do
  import Ecto.Query
  alias JobProcessor.{Repo, Job}

  @doc """
  Enqueue a job for processing.

  This is the public API that applications use to submit work.
  """
  def enqueue(module, function, args, opts \\ []) do
    payload = Job.encode_job(module, function, args)

    attrs = %{
      payload: payload,
      max_attempts: Keyword.get(opts, :max_attempts, 3),
      scheduled_at: Keyword.get(opts, :scheduled_at, DateTime.utc_now())
    }

    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetch available jobs for processing.

  This is called by our GenStage producer to get work.
  Uses FOR UPDATE SKIP LOCKED to avoid race conditions.
  """
  def fetch_jobs(limit) do
    now = DateTime.utc_now()

    Repo.transaction(fn ->
      # Find available jobs
      job_ids =
        from(j in Job,
          where: j.status == "queued" and j.scheduled_at <= ^now,
          limit: ^limit,
          select: j.id,
          lock: "FOR UPDATE SKIP LOCKED"
        )
        |> Repo.all()

      # Mark them as running and return the full job data
      {count, jobs} =
        from(j in Job, where: j.id in ^job_ids)
        |> Repo.update_all(
          [set: [status: "running", started_at: DateTime.utc_now()]],
          returning: [:id, :payload, :attempts, :max_attempts]
        )

      {count, jobs}
    end)
  end

  @doc """
  Mark a job as completed successfully.
  """
  def complete_job(job_id) do
    from(j in Job, where: j.id == ^job_id)
    |> Repo.update_all(
      set: [status: "completed", completed_at: DateTime.utc_now()]
    )
  end

  @doc """
  Mark a job as failed and handle retry logic.
  """
  def fail_job(job_id, error_message, attempts \\ 1) do
    job = Repo.get!(Job, job_id)

    if attempts >= job.max_attempts do
      # Permanently failed
      from(j in Job, where: j.id == ^job_id)
      |> Repo.update_all(
        set: [
          status: "failed",
          error_message: error_message,
          attempts: attempts,
          completed_at: DateTime.utc_now()
        ]
      )
    else
      # Retry later
      retry_at = DateTime.add(DateTime.utc_now(), 60 * attempts, :second)

      from(j in Job, where: j.id == ^job_id)
      |> Repo.update_all(
        set: [
          status: "queued",
          error_message: error_message,
          attempts: attempts,
          scheduled_at: retry_at
        ]
      )
    end
  end
end