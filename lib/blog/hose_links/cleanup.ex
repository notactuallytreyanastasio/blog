defmodule Blog.HoseLinks.Cleanup do
  use GenServer
  require Logger

  @cleanup_interval :timer.minutes(10)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_cleanup()
    {:ok, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    count = Blog.HoseLinks.cleanup_expired()

    if count > 0 do
      Logger.info("HoseLinks cleanup: deleted #{count} expired links")
    end

    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end
end
