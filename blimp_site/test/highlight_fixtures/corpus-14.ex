def handle_demand(demand, %{rate_limit: limit} = state) do
  now = System.monotonic_time(:millisecond)
  time_passed = now - state.last_emit

  allowed = min(demand, div(time_passed * limit, 1000))

  if allowed > 0 do
    events = generate_events(allowed)
    {:noreply, events, %{state | last_emit: now}}
  else
    # Schedule retry
    Process.send_after(self(), :retry_demand, 100)
    {:noreply, [], state}
  end
end