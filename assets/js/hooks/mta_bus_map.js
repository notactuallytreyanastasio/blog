const MtaBusMap = {
  mounted() {
    // Global variables
    let map;
    const markersByBusId = new Map();
    const mapId = this.el.id;

    const ROUTE_COLORS = {
      // Crosstown Routes
      'M14A-SBS': '#E31837',    // Red
      'M14D-SBS': '#FF6B00',    // Orange
      'M21': '#4CAF50',         // Green
      'M22': '#2196F3',         // Blue
      'M23-SBS': '#9C27B0',     // Purple
      'M34-SBS': '#673AB7',     // Deep Purple
      'M34A-SBS': '#5E35B1',    // Deep Purple 600
      'M42': '#4527A0',         // Deep Purple 800
      'M50': '#311B92',         // Deep Purple 900
      'M66': '#1A237E',         // Indigo 900
      'M72': '#0D47A1',         // Blue 900
      'M79-SBS': '#01579B',     // Light Blue 900
      'M86-SBS': '#006064',     // Cyan 900
      'M96': '#004D40',         // Teal 900
      'M106': '#1B5E20',        // Green 900
      'M116': '#33691E',        // Light Green 900
      // North-South Routes
      'M1': '#FF1744',          // Red A400
      'M2': '#F50057',          // Pink A400
      'M3': '#D500F9',          // Purple A400
      'M4': '#651FFF',          // Deep Purple A400
      'M5': '#3D5AFE',          // Indigo A400
      'M7': '#2979FF',          // Blue A400
      'M8': '#00B0FF',          // Light Blue A400
      'M9': '#00E5FF',          // Cyan A400
      'M10': '#1DE9B6',         // Teal A400
      'M11': '#00E676',         // Green A400
      'M12': '#76FF03',         // Light Green A400
      'M15': '#FFEA00',         // Yellow A400
      'M15-SBS': '#FFC400',     // Amber A400
      'M20': '#FF9100',         // Orange A400
      'M31': '#FF3D00',         // Deep Orange A400
      'M35': '#795548',         // Brown
      'M55': '#607D8B',         // Blue Grey
      'M57': '#FF8A80',         // Red A100
      'M60-SBS': '#FF80AB',     // Pink A100
      'M98': '#EA80FC',         // Purple A100
      'M100': '#B388FF',        // Deep Purple A100
      'M101': '#8C9EFF',        // Indigo A100
      'M102': '#82B1FF',        // Blue A100
      'M103': '#80D8FF',        // Light Blue A100
      'M104': '#84FFFF',        // Cyan A100
      // Limited Routes
      'M15-LTD': '#A7FFEB',     // Teal A100
      'M101-LTD': '#B9F6CA',    // Green A100
      'M102-LTD': '#CCFF90',    // Light Green A100
      'M103-LTD': '#F4FF81',    // Lime A100
      'M1-LTD': '#FFE57F',      // Amber A100
      'M2-LTD': '#FFD180',      // Orange A100
      'M3-LTD': '#FF9E80',      // Deep Orange A100
      'M4-LTD': '#D7CCC8',      // Brown 100
      'M5-LTD': '#CFD8DC'       // Blue Grey 100
    };

    const initMap = () => {
      console.log("Initializing map...");
      const mapElement = document.getElementById(mapId);
      if (!mapElement) {
        console.error("Map element not found!");
        return;
      }

      if (map) {
        console.log("Map already initialized");
        return;
      }

      try {
        // Initialize map centered on Lower East Side
        map = L.map(mapId, {
          center: [40.7185, -73.9835],
          zoom: 14,
          zoomControl: true,
          scrollWheelZoom: true
        });

        console.log("Map created successfully");

        L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
          subdomains: 'abcd',
          maxZoom: 19
        }).addTo(map);

        // Add user location control
        const userLocationControl = L.Control.extend({
          options: {
            position: 'topleft'
          },
          onAdd: function(map) {
            const container = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
            const button = L.DomUtil.create('a', 'leaflet-control-zoom-in', container);
            button.innerHTML = '📍';
            button.title = 'Show my location';
            button.style.fontSize = '18px';

            L.DomEvent.on(button, 'click', function(e) {
              L.DomEvent.stopPropagation(e);
              L.DomEvent.preventDefault(e);
              map.locate({setView: true, maxZoom: 16});
            });

            return container;
          }
        });

        map.addControl(new userLocationControl());

        // Request user location immediately
        map.locate({setView: true, maxZoom: 16});

        // Handle location found
        map.on('locationfound', function(e) {
          if (!window.userMarker) {
            window.userMarker = L.marker(e.latlng, {
              icon: L.divIcon({
                className: 'custom-div-icon',
                html: `<div style="
                  display: flex;
                  align-items: center;
                  gap: 4px;
                  pointer-events: none;
                ">
                  <div style="
                    background-color: #FF4081;
                    width: 16px;
                    height: 16px;
                    border-radius: 50%;
                    border: 3px solid white;
                    box-shadow: 0 0 4px rgba(0,0,0,0.5);
                  "></div>
                  <div style="
                    background-color: white;
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-size: 12px;
                    font-weight: bold;
                    box-shadow: 0 0 4px rgba(0,0,0,0.2);
                    color: #FF4081;
                  ">You</div>
                </div>`,
                iconSize: [80, 20],
                iconAnchor: [8, 10]
              })
            }).addTo(map);
          } else {
            window.userMarker.setLatLng(e.latlng);
          }
        });

        // Handle location error
        map.on('locationerror', function(e) {
          console.error("Error getting location:", e.message);
          alert("Unable to get your location. Please check your browser's location settings.");
        });

        // Force a resize after a short delay to ensure proper rendering
        setTimeout(() => {
          console.log("Invalidating map size...");
          map.invalidateSize();
        }, 100);
      } catch (error) {
        console.error("Error initializing map:", error);
      }
    };

    const updateMarkers = (busData) => {
      if (!map) {
        console.error("Map not initialized, initializing now...");
        initMap();
        setTimeout(() => updateMarkers(busData), 100);
        return;
      }

      console.log("Updating markers with buses:", busData);

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
                  flex-direction: column;
                  align-items: flex-start;
                  gap: 2px;
                  pointer-events: none;
                ">
                  <div style="
                    display: flex;
                    align-items: center;
                    gap: 4px;
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
                  </div>
                  <div style="
                    background-color: white;
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-size: 10px;
                    line-height: 1;
                    box-shadow: 0 0 4px rgba(0,0,0,0.2);
                    color: ${color};
                    max-width: 120px;
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                  ">${bus.destination ? bus.destination[0] : 'N/A'}</div>
                  <div style="
                    background-color: white;
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-size: 10px;
                    line-height: 1;
                    box-shadow: 0 0 4px rgba(0,0,0,0.2);
                    color: ${color};
                    max-width: 120px;
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                  ">${bus.direction === '1' ? 'Northbound' : 'Southbound'}</div>
                </div>`,
                iconSize: [120, 50],
                iconAnchor: [6, 25]
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
    };

    // Initialize map when mounted
    initMap();

    // Listen for bus updates from LiveView
    this.handleEvent("update_buses", (busData) => {
      console.log("Received bus update event:", busData);
      updateMarkers(busData);
    });

    // Handle sidebar toggle if present
    const sidebarToggle = document.getElementById('sidebar-toggle');
    if (sidebarToggle) {
      sidebarToggle.addEventListener('click', () => {
        setTimeout(() => map?.invalidateSize(), 300);
      });
    }
  }
};

export default MtaBusMap;