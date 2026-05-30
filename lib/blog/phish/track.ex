defmodule Blog.Phish.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          song_name: String.t() | nil,
          show_date: Date.t() | nil,
          set_name: String.t() | nil,
          position: integer() | nil,
          duration_ms: integer() | nil,
          likes: integer() | nil,
          is_jamchart: boolean() | nil,
          jam_notes: String.t() | nil,
          venue: String.t() | nil,
          location: String.t() | nil,
          jam_url: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "phish_tracks" do
    field :song_name, :string
    field :show_date, :date
    field :set_name, :string
    field :position, :integer
    field :duration_ms, :integer, default: 0
    field :likes, :integer, default: 0
    field :is_jamchart, :boolean, default: false
    field :jam_notes, :string, default: ""
    field :venue, :string
    field :location, :string
    field :jam_url, :string, default: ""

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:song_name, :show_date, :set_name, :position, :duration_ms, :likes, :is_jamchart, :jam_notes, :venue, :location, :jam_url])
    |> validate_required([:song_name, :show_date])
  end
end
