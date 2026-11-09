defmodule Blog.Repo.Migrations.CreatePinballScores do
  use Ecto.Migration

  def change do
    # Cash-outs from the pinball game at /pinball. The game runs in the
    # browser, so a row is what a browser said: Blog.Pinball caps and checks
    # the shape, and the API rate-limits per IP. That is all it can do.
    create table(:pinball_scores) do
      add :initials, :string, size: 3, null: false
      add :score, :integer, null: false
      add :stage, :integer, null: false
      add :lines, :integer, null: false
      add :badges, {:array, :string}, null: false, default: []
      timestamps(updated_at: false)
    end

    create index(:pinball_scores, [:score])
  end
end
