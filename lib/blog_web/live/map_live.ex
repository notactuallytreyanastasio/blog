defmodule BlogWeb.MapLive do
  use BlogWeb, :live_view
  require Logger
  alias Phoenix.Socket.Broadcast

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: BlogWeb.Endpoint.subscribe("map_updates")

    socket =
      socket
      |> assign(:page_title, "Spotify GeoMap")
      # Removed: |> assign(:layout, false)
      |> assign(:user_location, nil) # Will be %{lat: float, lng: float}
      |> assign(:show_spotify_prompt, false)
      |> assign(:markers, []) # List of %{lat: float, lng: float, link: string, name: string}

    {:ok, socket}
  end


  # Event handler for geolocation data from client hook
  @impl true
  def handle_event("got_location", %{"lat" => lat, "lng" => lng}, socket) do
    socket =
      socket
      |> assign(:user_location, %{lat: lat, lng: lng})
      |> assign(:show_spotify_prompt, true)
    {:noreply, socket}
  end

  # Event handler for Spotify link submission
  @impl true
  def handle_event("submit_spotify_link", %{"spotify_link" => link_param}, socket) do
    Logger.info("[MapLive] handle_event 'submit_spotify_link' called with link_param: #{inspect(link_param)}")

    link = case link_param do
      l when is_binary(l) -> l
      _ -> ""
    end
    Logger.info("[MapLive] Parsed link: #{inspect(link)}")

    user_name = "User #{:rand.uniform(1000)}" # Placeholder for user name
    Logger.info("[MapLive] Generated user_name: #{inspect(user_name)}")

    user_location = socket.assigns.user_location
    Logger.info("[MapLive] User location from assigns: #{inspect(user_location)}")

    if user_location do
      new_marker_payload = %{
        lat: user_location.lat,
        lng: user_location.lng,
        link: link,
        name: user_name
      }
      Logger.info("[MapLive] Broadcasting 'new_marker' with payload: #{inspect(new_marker_payload)}")
      BlogWeb.Endpoint.broadcast("map_updates", "new_marker", new_marker_payload)
      Logger.info("[MapLive] Broadcast sent.")

      socket = assign(socket, :show_spotify_prompt, false)
      {:noreply, socket}
    else
      Logger.error("[MapLive] Cannot broadcast 'new_marker': user_location is nil.")
      # Optionally, send a push_event to the client to inform about the error
      # socket = push_event(socket, "error_toast", %{message: "Could not add marker: location unknown."})
      {:noreply, assign(socket, :show_spotify_prompt, false)} # Still hide prompt
    end
  end

  @impl true
  def handle_event("cancel_spotify_prompt", _payload, socket) do
    {:noreply, assign(socket, :show_spotify_prompt, false)}
  end

  # Handle broadcasted new markers
  @impl true
  def handle_info(%Broadcast{event: "new_marker", payload: marker_data}, socket) do
    # Ensure marker_data is a map with the expected keys
    new_marker = if is_map(marker_data) and Map.has_key?(marker_data, :lat) and Map.has_key?(marker_data, :lng) do
      %{
        lat: marker_data.lat,
        lng: marker_data.lng,
        link: Map.get(marker_data, :link, "#"), # Default link if missing
        name: Map.get(marker_data, :name, "Anonymous") # Default name if missing
      }
    else
      nil # Or handle error appropriately
    end

    if new_marker do
      # Optionally keep the server-side assigns updated, though not strictly necessary for the map
      # if the hook handles all rendering based on pushed events.
      updated_markers = [new_marker | socket.assigns.markers]
      socket_after_assigns = assign(socket, :markers, updated_markers)

      # Push an event to the client-side MapHook with the new marker data
      socket_after_push = push_event(socket_after_assigns, "new_marker", new_marker)
      {:noreply, socket_after_push}
    else
      {:noreply, socket} # Or log an error
    end
  end

  # Catch-all for other broadcasts if needed
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end
end
