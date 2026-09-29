defmodule JobProcessor.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :status, :string, default: "queued"
    field :payload, :binary
    field :attempts, :integer, default: 0
    field :max_attempts, :integer, default: 3
    field :scheduled_at, :utc_datetime
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :error_message, :string

    timestamps()
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:status, :payload, :attempts, :max_attempts,
                    :scheduled_at, :started_at, :completed_at, :error_message])
    |> validate_required([:payload])
    |> validate_inclusion(:status, ["queued", "running", "completed", "failed"])
  end

  @doc """
  Serialize a function call into a job payload.

  This is where the magic happens - we can serialize any module, function,
  and arguments into binary data that can be stored and executed later.
  """
  def encode_job(module, function, args) do
    {module, function, args} |> :erlang.term_to_binary()
  end

  @doc """
  Deserialize a job payload back into a function call.
  """
  def decode_job(payload) do
    :erlang.binary_to_term(payload)
  end
end