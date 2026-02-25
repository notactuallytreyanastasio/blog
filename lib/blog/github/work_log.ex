defmodule Blog.GitHub.WorkLog do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.GitHub.WorkLogCommit

  def upsert_from_compare(repo, branch, event_id, compare_data) do
    commits = compare_data.commits
    stats = compare_data.stats

    Enum.each(commits, fn c ->
      attrs = %{
        event_id: event_id,
        repo: repo,
        branch: branch,
        sha: c.sha,
        message: c.message,
        additions: stats.additions,
        deletions: stats.deletions,
        committed_at: DateTime.utc_now()
      }

      %WorkLogCommit{}
      |> WorkLogCommit.changeset(attrs)
      |> Repo.insert(on_conflict: :nothing, conflict_target: :sha)
    end)
  end

  def list_recent do
    WorkLogCommit
    |> where([c], c.additions >= 10 or c.deletions >= 10)
    |> order_by([c], [desc: c.inserted_at])
    |> limit(100)
    |> Repo.all()
    |> group_by_event()
  end

  defp group_by_event(commits) do
    commits
    |> Enum.group_by(& &1.event_id)
    |> Enum.map(fn {_event_id, commits} ->
      first = List.first(commits)
      %{
        repo: first.repo,
        branch: first.branch,
        additions: first.additions,
        deletions: first.deletions,
        committed_at: first.committed_at,
        commits: Enum.map(commits, fn c -> %{sha: c.sha, message: c.message} end)
      }
    end)
    |> Enum.sort_by(& &1.committed_at, {:desc, DateTime})
  end
end
