defmodule BlogWeb.NathanLive do
  use BlogWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BlogWeb.NathanLive.RenderPage} id="nathan-page" />
    """
  end

  defmodule RenderPage do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H""" 
      <%= Phoenix.LiveView.Static.render_existing(BlogWeb.NathanLive.RenderPage, "nathan_live.html", assigns) %>
      """
    end
  end
end
