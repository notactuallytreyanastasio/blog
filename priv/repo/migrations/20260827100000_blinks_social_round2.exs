defmodule Blog.Repo.Migrations.BlinksSocialRound2 do
  use Ecto.Migration

  def change do
    # "x people saved this" — one row per (blink, anonymous device)
    create table(:blink_saves) do
      add :blink_id, references(:blinks, on_delete: :delete_all), null: false
      add :device_hash, :string, null: false

      timestamps()
    end

    create unique_index(:blink_saves, [:blink_id, :device_hash])

    # one-tap emoji on comments, deduped per device
    create table(:blink_comment_reactions) do
      add :comment_id, references(:blink_comments, on_delete: :delete_all), null: false
      add :emoji, :string, null: false
      add :device_hash, :string, null: false

      timestamps()
    end

    create unique_index(:blink_comment_reactions, [:comment_id, :emoji, :device_hash])
    create index(:blink_comment_reactions, [:comment_id])

    # tag-follow push filtering; [] means "push me everything" (old behavior)
    alter table(:apns_devices) do
      add :followed_tags, {:array, :text}, null: false, default: []
    end
  end
end
