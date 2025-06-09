defmodule BlogWeb.TestingLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen">
      <h1 style="font-size: 8rem; color: #ff69b4; font-weight: bold; text-align: center;">
        IM TESTING THINGS
      </h1>
    </div>
    """
  end
end