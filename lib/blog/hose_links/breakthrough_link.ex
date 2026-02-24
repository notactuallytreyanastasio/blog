defmodule Blog.HoseLinks.BreakthroughLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "breakthrough_links" do
    field :normalized_url, :string
    field :observations_at_breakthrough, :integer
    field :peak_observations, :integer
    field :first_seen_at, :utc_datetime
    field :breakthrough_at, :utc_datetime
    field :sample_raw_urls, {:array, :string}, default: []
    field :domain, :string

    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:normalized_url, :observations_at_breakthrough, :peak_observations, :first_seen_at, :breakthrough_at, :sample_raw_urls, :domain])
    |> validate_required([:normalized_url, :observations_at_breakthrough, :peak_observations, :first_seen_at, :breakthrough_at])
    |> unique_constraint(:normalized_url)
  end
end
