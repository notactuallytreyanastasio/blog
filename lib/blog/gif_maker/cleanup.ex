defmodule Blog.GifMaker.Cleanup do
  use GenServer
  require Logger

  @cleanup_interval :timer.minutes(30)

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
    count = Blog.GifMaker.cleanup_expired_jobs()

    if count > 0 do
      Logger.info("GIF Maker cleanup: deleted #{count} expired jobs")
    end

    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end
end
