defmodule BlogWeb.SmartStepsChannel do
  @moduledoc """
  Channel for real-time facilitator/participant sync in Smart Steps.
  Handles hover events so the facilitator can see which card the participant is peeking at.
  """

  use BlogWeb, :channel

  @impl true
  def join("smart_steps:" <> session_id, %{"role" => role}, socket) do
    socket =
      socket
      |> assign(:session_id, session_id)
      |> assign(:role, String.to_existing_atom(role))

    {:ok, socket}
  end

  def join("smart_steps:" <> session_id, _params, socket) do
    {:ok, assign(socket, :session_id, session_id)}
  end

  # Participant hovers over a card — facilitator sees peek-glow
  @impl true
  def handle_in("hover", %{"index" => index}, socket) do
    broadcast_from!(socket, "peer_hover", %{
      index: index,
      role: to_string(socket.assigns[:role] || "unknown")
    })

    {:noreply, socket}
  end

  # Participant leaves a card
  @impl true
  def handle_in("unhover", %{"index" => index}, socket) do
    broadcast_from!(socket, "peer_unhover", %{
      index: index,
      role: to_string(socket.assigns[:role] || "unknown")
    })

    {:noreply, socket}
  end

  # Participant selects a card
  @impl true
  def handle_in("select", %{"index" => index}, socket) do
    broadcast_from!(socket, "peer_select", %{
      index: index,
      role: to_string(socket.assigns[:role] || "unknown")
    })

    {:noreply, socket}
  end

  # Either side continues to next phase
  @impl true
  def handle_in("continue", _params, socket) do
    broadcast_from!(socket, "peer_continue", %{
      role: to_string(socket.assigns[:role] || "unknown")
    })

    {:noreply, socket}
  end
end
