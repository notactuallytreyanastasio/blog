defmodule Blog.Repo.Migrations.CreateBlinkComments do
  use Ecto.Migration

  def change do
    create table(:blink_comments) do
      add :blink_id, references(:blinks, on_delete: :delete_all), null: false
      add :author_name, :string, null: false
      add :content, :text, null: false
      # sha256 of poster ip + secret; kept only for rate limiting / abuse cleanup
      add :ip_hash, :string
      add :report_count, :integer, null: false, default: 0
      add :hidden_at, :naive_datetime

      timestamps()
    end

    create index(:blink_comments, [:blink_id])
    create index(:blink_comments, [:ip_hash])
  end
end
