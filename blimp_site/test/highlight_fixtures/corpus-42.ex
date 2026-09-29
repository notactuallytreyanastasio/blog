defmodule JobProcessor.DeadLetterQueue do
  def handle_permanent_failure(job, final_error) do
    dead_job = %{
      original_job: job,
      failed_at: DateTime.utc_now(),
      final_error: final_error,
      attempt_history: job.attempt_history || [],
      forensics: collect_forensics(job)
    }

    Repo.insert(%DeadJob{data: dead_job})
    JobProcessor.Notifications.send_dead_letter_alert(dead_job)
  end

  defp collect_forensics(job) do
    %{
      system_load: :erlang.statistics(:scheduler_utilization),
      memory_usage: :erlang.memory(),
      queue_depths: JobQueue.all_queue_depths(),
      recent_errors: JobProcessor.ErrorTracker.recent_errors(job.module)
    }
  end
end