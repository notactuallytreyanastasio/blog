defmodule Blog.Push.Notifier do
  @moduledoc """
  Subscribes to the "blinks" PubSub topic and, when a new blink is saved,
  pushes an APNs alert to every registered iOS device and a Web Push to every
  browser subscription (the PWA on a home screen). Re-saving an existing URL
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
    if MapSet.member?(state.seen, blink.id) or
         not (Blog.Push.APNS.configured?() or Blog.Push.WebPush.configured?()) do
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
    notify_apns(blink)
    notify_web(blink)
  end

  @doc false
  def notify_web(blink) do
    if Blog.Push.WebPush.configured?() do
      blink_tags = MapSet.new(blink.tags || [])

      payload = %{
        "title" => "new blink",
        "body" => blink.title || blink.url,
        "url" => blink.url,
        "blink_id" => blink.id
      }

      for sub <- Push.list_web_subscriptions(), wants_blink?(sub, blink_tags) do
        case Blog.Push.WebPush.send(sub, payload) do
          :ok -> Push.touch_web_subscription(sub)
          {:error, :expired} -> Push.delete_web_subscription(sub.endpoint)
          {:error, reason} -> Logger.warning("web push failed: #{inspect(reason)}")
        end
      end
    end
  end

  defp notify_apns(blink) do
    if Blog.Push.APNS.configured?(), do: do_notify_apns(blink)
  end

  defp do_notify_apns(blink) do
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

    blink_tags = MapSet.new(blink.tags || [])

    for device <- Push.list_devices(),
        wants_blink?(device, blink_tags) do
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

  # No followed tags = the original firehose; otherwise the blink must carry
  # at least one followed tag.
  defp wants_blink?(%{followed_tags: []}, _blink_tags), do: true
  defp wants_blink?(%{followed_tags: nil}, _blink_tags), do: true

  defp wants_blink?(%{followed_tags: followed}, blink_tags) do
    Enum.any?(followed, &MapSet.member?(blink_tags, &1))
  end
end
