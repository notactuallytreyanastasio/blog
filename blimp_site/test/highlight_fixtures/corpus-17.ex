defmodule JobProcessor.Consumer do
  use GenStage
  require Logger

  @doc """
  Starts the consumer.

  Like producers, consumers are just GenServer-like processes.
  The state can be anything you need for processing.
  """
  def start_link(opts \\ []) do
    GenStage.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    # The key difference: we declare ourselves as a :consumer
    # and specify which producer(s) to subscribe to
    {:consumer, opts, subscribe_to: [JobProcessor.Producer]}
  end

  @impl true
  def handle_events(events, _from, state) do
    Logger.info("Consumer received #{length(events)} events")

    # Process each event
    for event <- events do
      process_event(event, state)
    end

    # Always return {:noreply, [], state} for consumers
    # The empty list means we don't emit any events (we're not a producer)
    {:noreply, [], state}
  end

  defp process_event(event, state) do
    # For now, just log what we received
    Logger.info("Processing event: #{event}")
    IO.inspect({self(), event, state}, label: "Consumer processed")
  end
end