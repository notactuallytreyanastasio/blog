defmodule BlogWeb.SmartStepsLive.Designer do
  use BlogWeb, :live_view

  alias Blog.SmartSteps
  alias Blog.SmartSteps.{DesignerLogic, Trees}

  @impl true
  def mount(_params, _session, socket) do
    trees = SmartSteps.all_trees()

    {:ok,
     assign(socket,
       page_title: "Smart Steps - Designer",
       trees: trees,
       selected_tree: nil,
       validation_result: nil,
       tree_stats: nil
     )}
  end

  @impl true
  def handle_event("select_tree", %{"tree_id" => tree_id}, socket) do
    tree = Trees.get_tree(tree_id)

    if tree do
      validation = DesignerLogic.validate_tree(tree)
      depth = DesignerLogic.compute_depth(tree)
      paths = DesignerLogic.compute_all_paths(tree)
      orphans = DesignerLogic.find_orphans(tree.scenarios, tree.start_scenario_id)
      dead_ends = DesignerLogic.find_dead_ends(tree.scenarios)

      stats = %{
        scenario_count: map_size(tree.scenarios),
        depth: depth,
        path_count: length(paths),
        orphan_count: length(orphans),
        dead_end_count: length(dead_ends)
      }

      {:noreply,
       assign(socket,
         selected_tree: tree,
         validation_result: validation,
         tree_stats: stats
       )}
    else
      {:noreply, put_flash(socket, :error, "Tree not found")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page">
      <div class="max-w-6xl mx-auto px-4 py-8">
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-2xl font-bold" style="color: #2D3436;">Scenario Designer</h1>
          <.link navigate={~p"/smart-steps"} class="text-xs underline" style="color: #636E72;">Back</.link>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <%!-- Tree list --%>
          <div class="lg:col-span-1">
            <div class="bg-white rounded-2xl p-4" style="border: 1px solid #E0E0E0;">
              <h2 class="text-sm font-semibold mb-3" style="color: #2D3436;">Scenario Trees</h2>
              <div class="space-y-2">
                <button
                  :for={tree <- @trees}
                  phx-click="select_tree"
                  phx-value-tree_id={tree.id}
                  class="w-full text-left p-3 rounded-xl transition-colors text-sm"
                  style={if @selected_tree && @selected_tree.id == tree.id, do: "background-color: #BBDEFB; border: 1px solid #90CAF9;", else: ""}
                >
                  <div class="font-medium" style="color: #2D3436;"><%= tree.title %></div>
                  <div class="text-xs mt-1" style="color: #636E72;"><%= tree.theme %></div>
                </button>
              </div>
            </div>
          </div>

          <%!-- Tree details --%>
          <div class="lg:col-span-2">
            <div :if={@selected_tree == nil} class="bg-white rounded-2xl p-8 text-center" style="border: 1px solid #E0E0E0; color: #636E72;">
              Select a tree to view its details
            </div>

            <div :if={@selected_tree} class="space-y-6">
              <%!-- Stats --%>
              <div :if={@tree_stats} class="bg-white rounded-2xl p-6" style="border: 1px solid #E0E0E0;">
                <h2 class="text-lg font-semibold mb-4" style="color: #2D3436;"><%= @selected_tree.title %></h2>
                <p class="text-sm mb-4" style="color: #636E72;"><%= @selected_tree.description %></p>
                <div class="grid grid-cols-2 md:grid-cols-5 gap-3">
                  <div class="text-center p-2 rounded-xl" style="background-color: #F5F5F5;">
                    <div class="text-xl font-bold" style="color: #2D3436;"><%= @tree_stats.scenario_count %></div>
                    <div class="text-xs" style="color: #636E72;">Scenarios</div>
                  </div>
                  <div class="text-center p-2 rounded-xl" style="background-color: #F5F5F5;">
                    <div class="text-xl font-bold" style="color: #2D3436;"><%= @tree_stats.depth %></div>
                    <div class="text-xs" style="color: #636E72;">Max Depth</div>
                  </div>
                  <div class="text-center p-2 rounded-xl" style="background-color: #F5F5F5;">
                    <div class="text-xl font-bold" style="color: #2D3436;"><%= @tree_stats.path_count %></div>
                    <div class="text-xs" style="color: #636E72;">Paths</div>
                  </div>
                  <div class="text-center p-2 rounded-xl" style="background-color: #F5F5F5;">
                    <div class="text-xl font-bold" style={"color: #{if @tree_stats.orphan_count > 0, do: "#EC407A", else: "#66BB6A"};"}><%= @tree_stats.orphan_count %></div>
                    <div class="text-xs" style="color: #636E72;">Orphans</div>
                  </div>
                  <div class="text-center p-2 rounded-xl" style="background-color: #F5F5F5;">
                    <div class="text-xl font-bold" style={"color: #{if @tree_stats.dead_end_count > 0, do: "#EC407A", else: "#66BB6A"};"}><%= @tree_stats.dead_end_count %></div>
                    <div class="text-xs" style="color: #636E72;">Dead Ends</div>
                  </div>
                </div>
              </div>

              <%!-- Validation --%>
              <div :if={@validation_result} class="bg-white rounded-2xl p-6" style="border: 1px solid #E0E0E0;">
                <h3 class="text-sm font-semibold mb-3" style="color: #2D3436;">Validation</h3>
                <div :if={match?({:ok, _}, @validation_result)} class="flex items-center gap-2" style="color: #66BB6A;">
                  <span class="text-lg">&#10003;</span>
                  <span class="font-medium">Tree is valid</span>
                </div>
                <div :if={match?({:error, _}, @validation_result)}>
                  <div :for={error <- elem(@validation_result, 1)} class="flex items-center gap-2 mb-1" style="color: #EC407A;">
                    <span class="text-lg">&#10007;</span>
                    <span class="text-sm"><%= error %></span>
                  </div>
                </div>
              </div>

              <%!-- Scenario map --%>
              <div class="bg-white rounded-2xl p-6" style="border: 1px solid #E0E0E0;">
                <h3 class="text-sm font-semibold mb-3" style="color: #2D3436;">Scenario Map</h3>
                <div class="space-y-2">
                  <div
                    :for={{_id, scenario} <- Enum.sort_by(@selected_tree.scenarios, fn {_, s} -> s.level end)}
                    class="p-3 rounded-xl text-sm"
                    style={if scenario.is_game_over, do: "background-color: #F8BBD0; border: 1px solid #EC407A;", else: "background-color: #F5F5F5; border: 1px solid #E0E0E0;"}
                  >
                    <div class="flex items-center justify-between">
                      <div>
                        <span class="font-medium" style="color: #2D3436;"><%= scenario.title %></span>
                        <span class="ml-2 text-xs" style="color: #636E72;">L<%= scenario.level %></span>
                      </div>
                      <span :if={scenario.is_game_over} class="text-xs px-2 py-0.5 rounded-full font-medium" style="background-color: #EC407A; color: white;">
                        Game Over
                      </span>
                    </div>
                    <div :if={scenario.choices != []} class="mt-2 ml-4 space-y-1">
                      <div :for={choice <- scenario.choices} class="text-xs" style="color: #636E72;">
                        &rarr; <%= choice.text %> (<%= choice.risk_level %>) &rarr; <%= choice.next_scenario_id %>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
