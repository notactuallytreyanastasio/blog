defmodule BlogWeb.MtaBusMapLive do
  use BlogWeb, :live_view
  alias Blog.Mta.Client
  require Logger
  import BlogWeb.MTAComponents

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

  # Queens bus routes
  @queens_bus_routes %{
    # Local routes
    "Q1" => "MTA NYCT_Q1",
    "Q2" => "MTA NYCT_Q2",
    "Q3" => "MTA NYCT_Q3",
    "Q4" => "MTA NYCT_Q4",
    "Q5" => "MTA NYCT_Q5",
    "Q6" => "MTA NYCT_Q6",
    "Q7" => "MTA NYCT_Q7",
    "Q8" => "MTA NYCT_Q8",
    "Q9" => "MTA NYCT_Q9",
    "Q10" => "MTA NYCT_Q10",
    "Q11" => "MTA NYCT_Q11",
    "Q12" => "MTA NYCT_Q12",
    "Q13" => "MTA NYCT_Q13",
    "Q15" => "MTA NYCT_Q15",
    "Q15A" => "MTA NYCT_Q15A",
    "Q16" => "MTA NYCT_Q16",
    "Q17" => "MTA NYCT_Q17",
    "Q18" => "MTA NYCT_Q18",
    "Q19" => "MTA NYCT_Q19",
    "Q20A" => "MTA NYCT_Q20A",
    "Q20B" => "MTA NYCT_Q20B",
    "Q21" => "MTA NYCT_Q21",
    "Q22" => "MTA NYCT_Q22",
    "Q23" => "MTA NYCT_Q23",
    "Q24" => "MTA NYCT_Q24",
    "Q25" => "MTA NYCT_Q25",
    "Q26" => "MTA NYCT_Q26",
    "Q27" => "MTA NYCT_Q27",
    "Q28" => "MTA NYCT_Q28",
    "Q29" => "MTA NYCT_Q29",
    "Q30" => "MTA NYCT_Q30",
    "Q31" => "MTA NYCT_Q31",
    "Q32" => "MTA NYCT_Q32",
    "Q33" => "MTA NYCT_Q33",
    "Q34" => "MTA NYCT_Q34",
    "Q35" => "MTA NYCT_Q35",
    "Q36" => "MTA NYCT_Q36",
    "Q37" => "MTA NYCT_Q37",
    "Q38" => "MTA NYCT_Q38",
    "Q39" => "MTA NYCT_Q39",
    "Q40" => "MTA NYCT_Q40",
    "Q41" => "MTA NYCT_Q41",
    "Q42" => "MTA NYCT_Q42",
    "Q43" => "MTA NYCT_Q43",
    "Q44" => "MTA NYCT_Q44",
    "Q46" => "MTA NYCT_Q46",
    "Q47" => "MTA NYCT_Q47",
    "Q48" => "MTA NYCT_Q48",
    "Q49" => "MTA NYCT_Q49",
    "Q50" => "MTA NYCT_Q50",
    "Q52" => "MTA NYCT_Q52",
    "Q53" => "MTA NYCT_Q53",
    "Q54" => "MTA NYCT_Q54",
    "Q55" => "MTA NYCT_Q55",
    "Q56" => "MTA NYCT_Q56",
    "Q58" => "MTA NYCT_Q58",
    "Q59" => "MTA NYCT_Q59",
    "Q60" => "MTA NYCT_Q60",
    "Q64" => "MTA NYCT_Q64",
    "Q65" => "MTA NYCT_Q65",
    "Q66" => "MTA NYCT_Q66",
    "Q67" => "MTA NYCT_Q67",
    "Q69" => "MTA NYCT_Q69",
    "Q70" => "MTA NYCT_Q70",
    "Q72" => "MTA NYCT_Q72",
    "Q76" => "MTA NYCT_Q76",
    "Q77" => "MTA NYCT_Q77",
    "Q83" => "MTA NYCT_Q83",
    "Q84" => "MTA NYCT_Q84",
    "Q85" => "MTA NYCT_Q85",
    "Q88" => "MTA NYCT_Q88",
    "Q100" => "MTA NYCT_Q100",
    "Q101" => "MTA NYCT_Q101",
    "Q102" => "MTA NYCT_Q102",
    "Q103" => "MTA NYCT_Q103",
    "Q104" => "MTA NYCT_Q104",
    "Q110" => "MTA NYCT_Q110",
    "Q111" => "MTA NYCT_Q111",
    "Q112" => "MTA NYCT_Q112",
    "Q113" => "MTA NYCT_Q113",
    # Select Bus Service (SBS)
    "Q44-SBS" => "MTA NYCT_Q44+",
    "Q52-SBS" => "MTA NYCT_Q52+",
    "Q53-SBS" => "MTA NYCT_Q53+",
    "Q70-SBS" => "MTA NYCT_Q70+"
  }

  # Bronx bus routes
  @bronx_bus_routes %{
    # Local routes
    "Bx1" => "MTABC_BX1",
    "Bx2" => "MTABC_BX2",
    "Bx3" => "MTABC_BX3",
    "Bx4" => "MTABC_BX4",
    "Bx4A" => "MTABC_BX4A",
    "Bx5" => "MTABC_BX5",
    "Bx6" => "MTABC_BX6",
    "Bx7" => "MTABC_BX7",
    "Bx8" => "MTABC_BX8",
    "Bx9" => "MTABC_BX9",
    "Bx10" => "MTABC_BX10",
    "Bx11" => "MTABC_BX11",
    "Bx12" => "MTABC_BX12",
    "Bx13" => "MTABC_BX13",
    "Bx15" => "MTABC_BX15",
    "Bx16" => "MTABC_BX16",
    "Bx17" => "MTABC_BX17",
    "Bx18" => "MTABC_BX18",
    "Bx19" => "MTABC_BX19",
    "Bx20" => "MTABC_BX20",
    "Bx21" => "MTABC_BX21",
    "Bx22" => "MTABC_BX22",
    "Bx23" => "MTABC_BX23",
    "Bx24" => "MTABC_BX24",
    "Bx26" => "MTABC_BX26",
    "Bx27" => "MTABC_BX27",
    "Bx28" => "MTABC_BX28",
    "Bx29" => "MTABC_BX29",
    "Bx30" => "MTABC_BX30",
    "Bx31" => "MTABC_BX31",
    "Bx32" => "MTABC_BX32",
    "Bx33" => "MTABC_BX33",
    "Bx34" => "MTABC_BX34",
    "Bx35" => "MTABC_BX35",
    "Bx36" => "MTABC_BX36",
    "Bx38" => "MTABC_BX38",
    "Bx39" => "MTABC_BX39",
    "Bx40" => "MTABC_BX40",
    "Bx41" => "MTABC_BX41",
    "Bx42" => "MTABC_BX42",
    "Bx46" => "MTABC_BX46",
    "Bx99" => "MTABC_BX99",
    # Select Bus Service (SBS)
    "Bx6-SBS" => "MTABC_BX6+",
    "Bx12-SBS" => "MTABC_BX12+",
    "Bx41-SBS" => "MTABC_BX41+"
  }

  # All routes (Manhattan, Brooklyn, Queens, and Bronx)
  @all_bus_routes Map.merge(Map.merge(Map.merge(@manhattan_bus_routes, @brooklyn_bus_routes), @queens_bus_routes), @bronx_bus_routes)

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
       queens_bus_routes: @queens_bus_routes,
       bronx_bus_routes: @bronx_bus_routes,
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

    borough_name =
      case borough_atom do
        :manhattan -> "Manhattan"
        :brooklyn -> "Brooklyn"
        :queens -> "Queens"
        :bronx -> "Bronx"
        :all -> "All Boroughs"
      end

    # Let's select a default route for the borough to show something immediately
    default_route = case borough_atom do
      :manhattan -> "M21"
      :brooklyn -> "B41"
      :queens -> "Q58"
      :bronx -> "Bx12"
      :all -> "M21"
    end

    updated_routes = MapSet.new([default_route])

    {:noreply,
     socket
     |> assign(active_borough: borough_atom)
     |> assign(page_title: "#{borough_name} MTA Bus Tracker")
     |> assign(selected_routes: updated_routes)
     |> then(fn socket -> handle_info(:update_buses, socket) |> elem(1) end)}
  end

  @impl true
  def handle_event("select_all_borough_routes", %{"borough" => borough}, socket) do
    borough_atom = String.to_existing_atom(borough)

    routes =
      case borough_atom do
        :manhattan -> @manhattan_bus_routes
        :brooklyn -> @brooklyn_bus_routes
        :queens -> @queens_bus_routes
        :bronx -> @bronx_bus_routes
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
              <% :queens -> %>Queens
              <% :bronx -> %>Bronx
              <% :all -> %>All Boroughs
            <% end %> MTA Bus Tracker
          </h1>

          <div class="flex flex-wrap gap-2">
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

        <!-- Borough Selection Buttons -->
        <div class="mb-4">
          <div class="text-sm text-gray-500 mb-1">Select Borough:</div>
          <div class="flex flex-wrap gap-1">
            <button
              phx-click="select_borough"
              phx-value-borough="all"
              class={"px-3 py-1.5 text-sm font-medium rounded #{if @active_borough == :all, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"} #{if @loading, do: "opacity-75 cursor-wait", else: ""}"}
              disabled={@loading}
            >
              <%= if @loading && @active_borough == :all do %>
                <span class="flex items-center">
                  <svg class="animate-spin h-3 w-3 mr-1 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  All Boroughs
                </span>
              <% else %>
                All Boroughs
              <% end %>
            </button>
            <button
              phx-click="select_borough"
              phx-value-borough="manhattan"
              class={"px-3 py-1.5 text-sm font-medium rounded #{if @active_borough == :manhattan, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"} #{if @loading, do: "opacity-75 cursor-wait", else: ""}"}
              disabled={@loading}
            >
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full bg-red-500 mr-1.5"></div>
                <%= if @loading && @active_borough == :manhattan do %>
                  <span class="flex items-center">
                    <svg class="animate-spin h-3 w-3 mr-1 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Manhattan
                  </span>
                <% else %>
                  Manhattan
                <% end %>
              </div>
            </button>
            <button
              phx-click="select_borough"
              phx-value-borough="brooklyn"
              class={"px-3 py-1.5 text-sm font-medium rounded #{if @active_borough == :brooklyn, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"} #{if @loading, do: "opacity-75 cursor-wait", else: ""}"}
              disabled={@loading}
            >
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full bg-purple-500 mr-1.5"></div>
                <%= if @loading && @active_borough == :brooklyn do %>
                  <span class="flex items-center">
                    <svg class="animate-spin h-3 w-3 mr-1 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Brooklyn
                  </span>
                <% else %>
                  Brooklyn
                <% end %>
              </div>
            </button>
            <button
              phx-click="select_borough"
              phx-value-borough="queens"
              class={"px-3 py-1.5 text-sm font-medium rounded #{if @active_borough == :queens, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"} #{if @loading, do: "opacity-75 cursor-wait", else: ""}"}
              disabled={@loading}
            >
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full bg-green-500 mr-1.5"></div>
                <%= if @loading && @active_borough == :queens do %>
                  <span class="flex items-center">
                    <svg class="animate-spin h-3 w-3 mr-1 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Queens
                  </span>
                <% else %>
                  Queens
                <% end %>
              </div>
            </button>
            <button
              phx-click="select_borough"
              phx-value-borough="bronx"
              class={"px-3 py-1.5 text-sm font-medium rounded #{if @active_borough == :bronx, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"} #{if @loading, do: "opacity-75 cursor-wait", else: ""}"}
              disabled={@loading}
            >
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full bg-yellow-500 mr-1.5"></div>
                <%= if @loading && @active_borough == :bronx do %>
                  <span class="flex items-center">
                    <svg class="animate-spin h-3 w-3 mr-1 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Bronx
                  </span>
                <% else %>
                  Bronx
                <% end %>
              </div>
            </button>
          </div>

          <div class="mt-2">
            <button
              phx-click="select_all_borough_routes"
              phx-value-borough={@active_borough}
              class="px-4 py-1.5 text-sm font-medium text-white bg-green-500 hover:bg-green-600 rounded transition-colors"
              disabled={@loading}
            >
              <%= if @loading do %>
                <span class="flex items-center">
                  <svg class="animate-spin h-3 w-3 mr-1" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Loading...
                </span>
              <% else %>
                Select All <%= case @active_borough do
                  :manhattan -> "Manhattan"
                  :brooklyn -> "Brooklyn"
                  :queens -> "Queens"
                  :bronx -> "Bronx"
                  :all -> "Boroughs"
                end %> Routes
              <% end %>
            </button>
          </div>
        </div>

        <%= if @error do %>
          <p class="text-red-500 text-sm mb-2"><%= @error %></p>
        <% end %>

        <div class="flex-1 relative" style="min-height: calc(100vh - 180px);">
          <div id={@map_id} class="absolute inset-0 z-0" phx-hook="MtaBusMap" phx-update="ignore"></div>
        </div>

        <.bus_route_selection_modal
          show={@show_modal}
          active_borough={@active_borough}
          selected_routes={@selected_routes}
          manhattan_bus_routes={@manhattan_bus_routes}
          brooklyn_bus_routes={@brooklyn_bus_routes}
          queens_bus_routes={@queens_bus_routes}
          bronx_bus_routes={@bronx_bus_routes}
        />

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
