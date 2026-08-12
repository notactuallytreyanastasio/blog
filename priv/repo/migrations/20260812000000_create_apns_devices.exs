defmodule Blog.Repo.Migrations.CreateApnsDevices do
  use Ecto.Migration

  def change do
    create table(:apns_devices) do
      add :token, :text, null: false
      add :env, :text, null: false, default: "prod"

      timestamps()
    end

    create unique_index(:apns_devices, [:token])
  end
end
