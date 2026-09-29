# Traditional approach - producer decides when to push
loop do
  job = create_job()
  Queue.push(job)  # What if queue is full?
end