defmodule JobProcessor.ProducerTest do
  use ExUnit.Case
  alias JobProcessor.Producer

  test "producer emits events on demand" do
    {:ok, producer} = Producer.start_link(0)

    # Manually subscribe and ask for events
    {:ok, _subscription} = GenStage.sync_subscribe(self(), to: producer, max_demand: 5)

    # We should receive 5 events (0 through 4)
    assert_receive {:"$gen_consumer", {_, _}, [0, 1, 2, 3, 4]}
  end

  test "producer maintains state across demands" do
    {:ok, producer} = Producer.start_link(10)

    # First demand
    {:ok, _} = GenStage.sync_subscribe(self(), to: producer, max_demand: 3)
    assert_receive {:"$gen_consumer", {_, _}, [10, 11, 12]}

    # Second demand should continue from where we left off
    send(producer, {:"$gen_producer", {self(), nil}, {:ask, 2}})
    assert_receive {:"$gen_consumer", {_, _}, [13, 14]}
  end
end