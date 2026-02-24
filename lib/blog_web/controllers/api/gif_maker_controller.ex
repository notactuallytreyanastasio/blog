defmodule BlogWeb.Api.GifMakerController do
  use BlogWeb, :controller

  alias Blog.GifMaker

  def frame_image(conn, %{"frame_id" => frame_id}) do
    case GifMaker.get_frame_image(frame_id) do
      nil ->
        conn |> put_status(404) |> json(%{error: "Frame not found"})

      image_data ->
        conn
        |> put_resp_content_type("image/jpeg")
        |> put_resp_header("cache-control", "public, max-age=3600")
        |> send_resp(200, image_data)
    end
  end

  def gif_download(conn, %{"gif_id" => gif_id}) do
    case GifMaker.get_gif_data(gif_id) do
      nil ->
        conn |> put_status(404) |> json(%{error: "GIF not found"})

      gif_data ->
        conn
        |> put_resp_content_type("image/gif")
        |> put_resp_header("content-disposition", ~s(attachment; filename="concert.gif"))
        |> put_resp_header("cache-control", "public, max-age=3600")
        |> send_resp(200, gif_data)
    end
  end
end
