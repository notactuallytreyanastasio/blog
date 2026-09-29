def init(counter) do
  Logger.info("Producer starting with counter: #{counter}")
  {:producer, counter, dispatcher: GenStage.BroadcastDispatcher}
end