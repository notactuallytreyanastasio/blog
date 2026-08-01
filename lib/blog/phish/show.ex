defmodule Blog.Phish.Show do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          date: Date.t() | nil,
          venue: String.t() | nil,
          location: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          latitude: float() | nil,
          longitude: float() | nil,
          tour_name: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "phish_shows" do
    field :date, :date
    field :venue, :string
    field :location, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :latitude, :float
    field :longitude, :float
    field :tour_name, :string

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:date, :venue, :location, :city, :state, :country, :latitude, :longitude, :tour_name])
    |> validate_required([:date, :venue])
    |> unique_constraint(:date)
  end
end
