defmodule BlogWeb.TreesLive do
  use BlogWeb, :live_view
  alias MDEx

  @impl true
  def mount(_params, _session, socket) do
    page_title = "327 Years of Tree Law (A History & Timeline)"
    description = "With research help from Claude Opus 4, I gathered all I could about the history of treble damages in tree law in the US going back to the late 1600s. Here are my findings"

    meta_tags = [
      %{name: "description", content: description},
      # Open Graph
      %{property: "og:title", content: page_title},
      %{property: "og:description", content: description},
      %{property: "og:type", content: "article"},
      # Twitter Card
      %{name: "twitter:card", content: "summary_large_image"}, # or "summary"
      %{name: "twitter:title", content: page_title},
      %{name: "twitter:description", content: description}
      # Consider adding og:image and twitter:image if a preview image is available
      # e.g., %{property: "og:image", content: "URL_TO_YOUR_IMAGE"},
      # e.g., %{name: "twitter:image", content: "URL_TO_YOUR_IMAGE"},
    ]

    socket =
      socket
      |> assign(:layout, false) # This disables app.html.heex, root.html.heex should still apply
      |> assign(:page_title, page_title)
      |> assign(:meta_tags, meta_tags)

    {:ok, socket}
  end
end
