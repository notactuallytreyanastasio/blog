defmodule JobProcessor.TestJob do
  require Logger

  def hello(name) do
    Logger.info("Hello, #{name}!")
    Process.sleep(1000)  # Simulate some work
    "Greeted #{name}"
  end

  def failing_job do
    Logger.info("This job will fail...")
    raise "Intentional failure for testing"
  end

  def heavy_job(duration_ms) do
    Logger.info("Starting heavy job for #{duration_ms}ms")
    Process.sleep(duration_ms)
    Logger.info("Heavy job completed")
    "Completed heavy work"
  end
end