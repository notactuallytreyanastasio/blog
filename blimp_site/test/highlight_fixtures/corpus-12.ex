def handle_info(:new_data_available, state) do
  events = fetch_available_events()
  {:noreply, events, state}
end