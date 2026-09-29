iex -S mix

# Queue a simple job
JobProcessor.JobQueue.enqueue(JobProcessor.TestJob, :hello, ["World"])

# Queue a failing job (to test retry logic)
JobProcessor.JobQueue.enqueue(JobProcessor.TestJob, :failing_job, [])

# Queue multiple jobs to see parallel processing
for i <- 1..10 do
  JobProcessor.JobQueue.enqueue(JobProcessor.TestJob, :hello, ["Person #{i}"])
end