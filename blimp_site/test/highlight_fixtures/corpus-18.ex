def init(opts) do
  {:consumer, opts,
   subscribe_to: [
     {JobProcessor.Producer, min_demand: 5, max_demand: 50}
   ]}
end