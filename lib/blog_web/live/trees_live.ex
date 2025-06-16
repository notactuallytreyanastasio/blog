defmodule BlogWeb.TreesLive do
  use BlogWeb, :live_view
  alias MDEx

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:layout, false)

    {:ok, socket}
  end
end
