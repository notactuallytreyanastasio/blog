defmodule BlogWeb.GridLive do
  use BlogWeb, :live_view
  require Logger
  import Bitwise

  @grid_size 100
  @total_cells @grid_size * @grid_size
  @topic "grid_state"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)
    end

    # Get or create grid state from ETS
    grid_state = get_or_create_grid_state()

    {:ok, assign(socket,
      grid_state: grid_state,
      grid_size: @grid_size
    )}
  end

  def handle_event("toggle", %{"index" => index}, socket) do
    index = String.to_integer(index)
    new_state = toggle_bit(socket.assigns.grid_state, index)
    :ets.insert(:grid_state, {:state, new_state})

    # Broadcast the change
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:grid_update, new_state})

    {:noreply, assign(socket, grid_state: new_state)}
  end

  def handle_info({:grid_update, new_state}, socket) do
    {:noreply, assign(socket, grid_state: new_state)}
  end

  defp get_or_create_grid_state do
    try do
      :ets.new(:grid_state, [:set, :public, :named_table])
      initial_state = :binary.copy(<<0>>, div(@total_cells, 8) + 1)
      :ets.insert(:grid_state, {:state, initial_state})
      initial_state
    rescue
      ArgumentError ->
        # Table exists, get current state
        [{:state, state}] = :ets.lookup(:grid_state, :state)
        state
    end
  end

  defp toggle_bit(binary, index) do
    byte_index = div(index, 8)
    bit_index = rem(index, 8)

    <<prefix::binary-size(byte_index),
      byte::integer,
      rest::binary>> = binary

    new_byte = bxor(byte, 1 <<< bit_index)

    <<prefix::binary, new_byte::integer, rest::binary>>
  end

  defp bit_set?(binary, index) do
    byte_index = div(index, 8)
    bit_index = rem(index, 8)

    <<_prefix::binary-size(byte_index),
      byte::integer,
      _rest::binary>> = binary

    (byte &&& (1 <<< bit_index)) != 0
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h1 class="text-2xl font-bold mb-4">Shared Grid</h1>
      <div class="grid" style="grid-template-columns: repeat(100, 20px); gap: 1px; background-color: #eee; padding: 1px; width: fit-content;">
        <%= for y <- 0..(@grid_size-1) do %>
          <%= for x <- 0..(@grid_size-1) do %>
            <% index = y * @grid_size + x %>
            <div class="bg-white">
              <input
                type="checkbox"
                class="w-5 h-5 m-0 cursor-pointer"
                checked={bit_set?(@grid_state, index)}
                phx-click="toggle"
                phx-value-index={index}
              />
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
