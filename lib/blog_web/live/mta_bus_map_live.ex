defmodule BlogWeb.MtaBusMapLive do
  use BlogWeb, :live_view
  alias Blog.Mta.Client
  require Logger

  # Manhattan bus routes
  @manhattan_bus_routes %{
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

  # Brooklyn bus routes
  @brooklyn_bus_routes %{
    # Local routes
    "B1" => "MTA NYCT_B1",
    "B2" => "MTA NYCT_B2",
    "B3" => "MTA NYCT_B3",
    "B4" => "MTA NYCT_B4",
    "B6" => "MTA NYCT_B6",
    "B7" => "MTA NYCT_B7",
    "B8" => "MTA NYCT_B8",
    "B9" => "MTA NYCT_B9",
    "B11" => "MTA NYCT_B11",
    "B12" => "MTA NYCT_B12",
    "B13" => "MTA NYCT_B13",
    "B14" => "MTA NYCT_B14",
    "B15" => "MTA NYCT_B15",
    "B16" => "MTA NYCT_B16",
    "B17" => "MTA NYCT_B17",
    "B24" => "MTA NYCT_B24",
    "B25" => "MTA NYCT_B25",
    "B26" => "MTA NYCT_B26",
    "B31" => "MTA NYCT_B31",
    "B32" => "MTA NYCT_B32",
    "B35" => "MTA NYCT_B35",
    "B36" => "MTA NYCT_B36",
    "B37" => "MTA NYCT_B37",
    "B38" => "MTA NYCT_B38",
    "B39" => "MTA NYCT_B39",
    "B41" => "MTA NYCT_B41",
    "B43" => "MTA NYCT_B43",
    "B44" => "MTA NYCT_B44",
    "B45" => "MTA NYCT_B45",
    "B46" => "MTA NYCT_B46",
    "B47" => "MTA NYCT_B47",
    "B48" => "MTA NYCT_B48",
    "B49" => "MTA NYCT_B49",
    "B52" => "MTA NYCT_B52",
    "B54" => "MTA NYCT_B54",
    "B57" => "MTA NYCT_B57",
    "B60" => "MTA NYCT_B60",
    "B61" => "MTA NYCT_B61",
    "B62" => "MTA NYCT_B62",
    "B63" => "MTA NYCT_B63",
    "B64" => "MTA NYCT_B64",
    "B65" => "MTA NYCT_B65",
    "B67" => "MTA NYCT_B67",
    "B68" => "MTA NYCT_B68",
    "B69" => "MTA NYCT_B69",
    "B70" => "MTA NYCT_B70",
    "B74" => "MTA NYCT_B74",
    "B82" => "MTA NYCT_B82",
    "B83" => "MTA NYCT_B83",
    "B84" => "MTA NYCT_B84",
    "B100" => "MTA NYCT_B100",
    "B103" => "MTA NYCT_B103",
    # Select Bus Service (SBS)
    "B44-SBS" => "MTA NYCT_B44+",
    "B46-SBS" => "MTA NYCT_B46+",
    "B82-SBS" => "MTA NYCT_B82+"
  }

  # All routes (both Manhattan and Brooklyn)
  @all_bus_routes Map.merge(@manhattan_bus_routes, @brooklyn_bus_routes)

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
       manhattan_bus_routes: @manhattan_bus_routes,
       brooklyn_bus_routes: @brooklyn_bus_routes,
       active_borough: :manhattan,
       show_modal: false,
       loading: false,
       page_title: "MTA Bus Map Tracker"
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

    socket = assign(socket, loading: true)

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
     |> assign(buses: Map.new(results, fn %{route: route, buses: buses} -> {route, buses} end), loading: false)
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
  def handle_event("select_borough", %{"borough" => borough}, socket) do
    borough_atom = String.to_existing_atom(borough)

    routes =
      case borough_atom do
        :manhattan -> @manhattan_bus_routes
        :brooklyn -> @brooklyn_bus_routes
        :all -> @all_bus_routes
      end

    borough_name =
      case borough_atom do
        :manhattan -> "Manhattan"
        :brooklyn -> "Brooklyn"
        :all -> "All Boroughs"
      end

    {:noreply,
     socket
     |> assign(active_borough: borough_atom)
     |> assign(page_title: "#{borough_name} MTA Bus Tracker")}
  end

  @impl true
  def handle_event("select_all_borough_routes", %{"borough" => borough}, socket) do
    borough_atom = String.to_existing_atom(borough)

    routes =
      case borough_atom do
        :manhattan -> @manhattan_bus_routes
        :brooklyn -> @brooklyn_bus_routes
        :all -> @all_bus_routes
      end

    routes_keys = Map.keys(routes) |> MapSet.new()

    {:noreply,
     socket
     |> assign(selected_routes: routes_keys)
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
          <h1 class="text-xl sm:text-2xl font-bold">
            <%= case @active_borough do %>
              <% :manhattan -> %>Manhattan
              <% :brooklyn -> %>Brooklyn
              <% :all -> %>All Boroughs
            <% end %> MTA Bus Tracker
          </h1>

          <div class="flex flex-wrap gap-2">
            <!-- Borough Selection Buttons -->
            <div class="flex gap-1">
              <button
                phx-click="select_borough"
                phx-value-borough="manhattan"
                class={"rounded-l-md px-3 py-1.5 text-sm font-medium #{if @active_borough == :manhattan, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}"}
              >
                Manhattan
              </button>
              <button
                phx-click="select_borough"
                phx-value-borough="brooklyn"
                class={"px-3 py-1.5 text-sm font-medium #{if @active_borough == :brooklyn, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}"}
              >
                Brooklyn
              </button>
              <button
                phx-click="select_borough"
                phx-value-borough="all"
                class={"rounded-r-md px-3 py-1.5 text-sm font-medium #{if @active_borough == :all, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}"}
              >
                All
              </button>
            </div>

            <button
              phx-click="toggle_modal"
              class="bg-purple-500 hover:bg-purple-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base"
            >
              CHOOSE BUSES
            </button>
            <button
              phx-click="fetch_buses"
              class={"bg-blue-500 hover:bg-blue-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base flex items-center gap-1 #{if @loading, do: "opacity-75 cursor-not-allowed", else: ""}"}
              disabled={@loading}
            >
              <%= if @loading do %>
                <svg class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Loading...
              <% else %>
                Update
              <% end %>
            </button>
          </div>
        </div>

        <%= if @error do %>
          <p class="text-red-500 text-sm mb-2"><%= @error %></p>
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
                          <div class="flex gap-2">
                            <button
                              phx-click="select_all_borough_routes"
                              phx-value-borough={@active_borough}
                              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1.5 px-3 rounded text-xs sm:text-sm"
                            >
                              Select All <%= case @active_borough do %>
                                <% :manhattan -> %>Manhattan
                                <% :brooklyn -> %>Brooklyn
                                <% :all -> %>
                              <% end %>
                            </button>
                            <button
                              phx-click="select_all_routes"
                              class="bg-green-500 hover:bg-green-700 text-white font-bold py-1.5 px-3 rounded text-xs sm:text-sm"
                            >
                              Select All
                            </button>
                          </div>
                        </div>

                        <!-- Bus Route Selection Tabs -->
                        <div class="border-b border-gray-200 mb-4">
                          <nav class="-mb-px flex" aria-label="Borough tabs">
                            <button
                              phx-click="select_borough"
                              phx-value-borough="manhattan"
                              class={"w-1/3 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :manhattan, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                            >
                              Manhattan
                            </button>
                            <button
                              phx-click="select_borough"
                              phx-value-borough="brooklyn"
                              class={"w-1/3 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :brooklyn, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                            >
                              Brooklyn
                            </button>
                            <button
                              phx-click="select_borough"
                              phx-value-borough="all"
                              class={"w-1/3 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :all, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                            >
                              All Routes
                            </button>
                          </nav>
                        </div>

                        <div class="mt-2">
                          <%= if @active_borough == :manhattan || @active_borough == :all do %>
                            <div>
                              <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 sm:gap-4">
                                <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Manhattan Crosstown Routes</div>
                                <%= for {route, _} <- Enum.filter(@manhattan_bus_routes, fn {k, _} ->
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
                                    <span><%= route %></span>
                                  </label>
                                <% end %>

                                <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Manhattan North-South Routes</div>
                                <%= for {route, _} <- Enum.filter(@manhattan_bus_routes, fn {k, _} ->
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
                                    <span><%= route %></span>
                                  </label>
                                <% end %>

                                <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Manhattan Limited & Express</div>
                                <%= for {route, _} <- Enum.filter(@manhattan_bus_routes, fn {k, _} ->
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
                                    <span><%= route %></span>
                                  </label>
                                <% end %>
                              </div>
                            </div>
                          <% end %>

                          <%= if @active_borough == :brooklyn || @active_borough == :all do %>
                            <div>
                              <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 sm:gap-4">
                                <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Brooklyn Routes</div>
                                <%= for {route, _} <- Enum.filter(@brooklyn_bus_routes, fn {k, _} ->
                                  String.match?(k, ~r/^B\d+$/)
                                end) |> Enum.sort() do %>
                                  <label class="flex items-center space-x-1 sm:space-x-2 text-sm sm:text-base">
                                    <input
                                      type="checkbox"
                                      checked={MapSet.member?(@selected_routes, route)}
                                      phx-click="toggle_route"
                                      phx-value-route={route}
                                      class="form-checkbox h-3 w-3 sm:h-4 sm:w-4 text-blue-600"
                                    />
                                    <span><%= route %></span>
                                  </label>
                                <% end %>

                                <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Brooklyn SBS Routes</div>
                                <%= for {route, _} <- Enum.filter(@brooklyn_bus_routes, fn {k, _} ->
                                  String.contains?(k, "-SBS")
                                end) |> Enum.sort() do %>
                                  <label class="flex items-center space-x-1 sm:space-x-2 text-sm sm:text-base">
                                    <input
                                      type="checkbox"
                                      checked={MapSet.member?(@selected_routes, route)}
                                      phx-click="toggle_route"
                                      phx-value-route={route}
                                      class="form-checkbox h-3 w-3 sm:h-4 sm:w-4 text-blue-600"
                                    />
                                    <span><%= route %></span>
                                  </label>
                                <% end %>
                              </div>
                            </div>
                          <% end %>
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
