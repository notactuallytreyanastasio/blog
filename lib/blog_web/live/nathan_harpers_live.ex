defmodule BlogWeb.NathanHarpersLive do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Disable the default application layout.
    # The template lib/blog_web/live/nathan_live.html.heex will be the entire response.
    {:ok, assign(socket, :layout, false)}
  end

  # By convention, Phoenix LiveView will now look for and render
  # lib/blog_web/live/nathan_live.html.heex because:
  # 1. We are in the BlogWeb.NathanLive module.
  # 2. We have set :layout to false.
  # 3. An explicit render/1 function is not defined.
  # No need for the RenderPage component or the previous render/1 function.
end
