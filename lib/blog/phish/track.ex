defmodule Blog.Phish.Track do
  use Ecto.Schema
  import Ecto.Changeset

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
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:song_name, :show_date, :set_name, :position, :duration_ms, :likes, :is_jamchart, :jam_notes, :venue, :location, :jam_url])
    |> validate_required([:song_name, :show_date])
  end
end
