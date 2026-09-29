  # liveview definition with mount

  require Logger

  def handle_event("keydown", _key, socket), do: {:noreply, socket}
    Logger.info("Pressed: #{key}")
    {:noreply, socket}
  end

  def render(assigns)
    ~H"""
      <div class="p-4" phx-window-keydown="keydown">
        hi
      </div>
    """
  end