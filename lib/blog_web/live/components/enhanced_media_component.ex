defmodule BlogWeb.EnhancedMediaComponent do
  use BlogWeb, :live_component
  alias EarmarkParser

  # Props: id, title, content, media_url
  def render(assigns) do
    ~H"""
    <div id={@id} class="enhanced-media-component">
      <h5>{@title}</h5>
      <figure>
        <img src={@media_url} alt={@title} />
        <figcaption>{@content |> MDEx.to_html!() |> Phoenix.HTML.raw()}</figcaption>
      </figure>
    </div>
    """
  end
end
