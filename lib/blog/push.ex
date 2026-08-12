defmodule Blog.Push do
  @moduledoc "APNs device registry for the blinks iOS app."

  import Ecto.Query

  alias Blog.Push.Device
  alias Blog.Repo

  @doc "Upserts a device token. Re-registering refreshes env/updated_at."
  @spec register_device(String.t(), String.t()) :: {:ok, Device.t()} | {:error, Ecto.Changeset.t()}
  def register_device(token, env \\ "prod") do
    %Device{}
    |> Device.changeset(%{token: token, env: env})
    |> Repo.insert(
      on_conflict: {:replace, [:env, :updated_at]},
      conflict_target: :token,
      returning: true
    )
  end

  @spec list_devices() :: [Device.t()]
  def list_devices, do: Repo.all(Device)

  @doc "Drops a token APNs reported as dead (410 / BadDeviceToken)."
  @spec delete_device(String.t()) :: {non_neg_integer(), nil}
  def delete_device(token) do
    Repo.delete_all(from d in Device, where: d.token == ^token)
  end
end
