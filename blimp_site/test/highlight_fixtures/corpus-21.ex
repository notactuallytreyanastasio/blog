def handle_events(events, _from, state) do
  # Batch insert for efficiency
  records = Enum.map(events, &transform_event/1)
  Repo.insert_all(MyTable, records)

  {:noreply, [], state}
end