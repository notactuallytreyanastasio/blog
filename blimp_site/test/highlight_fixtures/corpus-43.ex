defmodule JobProcessor.Telemetry do
  def setup do
    events = [
      [:job_processor, :job, :start],
      [:job_processor, :job, :stop],
      [:job_processor, :job, :exception],
      [:job_processor, :queue, :depth]
    ]

    :telemetry.attach_many("job-processor-metrics", events, &handle_event/4, nil)
  end

  def handle_event([:job_processor, :job, :stop], measurements, metadata, _config) do
    JobProcessor.Metrics.record_job_duration(metadata.queue, measurements.duration)
    JobProcessor.Metrics.increment_jobs_completed(metadata.queue)
    JobProcessor.Metrics.record_job_success(metadata.module, metadata.function)
  end
end