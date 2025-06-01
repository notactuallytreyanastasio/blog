defmodule BlogWeb.SectionComponent do
  use BlogWeb, :live_component
  alias MDEx

  # Props: id, title, content
  def render(assigns) do
    ~H"""
    <section id={@id} class="section-component">
      <h3>{@title}</h3>
      <div>{@content |> MDEx.to_html!([]) |> Phoenix.HTML.raw()}</div>
    </section>
    """
  end
end
