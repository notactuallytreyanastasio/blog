defmodule BlogWeb.MtaBusMapLive do
  @moduledoc """
  LiveView for real-time MTA bus tracking across Manhattan, Brooklyn, and Queens.

  Displays bus positions on a Leaflet map with borough filtering and route selection.
  Bus positions refresh every 30 seconds via the MTA Bus Time API.
  """

  use BlogWeb, :live_view

  alias Blog.Mta.Client
  alias Blog.Mta.Routes

  import BlogWeb.MTAComponents

  require Logger

  @refresh_interval_ms 30_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval_ms, self(), :update_buses)
      send(self(), :update_buses)
    end

    initial_selected = MapSet.new(["M14A-SBS", "M14D-SBS", "M21", "M34-SBS"])

    {:ok,
     assign(socket,
       buses: %{},
       error: nil,
       map_id: "mta-bus-map",
       selected_routes: initial_selected,
       active_borough: :manhattan,
       show_modal: false,
       loading: false,
       page_title: "MTA Bus Map Tracker"
     )}
  end

  @impl true
  def handle_info(:update_buses, socket) do
    routes_to_fetch =
      Routes.all()
      |> Routes.filter_selected(socket.assigns.selected_routes)

    results = fetch_all_routes(routes_to_fetch)

    {:noreply,
     socket
     |> assign(buses: Routes.build_bus_map(results), loading: false)
     |> push_event("update_buses", %{buses: results})}
  end

  @impl true
  def handle_event("fetch_buses", _params, socket) do
    send(self(), :update_buses)
    {:noreply, assign(socket, loading: true)}
  end

  @impl true
  def handle_event("toggle_route", %{"route" => route}, socket) do
    new_selected = Routes.toggle_route(socket.assigns.selected_routes, route)
    send(self(), :update_buses)

    {:noreply, assign(socket, selected_routes: new_selected, loading: true)}
  end

  @impl true
  def handle_event("toggle_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  @impl true
  def handle_event("select_all_routes", _params, socket) do
    all_routes = Routes.all() |> Map.keys() |> MapSet.new()
    send(self(), :update_buses)

    {:noreply, assign(socket, selected_routes: all_routes, loading: true)}
  end

  @impl true
  def handle_event("select_borough", %{"borough" => borough}, socket) do
    borough_atom = String.to_existing_atom(borough)

    {:noreply,
     assign(socket,
       active_borough: borough_atom,
       page_title: "#{Routes.borough_name(borough_atom)} MTA Bus Tracker"
     )}
  end

  @impl true
  def handle_event("select_all_borough_routes", %{"borough" => borough}, socket) do
    borough_atom = String.to_existing_atom(borough)
    routes_keys = borough_atom |> Routes.for_borough() |> Map.keys() |> MapSet.new()
    send(self(), :update_buses)

    {:noreply, assign(socket, selected_routes: routes_keys, loading: true)}
  end

  defp fetch_all_routes(routes_to_fetch) do
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
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-winxp">
      <div class="os-window os-window-winxp mta-bus-window">
        <div class="os-titlebar">
          <span class="os-titlebar-title">MTA Bus Map - Live Transit Tracker</span>
          <div class="os-titlebar-buttons">
            <div class="os-btn-min"></div>
            <div class="os-btn-max"></div>
            <a href="/" class="os-btn-close"></a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>View</span>
          <span>Routes</span>
          <span>Help</span>
        </div>
        <div class="os-content mta-bus-content">
          <div class="h-full flex flex-col">
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
              <.header_bar active_borough={@active_borough} loading={@loading} />
              <.borough_selector active_borough={@active_borough} loading={@loading} />

              <%= if @error do %>
                <p class="text-red-500 text-sm mb-2">{@error}</p>
              <% end %>

              <div class="flex-1 relative mta-bus-map-container">
                <div
                  id={@map_id}
                  class="absolute inset-0 z-0"
                  phx-hook="MtaBusMap"
                  phx-update="ignore"
                >
                </div>
              </div>

              <.bus_route_selection_modal
                show={@show_modal}
                active_borough={@active_borough}
                selected_routes={@selected_routes}
                manhattan_bus_routes={Routes.for_borough(:manhattan)}
                brooklyn_bus_routes={Routes.for_borough(:brooklyn)}
                queens_bus_routes={Routes.for_borough(:queens)}
              />
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <span>Routes: {MapSet.size(@selected_routes)}</span>
          <span>Borough: {Routes.borough_name(@active_borough)}</span>
        </div>
      </div>
    </div>
    """
  end

  # -- Private components --

  attr :active_borough, :atom, required: true
  attr :loading, :boolean, required: true

  defp header_bar(assigns) do
    ~H"""
    <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 mb-2">
      <h1 class="text-xl sm:text-2xl font-bold">
        {Routes.borough_name(@active_borough)} MTA Bus Tracker
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
          class={[
            "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1.5 px-3 rounded text-sm sm:text-base flex items-center gap-1",
            @loading && "opacity-75 cursor-not-allowed"
          ]}
          disabled={@loading}
        >
          <%= if @loading do %>
            <.spinner size="h-4 w-4" /> Loading...
          <% else %>
            Update
          <% end %>
        </button>
      </div>
    </div>
    """
  end

  @borough_buttons [
    %{key: :all, color: nil},
    %{key: :manhattan, color: "bg-red-500"},
    %{key: :brooklyn, color: "bg-purple-500"},
    %{key: :queens, color: "bg-green-500"}
  ]

  attr :active_borough, :atom, required: true
  attr :loading, :boolean, required: true

  defp borough_selector(assigns) do
    assigns = assign(assigns, :borough_buttons, @borough_buttons)

    ~H"""
    <div class="mb-4">
      <div class="text-sm text-gray-500 mb-1">Select Borough:</div>
      <div class="flex flex-wrap gap-1">
        <.borough_button
          :for={btn <- @borough_buttons}
          borough={btn.key}
          color={btn.color}
          active_borough={@active_borough}
          loading={@loading}
        />
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
              <.spinner size="h-3 w-3" class="mr-1" /> Loading...
            </span>
          <% else %>
            Select All {Routes.borough_name(@active_borough)} Routes
          <% end %>
        </button>
      </div>
    </div>
    """
  end

  attr :borough, :atom, required: true
  attr :color, :string, default: nil
  attr :active_borough, :atom, required: true
  attr :loading, :boolean, required: true

  defp borough_button(assigns) do
    ~H"""
    <button
      phx-click="select_borough"
      phx-value-borough={@borough}
      class={[
        "px-3 py-1.5 text-sm font-medium rounded",
        if(@active_borough == @borough,
          do: "bg-blue-600 text-white",
          else: "bg-gray-200 text-gray-700 hover:bg-gray-300"
        ),
        @loading && "opacity-75 cursor-wait"
      ]}
      disabled={@loading}
    >
      <div class="flex items-center">
        <div :if={@color} class={"w-3 h-3 rounded-full #{@color} mr-1.5"}></div>
        <%= if @loading && @active_borough == @borough do %>
          <span class="flex items-center">
            <.spinner size="h-3 w-3" class="mr-1" />
            {Routes.borough_name(@borough)}
          </span>
        <% else %>
          {Routes.borough_name(@borough)}
        <% end %>
      </div>
    </button>
    """
  end

  attr :size, :string, default: "h-4 w-4"
  attr :class, :string, default: ""

  defp spinner(assigns) do
    ~H"""
    <svg
      class={"animate-spin #{@size} #{@class}"}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
      </circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      >
      </path>
    </svg>
    """
  end
end
