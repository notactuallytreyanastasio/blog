defmodule BlogWeb.GardenChannel do
  @moduledoc """
  Co-op relay for Pastel Garden Massacre (gaming.bobbby.online).

  The game is host-authoritative and runs entirely in the browser: the
  earliest player in a room simulates the enemies and broadcasts world
  snapshots, every player simulates their own knight and broadcasts its
  state. This channel holds no game state. It caps a room at four, tracks
  who is in it with Presence (clients pick the host as the earliest
  `joined_at`), and relays four message kinds to everyone else:

    * "p" - a player's own state, ~20/s from every client
    * "w" - world snapshot, ~15/s from the host
    * "e" - effect events (hits, kills, banners), batched by the host
    * "a" - action requests (swing, grab, throw) from guests to the host
  """
  use Phoenix.Channel

  alias BlogWeb.Presence

  @max_players 4
  @relay ~w(p w e a)

  @impl true
  def join("garden:" <> room, params, socket) when byte_size(room) in 1..32 do
    if map_size(Presence.list(socket)) >= @max_players do
      {:error, %{reason: "room_full"}}
    else
      id = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
      name = params |> Map.get("name", "knight") |> to_string() |> String.slice(0, 16)
      send(self(), :after_join)
      {:ok, %{id: id}, assign(socket, id: id, name: name)}
    end
  end

  def join(_topic, _params, _socket), do: {:error, %{reason: "bad_room"}}

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.id, %{
        name: socket.assigns.name,
        joined_at: System.system_time(:millisecond)
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) when event in @relay and is_map(payload) do
    broadcast_from!(socket, event, Map.put(payload, "from", socket.assigns.id))
    {:noreply, socket}
  end

  def handle_in(_event, _payload, socket), do: {:noreply, socket}
end
