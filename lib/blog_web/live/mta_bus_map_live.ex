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
    # North-South Routes
    "M1" => "MTA NYCT_M1",
    "M2" => "MTA NYCT_M2",
    "M3" => "MTA NYCT_M3",
    "M4" => "MTA NYCT_M4",
    "M15" => "MTA NYCT_M15",
    "M15-SBS" => "MTA NYCT_M15+",
    "M20" => "MTA NYCT_M20",
    "M101" => "MTA NYCT_M101",
    "M102" => "MTA NYCT_M102",
    "M103" => "MTA NYCT_M103",
    # Lower Manhattan
    "M9" => "MTA NYCT_M9",
    "M20" => "MTA NYCT_M20",
    "M42" => "MTA NYCT_M42",
    "M50" => "MTA NYCT_M50",
    "M57" => "MTA NYCT_M57",
    "M66" => "MTA NYCT_M66",
    "M72" => "MTA NYCT_M72",
    "M79-SBS" => "MTA NYCT_M79+",
    "M86-SBS" => "MTA NYCT_M86+"
  }

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Mounting MtaBusMapLive")
    if connected?(socket) do
      :timer.send_interval(15000, self(), :update_buses)
    end

    # Start with M21 selected by default
    initial_selected = MapSet.new(["M21"])

    {:ok, assign(socket,
      buses: %{},
      error: nil,
      map_id: "mta-bus-map",
      selected_routes: initial_selected,
      all_bus_routes: @all_bus_routes,
      show_modal: false
    )}
  end

  @impl true
  def handle_info(:update_buses, socket) do
    Logger.info("Handling update_buses info")

    # Only fetch selected routes
    selected_routes = socket.assigns.selected_routes
    routes_to_fetch = Map.filter(socket.assigns.all_bus_routes, fn {route, _} -> MapSet.member?(selected_routes, route) end)

    results = Enum.map(routes_to_fetch, fn {route_name, line_ref} ->
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
    new_selected = if MapSet.member?(selected_routes, route) do
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
  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col">
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/KFQW0q+MJTEXx+bCw=" crossorigin="" />
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

      <div class="p-4 bg-white">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-2xl font-bold">Manhattan Bus Tracker</h1>
          <div class="flex gap-2">
            <button
              phx-click="toggle_modal"
              class="bg-purple-500 hover:bg-purple-700 text-white font-bold py-2 px-4 rounded"
            >
              CHOOSE BUSES
            </button>
            <button
              phx-click="fetch_buses"
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            >
              Update Bus Locations
            </button>
          </div>
        </div>

        <%= if @error do %>
          <p class="text-red-500 mb-4"><%= @error %></p>
        <% end %>

        <%= if map_size(@buses) > 0 do %>
          <div class="bg-white shadow rounded-lg p-4 mb-4">
            <div class="text-green-500 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
              <%= for {route, buses} <- @buses do %>
                <div><%= route %>: <%= length(buses) %> buses</div>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>

      <div class="flex-1 relative" style="min-height: 500px;">
        <div id={@map_id} class="absolute inset-0 z-0" phx-update="ignore"></div>
      </div>

      <%= if @show_modal do %>
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity z-50">
          <div class="fixed inset-0 z-50 overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
              <div class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-3xl">
                <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
                  <div class="absolute top-0 right-0 pt-4 pr-4">
                    <button
                      phx-click="toggle_modal"
                      class="rounded-md bg-white text-gray-400 hover:text-gray-500"
                    >
                      <span class="sr-only">Close</span>
                      <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                  <div class="sm:flex sm:items-start">
                    <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left w-full">
                      <h3 class="text-xl font-semibold leading-6 text-gray-900 mb-4">Select Bus Routes</h3>
                      <div class="mt-2">
                        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                          <div class="col-span-full mb-2 font-bold text-lg">Crosstown Routes</div>
                          <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} -> String.contains?(k, ["M14", "M21", "M22", "M23"]) end) do %>
                            <label class="flex items-center space-x-2">
                              <input
                                type="checkbox"
                                checked={MapSet.member?(@selected_routes, route)}
                                phx-click="toggle_route"
                                phx-value-route={route}
                                class="form-checkbox h-4 w-4 text-blue-600"
                              />
                              <span><%= route %></span>
                            </label>
                          <% end %>

                          <div class="col-span-full mb-2 font-bold text-lg">North-South Routes</div>
                          <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} -> String.match?(k, ~r/^M([1-9]|15|101|102|103)/) end) do %>
                            <label class="flex items-center space-x-2">
                              <input
                                type="checkbox"
                                checked={MapSet.member?(@selected_routes, route)}
                                phx-click="toggle_route"
                                phx-value-route={route}
                                class="form-checkbox h-4 w-4 text-blue-600"
                              />
                              <span><%= route %></span>
                            </label>
                          <% end %>

                          <div class="col-span-full mb-2 font-bold text-lg">Other Manhattan Routes</div>
                          <%= for {route, _} <- Enum.filter(assigns.all_bus_routes, fn {k, _} -> String.match?(k, ~r/M(20|42|50|57|66|72|79|86)/) end) do %>
                            <label class="flex items-center space-x-2">
                              <input
                                type="checkbox"
                                checked={MapSet.member?(@selected_routes, route)}
                                phx-click="toggle_route"
                                phx-value-route={route}
                                class="form-checkbox h-4 w-4 text-blue-600"
                              />
                              <span><%= route %></span>
                            </label>
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                  <button
                    type="button"
                    phx-click="toggle_modal"
                    class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
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
        }
      </style>
    </div>

    <script>
      let map;
      let markers = [];

      const ROUTE_COLORS = {
        // Crosstown Routes
        'M14A-SBS': '#E31837',  // Red
        'M14D-SBS': '#FF6B00',  // Orange
        'M21': '#4CAF50',       // Green
        'M22': '#2196F3',       // Blue
        'M23-SBS': '#9C27B0',   // Purple
        // North-South Routes
        'M1': '#FF1744',        // Red A700
        'M2': '#F50057',        // Pink A400
        'M3': '#D500F9',        // Purple A400
        'M4': '#651FFF',        // Deep Purple A400
        'M15': '#3D5AFE',       // Indigo A400
        'M15-SBS': '#2979FF',   // Blue A400
        'M20': '#00B0FF',       // Light Blue A400
        'M101': '#00E5FF',      // Cyan A400
        'M102': '#1DE9B6',      // Teal A400
        'M103': '#00E676',      // Green A400
        // Other Manhattan Routes
        'M9': '#76FF03',        // Light Green A400
        'M42': '#C6FF00',       // Lime A400
        'M50': '#FFEA00',       // Yellow A400
        'M57': '#FFC400',       // Amber A400
        'M66': '#FF9100',       // Orange A400
        'M72': '#FF3D00',       // Deep Orange A400
        'M79-SBS': '#795548',   // Brown
        'M86-SBS': '#607D8B'    // Blue Grey
      };

      function initMap() {
        console.log("Initializing map...");
        const mapElement = document.getElementById('<%= @map_id %>');
        if (!mapElement) {
          console.error("Map element not found!");
          return;
        }

        try {
          // Initialize map centered on Lower East Side
          map = L.map('<%= @map_id %>').setView([40.7185, -73.9835], 14);
          console.log("Map created successfully");

          L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
            subdomains: 'abcd',
            maxZoom: 19
          }).addTo(map);

          // Set bounds for Lower Manhattan (expanded)
          const bounds = L.latLngBounds(
            [40.7800, -74.0200], // North West (above 14th St)
            [40.6900, -73.9600]  // South East (below Chinatown)
          );
          map.setMaxBounds(bounds);

          // Force a resize after a short delay to ensure proper rendering
          setTimeout(() => {
            console.log("Invalidating map size...");
            map.invalidateSize();
          }, 100);
        } catch (error) {
          console.error("Error initializing map:", error);
        }
      }

      // Global marker storage
      const markersByBusId = new Map();

      function updateMarkers(busData) {
        console.log("Updating markers with buses:", busData);
        if (!map) {
          console.error("Map not initialized!");
          return;
        }

        if (!busData || !busData.buses) {
          console.log("No buses to display");
          return;
        }

        // Track which buses are still active
        const activeBusIds = new Set();

        // Update or create markers for each bus
        busData.buses.forEach((routeData) => {
          const route = routeData.route;
          const buses = routeData.buses;
          const color = ROUTE_COLORS[route] || '#000000';

          buses.forEach(bus => {
            const busId = `${route}-${bus.id}`;
            activeBusIds.add(busId);

            const lat = parseFloat(bus.location.latitude);
            const lng = parseFloat(bus.location.longitude);

            if (isNaN(lat) || isNaN(lng)) {
              console.error("Invalid coordinates for bus:", bus);
              return;
            }

            let marker = markersByBusId.get(busId);
            if (marker) {
              // Update existing marker position
              marker.setLatLng([lat, lng]);
              if (!marker._map) {
                marker.addTo(map);
              }
            } else {
              // Create new marker
              marker = L.marker([lat, lng], {
                icon: L.divIcon({
                  className: 'custom-div-icon',
                  html: `<div style="
                    display: flex;
                    align-items: center;
                    gap: 4px;
                    pointer-events: none;
                  ">
                    <div style="
                      background-color: ${color};
                      width: 12px;
                      height: 12px;
                      border-radius: 50%;
                      border: 2px solid white;
                      box-shadow: 0 0 4px rgba(0,0,0,0.5);
                    "></div>
                    <div style="
                      background-color: white;
                      padding: 2px 4px;
                      border-radius: 4px;
                      font-size: 12px;
                      font-weight: bold;
                      box-shadow: 0 0 4px rgba(0,0,0,0.2);
                      color: ${color};
                    ">${route}</div>
                  </div>`,
                  iconSize: [48, 20],
                  iconAnchor: [6, 6]
                })
              })
              .bindPopup(`
                <div class="p-2">
                  <strong>${route} Bus ${bus.id}</strong><br>
                  Speed: ${bus.speed || 'N/A'} mph<br>
                  Destination: ${bus.destination ? bus.destination.join(', ') : 'N/A'}<br>
                  Direction: ${bus.direction === '1' ? 'Northbound' : 'Southbound'}<br>
                  Location: ${lat.toFixed(6)}, ${lng.toFixed(6)}
                </div>
              `)
              .addTo(map);

              markersByBusId.set(busId, marker);
            }
          });
        });

        // Hide markers for buses that are no longer active
        markersByBusId.forEach((marker, busId) => {
          if (!activeBusIds.has(busId)) {
            marker.remove();
          }
        });

        console.log(`Total active buses: ${activeBusIds.size}`);
      }

      // Initialize map when the page loads
      window.addEventListener("load", () => {
        console.log("Page loaded, initializing map...");
        initMap();
      });

      // Listen for bus updates from LiveView
      window.addEventListener("phx:update_buses", (event) => {
        console.log("Received bus update event:", event);
        console.log("Bus data:", event.detail);
        updateMarkers(event.detail);
      });

      // Handle sidebar toggle
      const sidebarToggle = document.getElementById('sidebar-toggle');
      if (sidebarToggle) {
        sidebarToggle.addEventListener('click', () => {
          setTimeout(() => {
            console.log("Sidebar toggled, invalidating map size...");
            map.invalidateSize();
          }, 300);
        });
      }

      // Initialize map immediately if the page is already loaded
      if (document.readyState === 'complete') {
        console.log("Page already loaded, initializing map immediately...");
        initMap();
      }
    </script>
    """
  end
end
