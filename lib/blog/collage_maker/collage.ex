defmodule Blog.CollageMaker.Collage do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          status: String.t() | nil,
          columns: integer() | nil,
          cell_size: integer() | nil,
          image_count: integer() | nil,
          collage_s3_key: String.t() | nil,
          collage_width: integer() | nil,
          collage_height: integer() | nil,
          collage_file_size: integer() | nil,
          ip_hash: String.t() | nil,
          error_message: String.t() | nil,
          share_token: String.t() | nil,
          expires_at: DateTime.t() | nil,
          images: [struct()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "collage_maker_collages" do
    field :status, :string, default: "uploading"
    field :columns, :integer, default: 3
    field :cell_size, :integer
    field :image_count, :integer
    field :collage_s3_key, :string
    field :collage_width, :integer
    field :collage_height, :integer
    field :collage_file_size, :integer
    field :ip_hash, :string
    field :error_message, :string
    field :share_token, :string
    field :expires_at, :utc_datetime

    has_many :images, Blog.CollageMaker.Image, foreign_key: :collage_id

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(collage, attrs) do
    collage
    |> cast(attrs, [:status, :columns, :cell_size, :image_count, :collage_s3_key,
                     :collage_width, :collage_height, :collage_file_size,
                     :ip_hash, :error_message, :share_token, :expires_at])
    |> validate_required([:status, :columns])
    |> validate_inclusion(:columns, 1..8)
    |> unique_constraint(:share_token)
  end

  @spec generate_share_token() :: String.t()
  def generate_share_token do
    :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
  end
end
