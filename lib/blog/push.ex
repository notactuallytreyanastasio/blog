defmodule Blog.Push do
  @moduledoc """
  Push registries for blinks: APNs device tokens from the iOS app, and Web
  Push subscriptions from the PWA pinned to a home screen.
  """

  import Ecto.Query

  alias Blog.Push.{Device, WebSubscription}
  alias Blog.Repo

  @doc "Upserts a device token. Re-registering refreshes env/tags/updated_at."
  @spec register_device(String.t(), String.t(), [String.t()]) ::
          {:ok, Device.t()} | {:error, Ecto.Changeset.t()}
  def register_device(token, env \\ "prod", followed_tags \\ []) do
    %Device{}
    |> Device.changeset(%{token: token, env: env, followed_tags: followed_tags})
    |> Repo.insert(
      on_conflict: {:replace, [:env, :followed_tags, :updated_at]},
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

  # ---------------------------------------------------------------------------
  # Web Push subscriptions (PWA)
  # ---------------------------------------------------------------------------

  @doc "Upserts a browser push subscription keyed by its endpoint."
  @spec register_web_subscription(map()) :: {:ok, WebSubscription.t()} | {:error, Ecto.Changeset.t()}
  def register_web_subscription(attrs) do
    %WebSubscription{}
    |> WebSubscription.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:p256dh, :auth, :followed_tags, :user_agent, :updated_at]},
      conflict_target: :endpoint,
      returning: true
    )
  end

  @spec list_web_subscriptions() :: [WebSubscription.t()]
  def list_web_subscriptions, do: Repo.all(WebSubscription)

  @spec get_web_subscription(String.t()) :: WebSubscription.t() | nil
  def get_web_subscription(endpoint), do: Repo.get_by(WebSubscription, endpoint: endpoint)

  @doc "Drops a subscription the push service reported gone, or that the user turned off."
  @spec delete_web_subscription(String.t()) :: {non_neg_integer(), nil}
  def delete_web_subscription(endpoint) do
    Repo.delete_all(from s in WebSubscription, where: s.endpoint == ^endpoint)
  end

  @spec touch_web_subscription(WebSubscription.t()) :: :ok
  def touch_web_subscription(sub) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    Repo.update_all(from(s in WebSubscription, where: s.id == ^sub.id), set: [last_ok_at: now])
    :ok
  end
end
