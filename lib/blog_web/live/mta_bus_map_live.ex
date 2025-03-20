defmodule BlogWeb.MtaBusMapLive do
  use BlogWeb, :live_view
  alias Blog.Mta.Client
  require Logger

  @all_bus_routes %{
    # Crosstown Routes
    "M14A-SBS" => "MTA NYCT_M14A+",
    "M14D-SBS" => "MTA NYCT_M14D+",
    "M21" => "MTA NYCT_M21",
    "M22" => "MTA NYCT_M22",
    "M23-SBS" => "MTA NYCT_M23+",
    "M34-SBS" => "MTA NYCT_M34+",
    "M34A-SBS" => "MTA NYCT_M34A+",
    "M42" => "MTA NYCT_M42",
    "M50" => "MTA NYCT_M50",
    "M66" => "MTA NYCT_M66",
    "M72" => "MTA NYCT_M72",
    "M79-SBS" => "MTA NYCT_M79+",
    "M86-SBS" => "MTA NYCT_M86+",
    "M96" => "MTA NYCT_M96",
    "M106" => "MTA NYCT_M106",
    "M116" => "MTA NYCT_M116",
    # North-South Routes
    "M1" => "MTA NYCT_M1",
    "M2" => "MTA NYCT_M2",
    "M3" => "MTA NYCT_M3",
    "M4" => "MTA NYCT_M4",
    "M5" => "MTA NYCT_M5",
    "M7" => "MTA NYCT_M7",
    "M8" => "MTA NYCT_M8",
    "M9" => "MTA NYCT_M9",
    "M10" => "MTA NYCT_M10",
    "M11" => "MTA NYCT_M11",
    "M12" => "MTA NYCT_M12",
    "M15" => "MTA NYCT_M15",
    "M15-SBS" => "MTA NYCT_M15+",
    "M20" => "MTA NYCT_M20",
    "M31" => "MTA NYCT_M31",
    "M35" => "MTA NYCT_M35",
    "M55" => "MTA NYCT_M55",
    "M57" => "MTA NYCT_M57",
    "M60-SBS" => "MTA NYCT_M60+",
    "M98" => "MTA NYCT_M98",
    "M100" => "MTA NYCT_M100",
    "M101" => "MTA NYCT_M101",
    "M102" => "MTA NYCT_M102",
    "M103" => "MTA NYCT_M103",
    "M104" => "MTA NYCT_M104",
    # Limited & Express Routes
    "M15-LTD" => "MTA NYCT_M15L",
    "M101-LTD" => "MTA NYCT_M101L",
    "M102-LTD" => "MTA NYCT_M102L",
    "M103-LTD" => "MTA NYCT_M103L",
    "M1-LTD" => "MTA NYCT_M1L",
    "M2-LTD" => "MTA NYCT_M2L",
    "M3-LTD" => "MTA NYCT_M3L",
    "M4-LTD" => "MTA NYCT_M4L",
    "M5-LTD" => "MTA NYCT_M5L"
  }

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Mounting MtaBusMapLive")

    if connected?(socket) do
      :timer.send_interval(30000, self(), :update_buses)
    end

    # Start with M21 selected by default
    initial_selected = MapSet.new(["M21"])

    {:ok,
     assign(socket,
       buses: %{},
       error: nil,
       map_id: "mta-bus-map",
       selected_routes: initial_selected,
       all_bus_routes: @all_bus_routes,
       show_modal: false,
       page_title: "Manhattan MTA Bus Tracker"
     )}
  end

  @impl true
  def handle_info(:update_buses, socket) do
    Logger.info("Handling update_buses info")

    # Only fetch selected routes
    selected_routes = socket.assigns.selected_routes

    routes_to_fetch =
      Map.filter(socket.assigns.all_bus_routes, fn {route, _} ->
        MapSet.member?(selected_routes, route)
      end)

    results =
      Enum.map(routes_to_fetch, fn {route_name, line_ref} ->
        case Client.fetch_route(line_ref) do
          {:ok, buses} ->
            Logger.info("Received #{length(buses)} buses for #{route_name}")
            %{route: route_name, buses: buses}

          {:error, error} ->
            Logger.error("Error fetching #{route_name}: #{inspect(error)}")
            %{route: route_name, buses: []}
        end
      end)

    {:noreply,
     socket
     |> assign(buses: Map.new(results, fn %{route: route, buses: buses} -> {route, buses} end))
     |> push_event("update_buses", %{buses: results})}
  end

  @impl true
  def handle_event("fetch_buses", _params, socket) do
    handle_info(:update_buses, socket)
  end

  @impl true
  def handle_event("toggle_route", %{"route" => route}, socket) do
    selected_routes = socket.assigns.selected_routes

    new_selected =
      if MapSet.member?(selected_routes, route) do
        MapSet.delete(selected_routes, route)
      else
        MapSet.put(selected_routes, route)
      end

    {:noreply,
     socket
     |> assign(selected_routes: new_selected)
     |> then(fn socket -> handle_info(:update_buses, socket) |> elem(1) end)}
  end

  @impl true
  def handle_event("toggle_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  @impl true
  def handle_event("select_all_routes", _params, socket) do
    all_routes = Map.keys(socket.assigns.all_bus_routes) |> MapSet.new()
    {:noreply,
     socket
     |> assign(selected_routes: all_routes)
     |> then(fn socket -> handle_info(:update_buses, socket) |> elem(1) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col">
      <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/KFQW0q+MJTEXx+bCw="
        crossorigin=""
      />
      <script
        src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
        crossorigin=""
      >
      </script>

      <div class="p-2 sm:p-4 bg-white">
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 mb-2">
          <h1 class="text-xl sm:text-2xl font-bold">Manhattan MTA Bus Tracker</h1>
          <div class="flex gap-2">
            <button
              phx-click="toggle_modal"
              class="bg-purple-500 hover:bg-purple-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base"
            >
              CHOOSE BUSES
            </button>
            <button
              phx-click="fetch_buses"
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base"
            >
              Update
            </button>
          </div>
        </div>

        <%= if @error do %>
          <p class="text-red-500 text-sm mb-2">{@error}</p>
        <% end %>

        <div class="flex-1 relative" style="min-height: calc(100vh - 130px);">
          <div id={@map_id} class="absolute inset-0 z-0" phx-hook="MtaBusMap" phx-update="ignore"></div>
        </div>

        <%= if @show_modal do %>
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity z-50">
            <div class="fixed inset-0 z-50 overflow-y-auto">
              <div class="flex min-h-full items-end justify-center p-2 sm:p-4 text-center sm:items-center sm:p-0">
                <div class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-3xl w-full">
                  <div class="bg-white px-2 sm:px-4 pb-2 sm:pb-4 pt-3 sm:pt-5">
                    <div class="absolute top-0 right-0 pt-2 sm:pt-4 pr-2 sm:pr-4">
                      <button
                        phx-click="toggle_modal"
                        class="rounded-md bg-white text-gray-400 hover:text-gray-500"
                      >
                        <span class="sr-only">Close</span>
                        <svg
                          class="h-5 w-5 sm:h-6 sm:w-6"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    </div>
                    <div class="sm:flex sm:items-start">
                      <div class="mt-2 sm:mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left w-full">
                        <div class="flex justify-between items-center mb-2 sm:mb-4">
                          <h3 class="text-lg sm:text-xl font-semibold leading-6 text-gray-900">
                            Select Bus Routes
                          </h3>
                          <button
                            phx-click="select_all_routes"
                            class="bg-green-500 hover:bg-green-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base"
                          >
                            Select All
                          </button>
                        </div>
                        <div class="mt-2">
                          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 sm:gap-4">
                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Crosstown Routes</div>
                            <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} ->
                              String.contains?(k, ["M14", "M21", "M22", "M23", "M34", "M42", "M50", "M66", "M72", "M79", "M86", "M96", "M106", "M116"])
                            end) do %>
                              <label class="flex items-center space-x-1 sm:space-x-2 text-sm sm:text-base">
                                <input
                                  type="checkbox"
                                  checked={MapSet.member?(@selected_routes, route)}
                                  phx-click="toggle_route"
                                  phx-value-route={route}
                                  class="form-checkbox h-3 w-3 sm:h-4 sm:w-4 text-blue-600"
                                />
                                <span>{route}</span>
                              </label>
                            <% end %>

                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">North-South Routes</div>
                            <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} ->
                              String.match?(k, ~r/^M([1-9]|1[0-5]|98|100|101|102|103|104|60-SBS)$/)
                            end) do %>
                              <label class="flex items-center space-x-1 sm:space-x-2 text-sm sm:text-base">
                                <input
                                  type="checkbox"
                                  checked={MapSet.member?(@selected_routes, route)}
                                  phx-click="toggle_route"
                                  phx-value-route={route}
                                  class="form-checkbox h-3 w-3 sm:h-4 sm:w-4 text-blue-600"
                                />
                                <span>{route}</span>
                              </label>
                            <% end %>

                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Limited & Express Routes</div>
                            <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} ->
                              String.contains?(k, "-LTD")
                            end) do %>
                              <label class="flex items-center space-x-1 sm:space-x-2 text-sm sm:text-base">
                                <input
                                  type="checkbox"
                                  checked={MapSet.member?(@selected_routes, route)}
                                  phx-click="toggle_route"
                                  phx-value-route={route}
                                  class="form-checkbox h-3 w-3 sm:h-4 sm:w-4 text-blue-600"
                                />
                                <span>{route}</span>
                              </label>
                            <% end %>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="bg-gray-50 px-2 sm:px-4 py-2 sm:py-3 sm:flex sm:flex-row-reverse sm:px-6">
                    <button
                      type="button"
                      phx-click="toggle_modal"
                      class="mt-2 sm:mt-3 inline-flex w-full justify-center rounded-md bg-white px-2 sm:px-3 py-1.5 sm:py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
                    >
                      Close
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% end %>

        <style>
          .leaflet-container {
            width: 100%;
            height: 100%;
            z-index: 1;
          }
        </style>
      </div>
    </div>
    """
  end
end
