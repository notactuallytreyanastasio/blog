defmodule Blog.GitHub.WorkLogCommit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_log_commits" do
    field :event_id, :string
    field :repo, :string
    field :branch, :string
    field :sha, :string
    field :message, :string
    field :additions, :integer, default: 0
    field :deletions, :integer, default: 0
    field :committed_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:event_id, :repo, :branch, :sha, :message, :additions, :deletions, :committed_at])
    |> validate_required([:event_id, :repo, :branch, :sha])
    |> unique_constraint(:sha)
  end
end
