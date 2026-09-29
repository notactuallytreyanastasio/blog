def handle_events(events, _from, state) do
  for event <- events do
    try do
      process_event(event)
    rescue
      e ->
        Logger.error("Failed to process event #{event.id}: #{inspect(e)}")
        # Could send to dead letter queue, retry later, etc.
    end
  end

  {:noreply, [], state}
end