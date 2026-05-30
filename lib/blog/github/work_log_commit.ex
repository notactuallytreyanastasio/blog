defmodule Blog.GitHub.WorkLogCommit do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          event_id: String.t() | nil,
          repo: String.t() | nil,
          branch: String.t() | nil,
          sha: String.t() | nil,
          message: String.t() | nil,
          additions: integer() | nil,
          deletions: integer() | nil,
          committed_at: DateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

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
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:event_id, :repo, :branch, :sha, :message, :additions, :deletions, :committed_at])
    |> validate_required([:event_id, :repo, :branch, :sha])
    |> unique_constraint(:sha)
  end
end
