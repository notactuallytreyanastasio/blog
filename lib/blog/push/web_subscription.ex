defmodule Blog.Push.WebSubscription do
  @moduledoc """
  A browser's Web Push subscription (the PushSubscription JSON Safari/Chrome
  hand back), used for the blinks PWA pinned to a home screen.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "web_push_subscriptions" do
    field :endpoint, :string
    field :p256dh, :string
    field :auth, :string
    # [] means "push me everything"; otherwise only blinks tagged with one of these
    field :followed_tags, {:array, :string}, default: []
    field :user_agent, :string
    field :last_ok_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:endpoint, :p256dh, :auth, :followed_tags, :user_agent, :last_ok_at])
    |> validate_required([:endpoint, :p256dh, :auth])
    |> validate_format(:endpoint, ~r/^https:\/\//)
    |> validate_length(:endpoint, max: 2000)
    |> validate_length(:p256dh, min: 80, max: 120)
    |> validate_length(:auth, min: 20, max: 30)
    |> update_change(:user_agent, &(&1 && String.slice(&1, 0, 255)))
    |> update_change(:followed_tags, fn tags ->
      tags
      |> Enum.filter(&is_binary/1)
      |> Enum.map(&(&1 |> String.trim() |> String.downcase()))
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()
      |> Enum.take(100)
    end)
    |> unique_constraint(:endpoint)
  end
end
