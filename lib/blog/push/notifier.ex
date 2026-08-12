defmodule Blog.Push.Notifier do
  @moduledoc """
  Subscribes to the "blinks" PubSub topic and pushes an APNs alert to every
  registered device when a new blink is saved. Re-saving an existing URL
  re-broadcasts :blink_saved, so pushes are deduped per blink id (bounded
  in-memory set).
  """
  use GenServer

  require Logger

  alias Blog.Push

  @max_seen 500

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Blog.PubSub, Blog.Blinks.topic())
    {:ok, %{seen_queue: :queue.new(), seen: MapSet.new()}}
  end

  @impl true
  def handle_info({:blink_saved, blink}, state) do
    if MapSet.member?(state.seen, blink.id) or not Blog.Push.APNS.configured?() do
      {:noreply, state}
    else
      Task.start(fn -> notify_all(blink) end)
      {:noreply, remember(state, blink.id)}
    end
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp remember(%{seen_queue: queue, seen: seen} = state, id) do
    queue = :queue.in(id, queue)
    seen = MapSet.put(seen, id)

    if MapSet.size(seen) > @max_seen do
      {{:value, oldest}, queue} = :queue.out(queue)
      %{state | seen_queue: queue, seen: MapSet.delete(seen, oldest)}
    else
      %{state | seen_queue: queue, seen: seen}
    end
  end

  defp notify_all(blink) do
    payload = %{
      "aps" => %{
        "alert" => %{
          "title" => "new blink",
          "body" => blink.title || blink.url
        },
        "sound" => "default"
      },
      "blink_id" => blink.id,
      "url" => blink.url
    }

    for device <- Push.list_devices() do
      case Blog.Push.APNS.push(device.token, device.env, payload) do
        :ok ->
          :ok

        {:error, 410, _body} ->
          Push.delete_device(device.token)

        {:error, status, body} ->
          if body =~ "BadDeviceToken", do: Push.delete_device(device.token)
          Logger.warning("APNs push rejected (#{status}): #{body}")

        {:error, :transport, msg} ->
          Logger.warning("APNs transport error: #{msg}")
      end
    end
  end
end
