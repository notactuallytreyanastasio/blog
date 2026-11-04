defmodule BlogWeb.TennisPotatoesController do
  use BlogWeb, :controller

  @doc """
  Serves "Tennis Potatoes", a Vite + TypeScript scrollytelling page built in
  ~/code/tennis_potatoes. The HTML shell lives at priv/static/tennis_potatoes.html
  and its hashed assets under priv/static/static/tennis-potatoes/.

  Root-level files in priv/static aren't in the Plug.Static allowlist, so the
  shell needs a route, same as /frontier.
  """
  def index(conn, _params) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/tennis_potatoes.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
