defmodule BlogWeb.CollageViewerLive do
  use BlogWeb, :live_view

  alias Blog.CollageMaker

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    case CollageMaker.get_collage_by_token(token) do
      nil ->
        {:ok,
         socket
         |> assign(page_title: "Not Found", collage: nil, images: [], viewer_config: nil)
         |> put_flash(:error, "Collage not found or expired.")}

      %{status: "ready"} = collage ->
        images = CollageMaker.list_images(collage.id)
        config = build_viewer_config(collage, images)

        {:ok,
         assign(socket,
           page_title: "Collage Viewer",
           collage: collage,
           images: images,
           viewer_config: config
         )}

      collage ->
        {:ok,
         assign(socket,
           page_title: "Collage Viewer",
           collage: collage,
           images: [],
           viewer_config: nil
         )}
    end
  end

  defp build_viewer_config(collage, images) do
    cell_size = collage.cell_size || 200
    columns = collage.columns
    total = length(images)
    rows = ceil(total / columns)
    canvas_w = columns * cell_size
    canvas_h = rows * cell_size

    image_positions =
      images
      |> Enum.sort_by(& &1.position)
      |> Enum.map(fn img ->
        row = div(img.position, columns)
        col = rem(img.position, columns)

        last_row? = row == rows - 1
        items_in_last = total - (rows - 1) * columns

        x =
          if last_row? and items_in_last < columns do
            offset = div((columns - items_in_last) * cell_size, 2)
            col * cell_size + offset
          else
            col * cell_size
          end

        y = row * cell_size

        url =
          if img.cropped_s3_key do
            Blog.Storage.url(img.cropped_s3_key)
          else
            Blog.Storage.url(img.original_s3_key)
          end

        %{url: url, x: x, y: y}
      end)

    Jason.encode!(%{
      images: image_positions,
      cellSize: cell_size,
      canvasWidth: canvas_w,
      canvasHeight: canvas_h
    })
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-start justify-center min-h-screen p-4 pt-8">
      <div class="os-window-mac" style="width: 90vw; max-width: 1200px;">
        <div class="os-titlebar">
          <a href="/collage-maker" class="os-btn-close" title="Back to Collage Maker"></a>
          <div class="os-titlebar-title">Collage Viewer</div>
        </div>

        <div class="os-content" style="padding: 0;">
          <%= if @collage && @collage.status == "ready" && @viewer_config do %>
            <div
              id="collage-viewer"
              phx-hook="CollageViewer"
              data-config={@viewer_config}
              class="cm-viewer-container"
              style="width: 100%; height: 70vh; cursor: grab;"
            >
            </div>
          <% else %>
            <div style="padding: 24px; text-align: center; font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 12px;">
              <%= if @collage do %>
                Collage is still processing. Refresh in a moment.
              <% else %>
                Collage not found or has expired.
              <% end %>
            </div>
          <% end %>
        </div>

        <div class="os-statusbar" style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 10px; color: #666;">
            Scroll to zoom &middot; Drag to pan &middot; Double-click to reset
          </span>
          <%= if @collage && @collage.collage_s3_key do %>
            <a
              href={Blog.Storage.url(@collage.collage_s3_key)}
              download="collage.jpg"
              target="_blank"
              style="font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 10px; text-decoration: underline;"
            >
              Download Full Res
            </a>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
