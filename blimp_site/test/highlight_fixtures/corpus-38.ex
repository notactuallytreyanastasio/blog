defmodule JobProcessor.QueueSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      # Email queue - fast, lightweight
      queue_spec(:email_queue, max_consumers: 5, max_demand: 1),

      # Analytics queue - batch processing
      queue_spec(:analytics_queue, max_consumers: 3, max_demand: 100),

      # ML queue - heavy computation
      queue_spec(:ml_queue, max_consumers: 1, max_demand: 1)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp queue_spec(queue_name, opts) do
    %{
      id: :"#{queue_name}_supervisor",
      start: {JobProcessor.QueueManager, :start_link, [queue_name, opts]},
      type: :supervisor
    }
  end
end