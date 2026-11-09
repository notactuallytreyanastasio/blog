defmodule BlogWeb.PinballController do
  use BlogWeb, :controller

  @doc """
  Serves "Spin Spin Spin", a pinball table with a slot machine in it, written
  in March in ~/code/spin_spin_spin and packaged here by `make blog` there.
  The HTML shell lives at priv/static/pinball.html and its JS modules under
  priv/static/static/pinball/.

  Root-level files in priv/static aren't in the Plug.Static allowlist, so the
  shell needs a route, same as /tennis-potatoes.
  """
  def index(conn, _params) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/pinball.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
