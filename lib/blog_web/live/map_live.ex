defmodule BlogWeb.MapLive do
  use BlogWeb, :live_view
  require Logger
  alias Phoenix.Socket.Broadcast
  alias Blog.GeoMap # Add alias for the new context
  alias Blog.GeoMap.TagIn # Alias for the schema for convenience

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: BlogWeb.Endpoint.subscribe("map_updates")

    initial_markers = 
      GeoMap.list_tag_ins()
      |> Enum.map(fn tag_in ->
        %{
          id: tag_in.id, # Pass ID if needed later
          lat: tag_in.latitude,
          lng: tag_in.longitude,
          name: tag_in.user_name,
          link: tag_in.spotify_link,
          note: tag_in.note,
          embed_url: parse_spotify_link_to_embed_url(tag_in.spotify_link)
        }
      end)

    socket =
      socket
      |> assign(:page_title, "Spotify GeoMap")
      |> assign(:user_location, nil)
      |> assign(:show_spotify_prompt, false)
      |> assign(:markers, initial_markers)
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
  def handle_event("submit_spotify_link", %{"user_name" => name_param, "spotify_link" => link_param, "note" => note_param}, socket) do
    Logger.info("[MapLive] handle_event 'submit_spotify_link' called with name_param: #{inspect(name_param)}, link_param: #{inspect(link_param)}, note_param: #{inspect(note_param)}")

    user_name = case name_param do
      n when is_binary(n) and n != "" -> n
      _ -> "Anonymous Wook" # Default if empty or not a string
    end

    link = case link_param do
      l when is_binary(l) -> l
      _ -> ""
    end
    note = case note_param do
      n when is_binary(n) -> n
      _ -> ""
    end
    Logger.info("[MapLive] Parsed user_name: #{inspect(user_name)}, link: #{inspect(link)}, note: #{inspect(note)}")

    user_location = socket.assigns.user_location
    Logger.info("[MapLive] User location from assigns: #{inspect(user_location)}")

    if user_location do
      tag_in_attrs = %{
        user_name: user_name,
        spotify_link: link,
        note: note,
        latitude: user_location.lat,
        longitude: user_location.lng
      }

      case GeoMap.create_tag_in(tag_in_attrs) do
        {:ok, tag_in} ->
          Logger.info("[MapLive] Successfully created TagIn: #{inspect(tag_in)}")
          embed_url = parse_spotify_link_to_embed_url(tag_in.spotify_link)
          
          new_marker_payload = %{
            id: tag_in.id, # Include the ID
            lat: tag_in.latitude,
            lng: tag_in.longitude,
            link: tag_in.spotify_link,
            name: tag_in.user_name,
            note: tag_in.note, # Include the note
            embed_url: embed_url
          }

          Logger.info("[MapLive] Broadcasting 'new_marker' with payload: #{inspect(new_marker_payload)}")
          BlogWeb.Endpoint.broadcast("map_updates", "new_marker", new_marker_payload)
          Logger.info("[MapLive] Broadcast sent.")

          socket_updated = assign(socket, :show_spotify_prompt, false)
          {:noreply, socket_updated}

        {:error, changeset} ->
          Logger.error("[MapLive] Failed to create TagIn: #{inspect(changeset)}")
          # Optionally, send an error to the user via push_event or flash
          socket_updated = assign(socket, :show_spotify_prompt, false) # Still hide prompt, or keep open to show error
          # You might want to add a flash message here: |> put_flash(:error, "Failed to save your tag-in.")
          {:noreply, socket_updated}
      end
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
    Logger.info("[MapLive] handle_info 'new_marker' received broadcast with payload: #{inspect(marker_data)}")
    # Ensure marker_data is a map with the expected keys
    new_marker = if is_map(marker_data) and Map.has_key?(marker_data, :lat) and Map.has_key?(marker_data, :lng) do
      %{
        id: Map.get(marker_data, :id),
        lat: marker_data.lat,
        lng: marker_data.lng,
        link: Map.get(marker_data, :link, "#"),
        name: Map.get(marker_data, :name, "Anonymous"),
        note: Map.get(marker_data, :note, ""), # Pass through note
        embed_url: Map.get(marker_data, :embed_url)
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

  # Helper function to parse Spotify link and create an embed URL
  defp parse_spotify_link_to_embed_url(link) do
    # Regex to capture Spotify track ID from various URL formats
    # Example: https://open.spotify.com/track/TRACK_ID?si=...
    # Example: https://open.spotify.com/intl-pt/track/TRACK_ID
    regex = ~r"open\.spotify\.com/(?:[^/]+/)?track/([a-zA-Z0-9]+)"

    case Regex.run(regex, link) do
      [_, track_id] ->
        "https://open.spotify.com/embed/track/#{track_id}"
      _ ->
        nil # Return nil if no track ID found, client can fallback
    end
  end
end
