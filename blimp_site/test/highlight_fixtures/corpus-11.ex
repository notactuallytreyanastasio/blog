def handle_demand(demand, state) do
  available = calculate_available_work()

  if available >= demand do
    events = fetch_events(demand)
    {:noreply, events, state}
  else
    # Can only partially fulfill demand
    events = fetch_events(available)
    {:noreply, events, state}
  end
end