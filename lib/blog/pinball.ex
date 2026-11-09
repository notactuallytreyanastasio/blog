defmodule Blog.Pinball do
  @moduledoc """
  The leaderboard for Spin Spin Spin (/pinball): the best cash-outs.
  """
  import Ecto.Query
  alias Blog.Pinball.Score
  alias Blog.Repo

  @doc "The top `limit` cash-outs, highest first; ties go to the earlier."
  def top(limit \\ 10) do
    Score
    |> order_by([s], desc: s.score, asc: s.inserted_at, asc: s.id)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc "Record a cash-out. Returns `{:ok, score}` or `{:error, changeset}`."
  def submit(attrs) do
    %Score{} |> Score.changeset(attrs) |> Repo.insert()
  end
end
