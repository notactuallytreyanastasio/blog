defmodule BlogWeb.FrontierController do
  use BlogWeb, :controller

  @doc """
  Serves the annotated version of the frontier models post: prose on the left,
  tl;dr bubbles on the right, with a toggle that drops the prose entirely.

  Self-contained HTML, same arrangement as the chess page — root-level files in
  priv/static aren't in the Plug.Static allowlist, so they need a route.
  """
  def index(conn, _params) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/frontier.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
