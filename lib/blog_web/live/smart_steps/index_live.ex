defmodule BlogWeb.SmartStepsLive.Index do
  use BlogWeb, :live_view

  alias Blog.SmartSteps

  @theme_labels %{
    sensory_overload: "Sensory",
    routine_change: "Routine",
    social_misunderstanding: "Social",
    friendship: "Friendship",
    bullying: "Bullying",
    self_advocacy: "Advocacy",
    emotional_regulation: "Emotions",
    transitions: "Transitions",
    group_participation: "Group Work",
    conflict_resolution: "Conflict"
  }

  @theme_badges %{
    sensory_overload: {"#F8BBD0", "#EC407A"},
    routine_change: {"#FFF9C4", "#b45309"},
    social_misunderstanding: {"#BBDEFB", "#42A5F5"},
    friendship: {"#C8E6C9", "#66BB6A"},
    bullying: {"#f3e5f5", "#9b59b6"},
    self_advocacy: {"#C8E6C9", "#66BB6A"},
    emotional_regulation: {"#F8BBD0", "#EC407A"},
    transitions: {"#FFF9C4", "#b45309"},
    group_participation: {"#BBDEFB", "#42A5F5"},
    conflict_resolution: {"#f3e5f5", "#9b59b6"}
  }

  @impl true
  def mount(_params, _session, socket) do
    trees = SmartSteps.all_trees()

    {:ok,
     assign(socket,
       page_title: "Smart Steps",
       trees: trees,
       role: nil
     )}
  end

  @impl true
  def handle_event("select_role", %{"role" => role}, socket) do
    role_atom = case role do
      "facilitator" -> :facilitator
      "participant" -> :participant
      _ -> nil
    end
    {:noreply, assign(socket, role: role_atom)}
  end

  @impl true
  def handle_event("launch_session", %{"tree_id" => tree_id}, socket) do
    session_id = SmartSteps.generate_session_id()
    role = socket.assigns.role || :facilitator

    case DynamicSupervisor.start_child(
           Blog.SmartSteps.SessionSupervisor,
           {Blog.SmartSteps.SessionServer, {session_id, tree_id, role}}
         ) do
      {:ok, _pid} ->
        {:noreply, push_navigate(socket, to: ~p"/smart-steps/play/#{session_id}?role=#{role}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to start session: #{inspect(reason)}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page">
      <div class="max-w-5xl mx-auto px-4 py-12">
        <%!-- Hero --%>
        <div class="text-center mb-12 ss-fade-in">
          <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-medium mb-4"
               style="background-color: #BBDEFB; color: #42A5F5;">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 10.5V6a1 1 0 0 0-1-1h-1a3 3 0 0 0-3 3"/><path d="M11 21.73a2 2 0 0 1-2.18-.37l-2.64-2.4A2 2 0 0 1 6 17.22V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12.22a2 2 0 0 1-.18 1.74l-2.64 2.4a2 2 0 0 1-2.18.37"/><path d="M12 3v18"/></svg>
            Smart Steps
          </div>
          <h1 class="text-3xl sm:text-4xl font-bold mb-3" style="color: #2D3436;">
            Real Scenarios. Real Conversations.
          </h1>
          <p class="max-w-xl mx-auto leading-relaxed" style="color: #636E72;">
            Walk through everyday situations together. A facilitator guides a
            young person through branching scenarios, building understanding
            through shared experience and honest conversation.
          </p>
        </div>

        <%!-- Role selection --%>
        <div :if={@role == nil} class="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-lg mx-auto mb-16">
          <button
            phx-click="select_role"
            phx-value-role="facilitator"
            class="bg-white rounded-xl p-6 text-center ss-hover-lift transition-all"
            style="border: 1px solid #E0E0E0;"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#66BB6A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mx-auto mb-2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            <p class="font-bold text-sm" style="color: #2D3436;">I'm a Facilitator</p>
            <p class="text-xs mt-1" style="color: #636E72;">Launch sessions and guide discussions</p>
          </button>
          <button
            phx-click="select_role"
            phx-value-role="participant"
            class="bg-white rounded-xl p-6 text-center ss-hover-lift transition-all"
            style="border: 1px solid #E0E0E0;"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#42A5F5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mx-auto mb-2"><polygon points="6 3 20 12 6 21 6 3"/></svg>
            <p class="font-bold text-sm" style="color: #2D3436;">I'm Joining</p>
            <p class="text-xs mt-1" style="color: #636E72;">Connect to a facilitator's session</p>
          </button>
        </div>

        <%!-- Active role banner --%>
        <div :if={@role != nil} class="mb-8 flex justify-center gap-4 items-center">
          <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium"
                style="background-color: #BBDEFB; color: #42A5F5;">
            Role: <%= String.capitalize(to_string(@role)) %>
          </span>
          <button phx-click="select_role" phx-value-role="" class="text-xs underline" style="color: #636E72;">
            Change role
          </button>
          <.link
            :if={@role == :participant}
            navigate={~p"/smart-steps/connect"}
            class="text-xs underline"
            style="color: #42A5F5;"
          >
            Join existing session
          </.link>
        </div>

        <%!-- Scenario trees --%>
        <div :if={@role != nil}>
          <h2 class="text-lg font-bold mb-4" style="color: #2D3436;">Browse Scenario Trees</h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 ss-stagger">
            <button
              :for={tree <- @trees}
              phx-click="launch_session"
              phx-value-tree_id={tree.id}
              class="text-left bg-white rounded-xl p-4 ss-hover-lift transition-all"
              style="border: 1px solid #E0E0E0;"
            >
              <div class="flex items-start justify-between mb-2">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#66BB6A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5"><path d="M17 10.5V6a1 1 0 0 0-1-1h-1a3 3 0 0 0-3 3"/><path d="M11 21.73a2 2 0 0 1-2.18-.37l-2.64-2.4A2 2 0 0 1 6 17.22V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12.22a2 2 0 0 1-.18 1.74l-2.64 2.4a2 2 0 0 1-2.18.37"/><path d="M12 3v18"/></svg>
                <span
                  class="text-xs px-2 py-0.5 rounded-full font-medium"
                  style={"background-color: #{elem(theme_badge(tree.theme), 0)}; color: #{elem(theme_badge(tree.theme), 1)};"}
                >
                  <%= theme_label(tree.theme) %>
                </span>
              </div>
              <h3 class="font-bold text-sm mb-1" style="color: #2D3436;"><%= tree.title %></h3>
              <p class="text-xs line-clamp-2 mb-3" style="color: #636E72;"><%= tree.description %></p>
              <div class="flex items-center gap-3 text-xs" style="color: #636E72;">
                <span><%= tree.age_range %></span>
                <span>~<%= tree.estimated_minutes %> min</span>
                <span><%= map_size(tree.scenarios) %> scenes</span>
              </div>
            </button>
          </div>
        </div>

        <%!-- Footer --%>
        <div class="text-center mt-12">
          <.link navigate={~p"/smart-steps/demo"} class="text-sm underline transition-colors" style="color: #636E72;">
            Watch a demo play out automatically
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp theme_label(theme) do
    Map.get(@theme_labels, theme, to_string(theme))
  end

  defp theme_badge(theme) do
    Map.get(@theme_badges, theme, {"#F5F5F5", "#636E72"})
  end
end
