defmodule Blog.SmartSteps.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          session_id: String.t() | nil,
          title: String.t() | nil,
          tree_id: String.t() | nil,
          level_data: [map()],
          average_metrics: map(),
          outcome_type: String.t() | nil,
          total_levels: integer() | nil,
          completed: boolean(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "smart_steps_sessions" do
    field :session_id, :string
    field :title, :string
    field :tree_id, :string
    field :level_data, {:array, :map}, default: []
    field :average_metrics, :map, default: %{}
    field :outcome_type, :string
    field :total_levels, :integer
    field :completed, :boolean, default: false

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:session_id, :title, :tree_id, :level_data, :average_metrics,
                    :outcome_type, :total_levels, :completed])
    |> validate_required([:session_id])
  end
end
