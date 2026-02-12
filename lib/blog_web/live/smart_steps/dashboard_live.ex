defmodule BlogWeb.SmartStepsLive.Dashboard do
  use BlogWeb, :live_view

  alias Blog.SmartSteps

  @impl true
  def mount(_params, _session, socket) do
    trees = SmartSteps.all_trees()

    {:ok,
     assign(socket,
       page_title: "Smart Steps - Dashboard",
       trees: trees
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page">
      <div class="max-w-4xl mx-auto px-4 py-8">
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-2xl font-bold" style="color: #2D3436;">Facilitator Dashboard</h1>
          <.link navigate={~p"/smart-steps"} class="text-xs underline" style="color: #636E72;">
            Back
          </.link>
        </div>

        <%!-- Quick start --%>
        <div class="bg-white rounded-2xl p-6 mb-8" style="border: 1px solid #E0E0E0;">
          <h2 class="text-sm font-semibold mb-4" style="color: #2D3436;">Quick Start</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 ss-stagger">
            <.link
              :for={tree <- @trees}
              navigate={~p"/smart-steps?role=facilitator"}
              class="p-3 rounded-xl text-center ss-hover-lift transition-all"
              style="background-color: #BBDEFB;"
            >
              <span class="text-sm font-medium" style="color: #42A5F5;"><%= tree.title %></span>
            </.link>
          </div>
        </div>

        <%!-- Empty state --%>
        <div class="bg-white rounded-2xl p-8 text-center" style="border: 1px solid #E0E0E0;">
          <p style="color: #636E72;">Session history will appear here after completing sessions.</p>
          <.link navigate={~p"/smart-steps"} class="inline-block mt-4 text-sm underline" style="color: #42A5F5;">
            Start a session
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
