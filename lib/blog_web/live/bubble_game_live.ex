defmodule BlogWeb.BubbleGameLive do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Bubble Shooter")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 w-full h-full bg-gray-900">
      <div id="bubble-game" class="w-full h-full" phx-hook="BubbleGame" phx-update="ignore">
        <canvas id="bubble-game-canvas" class="w-full h-full" style="display: block;"></canvas>
      </div>
      <div class="fixed top-4 left-4 text-white text-sm space-y-2">
        <h1 class="text-xl font-bold mb-4">Bubble Shooter</h1>
        <p>🎯 Move mouse to aim</p>
        <p>🖱️ Click to shoot</p>
        <p>🎯 Match 3+ bubbles to pop them</p>
        <p>⚠️ Game over if bubbles reach the bottom!</p>
      </div>
      <div class="fixed top-4 right-4 text-white">
        <div class="text-sm mb-2">Next Bubble:</div>
        <div id="next-bubble-preview" class="w-12 h-12 rounded-full border-2 border-white"></div>
      </div>
    </div>
    """
  end
end
