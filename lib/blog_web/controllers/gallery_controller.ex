defmodule BlogWeb.GalleryController do
  @moduledoc """
  Stable urls for iCloud-hosted photos.

  Apple's signed CDN urls expire every few hours, so baking them into a page
  would leave an ambient browser full of dead images by dinnertime. Instead the
  page references `/gallery/img/:guid/:size` forever and this redirects to
  whatever url is currently valid.

  The redirect is ~200 bytes and the megabyte still comes off Apple's CDN, so
  this costs no meaningful bandwidth and stores nothing.
  """
  use BlogWeb, :controller

  alias Blog.Gallery

  # Comfortably inside the ~3h signing window, so a cached redirect can never
  # outlive the url it points at.
  @max_age 1_800

  def image(conn, %{"guid" => guid, "size" => size}) do
    case Gallery.url(guid, parse_size(size)) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("no such photo")

      url ->
        conn
        |> put_resp_header("cache-control", "public, max-age=#{@max_age}")
        |> redirect(external: url)
    end
  end

  defp parse_size("thumb"), do: :thumb
  defp parse_size(_), do: :display
end
