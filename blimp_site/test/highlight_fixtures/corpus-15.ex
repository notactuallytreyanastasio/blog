def handle_demand(demand, %{buffer: buffer} = state) do
  {to_emit, remaining} = Enum.split(buffer, demand)

  if length(to_emit) < demand do
    # Buffer exhausted, try to refill
    new_events = fetch_more_events()
    all_events = to_emit ++ new_events
    {to_emit_now, to_buffer} = Enum.split(all_events, demand)
    {:noreply, to_emit_now, %{state | buffer: to_buffer}}
  else
    {:noreply, to_emit, %{state | buffer: remaining}}
  end
end