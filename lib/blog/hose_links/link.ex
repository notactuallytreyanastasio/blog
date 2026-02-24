defmodule Blog.HoseLinks.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hose_links" do
    field :normalized_url, :string
    field :observations, :integer, default: 1
    field :first_seen_at, :utc_datetime
    field :last_seen_at, :utc_datetime
    field :sample_raw_urls, {:array, :string}, default: []
    field :expires_at, :utc_datetime

    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:normalized_url, :observations, :first_seen_at, :last_seen_at, :sample_raw_urls, :expires_at])
    |> validate_required([:normalized_url, :first_seen_at, :last_seen_at, :expires_at])
    |> unique_constraint(:normalized_url)
  end
end
