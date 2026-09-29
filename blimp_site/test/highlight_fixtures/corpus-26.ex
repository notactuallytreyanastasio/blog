def start(_type, _args) do
  children = [
    # Start the Producer first
    JobProcessor.Producer,

    # Start multiple consumers
    {JobProcessor.Consumer, [id: :consumer_1]},
    {JobProcessor.Consumer, [id: :consumer_2]},
    {JobProcessor.Consumer, [id: :consumer_3]},

    # Other children
    JobProcessorWeb.Endpoint
  ]

  opts = [strategy: :one_for_one, name: JobProcessor.Supervisor]
  Supervisor.start_link(children, opts)
end