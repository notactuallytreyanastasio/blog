defmodule Blog.CameraBrowser.Listing do
  @moduledoc """
  One Craigslist post we've seen in a camera search, kept from the hour we
  first spotted it until Craigslist says it's gone.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "camera_listings" do
    field :posting_id, :integer
    field :area, :string
    field :subarea, :string
    field :location, :string
    field :neighborhood, :string
    field :title, :string
    field :price_cents, :integer
    field :url, :string
    field :lat, :float
    field :lng, :float
    field :category_id, :integer

    field :body, :string
    field :attrs, :map, default: %{}
    field :image_ids, {:array, :string}, default: []
    field :mirrored_images, {:array, :string}, default: []
    field :reply_url, :string
    field :contact, :map, default: %{}
    field :posted_at, :utc_datetime
    field :renewed_at, :utc_datetime
    field :cl_updated_at, :utc_datetime
    field :detail_fetched_at, :utc_datetime

    field :queries, {:array, :string}, default: []
    field :tags, {:array, :string}, default: []
    field :score, :integer, default: 0

    field :first_seen_at, :utc_datetime
    field :last_seen_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :closed_reason, :string

    field :starred_at, :utc_datetime
    field :hidden_at, :utc_datetime
    field :note, :string

    # the model's read on the post (see Blog.CameraBrowser.Analyst)
    field :analysis, :map
    field :analyzed_at, :utc_datetime
    field :analysis_error, :string

    # how many other live posts share this title+price (spam re-posts), set by
    # CameraBrowser.list_listings/1
    field :dupe_count, :integer, virtual: true, default: 1

    timestamps(type: :utc_datetime)
  end

  @fields ~w(posting_id area subarea location neighborhood title price_cents url lat lng
             category_id body attrs image_ids mirrored_images reply_url contact posted_at renewed_at
             cl_updated_at detail_fetched_at queries tags score first_seen_at last_seen_at
             closed_at closed_reason starred_at hidden_at note analysis analyzed_at analysis_error)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, @fields)
    |> validate_required([:posting_id, :area, :title, :url, :first_seen_at, :last_seen_at])
    |> update_change(:title, &String.slice(&1, 0, 255))
    |> unique_constraint(:posting_id)
  end

  @doc "Human city label: sfbay/sfc -> San Francisco, newyork/brk -> Brooklyn."
  @spec city(t() | map()) :: String.t()
  def city(%{subarea: sub, area: area}) do
    Map.get(
      %{
        "sfc" => "San Francisco",
        "eby" => "East Bay",
        "mnh" => "Manhattan",
        "brk" => "Brooklyn",
        "que" => "Queens",
        "brx" => "Bronx",
        "stn" => "Staten Island",
        "pen" => "Peninsula",
        "sby" => "South Bay",
        "nby" => "North Bay",
        "scz" => "Santa Cruz",
        "see" => "Seattle",
        "est" => "Eastside",
        "sno" => "Snohomish",
        "tac" => "Tacoma",
        "mlt" => "Portland",
        "wsc" => "Washington Co",
        "clc" => "Clackamas",
        "clk" => "Vancouver WA"
      },
      sub,
      sub || area
    )
  end

  @spec open?(t()) :: boolean()
  def open?(%{closed_at: nil}), do: true
  def open?(_), do: false
end
