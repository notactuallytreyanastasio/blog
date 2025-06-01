defmodule BlogWeb.AsideComponent do
  use BlogWeb, :live_component
  alias MDEx

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :is_collapsed, true)}
  end

  # Props: id, title, content
  def render(assigns) do
    ~H"""
    <aside id={@id} class="aside-component bg-gray-100 p-4 rounded-md mb-4">
      <h4 class="font-semibold text-lg cursor-pointer" phx-click="toggle_aside" phx-target={@myself}>
        {@title}
        <span>{if @is_collapsed, do: "▶", else: "▼"}</span>
      </h4>
      <%= if not @is_collapsed do %>
        <div class="mt-2">
          {@content |> MDEx.to_html!() |> Phoenix.HTML.raw()}
        </div>
      <% end %>
    </aside>
    """
  end

  @impl true
  def handle_event("toggle_aside", _, socket) do
    {:noreply, update(socket, :is_collapsed, fn is_collapsed -> not is_collapsed end)}
  end
end
