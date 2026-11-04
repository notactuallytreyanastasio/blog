defmodule BlogWeb.HotelCarbonController do
  use BlogWeb, :controller

  @moduledoc """
  The hotel carbon programme, entirely on this site:

    * `/hotel-carbon`             the interactive essay "One Night at the Waldorf"
    * `/hotel-carbon/studio`      the bottom-up measurement model
    * `/hotel-carbon/storylines`  the 2025-2040 storyline simulator
    * `/hotel-carbon/map`         the decision graph distilled
    * `/hotel-carbon/library`     theory documents, notes digest, open questions, board
    * `/hotel-carbon/ledger`      every facet on one linked D3 instrument (ledger.js, ledger.json)

  Each is a self-contained page under priv/static (same arrangement as chess
  and frontier: root-level files there are not in the Plug.Static allowlist,
  so they need a route). The essay's stylesheet, script and data live under
  priv/static/static/hotel-carbon/ and are served by Plug.Static at
  /static/hotel-carbon/*; D3 comes from /static/d3.v7.min.js, already vendored.
  No page references anything off this host.
  """

  @pages %{
    index: "hotel_carbon.html",
    studio: "hotel_carbon_studio.html",
    storylines: "hotel_carbon_storylines.html",
    map: "hotel_carbon_map.html",
    library: "hotel_carbon_library.html",
    ledger: "hotel_carbon_ledger.html"
  }

  for {action, file} <- @pages do
    def unquote(action)(conn, _params), do: send_page(conn, unquote(file))
  end

  defp send_page(conn, file) do
    path = :code.priv_dir(:blog) |> to_string() |> Path.join("static/#{file}")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, path)
  end
end
