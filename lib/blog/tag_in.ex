defmodule Blog.TagIn do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          user_name: String.t() | nil,
          spotify_link: String.t() | nil,
          note: String.t() | nil,
          latitude: float() | nil,
          longitude: float() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tag_ins" do
    field :user_name, :string
    field :spotify_link, :string
    field :note, :string # For text content, Ecto uses :string. DB handles length.
    field :latitude, :float
    field :longitude, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(tag_in, attrs) do
    tag_in
    |> cast(attrs, [:user_name, :spotify_link, :note, :latitude, :longitude])
    |> validate_required([:user_name, :spotify_link, :latitude, :longitude])
    # Optional: Add validations for spotify_link format if desired
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end
end
