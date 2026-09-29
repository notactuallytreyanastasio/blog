defmodule JobProcessor.AutoScaler do
  use GenServer

  def init(queue_name) do
    schedule_check()
    {:ok, %{queue: queue_name, consumers: [], target_consumers: 2}}
  end

  def handle_info(:check_scaling, state) do
    queue_depth = JobQueue.queue_depth(state.queue)
    current_consumers = length(state.consumers)

    target = calculate_target_consumers(queue_depth, current_consumers)

    new_state =
      cond do
        target > current_consumers -> scale_up(state, target - current_consumers)
        target < current_consumers -> scale_down(state, current_consumers - target)
        true -> state
      end

    schedule_check()
    {:noreply, new_state}
  end

  defp calculate_target_consumers(queue_depth, current) do
    cond do
      queue_depth > 1000 -> min(current + 2, 10)
      queue_depth > 100 -> min(current + 1, 10)
      queue_depth < 10 -> max(current - 1, 1)
      true -> current
    end
  end
end