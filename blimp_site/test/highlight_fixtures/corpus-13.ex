def handle_demand(demand, state) do
  jobs = Repo.all(
    from j in Job,
    where: j.status == "pending",
    limit: ^demand,
    lock: "FOR UPDATE SKIP LOCKED"
  )

  job_ids = Enum.map(jobs, & &1.id)

  Repo.update_all(
    from(j in Job, where: j.id in ^job_ids),
    set: [status: "processing"]
  )

  {:noreply, jobs, state}
end