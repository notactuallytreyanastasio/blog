defmodule BlogWeb.Plugs.BlinksPrefs do
  @moduledoc """
  Blinks view preferences that must exist before the first render: the
  always-shuffle cookie (so a shuffled frontpage never flashes in normal
  order first) and a per-page-load shuffle seed shared by the static and
  connected renders.
  """
  import Plug.Conn

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn = fetch_cookies(conn)

    conn
    |> put_session(:blinks_always_shuffle, conn.cookies["blinksAlwaysShuffle"] == "1")
    |> put_session(:blinks_shuffle_seed, Base.encode16(:crypto.strong_rand_bytes(4)))
  end
end
