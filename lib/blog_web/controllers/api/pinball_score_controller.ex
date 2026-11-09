defmodule BlogWeb.Api.PinballScoreController do
  @moduledoc """
  GET /api/pinball/scores: the top 10 cash-outs.
  POST /api/pinball/scores: record one, and answer with its id and the top 10.

  The game runs in the browser, so a posted score is whatever the browser
  says. This checks the shape (Blog.Pinball.Score) and rate-limits per IP:
  5 a minute, 40 a day.
  """
  use BlogWeb, :controller

  alias Blog.Pinball

  def index(conn, _params) do
    json(conn, %{scores: Enum.map(Pinball.top(), &row/1)})
  end

  def create(conn, params) do
    ip = client_ip(conn)

    if Blog.RateLimiter.allow?("pinball:" <> ip, 5, 60) and
         Blog.RateLimiter.allow?("pinball_day:" <> ip, 40, 24 * 3600) do
      case Pinball.submit(Map.take(params, ~w(initials score stage lines badges))) do
        {:ok, score} ->
          conn |> put_status(:created) |> json(%{id: score.id, scores: Enum.map(Pinball.top(), &row/1)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: first_error(changeset)})
      end
    else
      conn |> put_status(:too_many_requests) |> json(%{error: "too many scores from here; try again in a minute"})
    end
  end

  defp row(s), do: %{id: s.id, initials: s.initials, score: s.score, stage: s.stage, lines: s.lines, badges: s.badges}

  defp first_error(changeset) do
    {field, {msg, opts}} = hd(changeset.errors)
    msg = Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
    "#{field} #{msg}"
  end

  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] -> forwarded |> String.split(",") |> hd() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
