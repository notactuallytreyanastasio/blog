defmodule BlogWeb.MtaBusLive do
  use BlogWeb, :live_view
  alias Blog.Mta.Client

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      status: "Ready to fetch bus data",
      routes: %{},
      error: nil
    )}
  end

  @impl true
  def handle_event("fetch_buses", _params, socket) do
    case Client.fetch_buses() do
      {:ok, routes} ->
        total_buses = routes
          |> Map.values()
          |> Enum.map(&length/1)
          |> Enum.sum()

        {:noreply, assign(socket,
          status: "Found #{total_buses} buses across #{map_size(routes)} routes",
          routes: routes,
          error: nil
        )}
      {:error, error} ->
        {:noreply, assign(socket,
          status: "Error fetching buses",
          error: error,
          routes: %{}
        )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">MTA Bus Tracker</h1>

      <div class="bg-white shadow rounded-lg p-4">
        <div class="mb-4">
          <p class="text-gray-600">Status: <%= @status %></p>
          <%= if @error do %>
            <p class="text-red-500"><%= @error %></p>
          <% end %>
        </div>

        <button
          phx-click="fetch_buses"
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Fetch All Buses
        </button>

        <%= if map_size(@routes) > 0 do %>
          <div class="mt-4 space-y-6">
            <%= for {route_name, buses} <- @routes do %>
              <div class="border rounded-lg p-4">
                <h2 class="text-xl font-semibold mb-2">Route <%= route_name %></h2>
                <%= if length(buses) > 0 do %>
                  <div class="space-y-2">
                    <%= for bus <- buses do %>
                      <div class="border p-2 rounded bg-gray-50">
                        <p class="font-semibold">Bus ID: <%= bus.id %></p>
                        <p>Location: <%= bus.location.latitude %>, <%= bus.location.longitude %></p>
                        <p>Direction: <%= bus.direction %></p>
                        <p>Destination: <%= bus.destination %></p>
                        <p>Speed: <%= bus.speed %> mph</p>
                        <p class="text-sm text-gray-500">Last Updated: <%= bus.recorded_at %></p>
                      </div>
                    <% end %>
                  </div>
                <% else %>
                  <p class="text-gray-500">No buses currently active on this route</p>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
