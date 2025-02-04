defmodule BlogWeb.ReaderCountLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  require Logger

  @presence_topic "blog_presence"

  def mount(_params, _session, socket) do
    Logger.debug("Mounting ReaderCountLive")

    if connected?(socket) do
      Logger.debug("ReaderCountLive connected")

      # Subscribe to presence changes
      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)

      # Generate a unique ID for this connection
      reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

      # Track presence with process monitoring
      {:ok, _} = Presence.track(
        self(),
        @presence_topic,
        reader_id,
        %{
          name: "Reader-#{:rand.uniform(999)}",
          anonymous: true,
          joined_at: DateTime.utc_now(),
          phx_ref: socket.assigns.myself.phx_ref
        }
      )

      Logger.debug("Presence tracked for #{reader_id}")
      socket = assign(socket, :reader_id, reader_id)
    end

    {:ok, assign(socket,
      total_readers: presence_count(),
      show_names: false,
      show_name_form: true,
      name: "",
      presence_list: presence_list()
    )}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    Logger.debug("Presence diff - Joins: #{map_size(joins)}, Leaves: #{map_size(leaves)}")

    {:noreply, assign(socket,
      total_readers: presence_count(),
      presence_list: presence_list()
    )}
  end

  def handle_event("toggle-names", _, socket) do
    {:noreply, assign(socket, show_names: !socket.assigns.show_names)}
  end

  def handle_event("save-name", %{"name" => name}, socket) do
    if connected?(socket) do
      current_presence =
        Presence.list(@presence_topic)
        |> Enum.find(fn {id, %{metas: [meta | _]}} ->
          meta.phx_ref == socket.assigns.myself.phx_ref
        end)

      case current_presence do
        {reader_id, %{metas: [meta | _]}} ->
          {:ok, _} = Presence.update(self(), @presence_topic, reader_id, Map.merge(meta, %{
            name: name,
            anonymous: false
          }))
          {:noreply, assign(socket, show_name_form: false)}

        nil ->
          # If we can't find our presence, create a new one
          reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
          {:ok, _} = Presence.track(self(), @presence_topic, reader_id, %{
            name: name,
            anonymous: false,
            joined_at: DateTime.utc_now()
          })
          {:noreply, assign(socket, show_name_form: false)}
      end
    else
      {:noreply, socket}
    end
  end

  defp presence_count do
    count = Presence.list(@presence_topic) |> map_size()
    Logger.debug("Current presence count: #{count}")
    count
  end

  defp presence_list do
    Presence.list(@presence_topic)
  end

  def render(assigns) do
    ~H"""
    <div class="text-sm text-gray-500 mb-6">
      <div class="cursor-pointer" phx-click="toggle-names">
        <%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> online
      </div>

      <%= if @show_names do %>
        <div class="mt-2 space-y-1">
          <%= for {_id, %{metas: [meta | _]}} <- @presence_list do %>
            <div class="text-xs">
              <%= if Map.get(meta, :name) do %>
                <%= meta.name %>
                <%= if Map.get(meta, :anonymous, true) do %>
                  <span class="text-gray-400">(anonymous)</span>
                <% end %>
              <% else %>
                <span class="text-gray-400">Anonymous Reader</span>
              <% end %>
              <%= if Map.get(meta, :slug) do %>
                <span class="text-gray-400 text-xs">
                  (reading: <%= meta.slug %>)
                </span>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>

      <%= if @show_name_form do %>
        <form phx-submit="save-name" class="mt-4">
          <input type="text"
                 name="name"
                 value={@name}
                 placeholder="Enter your name"
                 class="text-sm rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                 autocomplete="off"
          />
          <button type="submit" class="ml-2 px-3 py-1 text-xs bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
            Save
          </button>
        </form>
      <% end %>
    </div>
    """
  end
end
