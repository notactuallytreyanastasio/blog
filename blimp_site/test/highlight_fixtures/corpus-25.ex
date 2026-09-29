def start(_type, _args) do
  children = [
    # Start the Producer first
    JobProcessor.Producer,

    # Then start the Consumer
    # The consumer will automatically connect to the producer
    JobProcessor.Consumer,

    # Other children like Ecto, Phoenix endpoint, etc.
    JobProcessorWeb.Endpoint
  ]

  opts = [strategy: :one_for_one, name: JobProcessor.Supervisor]
  Supervisor.start_link(children, opts)
end