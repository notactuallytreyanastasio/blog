defmodule Blog.Push.Device do
  @moduledoc """
  An iOS device registered for APNs pushes. `env` picks the APNs host:
  "dev" for Xcode-installed builds (sandbox), "prod" for TestFlight/App Store.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "apns_devices" do
    field :token, :string
    field :env, :string, default: "prod"

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:token, :env])
    |> validate_required([:token])
    |> validate_format(:token, ~r/^[0-9a-fA-F]{16,200}$/)
    |> validate_inclusion(:env, ["dev", "prod"])
    |> unique_constraint(:token)
  end
end
