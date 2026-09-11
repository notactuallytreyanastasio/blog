defmodule Blog.Repo.Migrations.CreateWebPushSubscriptions do
  use Ecto.Migration

  def change do
    create table(:web_push_subscriptions) do
      add :endpoint, :text, null: false
      add :p256dh, :string, null: false
      add :auth, :string, null: false
      add :followed_tags, {:array, :string}, null: false, default: []
      add :user_agent, :string
      add :last_ok_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:web_push_subscriptions, [:endpoint])
  end
end
