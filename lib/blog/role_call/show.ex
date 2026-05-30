defmodule Blog.RoleCall.Show do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          title: String.t() | nil,
          year_start: integer() | nil,
          year_end: integer() | nil,
          imdb_rating: float() | nil,
          genres: String.t() | nil,
          description: String.t() | nil,
          image_url: String.t() | nil,
          scraped_at: DateTime.t() | nil,
          credits: [struct()] | Ecto.Association.NotLoaded.t(),
          people: [struct()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @primary_key {:id, :string, autogenerate: false}
  schema "rc_shows" do
    field :title, :string
    field :year_start, :integer
    field :year_end, :integer
    field :imdb_rating, :float
    field :genres, :string
    field :description, :string
    field :image_url, :string
    field :scraped_at, :utc_datetime

    has_many :credits, Blog.RoleCall.Credit, foreign_key: :show_id
    many_to_many :people, Blog.RoleCall.Person, join_through: Blog.RoleCall.Credit

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:id, :title, :year_start, :year_end, :imdb_rating, :genres, :description, :image_url, :scraped_at])
    |> validate_required([:id, :title])
  end

  @spec genres_list(t()) :: list()
  def genres_list(%__MODULE__{genres: nil}), do: []
  def genres_list(%__MODULE__{genres: genres}) do
    case Jason.decode(genres) do
      {:ok, list} when is_list(list) -> list
      _ -> []
    end
  end
end
