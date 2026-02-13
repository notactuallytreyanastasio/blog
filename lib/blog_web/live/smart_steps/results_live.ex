defmodule BlogWeb.SmartStepsLive.Results do
  use BlogWeb, :live_view

  alias Blog.SmartSteps
  alias Blog.SmartSteps.{SessionServer, Trees}

  @metric_bar_colors %{
    self_awareness: "#66BB6A",
    self_management: "#42A5F5",
    social_awareness: "#EC407A",
    relationship_skills: "#FFEE58",
    decision_making: "#A5D6A7",
    self_advocacy: "#90CAF9"
  }

  @impl true
  def mount(%{"session_id" => session_id}, _session, socket) do
    game_state =
      if SessionServer.session_exists?(session_id) do
        SessionServer.get_state(session_id)
      else
        nil
      end

    if game_state do
      avg_metrics = SmartSteps.calculate_average_metrics(game_state.level_data)
      final_scenario = Trees.get_scenario(game_state.current_scenario_id, game_state.current_tree_id)

      {:ok,
       assign(socket,
         page_title: "Smart Steps - Results",
         session_id: session_id,
         game_state: game_state,
         avg_metrics: avg_metrics,
         level_data: game_state.level_data,
         final_scenario: final_scenario
       )}
    else
      {:ok,
       socket
       |> put_flash(:error, "Session not found")
       |> push_navigate(to: ~p"/smart-steps")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page">
      <div class="max-w-3xl mx-auto px-4 py-8">
        <h1 class="text-2xl font-bold mb-6 ss-fade-in" style="color: #2D3436;">Session Complete</h1>

        <div class="space-y-6">
          <%!-- Outcome banner --%>
          <div :if={@final_scenario && @final_scenario.outcome_type} class="ss-fade-in">
            <.outcome_banner
              outcome_type={@final_scenario.outcome_type}
              game_over_reason={@game_state.game_over_reason}
            />
          </div>

          <%!-- Stats --%>
          <div class="grid grid-cols-3 gap-3 ss-fade-in">
            <div class="bg-white rounded-xl p-3 text-center" style="border: 1px solid #E0E0E0;">
              <p class="text-2xl font-bold" style="color: #2D3436;"><%= length(@level_data) %></p>
              <p class="text-xs" style="color: #636E72;">Levels</p>
            </div>
            <div class="bg-white rounded-xl p-3 text-center" style="border: 1px solid #E0E0E0;">
              <p class="text-2xl font-bold" style="color: #2D3436;"><%= count_risk(@level_data, :low) %></p>
              <p class="text-xs" style="color: #636E72;">Safe choices</p>
            </div>
            <div class="bg-white rounded-xl p-3 text-center" style="border: 1px solid #E0E0E0;">
              <p class="text-2xl font-bold" style="color: #2D3436;"><%= count_risk(@level_data, :high) + count_risk(@level_data, :critical) %></p>
              <p class="text-xs" style="color: #636E72;">Risky choices</p>
            </div>
          </div>

          <%!-- Decision timeline --%>
          <div class="bg-white rounded-2xl p-6 ss-fade-in" style="border: 1px solid #E0E0E0;">
            <h3 class="text-sm font-semibold mb-2" style="color: #2D3436;">Decision Timeline</h3>
            <div class="space-y-2">
              <div :for={ld <- @level_data} class="flex items-start gap-3 text-sm">
                <span
                  class="text-xs px-2 py-0.5 rounded-full font-medium shrink-0 mt-0.5 text-white"
                  style={"background-color: #{risk_badge_color(ld.risk_level)};"}
                >
                  L<%= ld.level %>
                </span>
                <div>
                  <p class="font-medium" style="color: #2D3436;"><%= ld.scenario_title %></p>
                  <p class="text-xs" style="color: #636E72;"><%= ld.selected_choice_text %></p>
                </div>
              </div>
            </div>
          </div>

          <%!-- Learning points --%>
          <div
            :if={@final_scenario && @final_scenario.learning_points && @final_scenario.learning_points != []}
            class="rounded-2xl p-6 ss-fade-in"
            style="background-color: rgba(200,230,201,0.5); border: 1px solid #A5D6A7;"
          >
            <h3 class="text-sm font-semibold mb-2" style="color: #66BB6A;">Key Takeaways</h3>
            <ul class="space-y-1.5">
              <li :for={point <- @final_scenario.learning_points} class="text-sm flex items-start gap-2" style="color: #2D3436;">
                <span style="color: #66BB6A;" class="mt-0.5">&#x2022;</span>
                <%= point %>
              </li>
            </ul>
          </div>

          <%!-- Discussion prompt --%>
          <div
            :if={@final_scenario && @final_scenario.discussion_prompt}
            class="rounded-2xl p-6 ss-fade-in"
            style="background-color: rgba(187,222,251,0.5); border: 1px solid #90CAF9;"
          >
            <h3 class="text-sm font-semibold mb-2" style="color: #42A5F5;">Discussion Prompt</h3>
            <p class="text-sm" style="color: #2D3436;"><%= @final_scenario.discussion_prompt %></p>
          </div>

          <%!-- SEL Metrics --%>
          <div class="bg-white rounded-2xl p-6 ss-fade-in" style="border: 1px solid #E0E0E0;">
            <h3 class="text-sm font-semibold mb-3" style="color: #2D3436;">SEL Metrics</h3>
            <.metric_bar label="Self-Awareness" value={@avg_metrics.self_awareness} color={metric_color(:self_awareness)} />
            <.metric_bar label="Self-Management" value={@avg_metrics.self_management} color={metric_color(:self_management)} />
            <.metric_bar label="Social Awareness" value={@avg_metrics.social_awareness} color={metric_color(:social_awareness)} />
            <.metric_bar label="Relationship Skills" value={@avg_metrics.relationship_skills} color={metric_color(:relationship_skills)} />
            <.metric_bar label="Decision Making" value={@avg_metrics.decision_making} color={metric_color(:decision_making)} />
            <.metric_bar label="Self-Advocacy" value={@avg_metrics.self_advocacy} color={metric_color(:self_advocacy)} />
          </div>

          <%!-- Actions --%>
          <div class="flex gap-3">
            <.link
              navigate={~p"/smart-steps/dashboard"}
              class="flex-1 flex items-center justify-center gap-2 py-3 text-white rounded-xl font-semibold text-sm hover:opacity-90 transition-colors"
              style="background-color: #66BB6A;"
            >
              Save & Return to Dashboard
            </.link>
            <.link
              navigate={~p"/smart-steps"}
              class="flex items-center gap-1 px-4 py-3 rounded-xl text-sm transition-colors"
              style="border: 1px solid #E0E0E0; color: #636E72;"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>
              Menu
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp outcome_banner(assigns) do
    {bg, text_color, label} = outcome_style(assigns.outcome_type)
    assigns = assign(assigns, bg: bg, text_color: text_color, label: label)

    ~H"""
    <div class="rounded-xl p-4 text-center" style={"background-color: #{@bg};"}>
      <p class="text-lg font-bold" style={"color: #{@text_color};"}><%= @label %></p>
      <p :if={@game_over_reason} class="text-sm mt-1" style="color: #636E72;"><%= @game_over_reason %></p>
    </div>
    """
  end

  defp metric_bar(assigns) do
    ~H"""
    <div class="mb-3">
      <div class="flex items-center justify-between mb-1">
        <span class="text-xs" style="color: #636E72;"><%= @label %></span>
        <span class="text-xs font-mono" style="color: #636E72;"><%= @value %>/10</span>
      </div>
      <div class="w-full h-2 rounded-full overflow-hidden" style="background-color: #F5F5F5;">
        <div
          class="h-full rounded-full transition-all duration-500"
          style={"width: #{@value / 10 * 100}%; background-color: #{@color};"}
        />
      </div>
    </div>
    """
  end

  defp outcome_style(:positive), do: {"#C8E6C9", "#66BB6A", "Great outcome!"}
  defp outcome_style(:neutral), do: {"#F5F5F5", "#636E72", "Neutral outcome"}
  defp outcome_style(:negative), do: {"#FFF9C4", "#b45309", "Tough outcome"}
  defp outcome_style(:severe), do: {"#F8BBD0", "#EC407A", "Difficult outcome"}
  defp outcome_style(_), do: {"#F5F5F5", "#636E72", "Session complete"}

  defp risk_badge_color(:low), do: "#66BB6A"
  defp risk_badge_color(:medium), do: "#FFEE58"
  defp risk_badge_color(:high), do: "#EC407A"
  defp risk_badge_color(:critical), do: "#9b59b6"
  defp risk_badge_color(_), do: "#636E72"

  defp metric_color(key), do: Map.get(@metric_bar_colors, key, "#636E72")

  defp count_risk(level_data, risk) do
    Enum.count(level_data, fn ld -> ld.risk_level == risk end)
  end
end
