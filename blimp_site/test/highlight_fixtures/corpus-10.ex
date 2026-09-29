defmodule JobProcessor.Producer do
  use GenStage
  require Logger

  @doc """
  Starts the producer with an initial state.

  The state can be anything, but we'll use a counter to start simple.
  """
  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  @impl true
  def init(counter) do
    Logger.info("Producer starting with counter: #{counter}")
    {:producer, counter}
  end

  @impl true
  def handle_demand(demand, state) do
    Logger.info("Producer received demand for #{demand} events")

    # Generate events to fulfill demand
    events = Enum.to_list(state..(state + demand - 1))

    # Update our state
    new_state = state + demand

    # Return events and new state
    {:noreply, events, new_state}
  end
end