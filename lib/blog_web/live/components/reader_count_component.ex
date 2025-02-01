defmodule BlogWeb.ReaderCountComponent do
  use BlogWeb, :live_component
  alias BlogWeb.Presence

  @presence_topic "blog_presence"

  def mount(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
    end

    {:ok, assign(socket, total_readers: Presence.list(@presence_topic) |> map_size())}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, total_readers: Presence.list(@presence_topic) |> map_size())}
  end

  def render(assigns) do
    ~H"""
    <div class="text-sm text-gray-500 mb-6">
      <%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> online
    </div>
    """
  end
end
