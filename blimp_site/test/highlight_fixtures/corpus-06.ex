# keylogger_live.ex
defmodule BlogWeb.KeyloggerLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  require Logger

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pressed_key: "",
       show_modal: true,
       page_title: "Experiment - what key are you pressing"
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    {:noreply, assign(socket, pressed_key: key)}
  end

  def render(assigns) do
    ~H"""
    <div phx-window-keydown="keydown">
      <h1 class="text-[75px]">
        Pressing: <%= @pressed_key %>
      </h1>
    </div>
    """
  end
end