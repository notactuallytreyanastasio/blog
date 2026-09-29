def handle_events(events, _from, state) do
  for event <- events do
    file_path = "/tmp/processed_#{event.id}.json"
    File.write!(file_path, Jason.encode!(event))
  end

  {:noreply, [], state}
end