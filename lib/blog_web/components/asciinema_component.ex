defmodule BlogWeb.AsciinemaComponent do
  use BlogWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="asciinema-container my-8">
      <div 
        id={"asciinema-player-#{@id}"}
        phx-hook="AsciinemaPlayer"
        data-src={@src}
        data-autoplay={@autoplay}
        data-loop={@loop}
        data-start-at={@start_at}
        data-speed={@speed}
        data-theme={@theme}
        data-fit={@fit}
        data-font-size={@font_size}
        class="border border-gray-300 rounded-lg shadow-sm"
      >
      </div>
      <%= if @caption do %>
        <p class="text-sm text-gray-600 mt-2 text-center italic">{@caption}</p>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    # Set default values for asciinema player options
    assigns = Map.merge(%{
      autoplay: false,
      loop: false,
      start_at: nil,
      speed: 1,
      theme: "asciinema",
      fit: "width",
      font_size: "small",
      caption: nil
    }, assigns)

    {:ok, assign(socket, assigns)}
  end
end