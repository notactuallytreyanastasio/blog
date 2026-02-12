defmodule BlogWeb.SmartStepsLive.Play do
  use BlogWeb, :live_view

  alias Blog.SmartSteps.{SessionServer, Trees, Types}
  alias Blog.SmartSteps.Types.Metrics

  @impl true
  def mount(%{"session_id" => session_id} = params, _session, socket) do
    role = case params["role"] do
      "facilitator" -> :facilitator
      "participant" -> :participant
      _ -> :participant
    end

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "smart_steps:#{session_id}")
    end

    case get_or_start_session(session_id, params) do
      {:ok, game_state} ->
        scenario = get_current_scenario(game_state)

        {:ok,
         assign(socket,
           page_title: "Smart Steps - Playing",
           session_id: session_id,
           role: role,
           game_state: game_state,
           scenario: scenario,
           peer_hovered_index: -1,
           notes: "",
           metrics: %Metrics{},
           show_continue: false
         )}

      {:error, reason} ->
        {:ok,
         socket
         |> put_flash(:error, "Session error: #{inspect(reason)}")
         |> push_navigate(to: ~p"/smart-steps")}
    end
  end

  defp get_or_start_session(session_id, params) do
    if SessionServer.session_exists?(session_id) do
      {:ok, SessionServer.get_state(session_id)}
    else
      tree_id = params["tree_id"] || "fire-drill"
      role = case params["role"] do
        "facilitator" -> :facilitator
        _ -> :participant
      end

      case DynamicSupervisor.start_child(
             Blog.SmartSteps.SessionSupervisor,
             {SessionServer, {session_id, tree_id, role}}
           ) do
        {:ok, _pid} -> {:ok, SessionServer.get_state(session_id)}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp get_current_scenario(game_state) do
    Trees.get_scenario(game_state.current_scenario_id, game_state.current_tree_id)
  end

  # ============================================
  # Events
  # ============================================

  @impl true
  def handle_event("card_hover", %{"index" => index}, socket) do
    idx = if is_binary(index), do: String.to_integer(index), else: index
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "smart_steps:#{socket.assigns.session_id}",
      {:peer_hover, idx, socket.assigns.role}
    )
    {:noreply, socket}
  end

  @impl true
  def handle_event("card_unhover", %{"index" => index}, socket) do
    idx = if is_binary(index), do: String.to_integer(index), else: index
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "smart_steps:#{socket.assigns.session_id}",
      {:peer_unhover, idx, socket.assigns.role}
    )
    {:noreply, socket}
  end

  @impl true
  def handle_event("card_select", %{"index" => index}, socket) do
    idx = if is_binary(index), do: String.to_integer(index), else: index
    SessionServer.select_choice(socket.assigns.session_id, idx)
    {:noreply, assign(socket, show_continue: true)}
  end

  @impl true
  def handle_event("continue_to_discussion", _params, socket) do
    SessionServer.continue_to_discussion(socket.assigns.session_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_notes", %{"notes" => notes}, socket) do
    {:noreply, assign(socket, notes: notes)}
  end

  @impl true
  def handle_event("update_metric", %{"metric" => metric, "value" => value}, socket) do
    val = if is_binary(value), do: String.to_integer(value), else: value
    metrics = Map.put(socket.assigns.metrics, String.to_existing_atom(metric), val)
    {:noreply, assign(socket, metrics: metrics)}
  end

  @impl true
  def handle_event("proceed_from_discussion", _params, socket) do
    %{session_id: session_id, notes: notes, metrics: metrics} = socket.assigns

    case SessionServer.proceed_from_discussion(session_id, notes, metrics) do
      {:ok, _game_state} ->
        {:noreply, assign(socket, notes: "", metrics: %Metrics{}, show_continue: false)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("view_results", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/smart-steps/results/#{socket.assigns.session_id}")}
  end

  # ============================================
  # PubSub handlers
  # ============================================

  @impl true
  def handle_info({:state_update, game_state}, socket) do
    scenario = get_current_scenario(game_state)

    socket =
      socket
      |> assign(game_state: game_state, scenario: scenario)
      |> then(fn s ->
        if game_state.phase == :game do
          push_event(s, "reset_cards", %{})
        else
          s
        end
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:peer_hover, index, from_role}, socket) do
    if from_role != socket.assigns.role do
      socket =
        socket
        |> assign(peer_hovered_index: index)
        |> push_event("peer_glow", %{index: index})
        |> push_event("peer_flip", %{index: index})

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:peer_unhover, index, from_role}, socket) do
    if from_role != socket.assigns.role do
      socket =
        socket
        |> assign(peer_hovered_index: -1)
        |> push_event("peer_unglow", %{index: index})
        |> push_event("peer_unflip", %{index: index})

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_msg, socket), do: {:noreply, socket}

  # ============================================
  # Render
  # ============================================

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page">
      <div class="max-w-5xl mx-auto px-4 py-6">
        <%!-- Back button --%>
        <.link
          navigate={~p"/smart-steps"}
          class="inline-flex items-center gap-1 text-xs mb-4 transition-colors"
          style="color: #636E72;"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>
          Exit Session
        </.link>

        <div class="flex gap-6">
          <div class="flex-1">
            <%!-- Game Phase --%>
            <div :if={@game_state.phase == :game && @scenario}>
              <.game_phase
                scenario={@scenario}
                game_state={@game_state}
                session_id={@session_id}
                role={@role}
                show_continue={@show_continue}
                peer_hovered_index={@peer_hovered_index}
              />
            </div>

            <%!-- Discussion Phase --%>
            <div :if={@game_state.phase == :discussion && @scenario}>
              <.discussion_phase
                scenario={@scenario}
                game_state={@game_state}
                role={@role}
                notes={@notes}
                metrics={@metrics}
              />
            </div>

            <%!-- Results Phase --%>
            <div :if={@game_state.phase == :results}>
              <.results_phase game_state={@game_state} />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================
  # Components
  # ============================================

  defp game_phase(assigns) do
    ~H"""
    <div class="ss-fade-in max-w-3xl mx-auto">
      <%!-- Session banner --%>
      <div class="flex items-center justify-between mb-4 px-1">
        <span class="text-xs font-mono px-3 py-1 rounded-full" style="color: #636E72; background-color: #F5F5F5;">
          Session <%= @session_id %>
        </span>
        <span class="text-xs font-medium" style="color: #636E72;">
          Level <%= @game_state.current_level %>
        </span>
      </div>

      <%!-- Scenario card --%>
      <div class="bg-white rounded-2xl overflow-hidden" style="border: 1px solid #E0E0E0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
        <%!-- Color header bar --%>
        <div class="h-3 w-full" style={"background-color: #{@scenario.image_color};"}></div>

        <div class="p-6">
          <%!-- Location --%>
          <div class="flex items-center gap-1.5 mb-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#636E72" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
            <span class="text-xs font-medium uppercase tracking-wide" style="color: #636E72;">
              <%= @scenario.location %>
            </span>
          </div>

          <%!-- Title & Description --%>
          <h2 class="text-xl font-bold mb-3" style="color: #2D3436;"><%= @scenario.title %></h2>
          <p class="leading-relaxed mb-6" style="color: #636E72;"><%= @scenario.description %></p>

          <%!-- Flip cards --%>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6 ss-stagger">
            <div
              :for={{choice, idx} <- Enum.with_index(@scenario.choices)}
              id={"card-#{idx}"}
              phx-hook="FlipCard"
              data-index={idx}
              data-selected={if @game_state.selected_choice_index == idx, do: "true", else: "false"}
              role="button"
              tabindex="0"
              aria-label={"Option #{idx + 1} — click to reveal"}
              class={[
                "flip-card",
                @game_state.selected_choice_index == idx && "selected",
                @peer_hovered_index == idx && "peer-glow"
              ]}
            >
              <div class="flip-inner">
                <%!-- Front (face-down) --%>
                <div class="flip-front">
                  <span class="text-2xl font-bold" style="color: #636E72;">
                    Option <%= idx + 1 %>
                  </span>
                </div>
                <%!-- Back (face-up, revealed on click) --%>
                <div class={"flip-back risk-#{choice.risk_level}"}>
                  <p class="text-sm leading-relaxed" style="color: #2D3436;"><%= choice.text %></p>
                  <div class="flex items-center justify-between mt-2">
                    <span class={"text-xs px-2 py-0.5 rounded-full text-white font-medium #{risk_badge_bg(choice.risk_level)}"}>
                      <%= if @game_state.selected_choice_index == idx, do: "Selected", else: "Click to select" %>
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <%!-- Continue button --%>
          <button
            phx-click="continue_to_discussion"
            disabled={@game_state.selected_choice_index < 0}
            class={[
              "w-full py-3 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2",
              @game_state.selected_choice_index >= 0 && "text-white hover:opacity-90",
              @game_state.selected_choice_index < 0 && "cursor-not-allowed"
            ]}
            style={if @game_state.selected_choice_index >= 0, do: "background-color: #42A5F5;", else: "background-color: #F5F5F5; color: #636E72;"}
          >
            Continue
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp discussion_phase(assigns) do
    selected_choice = if assigns.game_state.selected_choice_index >= 0 do
      Enum.at(assigns.scenario.choices, assigns.game_state.selected_choice_index)
    end
    assigns = assign(assigns, selected_choice: selected_choice)

    ~H"""
    <div :if={@role == :participant} class="max-w-lg mx-auto text-center ss-fade-in p-8">
      <div class="bg-white rounded-2xl p-8" style="border: 1px solid #E0E0E0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
        <h2 class="text-lg font-bold mb-2" style="color: #2D3436;">Discussion Time</h2>
        <p :if={@selected_choice} class="mb-2" style="color: #636E72;">
          You selected: "<%= @selected_choice.text %>"
        </p>
        <p class="text-sm mb-6" style="color: #636E72;">
          Please wait while the facilitator reviews your choice and takes notes.
        </p>
      </div>
    </div>

    <div :if={@role == :facilitator} class="max-w-2xl mx-auto ss-fade-in">
      <div class="bg-white rounded-2xl p-6" style="border: 1px solid #E0E0E0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
        <h2 class="text-lg font-bold mb-1" style="color: #2D3436;">Discussion Phase</h2>
        <p :if={@selected_choice} class="text-sm mb-4" style="color: #636E72;">
          Selected: "<%= @selected_choice.text %>"
        </p>
        <p :if={@scenario.discussion_prompt} class="text-sm italic mb-4" style="color: #636E72;">
          <%= @scenario.discussion_prompt %>
        </p>

        <%!-- Notes --%>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1.5" style="color: #2D3436;">Facilitator Notes</label>
          <textarea
            phx-change="update_notes"
            name="notes"
            value={@notes}
            placeholder="How did the participant respond? What did you discuss?"
            rows="3"
            class="w-full px-3 py-2 rounded-lg text-sm resize-none focus:outline-none focus:ring-2"
            style="border: 1px solid #E0E0E0; color: #2D3436; --tw-ring-color: rgba(144,202,249,0.5);"
          ><%= @notes %></textarea>
        </div>

        <%!-- SEL Metrics --%>
        <div class="space-y-4 mb-6">
          <h3 class="text-sm font-semibold" style="color: #2D3436;">SEL Metrics</h3>
          <.metric_slider metric="self_awareness" label="Self-Awareness" value={@metrics.self_awareness} />
          <.metric_slider metric="self_management" label="Self-Management" value={@metrics.self_management} />
          <.metric_slider metric="social_awareness" label="Social Awareness" value={@metrics.social_awareness} />
          <.metric_slider metric="relationship_skills" label="Relationship Skills" value={@metrics.relationship_skills} />
          <.metric_slider metric="decision_making" label="Decision Making" value={@metrics.decision_making} />
          <.metric_slider metric="self_advocacy" label="Self-Advocacy" value={@metrics.self_advocacy} />
        </div>

        <%!-- Proceed --%>
        <button
          phx-click="proceed_from_discussion"
          class="w-full py-3 text-white rounded-xl font-semibold text-sm hover:opacity-90 transition-colors"
          style="background-color: #66BB6A;"
        >
          Proceed to Next Level
        </button>
      </div>
    </div>
    """
  end

  defp results_phase(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto ss-fade-in">
      <div class="bg-white rounded-2xl p-6 text-center" style="border: 1px solid #E0E0E0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
        <h2 class="text-2xl font-bold mb-4" style="color: #2D3436;">Session Complete!</h2>
        <p :if={@game_state[:game_over_reason]} class="mb-6" style="color: #636E72;">
          <%= @game_state.game_over_reason %>
        </p>
        <button
          phx-click="view_results"
          class="px-8 py-3 text-white rounded-xl font-semibold text-sm hover:opacity-90 transition-colors"
          style="background-color: #42A5F5;"
        >
          View Full Results
        </button>
      </div>
    </div>
    """
  end

  defp metric_slider(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-1">
        <label class="text-xs" style="color: #636E72;"><%= @label %></label>
        <span class="text-xs font-mono" style="color: #636E72;"><%= @value %></span>
      </div>
      <input
        type="range"
        min="1"
        max="10"
        value={@value}
        phx-change="update_metric"
        name="metric"
        phx-value-metric={@metric}
        phx-value-value={@value}
        class="w-full h-2 rounded-full appearance-none cursor-pointer"
        style="background-color: #F5F5F5; accent-color: #42A5F5;"
      />
    </div>
    """
  end

  defp risk_badge_bg(:low), do: "bg-[#66BB6A]"
  defp risk_badge_bg(:medium), do: "bg-[#FFEE58] !text-[#2D3436]"
  defp risk_badge_bg(:high), do: "bg-[#EC407A]"
  defp risk_badge_bg(:critical), do: "bg-[#9b59b6]"
  defp risk_badge_bg(_), do: "bg-[#636E72]"
end
