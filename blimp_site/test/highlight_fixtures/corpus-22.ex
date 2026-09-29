def handle_events(events, _from, state) do
  for event <- events do
    case HTTPoison.post(state.webhook_url, Jason.encode!(event)) do
      {:ok, %{status_code: 200}} -> :ok
      {:error, reason} -> Logger.error("Webhook failed: #{inspect(reason)}")
    end
  end

  {:noreply, [], state}
end