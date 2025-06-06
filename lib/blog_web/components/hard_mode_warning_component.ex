defmodule BlogWeb.HardModeWarningComponent do
  use BlogWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" phx-click="dismiss-hard-mode-warning">
      <div class="bg-white rounded-lg p-6 max-w-sm mx-4 shadow-xl" phx-click-away="dismiss-hard-mode-warning">
        <div class="text-center">
          <div class="text-2xl mb-2">⚠️</div>
          <h2 class="text-lg font-bold mb-2">Hard Mode Enabled</h2>
          <p class="text-sm text-gray-600 mb-4">
            You're playing in Hard Mode! Any revealed hints must be used in subsequent guesses.
          </p>
          <button
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm font-medium"
            phx-click="dismiss-hard-mode-warning"
          >
            Got it!
          </button>
        </div>
      </div>
    </div>
    """
  end
end