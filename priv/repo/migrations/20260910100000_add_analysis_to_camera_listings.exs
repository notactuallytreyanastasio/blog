defmodule Blog.Repo.Migrations.AddAnalysisToCameraListings do
  use Ecto.Migration

  def change do
    alter table(:camera_listings) do
      # OpenAI take on the post: quick_take, rarity, price_take, commentary, fun_features, facts, model
      add :analysis, :map
      add :analyzed_at, :utc_datetime
      add :analysis_error, :string
    end

    create index(:camera_listings, [:analyzed_at])
  end
end
