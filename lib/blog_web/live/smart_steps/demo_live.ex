defmodule BlogWeb.SmartStepsLive.Demo do
  use BlogWeb, :live_view

  alias Blog.SmartSteps
  alias Blog.SmartSteps.Trees

  @step_interval 2000

  @impl true
  def mount(_params, _session, socket) do
    trees = SmartSteps.all_trees()
    first_tree = List.first(trees)

    {:ok,
     assign(socket,
       page_title: "Smart Steps - Demo",
       trees: trees,
       selected_tree: first_tree,
       path: [],
       current_step: 0,
       playing: false,
       scenarios: []
     )}
  end

  @impl true
  def handle_event("select_tree", %{"tree_id" => tree_id}, socket) do
    tree = Trees.get_tree(tree_id)
    {:noreply, assign(socket, selected_tree: tree, path: [], current_step: 0, playing: false, scenarios: [])}
  end

  @impl true
  def handle_event("start_demo", _params, socket) do
    tree = socket.assigns.selected_tree

    if tree do
      path = SmartSteps.generate_random_path(tree)

      scenarios =
        Enum.map(path, fn scenario_id ->
          Map.get(tree.scenarios, scenario_id)
        end)
        |> Enum.reject(&is_nil/1)

      if connected?(socket), do: Process.send_after(self(), :next_step, @step_interval)

      {:noreply,
       assign(socket,
         path: path,
         scenarios: scenarios,
         current_step: 0,
         playing: true
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("stop_demo", _params, socket) do
    {:noreply, assign(socket, playing: false)}
  end

  @impl true
  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign(socket, path: [], current_step: 0, playing: false, scenarios: [])}
  end

  @impl true
  def handle_info(:next_step, socket) do
    if socket.assigns.playing && socket.assigns.current_step < length(socket.assigns.scenarios) - 1 do
      Process.send_after(self(), :next_step, @step_interval)
      {:noreply, assign(socket, current_step: socket.assigns.current_step + 1)}
    else
      {:noreply, assign(socket, playing: false)}
    end
  end

  @impl true
  def render(assigns) do
    current_scenario =
      if assigns.scenarios != [] do
        Enum.at(assigns.scenarios, assigns.current_step)
      end

    assigns = assign(assigns, current_scenario: current_scenario)

    ~H"""
    <div class="ss-page">
      <div class="max-w-3xl mx-auto px-4 py-8">
        <div class="text-center mb-8 ss-fade-in">
          <h1 class="text-2xl font-bold mb-2" style="color: #2D3436;">Demo Mode</h1>
          <p style="color: #636E72;">Watch an automated playthrough of a scenario tree</p>
        </div>

        <%!-- Tree selector --%>
        <div class="flex flex-wrap justify-center gap-2 mb-8">
          <button
            :for={tree <- @trees}
            phx-click="select_tree"
            phx-value-tree_id={tree.id}
            class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
            style={if @selected_tree && @selected_tree.id == tree.id, do: "background-color: #42A5F5; color: white;", else: "background-color: white; color: #2D3436; border: 1px solid #E0E0E0;"}
          >
            <%= tree.title %>
          </button>
        </div>

        <%!-- Controls --%>
        <div class="text-center mb-8 space-x-3">
          <button
            :if={!@playing}
            phx-click="start_demo"
            class="px-6 py-2 text-white rounded-xl font-medium transition-colors hover:opacity-90"
            style="background-color: #66BB6A;"
          >
            Start Demo
          </button>
          <button
            :if={@playing}
            phx-click="stop_demo"
            class="px-6 py-2 text-white rounded-xl font-medium transition-colors hover:opacity-90"
            style="background-color: #EC407A;"
          >
            Stop
          </button>
          <button
            :if={@path != [] && !@playing}
            phx-click="reset_demo"
            class="px-6 py-2 rounded-xl font-medium transition-colors"
            style="background-color: #F5F5F5; color: #636E72;"
          >
            Reset
          </button>
        </div>

        <%!-- Progress bar --%>
        <div :if={@path != []} class="mb-6">
          <div class="flex items-center justify-between text-sm mb-2" style="color: #636E72;">
            <span>Step <%= @current_step + 1 %> of <%= length(@scenarios) %></span>
            <span :if={@playing} class="animate-pulse" style="color: #66BB6A;">Playing...</span>
          </div>
          <div class="w-full h-2 rounded-full" style="background-color: #E0E0E0;">
            <div
              class="h-2 rounded-full transition-all duration-500"
              style={"width: #{if length(@scenarios) > 0, do: (@current_step + 1) / length(@scenarios) * 100, else: 0}%; background-color: #42A5F5;"}
            />
          </div>
        </div>

        <%!-- Current scenario --%>
        <div :if={@current_scenario} class="bg-white rounded-2xl overflow-hidden ss-fade-in-up" style="border: 1px solid #E0E0E0;">
          <div class="h-3 w-full" style={"background-color: #{@current_scenario.image_color};"}></div>
          <div class="p-6">
            <div class="flex items-center gap-2 mb-3">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#636E72" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
              <span class="text-xs font-medium uppercase tracking-wide" style="color: #636E72;"><%= @current_scenario.location %></span>
              <span class="text-xs" style="color: #636E72;">Level <%= @current_scenario.level %></span>
            </div>
            <h2 class="text-xl font-bold mb-3" style="color: #2D3436;"><%= @current_scenario.title %></h2>
            <p class="leading-relaxed mb-4" style="color: #636E72;"><%= @current_scenario.description %></p>

            <div :if={@current_scenario.is_game_over} class="mt-4 p-4 rounded-xl" style="background-color: rgba(200,230,201,0.5);">
              <p class="font-medium" style="color: #66BB6A;">Game Over</p>
              <p :if={@current_scenario.discussion_prompt} class="text-sm mt-2 italic" style="color: #2D3436;">
                <%= @current_scenario.discussion_prompt %>
              </p>
            </div>

            <div :if={!@current_scenario.is_game_over && @current_scenario.choices != []} class="mt-4 space-y-2">
              <p class="text-sm" style="color: #636E72;">Choices available:</p>
              <div :for={choice <- @current_scenario.choices} class="p-3 rounded-lg text-sm" style="background-color: #F5F5F5; color: #2D3436;">
                <%= choice.text %>
              </div>
            </div>
          </div>
        </div>

        <%!-- Footer --%>
        <div class="mt-8 text-center">
          <.link navigate={~p"/smart-steps"} class="text-sm underline" style="color: #636E72;">
            Back to Smart Steps
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
