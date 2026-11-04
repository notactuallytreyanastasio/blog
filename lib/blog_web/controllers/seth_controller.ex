defmodule BlogWeb.SethController do
  use BlogWeb, :controller

  @moduledoc """
  Serves the five landing page directions for SEE Right Through Consulting.

  Each is a self-contained HTML file under priv/static/static/seth/ (the outer
  `static` is the web root; priv_dir resolves to priv/, hence the doubled segment). Those are
  already reachable through Plug.Static at /static/seth/vN.html, but the bare
  directory 404s there (Plug.Static has no directory index) and the .html paths
  are awkward to hand to a client — so these routes give them clean URLs:

      /seth      the chooser
      /seth/v1   … /seth/v5

  Same arrangement as the chess and frontier pages.
  """

  @versions ~w(v1 v2 v4 v5 v6 v7 copy)

  def index(conn, _params), do: send_page(conn, "index")

  # Whitelisted in the head so no user-supplied string ever reaches Path.join.
  def show(conn, %{"version" => version}) when version in @versions do
    send_page(conn, version)
  end

  def show(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "No such version. Try /seth")
  end

  defp send_page(conn, name) do
    path =
      :code.priv_dir(:blog)
      |> to_string()
      |> Path.join("static/static/seth/#{name}.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
