defmodule BlogWeb.ChessController do
  use BlogWeb, :controller

  @doc """
  Serves the self-contained Chess-9 game built from the Temper-compiled engine.
  The entire game runs client-side — no server round-trips during play.
  """
  def index(conn, _params) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/chess9.html")
    send_file(conn, 200, path)
  end
end
