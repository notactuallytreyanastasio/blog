defmodule BlogWeb.SkeeController do
  use BlogWeb, :controller

  @doc """
  Serves "Skee Skee Skee", skee-ball with a slot machine in it: the browser
  port of the iPhone game, written in March in ~/code/skee_skee_skee_march and
  packaged here by `make blog` there. The HTML shell lives at
  priv/static/skee.html and its modules under priv/static/static/skee/<build>/.

  The casino host talks to the same-origin relay at /skee-host/chat, which
  Caddy sends to the skee-relay service, not to this app.

  Root-level files in priv/static aren't in the Plug.Static allowlist, so the
  shell needs a route, same as /pinball.
  """
  def index(conn, _params) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/skee.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
