defmodule Blog.SmartSteps.Session do
  use Ecto.Schema
  import Ecto.Changeset

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
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:session_id, :title, :tree_id, :level_data, :average_metrics,
                    :outcome_type, :total_levels, :completed])
    |> validate_required([:session_id])
  end
end
