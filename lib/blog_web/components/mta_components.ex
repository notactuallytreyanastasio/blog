defmodule BlogWeb.MTAComponents do
  use Phoenix.Component

  @doc """
  A modal component for selecting bus routes.

  ## Props

  * `show` - boolean indicating whether the modal should be displayed
  * `active_borough` - the currently active borough (:manhattan, :brooklyn, :queens, :bronx, or :all)
  * `selected_routes` - a MapSet containing the currently selected routes
  * `manhattan_bus_routes` - a map of Manhattan bus routes
  * `brooklyn_bus_routes` - a map of Brooklyn bus routes
  * `queens_bus_routes` - a map of Queens bus routes
  * `bronx_bus_routes` - a map of Bronx bus routes
  """
  attr :show, :boolean, required: true
  attr :active_borough, :atom, required: true
  attr :selected_routes, :any, required: true
  attr :manhattan_bus_routes, :map, required: true
  attr :brooklyn_bus_routes, :map, required: true
  attr :queens_bus_routes, :map, required: true
  attr :bronx_bus_routes, :map, required: true

  def bus_route_selection_modal(assigns) do
    ~H"""
    <%= if @show do %>
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
                            <% :queens -> %>Queens
                            <% :bronx -> %>Bronx
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
                      <nav class="-mb-px flex flex-wrap" aria-label="Borough tabs">
                        <button
                          phx-click="select_borough"
                          phx-value-borough="manhattan"
                          class={"w-1/5 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :manhattan, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                        >
                          Manhattan
                        </button>
                        <button
                          phx-click="select_borough"
                          phx-value-borough="brooklyn"
                          class={"w-1/5 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :brooklyn, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                        >
                          Brooklyn
                        </button>
                        <button
                          phx-click="select_borough"
                          phx-value-borough="queens"
                          class={"w-1/5 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :queens, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                        >
                          Queens
                        </button>
                        <button
                          phx-click="select_borough"
                          phx-value-borough="bronx"
                          class={"w-1/5 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :bronx, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
                        >
                          Bronx
                        </button>
                        <button
                          phx-click="select_borough"
                          phx-value-borough="all"
                          class={"w-1/5 py-2 px-1 border-b-2 text-sm font-medium #{if @active_borough == :all, do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
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

                      <%= if @active_borough == :queens || @active_borough == :all do %>
                        <div>
                          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 sm:gap-4">
                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Queens Routes</div>
                            <%= for {route, _} <- Enum.filter(@queens_bus_routes, fn {k, _} ->
                              String.match?(k, ~r/^Q\d+[A-Z]?$/)
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

                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Queens SBS Routes</div>
                            <%= for {route, _} <- Enum.filter(@queens_bus_routes, fn {k, _} ->
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

                      <%= if @active_borough == :bronx || @active_borough == :all do %>
                        <div>
                          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 sm:gap-4">
                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Bronx Routes</div>
                            <%= for {route, _} <- Enum.filter(@bronx_bus_routes, fn {k, _} ->
                              String.match?(k, ~r/^Bx\d+[A-Z]?$/) and not String.contains?(k, "-SBS")
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

                            <div class="col-span-full mb-1 sm:mb-2 font-bold text-base sm:text-lg">Bronx SBS Routes</div>
                            <%= for {route, _} <- Enum.filter(@bronx_bus_routes, fn {k, _} ->
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
    """
  end
end
