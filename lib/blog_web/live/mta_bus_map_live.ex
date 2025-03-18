defmodule BlogWeb.MtaBusMapLive do
  use BlogWeb, :live_view
  alias Blog.Mta.Client
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Mounting MtaBusMapLive")
    if connected?(socket) do
      :timer.send_interval(10000, self(), :update_buses)
    end

    {:ok, assign(socket,
      buses: [],
      error: nil,
      map_id: "mta-bus-map"
    )}
  end

  @impl true
  def handle_info(:update_buses, socket) do
    Logger.info("Handling update_buses info")
    case Client.fetch_route("MTA NYCT_M21") do
      {:ok, buses} ->
        Logger.info("Received #{length(buses)} buses")
        {:noreply,
          socket
          |> assign(buses: buses)
          |> push_event("update_buses", %{buses: buses})}
      {:error, error} ->
        Logger.error("Error fetching buses: #{inspect(error)}")
        {:noreply, assign(socket, error: error)}
    end
  end

  @impl true
  def handle_event("fetch_buses", _params, socket) do
    Logger.info("Handling fetch_buses event")
    case Client.fetch_route("MTA NYCT_M21") do
      {:ok, buses} ->
        Logger.info("Received #{length(buses)} buses")
        {:noreply,
          socket
          |> assign(buses: buses)
          |> push_event("update_buses", %{buses: buses})}
      {:error, error} ->
        Logger.error("Error fetching buses: #{inspect(error)}")
        {:noreply, assign(socket, error: error)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col">
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/KFQW0q+MJTEXx+bCw=" crossorigin="" />
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

      <div class="p-4 bg-white">
        <h1 class="text-2xl font-bold mb-4">M21 Bus Tracker</h1>

        <div class="bg-white shadow rounded-lg p-4">
          <div class="mb-4">
            <%= if @error do %>
              <p class="text-red-500"><%= @error %></p>
            <% end %>
            <%= if length(@buses) > 0 do %>
              <p class="text-green-500">Found <%= length(@buses) %> buses</p>
            <% end %>
          </div>

          <button
            phx-click="fetch_buses"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mb-4"
          >
            Update Bus Locations
          </button>
        </div>
      </div>

      <div class="flex-1 relative" style="min-height: 500px;">
        <div id={@map_id} class="absolute inset-0 z-0" phx-update="ignore"></div>
      </div>

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

      function initMap() {
        console.log("Initializing map...");
        const mapElement = document.getElementById('<%= @map_id %>');
        if (!mapElement) {
          console.error("Map element not found!");
          return;
        }

        try {
          // Initialize map centered on Lower East Side
          map = L.map('<%= @map_id %>').setView([40.7185, -73.9835], 16);
          console.log("Map created successfully");

          L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
            subdomains: 'abcd',
            maxZoom: 19
          }).addTo(map);

          // Set bounds for Lower East Side
          const bounds = L.latLngBounds(
            [40.7250, -73.9950], // North West (around East Houston & Bowery)
            [40.7120, -73.9720]  // South East (around Grand & East Broadway)
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

      function updateMarkers(buses) {
        console.log("Updating markers with buses:", buses);
        if (!map) {
          console.error("Map not initialized!");
          return;
        }

        // Clear existing markers
        markers.forEach(marker => marker.remove());
        markers = [];

        if (!buses || buses.length === 0) {
          console.log("No buses to display");
          return;
        }

        // Add new markers
        buses.forEach(bus => {
          console.log("Adding marker for bus:", bus);
          const lat = parseFloat(bus.location.latitude);
          const lng = parseFloat(bus.location.longitude);

          console.log(`Creating marker at coordinates: ${lat}, ${lng}`);

          if (isNaN(lat) || isNaN(lng)) {
            console.error("Invalid coordinates:", bus.location);
            return;
          }

          const marker = L.marker([lat, lng], {
            icon: L.divIcon({
              className: 'custom-div-icon',
              html: `<div style="
                display: flex;
                align-items: center;
                gap: 4px;
              ">
                <div style="
                  background-color: #4CAF50;
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
                  color: #4CAF50;
                ">M21</div>
              </div>`,
              iconSize: [48, 20],
              iconAnchor: [6, 6]
            })
          })
          .bindPopup(`
            <div class="p-2">
              <strong>M21 Bus ${bus.id}</strong><br>
              Speed: ${bus.speed || 'N/A'} mph<br>
              Destination: ${bus.destination.join(', ')}<br>
              Direction: ${bus.direction === '1' ? 'Northbound' : 'Southbound'}<br>
              Location: ${lat.toFixed(6)}, ${lng.toFixed(6)}
            </div>
          `)
          .addTo(map);

          markers.push(marker);
          console.log("Marker added successfully");
        });
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
        updateMarkers(event.detail.buses);
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
