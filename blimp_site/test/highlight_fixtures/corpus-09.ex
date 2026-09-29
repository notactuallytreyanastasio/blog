# GenStage approach - consumer decides when to pull
def handle_demand(demand, state) do
  jobs = create_jobs(demand)  # Only create what's asked for
  {:noreply, jobs, state}
end