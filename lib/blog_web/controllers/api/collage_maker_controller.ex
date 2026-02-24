defmodule BlogWeb.Api.CollageMakerController do
  use BlogWeb, :controller

  alias Blog.CollageMaker

  def download(conn, %{"collage_id" => collage_id}) do
    case CollageMaker.get_collage(collage_id) do
      nil ->
        conn |> put_status(404) |> json(%{error: "Collage not found"})

      %{status: "ready", collage_s3_key: key} when not is_nil(key) ->
        url = Blog.Storage.url(key)

        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      _ ->
        conn |> put_status(404) |> json(%{error: "Collage not ready"})
    end
  end
end
