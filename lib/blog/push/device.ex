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
    # [] means "push me everything"; otherwise only blinks tagged with one of these
    field :followed_tags, {:array, :string}, default: []

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:token, :env, :followed_tags])
    |> validate_required([:token])
    |> validate_format(:token, ~r/^[0-9a-fA-F]{16,200}$/)
    |> validate_inclusion(:env, ["dev", "prod"])
    |> update_change(:followed_tags, fn tags ->
      tags
      |> Enum.filter(&is_binary/1)
      |> Enum.map(&(&1 |> String.trim() |> String.downcase()))
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()
      |> Enum.take(100)
    end)
    |> unique_constraint(:token)
  end
end
